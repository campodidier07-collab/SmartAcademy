import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../controllers/controlador_auth.dart';
import 'pantalla_dashboard.dart';
import 'pantalla_registro.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_snackbar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      final authController = Provider.of<AuthController>(context, listen: false);
      final success = await authController.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (success) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const DashboardScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      } else {
        if (!mounted) return;
        CustomSnackbar.show(
          context,
          message: 'Credenciales incorrectas o usuario no encontrado',
          type: SnackbarType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthController>().isLoading;

    return Scaffold(
      backgroundColor: AppTheme.backgroundMain,
      body: Stack(
        children: [
          // Background Elements
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.12),
                    blurRadius: 100,
                    spreadRadius: 40,
                  )
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 340,
              height: 340,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.secondaryPurple.withValues(alpha: 0.08),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.secondaryPurple.withValues(alpha: 0.12),
                    blurRadius: 100,
                    spreadRadius: 40,
                  )
                ],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: CustomCard(
                    glass: true,
                    padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Logo Area
                          Center(
                            child: Container(
                              width: 74,
                              height: 74,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.cardElevated,
                                border: Border.all(color: AppTheme.borderLight, width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                                    blurRadius: 20,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Image.asset(
                                'lib/assets/imagenes/logo.png',
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => const Icon(
                                  LucideIcons.graduationCap,
                                  size: 34,
                                  color: AppTheme.primaryBlue,
                                ),
                              ),
                            ),
                          ).animate().fade(delay: 100.ms).scale(curve: Curves.easeOutBack),

                          const SizedBox(height: 22),

                          // Welcome Text
                          Text(
                            'Bienvenido de nuevo',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textMain,
                              letterSpacing: -0.2,
                            ),
                          ).animate().fade().slideY(begin: 0.15),
                          const SizedBox(height: 6),
                          Text(
                            'Ingresa tus credenciales para continuar',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ).animate().fade(delay: 100.ms).slideY(begin: 0.15),
                          const SizedBox(height: 28),

                          // Form Fields
                          CustomTextField(
                            label: 'Correo electrónico',
                            hint: 'admin@smartacademy.com',
                            icon: LucideIcons.mail,
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) => (value == null || value.trim().isEmpty)
                                ? 'Ingresa tu correo'
                                : null,
                          ).animate().fade(delay: 200.ms).slideY(begin: 0.15),
                          const SizedBox(height: 18),
                          CustomTextField(
                            label: 'Contraseña',
                            hint: '••••••••',
                            icon: LucideIcons.lock,
                            controller: _passwordController,
                            obscureText: true,
                            validator: (value) => (value == null || value.trim().isEmpty)
                                ? 'Ingresa tu contraseña'
                                : null,
                          ).animate().fade(delay: 300.ms).slideY(begin: 0.15),

                          const SizedBox(height: 10),

                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                CustomSnackbar.show(
                                  context,
                                  message: 'Contacta al administrador para recuperar tu clave.',
                                  type: SnackbarType.info,
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                              ),
                              child: Text(
                                '¿Olvidaste tu contraseña?',
                                style: GoogleFonts.outfit(
                                  color: AppTheme.primaryBlue,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ).animate().fade(delay: 350.ms),

                          const SizedBox(height: 20),

                          // Login Button
                          CustomButton(
                            text: 'Iniciar Sesión',
                            isLoading: isLoading,
                            onPressed: _login,
                          ).animate().fade(delay: 450.ms).slideY(begin: 0.15),

                          const SizedBox(height: 26),

                          // Register Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '¿No tienes una cuenta? ',
                                style: GoogleFonts.outfit(
                                  color: AppTheme.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation, secondaryAnimation) =>
                                          const RegisterScreen(),
                                      transitionsBuilder:
                                          (context, animation, secondaryAnimation, child) {
                                        return FadeTransition(opacity: animation, child: child);
                                      },
                                    ),
                                  );
                                },
                                child: Text(
                                  'Regístrate',
                                  style: GoogleFonts.outfit(
                                    color: AppTheme.primaryBlue,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ).animate().fade(delay: 550.ms),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
