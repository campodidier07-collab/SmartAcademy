import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/controlador_horarios.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_header.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_empty_state.dart';
import '../controllers/controlador_auth.dart';
import 'formulario_horarios.dart';

class SchedulesScreen extends StatefulWidget {
  final int? cursoId;
  const SchedulesScreen({super.key, this.cursoId});

  @override
  State<SchedulesScreen> createState() => _SchedulesScreenState();
}

class _SchedulesScreenState extends State<SchedulesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.cursoId != null) {
        context.read<ScheduleController>().loadSchedules(widget.cursoId!);
      }
    });
  }

  Color _getDayColor(String day) {
    switch (day.toLowerCase()) {
      case 'lunes': return AppTheme.primaryBlue;
      case 'martes': return AppTheme.secondaryPurple;
      case 'miércoles': case 'miercoles': return AppTheme.success;
      case 'jueves': return AppTheme.warning;
      case 'viernes': return const Color(0xFF14B8A6); // Teal
      case 'sábado': case 'sabado': return AppTheme.error;
      default: return AppTheme.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AuthController>().currentUser?.rol == 'Administrador';

    return Scaffold(
      backgroundColor: AppTheme.backgroundMain,
      floatingActionButton: isAdmin ? Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ScheduleFormScreen(preselectedCursoId: widget.cursoId),
              ),
            );
          },
          backgroundColor: AppTheme.primaryBlue,
          elevation: 4,
          icon: const Icon(LucideIcons.plus, color: Colors.white, size: 20),
          label: Text(
            'Nuevo Horario',
            style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
      ) : null,
      body: SafeArea(
        child: Column(
          children: [
            CustomHeader(
              title: widget.cursoId != null ? 'Horario del Curso' : 'Mi Horario Semanal',
              subtitle: 'Consulta tus bloques y salones de clase',
              showBackButton: true,
            ),
            
            Expanded(
              child: Consumer<ScheduleController>(
                builder: (context, controller, child) {
                  if (controller.isLoading) {
                    return const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue));
                  }

                  if (controller.schedules.isEmpty) {
                    return const CustomEmptyState(
                      icon: LucideIcons.calendarOff,
                      title: 'Sin Clases Programadas',
                      description: 'No hay horarios de clase registrados para mostrar en este momento.',
                    );
                  }

                  final daysOrder = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'];
                  final Map<String, List<Schedule>> grouped = {};
                  
                  for (var day in daysOrder) {
                    grouped[day] = controller.schedules.where((s) => 
                      s.dia.toLowerCase() == day.toLowerCase() || 
                      (day == 'Miércoles' && s.dia.toLowerCase() == 'miercoles')
                    ).toList();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                    itemCount: daysOrder.length,
                    itemBuilder: (context, index) {
                      final day = daysOrder[index];
                      final daySchedules = grouped[day] ?? [];

                      if (daySchedules.isEmpty) return const SizedBox.shrink();

                      final dayColor = _getDayColor(day);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Cabecera del día
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: dayColor,
                                    borderRadius: BorderRadius.circular(2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: dayColor.withValues(alpha: 0.4),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  day,
                                  style: GoogleFonts.outfit(
                                    color: AppTheme.textPrimary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: dayColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: dayColor.withValues(alpha: 0.3)),
                                  ),
                                  child: Text(
                                    '${daySchedules.length} ${daySchedules.length == 1 ? 'clase' : 'clases'}',
                                    style: GoogleFonts.outfit(
                                      color: dayColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fade(delay: (index * 60).ms).slideX(begin: -0.05),
                          
                          // Tarjetas de horarios
                          ...daySchedules.map((schedule) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: CustomCard(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    // Bloque de horas con diseño de ticket M3
                                    Container(
                                      width: 78,
                                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                                      decoration: BoxDecoration(
                                        color: dayColor.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: dayColor.withValues(alpha: 0.25)),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            schedule.horaInicio, 
                                            style: GoogleFonts.outfit(
                                              fontWeight: FontWeight.w700, 
                                              fontSize: 13, 
                                              color: dayColor,
                                            ),
                                          ),
                                          Container(
                                            margin: const EdgeInsets.symmetric(vertical: 2),
                                            width: 14,
                                            height: 1,
                                            color: dayColor.withValues(alpha: 0.4),
                                          ),
                                          Text(
                                            schedule.horaFin, 
                                            style: GoogleFonts.outfit(
                                              fontWeight: FontWeight.w700, 
                                              fontSize: 13, 
                                              color: dayColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    
                                    // Detalles de salón y curso
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(6),
                                                decoration: BoxDecoration(
                                                  color: AppTheme.surfaceCardElevated,
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: const Icon(LucideIcons.doorOpen, size: 14, color: AppTheme.primaryBlue),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  'Salón ${schedule.salon}',
                                                  style: GoogleFonts.outfit(
                                                    fontSize: 15, 
                                                    fontWeight: FontWeight.w600, 
                                                    color: AppTheme.textPrimary,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(6),
                                                decoration: BoxDecoration(
                                                  color: AppTheme.surfaceCardElevated,
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: const Icon(LucideIcons.bookOpen, size: 14, color: AppTheme.textMuted),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  'Curso #${schedule.cursoId}',
                                                  style: GoogleFonts.outfit(
                                                    fontSize: 13, 
                                                    color: AppTheme.textMuted, 
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ).animate().fade(delay: (index * 80).ms).slideY(begin: 0.08),
                            );
                          }),
                          const SizedBox(height: 6),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
