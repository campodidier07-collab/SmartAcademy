import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/auth_controller.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';
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
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;
    
    final authController = Provider.of<AuthController>(context, listen: false);
    final isLoggedIn = await authController.checkLoginStatus();

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
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.neonBlue.withOpacity(0.05),
                boxShadow: [
                  BoxShadow(color: AppTheme.neonBlue.withOpacity(0.1), blurRadius: 100, spreadRadius: 50),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            right: -50,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.neonBlueDark.withOpacity(0.1),
                boxShadow: [
                  BoxShadow(color: AppTheme.neonBlueDark.withOpacity(0.2), blurRadius: 100, spreadRadius: 50),
                ],
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'lib/assets/imagenes/logo.png',
                  width: 150,
                  height: 150,
                ).animate()
                 .fade(duration: 800.ms)
                 .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack),
                const SizedBox(height: 32),
                Text(
                  'SMARTACADEMY',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 32,
                    letterSpacing: 2,
                  ),
                ).animate()
                 .fade(delay: 400.ms, duration: 800.ms)
                 .slideY(begin: 0.2, curve: Curves.easeOutQuad),
                const SizedBox(height: 8),
                Text(
                  'Tu progreso, nuestra meta',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ).animate()
                 .fade(delay: 800.ms, duration: 800.ms)
                 .slideY(begin: 0.2, curve: Curves.easeOutQuad),
                const SizedBox(height: 64),
                
                SizedBox(
                  width: 200,
                  child: Column(
                    children: [
                      LinearProgressIndicator(
                        backgroundColor: Colors.white.withOpacity(0.1),
                        color: AppTheme.neonBlue,
                        minHeight: 4,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Cargando...',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      )
                    ],
                  ),
                ).animate()
                 .fade(delay: 1200.ms, duration: 800.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
