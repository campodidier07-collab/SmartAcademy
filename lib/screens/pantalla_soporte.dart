import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_header.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_snackbar.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundMain,
      body: SafeArea(
        child: Column(
          children: [
            const CustomHeader(
              title: 'Ayuda y Soporte',
              subtitle: 'Centro de asistencia y resolución de dudas',
              showBackButton: true,
            ),
            
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                children: [
                  // Hero Card de Soporte
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primaryBlue.withValues(alpha: 0.18),
                          AppTheme.secondaryPurple.withValues(alpha: 0.12),
                          AppTheme.surfaceCard,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.25)),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue.withValues(alpha: 0.18),
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.3)),
                          ),
                          child: const Icon(LucideIcons.headphones, size: 36, color: AppTheme.primaryBlue),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '¿Cómo podemos ayudarte?',
                          style: GoogleFonts.outfit(
                            color: AppTheme.textPrimary, 
                            fontSize: 20, 
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Encuentra respuestas a preguntas frecuentes o comunícate con la administración académica.',
                          style: GoogleFonts.outfit(
                            color: AppTheme.textSecondary, 
                            fontSize: 13,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ).animate().fade().slideY(begin: -0.05),
                  
                  const SizedBox(height: 28),
                  
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 12),
                    child: Text(
                      'PREGUNTAS FRECUENTES',
                      style: GoogleFonts.outfit(
                        color: AppTheme.primaryBlue, 
                        fontWeight: FontWeight.bold, 
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  
                  _buildFaqTile(
                    '¿Cómo modifico las calificaciones de los estudiantes?',
                    'Ve a la pestaña de Calificaciones desde el menú inferior, filtra por el curso correspondiente y presiona el botón "Gestionar Calificación" para actualizar las notas.',
                    60,
                  ),
                  _buildFaqTile(
                    '¿Cómo registro la asistencia de una sesión de clase?',
                    'Accede al módulo de Asistencia, selecciona el curso y la fecha actual, y luego marca a cada estudiante como Presente, Ausente o Retardo antes de guardar.',
                    120,
                  ),
                  _buildFaqTile(
                    '¿Cómo puedo restablecer mi contraseña?',
                    'Dirígete a tu Perfil > Configuración > Cambiar Contraseña para actualizarla. Si olvidaste tu acceso, solicita al Administrador que te asigne una nueva clave temporal.',
                    180,
                  ),
                  _buildFaqTile(
                    '¿Cómo funciona el Carnet Digital con código QR?',
                    'En la sección "Mis Datos" pulsa "Ver Carnet Digital (3D)". Podrás rotar la tarjeta con el dedo e interactuar con el código QR para escanear asistencia en el aula.',
                    240,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  CustomButton(
                    text: 'Contactar a Soporte Académico',
                    icon: LucideIcons.mail,
                    onPressed: () {
                      CustomSnackbar.show(
                        context, 
                        message: 'Canal de soporte: soporte@smartacademy.edu',
                        type: SnackbarType.info,
                      );
                    },
                  ).animate().fade(delay: 300.ms).slideY(begin: 0.05),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqTile(String question, String answer, int delayMs) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: CustomCard(
        padding: EdgeInsets.zero,
        child: Theme(
          data: ThemeData(
            dividerColor: Colors.transparent,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            title: Text(
              question, 
              style: GoogleFonts.outfit(
                color: AppTheme.textPrimary, 
                fontWeight: FontWeight.w600, 
                fontSize: 14,
              ),
            ),
            collapsedIconColor: AppTheme.textMuted,
            iconColor: AppTheme.primaryBlue,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(
                  answer,
                  style: GoogleFonts.outfit(
                    color: AppTheme.textSecondary, 
                    height: 1.5, 
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fade(delay: delayMs.ms).slideX(begin: 0.03);
  }
}
