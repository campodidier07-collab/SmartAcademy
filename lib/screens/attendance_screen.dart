import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../controllers/attendance_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class AttendanceScreen extends StatefulWidget {
  final int cursoId;
  const AttendanceScreen({super.key, required this.cursoId});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AttendanceController>().loadAttendances(widget.cursoId);
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Presente': return AppTheme.successColor;
      case 'Ausente': return AppTheme.errorColor;
      case 'Tarde': return AppTheme.warningColor;
      default: return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Presente': return Icons.check_circle_outline;
      case 'Ausente': return Icons.cancel_outlined;
      case 'Tarde': return Icons.access_time;
      default: return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userRole = context.read<AuthController>().currentUser?.rol;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Control de Asistencia'),
        backgroundColor: Colors.transparent,
      ),
      body: Consumer<AttendanceController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.attendances.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.fact_check_outlined, size: 64, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text('Sin registros de asistencia', style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 8),
                  Text('Los registros aparecerán aquí.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
                ],
              ),
            ).animate().fade();
          }

          return ListView.separated(
            itemCount: controller.attendances.length,
            padding: const EdgeInsets.all(24),
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final att = controller.attendances[index];
              final statusColor = _getStatusColor(att.estado);
              final statusIcon = _getStatusIcon(att.estado);

              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(statusIcon, color: statusColor, size: 24),
                  ),
                  title: Text(
                    'Estudiante ID: ${att.estudianteId}',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                        const SizedBox(width: 4),
                        Text(att.fecha, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                      ],
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      att.estado,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ).animate()
               .fade(delay: (index * 60).ms)
               .slideX(begin: 0.05);
            },
          );
        },
      ),
      floatingActionButton: (userRole == 'Profesor' || userRole == 'Administrador')
          ? FloatingActionButton.extended(
              onPressed: () => _showAttendanceDialog(context),
              icon: const Icon(Icons.add_task),
              label: const Text('Registrar'),
            ).animate().fade(delay: 500.ms).scale()
          : null,
    );
  }

  void _showAttendanceDialog(BuildContext context) {
    final estIdController = TextEditingController();
    String selectedStatus = 'Presente';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Registrar Asistencia'),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: estIdController,
                  decoration: const InputDecoration(
                    labelText: 'ID Estudiante',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Estado',
                    prefixIcon: Icon(Icons.fact_check_outlined),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Presente', child: Text('✅ Presente')),
                    DropdownMenuItem(value: 'Ausente', child: Text('❌ Ausente')),
                    DropdownMenuItem(value: 'Tarde', child: Text('⏰ Tarde')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = value!;
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
              FilledButton(
                onPressed: () {
                  final att = Attendance(
                    cursoId: widget.cursoId,
                    estudianteId: int.tryParse(estIdController.text) ?? 0,
                    fecha: DateFormat('yyyy-MM-dd').format(DateTime.now()),
                    estado: selectedStatus,
                  );
                  context.read<AttendanceController>().saveAttendance(att);
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
