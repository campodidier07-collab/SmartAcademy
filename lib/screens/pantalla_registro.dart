import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../controllers/controlador_auth.dart';
import 'pantalla_dashboard.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_snackbar.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final String _selectedRol = 'Estudiante';

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      final authController = Provider.of<AuthController>(context, listen: false);
      final success = await authController.register(
        _nombreController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _selectedRol,
      );

      if (success) {
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const DashboardScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
          (route) => false,
        );
      } else {
        if (!mounted) return;
        CustomSnackbar.show(
          context,
          message: 'Error al registrar o correo ya registrado.',
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Center(
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppTheme.cardElevated.withValues(alpha: 0.8),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: IconButton(
                icon: const Icon(LucideIcons.arrowLeft, color: AppTheme.textMain, size: 18),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background Elements
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 340,
              height: 340,
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
            right: -100,
            child: Container(
              width: 360,
              height: 360,
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
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: CustomCard(
                    glass: true,
                    padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 30),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Title Area
                          Text(
                            'Crear Cuenta',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textMain,
                              letterSpacing: -0.2,
                            ),
                          ).animate().fade().slideY(begin: 0.15),
                          const SizedBox(height: 6),
                          Text(
                            'Únete a SmartAcademy y gestiona tu futuro',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ).animate().fade(delay: 100.ms).slideY(begin: 0.15),
                          const SizedBox(height: 26),

                          // Form Fields
                          CustomTextField(
                            label: 'Nombre completo',
                            hint: 'Juan Pérez',
                            icon: LucideIcons.user,
                            controller: _nombreController,
                            keyboardType: TextInputType.name,
                            validator: (value) =>
                                (value == null || value.trim().isEmpty) ? 'Ingresa tu nombre' : null,
                          ).animate().fade(delay: 200.ms).slideY(begin: 0.15),
                          const SizedBox(height: 18),

                          CustomTextField(
                            label: 'Correo electrónico',
                            hint: 'ejemplo@correo.com',
                            icon: LucideIcons.mail,
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) =>
                                (value == null || value.trim().isEmpty) ? 'Ingresa tu correo' : null,
                          ).animate().fade(delay: 300.ms).slideY(begin: 0.15),
                          const SizedBox(height: 18),

                          CustomTextField(
                            label: 'Contraseña',
                            hint: '••••••••',
                            icon: LucideIcons.lock,
                            controller: _passwordController,
                            obscureText: true,
                            validator: (value) => (value == null || value.length < 6)
                                ? 'Mínimo 6 caracteres'
                                : null,
                          ).animate().fade(delay: 400.ms).slideY(begin: 0.15),
                          const SizedBox(height: 24),

                          // Register Button
                          CustomButton(
                            text: 'Registrarse',
                            isLoading: isLoading,
                            onPressed: _register,
                          ).animate().fade(delay: 500.ms).slideY(begin: 0.15),

                          const SizedBox(height: 24),

                          // Login Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '¿Ya tienes una cuenta? ',
                                style: GoogleFonts.outfit(
                                  color: AppTheme.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Text(
                                  'Inicia sesión',
                                  style: GoogleFonts.outfit(
                                    color: AppTheme.primaryBlue,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ).animate().fade(delay: 600.ms),
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
