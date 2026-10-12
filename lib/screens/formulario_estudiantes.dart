import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/controlador_estudiantes.dart';
import '../controllers/controlador_auth.dart';
import '../controllers/controlador_cursos.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_header.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_dropdown.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/custom_card.dart';

class StudentFormScreen extends StatefulWidget {
  final Student? student;

  const StudentFormScreen({super.key, this.student});

  @override
  State<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends State<StudentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _docController;
  late TextEditingController _nombreController;
  late TextEditingController _apellidoController;
  late TextEditingController _correoController;
  late TextEditingController _telefonoController;
  late TextEditingController _programaController;
  late TextEditingController _semestreController;
  late TextEditingController _passwordController;
  
  String _estado = 'Activo';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseController>().loadCourses();
    });
    
    _docController = TextEditingController(text: widget.student?.documento ?? '');
    _nombreController = TextEditingController(text: widget.student?.nombre ?? '');
    _apellidoController = TextEditingController(text: widget.student?.apellido ?? '');
    _correoController = TextEditingController(text: widget.student?.correo ?? '');
    _telefonoController = TextEditingController(text: widget.student?.telefono ?? '');
    _programaController = TextEditingController(text: widget.student?.programa ?? '');
    _semestreController = TextEditingController(text: widget.student?.semestre.toString() ?? '');
    _passwordController = TextEditingController();
    _estado = widget.student?.estado ?? 'Activo';
  }

  @override
  void dispose() {
    _docController.dispose();
    _nombreController.dispose();
    _apellidoController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _programaController.dispose();
    _semestreController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _saveStudent() async {
    if (_formKey.currentState!.validate()) {
      final newStudent = Student(
        id: widget.student?.id,
        documento: _docController.text.trim(),
        nombre: _nombreController.text.trim(),
        apellido: _apellidoController.text.trim(),
        correo: _correoController.text.trim(),
        telefono: _telefonoController.text.trim(),
        programa: _programaController.text.trim(),
        semestre: int.tryParse(_semestreController.text.trim()) ?? 1,
        estado: _estado,
      );

      final controller = context.read<StudentController>();
      final authCtrl = context.read<AuthController>();

      if (widget.student == null) {
        final fullName = '${_nombreController.text.trim()} ${_apellidoController.text.trim()}'.trim();
        final userCreated = await authCtrl.registerUserWithoutLogin(
          fullName,
          _correoController.text.trim(),
          _passwordController.text.trim(),
          'Estudiante',
        );
        if (!userCreated) {
          if (mounted) {
            CustomSnackbar.show(
              context, 
              message: 'El correo electrónico ya está registrado', 
              type: SnackbarType.error,
            );
          }
          return;
        }
        await controller.addStudent(newStudent);
      } else {
        await controller.updateStudent(newStudent);
      }

      if (mounted) {
        Navigator.pop(context);
        CustomSnackbar.show(
          context, 
          message: widget.student == null ? 'Estudiante registrado exitosamente' : 'Estudiante actualizado exitosamente',
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
              title: widget.student == null ? 'Nuevo Estudiante' : 'Editar Estudiante',
              subtitle: 'Ingresa los datos del estudiante',
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
                            
                            LayoutBuilder(
                              builder: (context, constraints) {
                                if (constraints.maxWidth > 500) {
                                  return Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(child: _buildNameField()),
                                      const SizedBox(width: 14),
                                      Expanded(child: _buildLastNameField()),
                                    ],
                                  );
                                }
                                return Column(
                                  children: [
                                    _buildNameField(),
                                    const SizedBox(height: 14),
                                    _buildLastNameField(),
                                  ],
                                );
                              },
                            ).animate().fade(delay: 140.ms).slideY(begin: 0.08),
                            const SizedBox(height: 14),
                            _buildEmailField().animate().fade(delay: 200.ms).slideY(begin: 0.08),
                            if (widget.student == null) ...[
                              const SizedBox(height: 14),
                              _buildPasswordField().animate().fade(delay: 260.ms).slideY(begin: 0.08),
                            ],
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Tarjeta 2: Información Académica
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
                                  child: const Icon(LucideIcons.graduationCap, size: 18, color: AppTheme.secondaryPurple),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Información Académica',
                                  style: GoogleFonts.outfit(
                                    color: AppTheme.textPrimary,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ).animate().fade(delay: 280.ms).slideX(begin: -0.05),
                            const SizedBox(height: 20),
                            
                            LayoutBuilder(
                              builder: (context, constraints) {
                                if (constraints.maxWidth > 500) {
                                  return Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(flex: 2, child: _buildProgramField()),
                                      const SizedBox(width: 14),
                                      Expanded(child: _buildSemesterField()),
                                    ],
                                  );
                                }
                                return Column(
                                  children: [
                                    _buildProgramField(),
                                    const SizedBox(height: 14),
                                    _buildSemesterField(),
                                  ],
                                );
                              },
                            ).animate().fade(delay: 340.ms).slideY(begin: 0.08),
                            const SizedBox(height: 14),
                            
                            CustomDropdown<String>(
                              label: 'Estado del Estudiante',
                              value: _estado,
                              items: [
                                DropdownMenuItem(
                                  value: 'Activo', 
                                  child: Text('Activo', style: GoogleFonts.outfit(color: AppTheme.textPrimary, fontSize: 14)),
                                ),
                                DropdownMenuItem(
                                  value: 'Inactivo', 
                                  child: Text('Inactivo', style: GoogleFonts.outfit(color: AppTheme.textPrimary, fontSize: 14)),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _estado = value);
                                }
                              },
                            ).animate().fade(delay: 400.ms).slideY(begin: 0.08),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      CustomButton(
                        text: widget.student == null ? 'Guardar Estudiante' : 'Actualizar Estudiante',
                        icon: LucideIcons.save,
                        onPressed: _saveStudent,
                      ).animate().fade(delay: 460.ms).scale(begin: const Offset(0.98, 0.98)),
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
    label: 'Nombres', 
    icon: LucideIcons.user,
    validator: _requiredValidator,
  );
  
  Widget _buildLastNameField() => CustomTextField(
    controller: _apellidoController, 
    label: 'Apellidos', 
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
  
  Widget _buildProgramField() {
    return Consumer<CourseController>(
      builder: (context, controller, child) {
        if (controller.courses.isEmpty && !controller.isLoading) {
          return CustomTextField(
            controller: _programaController, 
            label: 'Programa Académico', 
            icon: LucideIcons.book,
            validator: _requiredValidator,
          );
        }

        final courseNames = controller.courses.map((c) => c.nombre).toList();
        String? selectedValue = _programaController.text.isNotEmpty && courseNames.contains(_programaController.text) 
            ? _programaController.text 
            : null;

        return CustomDropdown<String>(
          label: 'Programa / Asignatura',
          value: selectedValue,
          items: courseNames.map((name) => DropdownMenuItem(
            value: name, 
            child: Text(name, style: GoogleFonts.outfit(color: AppTheme.textPrimary, fontSize: 14)),
          )).toList(),
          onChanged: (value) {
            setState(() {
              _programaController.text = value ?? '';
              if (value != null) {
                try {
                  final course = controller.courses.firstWhere((c) => c.nombre == value);
                  _semestreController.text = course.creditos.toString();
                } catch (e) {
                  // Ignore if not found
                }
              }
            });
          },
        );
      },
    );
  }
  
  Widget _buildSemesterField() => CustomTextField(
    controller: _semestreController, 
    label: 'Créditos / Semestre', 
    icon: LucideIcons.award, 
    keyboardType: TextInputType.number,
    validator: _requiredValidator,
  );

  Widget _buildPasswordField() => CustomTextField(
    controller: _passwordController,
    label: 'Contraseña de Acceso',
    icon: LucideIcons.key,
    obscureText: true,
    validator: (val) {
      if (widget.student == null && (val == null || val.trim().isEmpty)) return 'La contraseña es requerida';
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
