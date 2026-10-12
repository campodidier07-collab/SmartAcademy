import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/controlador_auth.dart';
import 'pantalla_login.dart';
import 'pantalla_mis_datos.dart';
import 'pantalla_configuracion.dart';
import 'pantalla_soporte.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_header.dart';
import '../widgets/custom_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final user = context.read<AuthController>().currentUser;
    if (user == null) return;
    
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profile_image_path_${user.id}');
    if (path != null && mounted) {
      setState(() {
        _imagePath = path;
      });
    }
  }

  Color _getRoleColor(String? role) {
    switch (role) {
      case 'Profesor': return AppTheme.secondaryPurple;
      case 'Administrador': return AppTheme.warning;
      default: return AppTheme.primaryBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().currentUser;
    final roleColor = _getRoleColor(user?.rol);
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundMain,
      body: SafeArea(
        child: Column(
          children: [
            const CustomHeader(
              title: 'Mi Perfil',
              subtitle: 'Ajustes y preferencias de cuenta',
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  children: [
                    // Sección Avatar & Identidad
                    CustomCard(
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                      child: Column(
                        children: [
                          Center(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 96,
                                  height: 96,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        roleColor.withValues(alpha: 0.3),
                                        AppTheme.primaryBlue.withValues(alpha: 0.15),
                                      ],
                                    ),
                                    border: Border.all(
                                      color: roleColor.withValues(alpha: 0.5),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: roleColor.withValues(alpha: 0.2),
                                        blurRadius: 16,
                                      ),
                                    ],
                                  ),
                                ),
                                if (_imagePath != null && File(_imagePath!).existsSync())
                                  ClipOval(
                                    child: Image.file(
                                      File(_imagePath!),
                                      width: 82,
                                      height: 82,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                else
                                  CircleAvatar(
                                    radius: 41,
                                    backgroundColor: AppTheme.surfaceCardElevated,
                                    child: Text(
                                      user?.nombre.isNotEmpty == true ? user!.nombre[0].toUpperCase() : 'U',
                                      style: GoogleFonts.outfit(
                                        color: roleColor,
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            user?.nombre ?? 'Usuario',
                            style: GoogleFonts.outfit(
                              color: AppTheme.textPrimary,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.correo ?? 'correo@ejemplo.com',
                            style: GoogleFonts.outfit(
                              color: AppTheme.textMuted,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                            decoration: BoxDecoration(
                              color: roleColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: roleColor.withValues(alpha: 0.35)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(color: roleColor, shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  user?.rol ?? 'Rol',
                                  style: GoogleFonts.outfit(
                                    color: roleColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fade().slideY(begin: -0.05),
                    
                    const SizedBox(height: 20),
                    
                    // Opciones de Configuración
                    _buildMenuItem(
                      context,
                      icon: LucideIcons.userCircle,
                      iconColor: AppTheme.primaryBlue,
                      title: 'Mis datos personales',
                      subtitle: 'Foto de perfil, carnet digital y datos',
                      delayMs: 60,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const MyDataScreen()));
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: LucideIcons.settings,
                      iconColor: AppTheme.secondaryPurple,
                      title: 'Configuración general',
                      subtitle: 'Notificaciones, tema e idioma',
                      delayMs: 120,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: LucideIcons.helpCircle,
                      iconColor: const Color(0xFF14B8A6), // Teal
                      title: 'Centro de ayuda y soporte',
                      subtitle: 'Preguntas frecuentes y asistencia técnica',
                      delayMs: 180,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportScreen()));
                      },
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Botón Cerrar Sesión
                    CustomCard(
                      padding: EdgeInsets.zero,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: AppTheme.surfaceCard,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                title: Text(
                                  '¿Cerrar sesión?',
                                  style: GoogleFonts.outfit(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
                                ),
                                content: Text(
                                  '¿Estás seguro de que deseas salir de tu cuenta?',
                                  style: GoogleFonts.outfit(color: AppTheme.textSecondary, fontSize: 14),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: Text('Cancelar', style: GoogleFonts.outfit(color: AppTheme.textMuted)),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.error,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: Text('Cerrar sesión', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true && context.mounted) {
                              await context.read<AuthController>().logout();
                              if (context.mounted) {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                                );
                              }
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppTheme.error.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(LucideIcons.logOut, color: AppTheme.error, size: 20),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Cerrar sesión',
                                        style: GoogleFonts.outfit(
                                          color: AppTheme.error,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        'Finalizar la sesión en este dispositivo',
                                        style: GoogleFonts.outfit(
                                          color: AppTheme.textMuted,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(LucideIcons.chevronRight, color: AppTheme.textMuted, size: 18),
                              ],
                            ),
                          ),
                        ),
                      ),
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

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required int delayMs,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CustomCard(
        padding: EdgeInsets.zero,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.outfit(
                            color: AppTheme.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: GoogleFonts.outfit(
                            color: AppTheme.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(LucideIcons.chevronRight, color: AppTheme.textMuted, size: 18),
                ],
              ),
            ),
          ),
        ),
      ).animate().fade(delay: delayMs.ms).slideX(begin: 0.03),
    );
  }
}
