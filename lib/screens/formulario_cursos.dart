import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/controlador_cursos.dart';
import '../controllers/controlador_profesores.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_header.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_dropdown.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/custom_card.dart';

class CourseFormScreen extends StatefulWidget {
  final Course? course;

  const CourseFormScreen({super.key, this.course});

  @override
  State<CourseFormScreen> createState() => _CourseFormScreenState();
}

class _CourseFormScreenState extends State<CourseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _codigoController;
  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;
  late TextEditingController _creditosController;
  
  int? _profesorId;

  @override
  void initState() {
    super.initState();
    _codigoController = TextEditingController(text: widget.course?.codigo ?? '');
    _nombreController = TextEditingController(text: widget.course?.nombre ?? '');
    _descripcionController = TextEditingController(text: widget.course?.descripcion ?? '');
    _creditosController = TextEditingController(text: widget.course?.creditos.toString() ?? '');
    _profesorId = widget.course?.profesorId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeacherController>().loadTeachers();
    });
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _nombreController.dispose();
    _descripcionController.dispose();
    _creditosController.dispose();
    super.dispose();
  }

  void _saveCourse() async {
    if (_formKey.currentState!.validate() && _profesorId != null) {
      final newCourse = Course(
        id: widget.course?.id,
        codigo: _codigoController.text.trim(),
        nombre: _nombreController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        creditos: int.tryParse(_creditosController.text.trim()) ?? 3,
        profesorId: _profesorId!,
      );

      final controller = context.read<CourseController>();
      if (widget.course == null) {
        await controller.addCourse(newCourse);
      } else {
        await controller.updateCourse(newCourse);
      }

      if (mounted) {
        Navigator.pop(context);
        CustomSnackbar.show(
          context,
          message: widget.course == null ? 'Curso agregado exitosamente' : 'Curso actualizado exitosamente',
          type: SnackbarType.success,
        );
      }
    } else if (_profesorId == null) {
      CustomSnackbar.show(
        context,
        message: 'Por favor selecciona un profesor asignado',
        type: SnackbarType.warning,
      );
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
              title: widget.course == null ? 'Nuevo Curso' : 'Editar Curso',
              subtitle: 'Ingresa los detalles de la asignatura',
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
                      // Tarjeta 1: Información del Curso
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
                                  child: const Icon(LucideIcons.bookOpen, size: 18, color: AppTheme.primaryBlue),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Información de la Asignatura',
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
                                      Expanded(flex: 2, child: _buildCodeField()),
                                      const SizedBox(width: 14),
                                      Expanded(child: _buildCreditsField()),
                                    ],
                                  );
                                }
                                return Column(
                                  children: [
                                    _buildCodeField(),
                                    const SizedBox(height: 14),
                                    _buildCreditsField(),
                                  ],
                                );
                              },
                            ).animate().fade(delay: 80.ms).slideY(begin: 0.08),
                            const SizedBox(height: 14),
                            
                            _buildNameField().animate().fade(delay: 140.ms).slideY(begin: 0.08),
                            const SizedBox(height: 14),
                            _buildDescriptionField().animate().fade(delay: 200.ms).slideY(begin: 0.08),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Tarjeta 2: Asignación Docente
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
                                  'Asignación Docente',
                                  style: GoogleFonts.outfit(
                                    color: AppTheme.textPrimary,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ).animate().fade(delay: 260.ms).slideX(begin: -0.05),
                            const SizedBox(height: 20),
                            
                            Consumer<TeacherController>(
                              builder: (context, teacherController, child) {
                                if (teacherController.isLoading) {
                                  return const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue));
                                }

                                return CustomDropdown<int>(
                                  label: 'Profesor Encargado',
                                  value: _profesorId,
                                  items: teacherController.teachers.map((teacher) {
                                    return DropdownMenuItem(
                                      value: teacher.id,
                                      child: Text(
                                        '${teacher.nombre} (${teacher.especialidad})',
                                        style: GoogleFonts.outfit(color: AppTheme.textPrimary, fontSize: 14),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _profesorId = value;
                                    });
                                  },
                                );
                              },
                            ).animate().fade(delay: 320.ms).slideY(begin: 0.08),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      CustomButton(
                        text: widget.course == null ? 'Guardar Curso' : 'Actualizar Curso',
                        icon: LucideIcons.save,
                        onPressed: _saveCourse,
                      ).animate().fade(delay: 380.ms).scale(begin: const Offset(0.98, 0.98)),
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

  Widget _buildCodeField() => CustomTextField(
    controller: _codigoController, 
    label: 'Código de Asignatura', 
    hint: 'Ej: CS-101',
    icon: LucideIcons.hash,
    validator: (val) => val == null || val.trim().isEmpty ? 'Requerido' : null,
  );
  
  Widget _buildCreditsField() => CustomTextField(
    controller: _creditosController, 
    label: 'Créditos', 
    hint: '3',
    icon: LucideIcons.award, 
    keyboardType: TextInputType.number,
    validator: (val) => val == null || val.trim().isEmpty ? 'Requerido' : null,
  );
  
  Widget _buildNameField() => CustomTextField(
    controller: _nombreController, 
    label: 'Nombre del Curso', 
    hint: 'Ej: Algoritmos y Estructuras de Datos',
    icon: LucideIcons.book,
    validator: (val) => val == null || val.trim().isEmpty ? 'Requerido' : null,
  );
  
  Widget _buildDescriptionField() => CustomTextField(
    controller: _descripcionController, 
    label: 'Descripción (Opcional)', 
    hint: 'Breve resumen del contenido y objetivos...',
    icon: LucideIcons.alignLeft,
    maxLines: 3,
  );
}
