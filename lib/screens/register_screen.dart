import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/auth_controller.dart';
import 'dashboard_screen.dart';
import '../theme/app_theme.dart';

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
  bool _obscureText = true;
  String _selectedRol = 'Estudiante';

  final List<String> _roles = ['Administrador', 'Profesor', 'Estudiante'];

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
        _nombreController.text,
        _emailController.text,
        _passwordController.text,
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                const Text('Error al registrar o correo ya en uso.'),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthController>().isLoading;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
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
                  BoxShadow(
                    color: AppTheme.neonBlue.withOpacity(0.1),
                    blurRadius: 100,
                    spreadRadius: 50,
                  )
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
                color: AppTheme.neonBlueDark.withOpacity(0.2),
              ),
            ),
          ),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Title Area
                        Text(
                          'Crear Cuenta',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32),
                        ).animate().fade().slideY(begin: -0.1),
                        const SizedBox(height: 8),
                        Text(
                          'Únete a SmartAcademy y comienza a gestionar tu futuro.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white70,
                          ),
                        ).animate().fade(delay: 100.ms).slideY(begin: -0.1),
                        const SizedBox(height: 40),

                        // Form Fields
                        TextFormField(
                          controller: _nombreController,
                          keyboardType: TextInputType.name,
                          decoration: InputDecoration(
                            labelText: 'Nombre completo',
                            prefixIcon: const Icon(Icons.person_outline),
                            filled: true,
                            fillColor: AppTheme.surfaceDark,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) => value!.isEmpty ? 'Ingresa tu nombre' : null,
                        ).animate().fade(delay: 200.ms).slideX(begin: -0.1),
                        const SizedBox(height: 16),
                        
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Correo electrónico',
                            prefixIcon: const Icon(Icons.email_outlined),
                            filled: true,
                            fillColor: AppTheme.surfaceDark,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) => value!.isEmpty ? 'Ingresa tu correo' : null,
                        ).animate().fade(delay: 300.ms).slideX(begin: -0.1),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscureText,
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.white54),
                              onPressed: () => setState(() => _obscureText = !_obscureText),
                            ),
                            filled: true,
                            fillColor: AppTheme.surfaceDark,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) => value!.length < 6 ? 'Mínimo 6 caracteres' : null,
                        ).animate().fade(delay: 400.ms).slideX(begin: -0.1),
                        const SizedBox(height: 16),

                        DropdownButtonFormField<String>(
                          value: _selectedRol,
                          decoration: InputDecoration(
                            labelText: 'Rol',
                            prefixIcon: const Icon(Icons.badge_outlined),
                            filled: true,
                            fillColor: AppTheme.surfaceDark,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          dropdownColor: AppTheme.surfaceDark,
                          items: _roles.map((String rol) {
                            return DropdownMenuItem<String>(
                              value: rol,
                              child: Text(rol, style: const TextStyle(color: Colors.white)),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _selectedRol = newValue!;
                            });
                          },
                        ).animate().fade(delay: 500.ms).slideX(begin: -0.1),
                        const SizedBox(height: 32),

                        // Register Button
                        Container(
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.neonBlue, AppTheme.neonBlueDark],
                            ),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.neonBlue.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text('Registrarse', style: TextStyle(color: Colors.white, fontSize: 16)),
                          ),
                        ).animate().fade(delay: 600.ms).scale(begin: const Offset(0.95, 0.95)),

                        const SizedBox(height: 32),

                        // Login Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('¿Ya tienes una cuenta? ', style: TextStyle(color: Colors.white54)),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Inicia sesión', style: TextStyle(color: AppTheme.neonBlue)),
                            ),
                          ],
                        ).animate().fade(delay: 700.ms),
                      ],
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
