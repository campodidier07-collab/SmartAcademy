import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/teacher_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/models.dart';
import 'teacher_form_screen.dart';

class TeachersScreen extends StatefulWidget {
  const TeachersScreen({super.key});

  @override
  State<TeachersScreen> createState() => _TeachersScreenState();
}

class _TeachersScreenState extends State<TeachersScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeacherController>().loadTeachers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Directorio de Profesores'),
        centerTitle: false,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar por documento, nombre o especialidad...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ).animate().fade().slideY(begin: -0.2),
          const SizedBox(height: 16),
          Expanded(
            child: Consumer<TeacherController>(
              builder: (context, controller, child) {
                if (controller.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final filteredTeachers = controller.teachers.where((teacher) {
                  return teacher.nombre.toLowerCase().contains(_searchQuery) ||
                         teacher.especialidad.toLowerCase().contains(_searchQuery) ||
                         teacher.documento.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filteredTeachers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_off_outlined, size: 64, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        Text('No se encontraron profesores.', style: Theme.of(context).textTheme.bodyLarge),
                      ],
                    ),
                  ).animate().fade();
                }

                return ListView.separated(
                  itemCount: filteredTeachers.length,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final teacher = filteredTeachers[index];
                    return _TeacherListTile(teacher: teacher, onConfirmDelete: () => _confirmDelete(context, teacher))
                        .animate()
                        .fade(delay: (index * 50).ms)
                        .slideX(begin: 0.1);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: context.watch<AuthController>().currentUser?.rol == 'Administrador'
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TeacherFormScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Nuevo Profesor'),
            ).animate().fade(delay: 500.ms).scale()
          : null,
    );
  }

  Future<void> _confirmDelete(BuildContext context, Teacher teacher) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Profesor'),
        content: Text('¿Estás seguro de eliminar al profesor ${teacher.nombre}? Esta acción no se puede deshacer.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await context.read<TeacherController>().deleteTeacher(teacher.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profesor eliminado exitosamente')),
        );
      }
    }
  }
}

class _TeacherListTile extends StatelessWidget {
  final Teacher teacher;
  final VoidCallback onConfirmDelete;

  const _TeacherListTile({required this.teacher, required this.onConfirmDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
          child: Text(
            teacher.nombre.substring(0, 1).toUpperCase(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        title: Text(
          teacher.nombre,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.white),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.workspace_premium_outlined, size: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      teacher.especialidad, 
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.email_outlined, size: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      teacher.correo, 
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.2), // Neon green active by default
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Activo',
                style: TextStyle(
                  color: Color(0xFF10B981),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.white54),
          ],
        ),
        onTap: () {
          final user = context.read<AuthController>().currentUser;
          if (user?.rol == 'Administrador') {
            Navigator.push(context, MaterialPageRoute(builder: (context) => TeacherFormScreen(teacher: teacher)));
          }
        },
      ),
    );
  }
}
