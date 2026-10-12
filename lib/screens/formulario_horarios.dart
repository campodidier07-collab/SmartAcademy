import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/controlador_horarios.dart';
import '../controllers/controlador_cursos.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_header.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_dropdown.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/custom_card.dart';

class ScheduleFormScreen extends StatefulWidget {
  final Schedule? schedule;
  final int? preselectedCursoId;

  const ScheduleFormScreen({super.key, this.schedule, this.preselectedCursoId});

  @override
  State<ScheduleFormScreen> createState() => _ScheduleFormScreenState();
}

class _ScheduleFormScreenState extends State<ScheduleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  int? _selectedCursoId;
  String _selectedDia = 'Lunes';
  late TextEditingController _horaInicioController;
  late TextEditingController _horaFinController;
  late TextEditingController _salonController;
  
  final List<String> _dias = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'];

  @override
  void initState() {
    super.initState();
    _selectedCursoId = widget.schedule?.cursoId ?? widget.preselectedCursoId;
    _selectedDia = widget.schedule?.dia ?? 'Lunes';
    _horaInicioController = TextEditingController(text: widget.schedule?.horaInicio ?? '08:00');
    _horaFinController = TextEditingController(text: widget.schedule?.horaFin ?? '10:00');
    _salonController = TextEditingController(text: widget.schedule?.salon ?? '');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<CourseController>().courses.isEmpty) {
        context.read<CourseController>().loadCourses();
      }
    });
  }

  @override
  void dispose() {
    _horaInicioController.dispose();
    _horaFinController.dispose();
    _salonController.dispose();
    super.dispose();
  }

  void _saveSchedule() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCursoId == null) {
        CustomSnackbar.show(
          context,
          message: 'Debes seleccionar un curso',
          type: SnackbarType.warning,
        );
        return;
      }

      final newSchedule = Schedule(
        id: widget.schedule?.id,
        cursoId: _selectedCursoId!,
        dia: _selectedDia,
        horaInicio: _horaInicioController.text.trim(),
        horaFin: _horaFinController.text.trim(),
        salon: _salonController.text.trim(),
      );

      final controller = context.read<ScheduleController>();
      await controller.saveSchedule(newSchedule);

      if (mounted) {
        Navigator.pop(context);
        CustomSnackbar.show(
          context, 
          message: widget.schedule == null ? 'Horario registrado exitosamente' : 'Horario actualizado exitosamente',
          type: SnackbarType.success,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final courses = context.watch<CourseController>().courses;
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundMain,
      body: SafeArea(
        child: Column(
          children: [
            CustomHeader(
              title: widget.schedule == null ? 'Nuevo Horario' : 'Editar Horario',
              subtitle: 'Asigna el salón y bloque horario',
              showBackButton: true,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: CustomCard(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBlue.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(LucideIcons.calendarClock, size: 18, color: AppTheme.primaryBlue),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Detalles del Bloque',
                              style: GoogleFonts.outfit(
                                color: AppTheme.textPrimary,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ).animate().fade().slideX(begin: -0.05),
                        const SizedBox(height: 20),

                        CustomDropdown<int>(
                          label: 'Curso Asignado',
                          value: _selectedCursoId,
                          items: courses.map((Course course) {
                            return DropdownMenuItem<int>(
                              value: course.id,
                              child: Text(
                                '${course.codigo} - ${course.nombre}',
                                style: GoogleFonts.outfit(color: AppTheme.textPrimary, fontSize: 14),
                              ),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _selectedCursoId = newValue;
                            });
                          },
                        ).animate().fade(delay: 80.ms).slideY(begin: 0.08),
                        
                        const SizedBox(height: 16),
                        CustomDropdown<String>(
                          label: 'Día de la Semana',
                          value: _selectedDia,
                          items: _dias.map((String dia) {
                            return DropdownMenuItem<String>(
                              value: dia,
                              child: Text(
                                dia,
                                style: GoogleFonts.outfit(color: AppTheme.textPrimary, fontSize: 14),
                              ),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedDia = newValue;
                              });
                            }
                          },
                        ).animate().fade(delay: 140.ms).slideY(begin: 0.08),
                        
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                label: 'Hora Inicio',
                                hint: '08:00',
                                icon: LucideIcons.clock,
                                controller: _horaInicioController,
                                validator: (value) => value == null || value.trim().isEmpty ? 'Requerido' : null,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: CustomTextField(
                                label: 'Hora Fin',
                                hint: '10:00',
                                icon: LucideIcons.clock4,
                                controller: _horaFinController,
                                validator: (value) => value == null || value.trim().isEmpty ? 'Requerido' : null,
                              ),
                            ),
                          ],
                        ).animate().fade(delay: 200.ms).slideY(begin: 0.08),

                        const SizedBox(height: 16),
                        CustomTextField(
                          label: 'Salón / Aula de Clase',
                          hint: 'Ej: Aula Magna / A-102',
                          icon: LucideIcons.doorOpen,
                          controller: _salonController,
                          validator: (value) => value == null || value.trim().isEmpty ? 'Ingresa el salón' : null,
                        ).animate().fade(delay: 260.ms).slideY(begin: 0.08),
                        
                        const SizedBox(height: 28),
                        CustomButton(
                          text: widget.schedule == null ? 'Guardar Horario' : 'Actualizar Horario',
                          icon: LucideIcons.save,
                          onPressed: _saveSchedule,
                        ).animate().fade(delay: 320.ms).scale(begin: const Offset(0.98, 0.98)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
