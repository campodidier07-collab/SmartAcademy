import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/schedule_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/models.dart';

class SchedulesScreen extends StatefulWidget {
  final int cursoId;
  const SchedulesScreen({super.key, required this.cursoId});

  @override
  State<SchedulesScreen> createState() => _SchedulesScreenState();
}

class _SchedulesScreenState extends State<SchedulesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScheduleController>().loadSchedules(widget.cursoId);
    });
  }

  Color _getDayColor(String day) {
    switch (day.toLowerCase()) {
      case 'lunes': return const Color(0xFF4F46E5);
      case 'martes': return const Color(0xFF14B8A6);
      case 'miércoles': case 'miercoles': return const Color(0xFFF59E0B);
      case 'jueves': return const Color(0xFFEF4444);
      case 'viernes': return const Color(0xFF10B981);
      case 'sábado': case 'sabado': return const Color(0xFF8B5CF6);
      default: return const Color(0xFF64748B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userRole = context.read<AuthController>().currentUser?.rol;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Horarios del Curso'),
        backgroundColor: Colors.transparent,
      ),
      body: Consumer<ScheduleController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.schedules.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_month_outlined, size: 64, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text('Sin horarios asignados', style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 8),
                  Text('Los horarios aparecerán aquí.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
                ],
              ),
            ).animate().fade();
          }

          return ListView.separated(
            itemCount: controller.schedules.length,
            padding: const EdgeInsets.all(24),
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final schedule = controller.schedules[index];
              final dayColor = _getDayColor(schedule.dia);

              return Card(
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      // Indicador lateral de color por día
                      Container(
                        width: 6,
                        decoration: BoxDecoration(
                          color: dayColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            bottomLeft: Radius.circular(16),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              // Día de la semana
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: dayColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    schedule.dia.substring(0, 3).toUpperCase(),
                                    style: TextStyle(
                                      color: dayColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Info del horario
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      schedule.dia,
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(Icons.access_time, size: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            '${schedule.horaInicio} — ${schedule.horaFin}',
                                            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Salón
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.room_outlined, size: 16, color: Theme.of(context).colorScheme.primary),
                                    const SizedBox(width: 4),
                                    Text(
                                      schedule.salon,
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate()
               .fade(delay: (index * 80).ms)
               .slideX(begin: 0.05);
            },
          );
        },
      ),
      floatingActionButton: (userRole == 'Administrador')
          ? FloatingActionButton.extended(
              onPressed: () => _showScheduleDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Añadir Horario'),
            ).animate().fade(delay: 500.ms).scale()
          : null,
    );
  }

  void _showScheduleDialog(BuildContext context) {
    String? selectedDia;
    final inicioController = TextEditingController();
    final finController = TextEditingController();
    final salonController = TextEditingController();

    final dias = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Añadir Horario'),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedDia,
                    decoration: const InputDecoration(
                      labelText: 'Día de la semana',
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                    items: dias.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedDia = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: inicioController,
                    decoration: const InputDecoration(
                      labelText: 'Hora de inicio (ej. 8:00)',
                      prefixIcon: Icon(Icons.play_arrow_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: finController,
                    decoration: const InputDecoration(
                      labelText: 'Hora de fin (ej. 10:00)',
                      prefixIcon: Icon(Icons.stop_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: salonController,
                    decoration: const InputDecoration(
                      labelText: 'Salón',
                      prefixIcon: Icon(Icons.room_outlined),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
              FilledButton(
                onPressed: () {
                  if (selectedDia == null) return;
                  final schedule = Schedule(
                    cursoId: widget.cursoId,
                    dia: selectedDia!,
                    horaInicio: inicioController.text,
                    horaFin: finController.text,
                    salon: salonController.text,
                  );
                  context.read<ScheduleController>().saveSchedule(schedule);
                  Navigator.pop(context);
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      ),
    );
  }
}
