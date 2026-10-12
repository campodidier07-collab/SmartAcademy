import 'dart:math';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class CarnetDigital extends StatefulWidget {
  final String nombre;
  final String rol;
  final String documento;
  final String programa;
  final String telefono;

  const CarnetDigital({
    super.key, 
    required this.nombre,
    required this.rol,
    required this.documento,
    required this.programa,
    required this.telefono,
  });

  @override
  State<CarnetDigital> createState() => _CarnetDigitalState();
}

class _CarnetDigitalState extends State<CarnetDigital> with SingleTickerProviderStateMixin {
  double _tiltX = 0.0;
  double _tiltY = 0.0;
  bool _isBack = false;

  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _flipAnimation = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOutBack),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _tiltX += details.delta.dy * -0.01;
      _tiltY += details.delta.dx * 0.01;

      _tiltX = _tiltX.clamp(-0.4, 0.4);
      _tiltY = _tiltY.clamp(-0.4, 0.4);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _tiltX = 0.0;
      _tiltY = 0.0;
    });
  }

  void _toggleFlip() {
    if (_isBack) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    _isBack = !_isBack;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cardWidth = size.width * 0.82;
    final cardHeight = cardWidth * 1.58; // Proporción tarjeta ID (CR80)

    return GestureDetector(
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      onTap: _toggleFlip,
      child: Center(
        child: AnimatedBuilder(
          animation: _flipAnimation,
          builder: (context, child) {
            final flipValue = _flipAnimation.value;
            final isFrontVisible = flipValue <= pi / 2;

            final transform = Matrix4.identity()
              ..setEntry(3, 2, 0.001) // Perspectiva 3D
              ..rotateX(_tiltX)
              ..rotateY(_tiltY + flipValue);

            return Transform(
              alignment: FractionalOffset.center,
              transform: transform,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Sombra del carnet
                  Container(
                    width: cardWidth,
                    height: cardHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.35),
                          blurRadius: 36,
                          spreadRadius: 2,
                          offset: Offset(_tiltY * -40, _tiltX * -40),
                        ),
                        BoxShadow(
                          color: AppTheme.secondaryPurple.withValues(alpha: 0.25),
                          blurRadius: 48,
                          spreadRadius: -4,
                        ),
                      ],
                    ),
                  ),

                  // Contenido del Carnet
                  Container(
                    width: cardWidth,
                    height: cardHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: AppTheme.surfaceCard,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                        width: 1.5,
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primaryBlue.withValues(alpha: 0.25),
                          AppTheme.surfaceCardElevated,
                        ],
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        children: [
                          // Base del carnet
                          isFrontVisible
                              ? _buildFront(cardWidth, cardHeight)
                              : Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.rotationY(pi),
                                  child: _buildBack(cardWidth, cardHeight),
                                ),

                          // Efecto holográfico
                          Positioned.fill(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 80),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment(
                                    -1.0 + (_tiltY * 3), 
                                    -1.0 + (_tiltX * 3),
                                  ),
                                  end: Alignment(
                                    1.0 + (_tiltY * 3), 
                                    1.0 + (_tiltX * 3),
                                  ),
                                  stops: const [0.0, 0.4, 0.5, 0.6, 1.0],
                                  colors: [
                                    Colors.transparent,
                                    Colors.white.withValues(alpha: 0.08),
                                    Colors.white.withValues(alpha: 0.35),
                                    Colors.white.withValues(alpha: 0.08),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFront(double width, double height) {
    final initials = widget.nombre.isNotEmpty ? widget.nombre[0].toUpperCase() : 'U';

    return Padding(
      padding: const EdgeInsets.all(22.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header Logo & Marca
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset('lib/assets/imagenes/logo.png', width: 36, height: 36),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'SMARTACADEMY',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    'CARNET DIGITAL OFICIAL',
                    style: GoogleFonts.outfit(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.w600,
                      fontSize: 9,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Foto / Avatar
          Container(
            width: 108,
            height: 108,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.surfaceCardElevated,
              border: Border.all(color: AppTheme.primaryBlue, width: 3),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.4), 
                  blurRadius: 18,
                ),
              ],
            ),
            child: Center(
              child: Text(
                initials,
                style: GoogleFonts.outfit(
                  fontSize: 42, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Nombre
          Text(
            widget.nombre,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),

          // Rol & Programa
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.35)),
            ),
            child: Text(
              widget.rol.toUpperCase(),
              style: GoogleFonts.outfit(
                fontSize: 11,
                color: AppTheme.primaryBlue,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 8),

          Text(
            widget.programa,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          
          const Spacer(),

          // ID y Chip NFC visual
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ID INSTITUCIONAL', 
                      style: GoogleFonts.outfit(fontSize: 9, color: AppTheme.textMuted, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      widget.documento,
                      style: GoogleFonts.outfit(
                        fontSize: 15, 
                        fontWeight: FontWeight.bold, 
                        color: Colors.white, 
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const Icon(Icons.nfc, color: AppTheme.primaryBlue, size: 26),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBack(double width, double height) {
    return Padding(
      padding: const EdgeInsets.all(22.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'ESCANEA PARA ASISTENCIA',
            style: GoogleFonts.outfit(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          
          // QR Code
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 12,
                ),
              ],
            ),
            child: QrImageView(
              data: 'SA-${widget.documento}-USR',
              version: QrVersions.auto,
              size: width * 0.55,
              backgroundColor: Colors.white,
            ),
          ),
          
          const Spacer(),
          Text(
            'Contacto de emergencia:',
            style: GoogleFonts.outfit(color: AppTheme.textMuted, fontSize: 11),
          ),
          const SizedBox(height: 2),
          Text(
            widget.telefono,
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.white.withValues(alpha: 0.1)),
          const SizedBox(height: 8),
          Text(
            'Este carnet es personal e intransferible. Válido exclusivamente para actividades y accesos oficiales en SmartAcademy.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(color: AppTheme.textMuted, fontSize: 10, height: 1.3),
          ),
        ],
      ),
    );
  }
}
