import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../controllers/controlador_auth.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_header.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/carnet_digital.dart';

class MyDataScreen extends StatefulWidget {
  const MyDataScreen({super.key});

  @override
  State<MyDataScreen> createState() => _MyDataScreenState();
}

class _MyDataScreenState extends State<MyDataScreen> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  Student? _student;

  @override
  void initState() {
    super.initState();
    _loadImage();
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    final user = context.read<AuthController>().currentUser;
    if (user == null) return;
    try {
      final client = supa.Supabase.instance.client;
      final maps = await client.from('estudiantes').select().eq('correo', user.correo);
      if (maps.isNotEmpty && mounted) {
        setState(() {
          _student = Student.fromMap(maps.first);
        });
      }
    } catch (e) {
      debugPrint('Error cargando estudiante: $e');
    }
  }

  Future<void> _loadImage() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final user = context.read<AuthController>().currentUser;
    if (user == null) return;
    
    final imagePath = prefs.getString('profile_image_path_${user.id}');
    if (imagePath != null && File(imagePath).existsSync()) {
      setState(() {
        _imageFile = File(imagePath);
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final directory = await getApplicationDocumentsDirectory();
        final fileName = path.basename(pickedFile.path);
        final savedImage = await File(pickedFile.path).copy('${directory.path}/$fileName');
        
        final prefs = await SharedPreferences.getInstance();
        if (!mounted) return;
        final user = context.read<AuthController>().currentUser;
        if (user != null) {
          await prefs.setString('profile_image_path_${user.id}', savedImage.path);
        }

        setState(() {
          _imageFile = savedImage;
        });
        if (mounted) CustomSnackbar.show(context, message: 'Foto de perfil actualizada exitosamente', type: SnackbarType.success);
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.show(context, message: 'Error al seleccionar imagen', type: SnackbarType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().currentUser;

    return Scaffold(
      backgroundColor: AppTheme.backgroundMain,
      body: SafeArea(
        child: Column(
          children: [
            const CustomHeader(
              title: 'Mis Datos',
              subtitle: 'Información y credenciales de cuenta',
              showBackButton: true,
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar con selector
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 104,
                              height: 104,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.primaryBlue.withValues(alpha: 0.3),
                                    AppTheme.secondaryPurple.withValues(alpha: 0.2),
                                  ],
                                ),
                                border: Border.all(
                                  color: AppTheme.primaryBlue.withValues(alpha: 0.5),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryBlue.withValues(alpha: 0.25),
                                    blurRadius: 16,
                                  ),
                                ],
                              ),
                            ),
                            CircleAvatar(
                              radius: 46,
                              backgroundColor: AppTheme.surfaceCardElevated,
                              backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                              child: _imageFile == null 
                                  ? Text(
                                      user?.nombre.isNotEmpty == true ? user!.nombre[0].toUpperCase() : 'U',
                                      style: GoogleFonts.outfit(
                                        color: AppTheme.primaryBlue,
                                        fontSize: 34,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryBlue,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppTheme.backgroundMain, width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryBlue.withValues(alpha: 0.4),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: const Icon(LucideIcons.camera, size: 14, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fade().scale(begin: const Offset(0.95, 0.95)),
                    
                    const SizedBox(height: 28),
                    
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 12),
                      child: Text(
                        'DATOS DE LA CUENTA', 
                        style: GoogleFonts.outfit(
                          color: AppTheme.primaryBlue, 
                          fontWeight: FontWeight.bold, 
                          fontSize: 12,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    
                    _buildDataField(
                      context, 
                      'Nombre Completo', 
                      _student != null ? '${_student!.nombre} ${_student!.apellido}' : (user?.nombre ?? 'Usuario'), 
                      LucideIcons.user, 
                      60,
                    ),
                    const SizedBox(height: 12),
                    _buildDataField(context, 'Correo Electrónico', user?.correo ?? 'correo@ejemplo.com', LucideIcons.mail, 120),
                    const SizedBox(height: 12),
                    _buildDataField(context, 'Rol en el Sistema', user?.rol ?? 'Rol', LucideIcons.shieldCheck, 180),
                    if (_student != null) ...[
                      const SizedBox(height: 12),
                      _buildDataField(context, 'Documento de Identidad', _student!.documento, LucideIcons.creditCard, 210),
                      const SizedBox(height: 12),
                      _buildDataField(context, 'Programa Académico', _student!.programa, LucideIcons.bookOpen, 240),
                      if (_student!.telefono.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _buildDataField(context, 'Teléfono', _student!.telefono, LucideIcons.phone, 270),
                      ],
                    ],
                    
                    const SizedBox(height: 28),
                    
                    // Carnet Digital Botón
                    CustomButton(
                      text: 'Ver Carnet Digital (3D)',
                      icon: LucideIcons.scanFace,
                      onPressed: () {
                        showGeneralDialog(
                          context: context,
                          barrierDismissible: true,
                          barrierLabel: 'Cerrar',
                          barrierColor: Colors.black.withValues(alpha: 0.85),
                          transitionDuration: const Duration(milliseconds: 350),
                          pageBuilder: (context, animation, secondaryAnimation) {
                            return ScaleTransition(
                              scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                              child: Material(
                                color: Colors.transparent,
                                child: Stack(
                                  children: [
                                    Center(
                                      child: CarnetDigital(
                                        nombre: _student != null ? '${_student!.nombre} ${_student!.apellido}' : (user?.nombre ?? 'Usuario'),
                                        rol: user?.rol ?? 'Estudiante',
                                        documento: _student?.documento ?? user?.id.toString() ?? '1001',
                                        programa: _student?.programa ?? 'SmartAcademy',
                                        telefono: (_student?.telefono != null && _student!.telefono.isNotEmpty) ? _student!.telefono : 'Línea de soporte activa',
                                      ),
                                    ),
                                    Positioned(
                                      top: 48,
                                      right: 24,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.6),
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                                        ),
                                        child: IconButton(
                                          icon: const Icon(LucideIcons.x, color: Colors.white, size: 22),
                                          onPressed: () => Navigator.pop(context),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ).animate().fade(delay: 240.ms).slideY(begin: 0.05),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataField(BuildContext context, String label, String value, IconData icon, int delayMs) {
    return CustomCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.surfaceCardElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Icon(icon, color: AppTheme.primaryBlue, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label, 
                  style: GoogleFonts.outfit(
                    color: AppTheme.textMuted, 
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value, 
                  style: GoogleFonts.outfit(
                    color: AppTheme.textPrimary, 
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fade(delay: delayMs.ms).slideX(begin: 0.03);
  }
}
