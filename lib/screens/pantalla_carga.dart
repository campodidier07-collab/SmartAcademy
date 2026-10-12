import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../controllers/controlador_auth.dart';
import 'pantalla_login.dart';
import 'pantalla_dashboard.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;

    final authController = Provider.of<AuthController>(context, listen: false);
    final isLoggedIn = await authController.checkLoginStatus();
    if (!mounted) return;

    if (isLoggedIn) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const DashboardScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundMain,
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -80,
            left: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.12),
                    blurRadius: 100,
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -60,
            child: Container(
              width: 380,
              height: 380,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.secondaryPurple.withValues(alpha: 0.08),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.secondaryPurple.withValues(alpha: 0.14),
                    blurRadius: 100,
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.cardElevated,
                      border: Border.all(color: AppTheme.borderLight, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.25),
                          blurRadius: 30,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(18),
                    child: Image.asset(
                      'lib/assets/imagenes/logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        LucideIcons.graduationCap,
                        size: 56,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  )
                      .animate()
                      .fade(duration: 700.ms)
                      .scale(begin: const Offset(0.85, 0.85), curve: Curves.easeOutBack),
                  const SizedBox(height: 28),
                  Text(
                    'SMARTACADEMY',
                    style: GoogleFonts.outfit(
                      color: AppTheme.textMain,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 3,
                    ),
                  )
                      .animate()
                      .fade(delay: 300.ms, duration: 600.ms)
                      .slideY(begin: 0.15, curve: Curves.easeOutCubic),
                  const SizedBox(height: 8),
                  Text(
                    'Excelencia académica y gestión inteligente',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  )
                      .animate()
                      .fade(delay: 500.ms, duration: 600.ms)
                      .slideY(begin: 0.15, curve: Curves.easeOutCubic),
                  const SizedBox(height: 56),
                  SizedBox(
                    width: 180,
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: const LinearProgressIndicator(
                            backgroundColor: AppTheme.cardElevated,
                            color: AppTheme.primaryBlue,
                            minHeight: 4,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Iniciando sistema...',
                          style: GoogleFonts.outfit(
                            color: AppTheme.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      ],
                    ),
                  ).animate().fade(delay: 700.ms, duration: 600.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
