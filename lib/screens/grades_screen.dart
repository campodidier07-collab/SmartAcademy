import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/grade_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class GradesScreen extends StatefulWidget {
  final int cursoId;
  const GradesScreen({super.key, required this.cursoId});

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GradeController>().loadGrades(widget.cursoId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final userRole = context.read<AuthController>().currentUser?.rol;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calificaciones'),
        backgroundColor: Colors.transparent,
      ),
      body: Consumer<GradeController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.grades.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.grading_outlined, size: 64, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text('No hay notas registradas', style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 8),
                  Text('Las calificaciones aparecerán aquí.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
                ],
              ),
            ).animate().fade();
          }

          return ListView.separated(
            itemCount: controller.grades.length,
            padding: const EdgeInsets.all(24),
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final grade = controller.grades[index];
              final definitiva = grade.definitiva ?? 0;
              final passed = definitiva >= 3.0;

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                child: Text(
                                  '${grade.estudianteId}',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Estudiante ID: ${grade.estudianteId}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                                  const SizedBox(height: 2),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: passed ? AppTheme.successColor.withOpacity(0.1) : AppTheme.errorColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      passed ? 'Aprobado' : 'Reprobado',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: passed ? AppTheme.successColor : AppTheme.errorColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (userRole == 'Profesor' || userRole == 'Administrador')
                            IconButton(
                              icon: Icon(Icons.edit_outlined, color: Theme.of(context).colorScheme.primary),
                              onPressed: () => _showGradeDialog(context, grade),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildGradeChip(context, 'Parcial 1', grade.parcial1),
                          _buildGradeChip(context, 'Parcial 2', grade.parcial2),
                          _buildGradeChip(context, 'Parcial 3', grade.parcial3),
                          _buildGradeChip(context, 'T. Final', grade.trabajoFinal),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Nota Definitiva', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                          Text(
                            grade.definitiva?.toStringAsFixed(1) ?? 'N/A',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: passed ? AppTheme.successColor : AppTheme.errorColor,
                            ),
                          ),
                        ],
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
      floatingActionButton: (userRole == 'Profesor' || userRole == 'Administrador')
          ? FloatingActionButton.extended(
              onPressed: () => _showGradeDialog(context, null),
              icon: const Icon(Icons.add),
              label: const Text('Nueva Nota'),
            ).animate().fade(delay: 500.ms).scale()
          : null,
    );
  }

  Widget _buildGradeChip(BuildContext context, String label, double? value) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value?.toStringAsFixed(1) ?? '—',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  void _showGradeDialog(BuildContext context, Grade? existingGrade) {
    final estIdController = TextEditingController(text: existingGrade?.estudianteId.toString() ?? '');
    final p1Controller = TextEditingController(text: existingGrade?.parcial1?.toString() ?? '');
    final p2Controller = TextEditingController(text: existingGrade?.parcial2?.toString() ?? '');
    final p3Controller = TextEditingController(text: existingGrade?.parcial3?.toString() ?? '');
    final tfController = TextEditingController(text: existingGrade?.trabajoFinal?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existingGrade == null ? 'Agregar Nota' : 'Editar Nota'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (existingGrade == null)
                TextFormField(controller: estIdController, decoration: const InputDecoration(labelText: 'ID Estudiante', prefixIcon: Icon(Icons.person_outline)), keyboardType: TextInputType.number),
              if (existingGrade == null) const SizedBox(height: 16),
              TextFormField(controller: p1Controller, decoration: const InputDecoration(labelText: 'Parcial 1', prefixIcon: Icon(Icons.looks_one_outlined)), keyboardType: const TextInputType.numberWithOptions(decimal: true)),
              const SizedBox(height: 16),
              TextFormField(controller: p2Controller, decoration: const InputDecoration(labelText: 'Parcial 2', prefixIcon: Icon(Icons.looks_two_outlined)), keyboardType: const TextInputType.numberWithOptions(decimal: true)),
              const SizedBox(height: 16),
              TextFormField(controller: p3Controller, decoration: const InputDecoration(labelText: 'Parcial 3', prefixIcon: Icon(Icons.looks_3_outlined)), keyboardType: const TextInputType.numberWithOptions(decimal: true)),
              const SizedBox(height: 16),
              TextFormField(controller: tfController, decoration: const InputDecoration(labelText: 'Trabajo Final', prefixIcon: Icon(Icons.assignment_outlined)), keyboardType: const TextInputType.numberWithOptions(decimal: true)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              final newGrade = Grade(
                id: existingGrade?.id,
                cursoId: widget.cursoId,
                estudianteId: int.tryParse(estIdController.text) ?? 0,
                parcial1: double.tryParse(p1Controller.text),
                parcial2: double.tryParse(p2Controller.text),
                parcial3: double.tryParse(p3Controller.text),
                trabajoFinal: double.tryParse(tfController.text),
              );
              context.read<GradeController>().saveGrade(newGrade);
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
