import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/controlador_profesores.dart';
import '../controllers/controlador_auth.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_header.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/custom_card.dart';

class TeacherFormScreen extends StatefulWidget {
  final Teacher? teacher;

  const TeacherFormScreen({super.key, this.teacher});

  @override
  State<TeacherFormScreen> createState() => _TeacherFormScreenState();
}

class _TeacherFormScreenState extends State<TeacherFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _docController;
  late TextEditingController _nombreController;
  late TextEditingController _correoController;
  late TextEditingController _telefonoController;
  late TextEditingController _especialidadController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _docController = TextEditingController(text: widget.teacher?.documento ?? '');
    _nombreController = TextEditingController(text: widget.teacher?.nombre ?? '');
    _correoController = TextEditingController(text: widget.teacher?.correo ?? '');
    _telefonoController = TextEditingController(text: widget.teacher?.telefono ?? '');
    _especialidadController = TextEditingController(text: widget.teacher?.especialidad ?? '');
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _docController.dispose();
    _nombreController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _especialidadController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _saveTeacher() async {
    if (_formKey.currentState!.validate()) {
      final newTeacher = Teacher(
        id: widget.teacher?.id,
        documento: _docController.text.trim(),
        nombre: _nombreController.text.trim(),
        correo: _correoController.text.trim(),
        telefono: _telefonoController.text.trim(),
        especialidad: _especialidadController.text.trim(),
      );

      final controller = context.read<TeacherController>();
      final authCtrl = context.read<AuthController>();
      
      if (widget.teacher == null) {
        // Create User account first
        final userCreated = await authCtrl.registerUserWithoutLogin(
          _nombreController.text.trim(), 
          _correoController.text.trim(), 
          _passwordController.text.trim(), 
          'Profesor',
        );
        if (!userCreated) {
          if (mounted) CustomSnackbar.show(context, message: 'El correo electrónico ya está registrado', type: SnackbarType.error);
          return;
        }
        await controller.addTeacher(newTeacher);
      } else {
        await controller.updateTeacher(newTeacher);
      }

      if (mounted) {
        Navigator.pop(context);
        CustomSnackbar.show(
          context, 
          message: widget.teacher == null ? 'Profesor registrado exitosamente' : 'Profesor actualizado exitosamente',
          type: SnackbarType.success,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundMain,
      body: SafeArea(
        child: Column(
          children: [
            CustomHeader(
              title: widget.teacher == null ? 'Nuevo Profesor' : 'Editar Profesor',
              subtitle: 'Ingresa los datos del docente',
              showBackButton: true,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Tarjeta 1: Información Personal
                      CustomCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryBlue.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(LucideIcons.user, size: 18, color: AppTheme.primaryBlue),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Información Personal',
                                  style: GoogleFonts.outfit(
                                    color: AppTheme.textPrimary,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ).animate().fade().slideX(begin: -0.05),
                            const SizedBox(height: 20),
                            
                            LayoutBuilder(
                              builder: (context, constraints) {
                                if (constraints.maxWidth > 500) {
                                  return Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(child: _buildDocField()),
                                      const SizedBox(width: 14),
                                      Expanded(child: _buildPhoneField()),
                                    ],
                                  );
                                }
                                return Column(
                                  children: [
                                    _buildDocField(),
                                    const SizedBox(height: 14),
                                    _buildPhoneField(),
                                  ],
                                );
                              },
                            ).animate().fade(delay: 80.ms).slideY(begin: 0.08),
                            const SizedBox(height: 14),
                            
                            _buildNameField().animate().fade(delay: 140.ms).slideY(begin: 0.08),
                            const SizedBox(height: 14),
                            _buildEmailField().animate().fade(delay: 200.ms).slideY(begin: 0.08),
                            if (widget.teacher == null) ...[
                              const SizedBox(height: 14),
                              _buildPasswordField().animate().fade(delay: 260.ms).slideY(begin: 0.08),
                            ],
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Tarjeta 2: Información Profesional
                      CustomCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.secondaryPurple.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(LucideIcons.briefcase, size: 18, color: AppTheme.secondaryPurple),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Información Profesional',
                                  style: GoogleFonts.outfit(
                                    color: AppTheme.textPrimary,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ).animate().fade(delay: 300.ms).slideX(begin: -0.05),
                            const SizedBox(height: 20),
                            
                            _buildSpecialtyField().animate().fade(delay: 360.ms).slideY(begin: 0.08),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      CustomButton(
                        text: widget.teacher == null ? 'Guardar Profesor' : 'Actualizar Profesor',
                        icon: LucideIcons.save,
                        onPressed: _saveTeacher,
                      ).animate().fade(delay: 420.ms).scale(begin: const Offset(0.98, 0.98)),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocField() => CustomTextField(
    controller: _docController, 
    label: 'Documento de Identidad', 
    icon: LucideIcons.creditCard,
    validator: _requiredValidator,
  );
  
  Widget _buildPhoneField() => CustomTextField(
    controller: _telefonoController, 
    label: 'Teléfono Móvil', 
    icon: LucideIcons.phone, 
    keyboardType: TextInputType.phone,
    validator: _requiredValidator,
  );
  
  Widget _buildNameField() => CustomTextField(
    controller: _nombreController, 
    label: 'Nombre Completo', 
    icon: LucideIcons.user,
    validator: _requiredValidator,
  );
  
  Widget _buildEmailField() => CustomTextField(
    controller: _correoController, 
    label: 'Correo Electrónico', 
    icon: LucideIcons.mail, 
    keyboardType: TextInputType.emailAddress,
    validator: (value) {
      if (value == null || value.trim().isEmpty) return 'El correo es requerido';
      if (!value.contains('@')) return 'Formato de correo no válido';
      return null;
    },
  );
  
  Widget _buildSpecialtyField() => CustomTextField(
    controller: _especialidadController, 
    label: 'Especialidad / Departamento', 
    hint: 'Ej: Matemáticas, Ciencias, Literatura',
    icon: LucideIcons.graduationCap,
    validator: _requiredValidator,
  );

  Widget _buildPasswordField() => CustomTextField(
    controller: _passwordController,
    label: 'Contraseña de Acceso',
    icon: LucideIcons.key,
    obscureText: true,
    validator: (val) {
      if (widget.teacher == null && (val == null || val.trim().isEmpty)) return 'La contraseña es requerida';
      if (val != null && val.trim().isNotEmpty && val.trim().length < 6) return 'Mínimo 6 caracteres';
      return null;
    },
  );

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obligatorio';
    }
    return null;
  }
}
