import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_header.dart';
import '../widgets/custom_snackbar.dart';
import '../controllers/controlador_asistencias.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

class AttendanceScannerScreen extends StatefulWidget {
  final int? cursoId;
  const AttendanceScannerScreen({super.key, this.cursoId});

  @override
  State<AttendanceScannerScreen> createState() => _AttendanceScannerScreenState();
}

class _AttendanceScannerScreenState extends State<AttendanceScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  final bool _isScanning = true;
  bool _isProcessing = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _processQRCode(String barcode) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      String documentoCandidate = barcode.trim();
      if (documentoCandidate.startsWith('SA-') && documentoCandidate.endsWith('-USR')) {
        final parts = documentoCandidate.split('-');
        if (parts.length >= 2) {
          documentoCandidate = parts[1].trim();
        }
      }

      final client = supa.Supabase.instance.client;

      // 1. Buscar por documento de identidad (cédula)
      var maps = await client.from('estudiantes').select().eq('documento', documentoCandidate);

      // 2. Si no se encuentra y es numérico, buscar por id de estudiante
      if (maps.isEmpty && int.tryParse(documentoCandidate) != null) {
        maps = await client.from('estudiantes').select().eq('id', int.parse(documentoCandidate));
      }

      // 3. Si aún no se encuentra y es numérico, buscar por id de usuario y cruzar por correo
      if (maps.isEmpty && int.tryParse(documentoCandidate) != null) {
        final userMaps = await client.from('usuarios').select().eq('id', int.parse(documentoCandidate));
        if (userMaps.isNotEmpty) {
          final userEmail = userMaps.first['correo'] as String?;
          if (userEmail != null && userEmail.isNotEmpty) {
            maps = await client.from('estudiantes').select().eq('correo', userEmail);
          }
        }
      }

      if (maps.isNotEmpty) {
        final estudiante = maps.first;
        final estudianteId = estudiante['id'] as int;
        final nombre = estudiante['nombre'] as String;
        final apellido = estudiante['apellido'] as String;

        final int targetCursoId = widget.cursoId ?? 1;
        await client.from('asistencias').insert({
          'estudiante_id': estudianteId,
          'curso_id': targetCursoId,
          'fecha': DateTime.now().toIso8601String(),
          'estado': 'Presente',
        });

        if (mounted) {
          context.read<AttendanceController>().loadAttendances();
          _showSuccessDialog(nombre, apellido);
        }
      } else {
        if (mounted) CustomSnackbar.show(context, message: 'Estudiante no encontrado en el sistema', type: SnackbarType.error);
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) setState(() => _isProcessing = false);
      }
    } catch (e) {
      if (mounted) CustomSnackbar.show(context, message: 'Error al procesar el código: $e', type: SnackbarType.error);
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showSuccessDialog(String nombre, String apellido) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.checkCircle, color: AppTheme.success, size: 48),
              ),
              const SizedBox(height: 16),
              Text(
                '¡Asistencia Registrada!',
                style: GoogleFonts.outfit(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '$nombre $apellido', 
                style: GoogleFonts.outfit(color: AppTheme.primaryBlue, fontSize: 16, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Hora: ${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')} • Presente',
                style: GoogleFonts.outfit(color: AppTheme.textMuted, fontSize: 12),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.pop(dialogCtx);
                        Navigator.pop(context, true);
                      },
                      child: Text('Ver Lista', style: GoogleFonts.outfit(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.pop(dialogCtx);
                        if (mounted) setState(() => _isProcessing = false);
                      },
                      child: Text('Siguiente', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundMain,
      body: SafeArea(
        child: Column(
          children: [
            const CustomHeader(
              title: 'Escáner de Asistencia',
              subtitle: 'Apunta la cámara al carnet digital del estudiante',
              showBackButton: true,
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.35), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Stack(
                    children: [
                      MobileScanner(
                        controller: _scannerController,
                        onDetect: (capture) {
                          final List<Barcode> barcodes = capture.barcodes;
                          for (final barcode in barcodes) {
                            if (barcode.rawValue != null && _isScanning) {
                              _processQRCode(barcode.rawValue!);
                            }
                          }
                        },
                      ),
                      
                      // Viewfinder central con estilo moderno
                      Center(
                        child: Container(
                          width: 240,
                          height: 240,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppTheme.primaryBlue, width: 2),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                                blurRadius: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Barra inferior con controles de cámara
                      Positioned(
                        bottom: 0, left: 0, right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter, end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.85)],
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                icon: const Icon(LucideIcons.flashlight, color: Colors.white, size: 22),
                                tooltip: 'Linterna',
                                onPressed: () => _scannerController.toggleTorch(),
                              ),
                              IconButton(
                                icon: const Icon(LucideIcons.camera, color: Colors.white, size: 22),
                                tooltip: 'Cambiar cámara',
                                onPressed: () => _scannerController.switchCamera(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fade().scale(begin: const Offset(0.98, 0.98)),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20, left: 24, right: 24, top: 4),
              child: Text(
                'El escáner detectará automáticamente el código QR cuando esté enfocado.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(color: AppTheme.textMuted, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
