import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/course_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/models.dart';
import 'course_form_screen.dart';
import 'grades_screen.dart';
import 'attendance_screen.dart';
import 'schedules_screen.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseController>().loadCourses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Directorio de Cursos'),
        centerTitle: false,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar por código o nombre del curso...',
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
            child: Consumer<CourseController>(
              builder: (context, controller, child) {
                if (controller.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final filteredCourses = controller.courses.where((course) {
                  return course.nombre.toLowerCase().contains(_searchQuery) ||
                         course.codigo.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filteredCourses.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.menu_book_outlined, size: 64, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        Text('No se encontraron cursos.', style: Theme.of(context).textTheme.bodyLarge),
                      ],
                    ),
                  ).animate().fade();
                }

                return ListView.separated(
                  itemCount: filteredCourses.length,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final course = filteredCourses[index];
                    return _CourseListTile(course: course, onConfirmDelete: () => _confirmDelete(context, course))
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
                    builder: (context) => const CourseFormScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Nuevo Curso'),
            ).animate().fade(delay: 500.ms).scale()
          : null,
    );
  }

  Future<void> _confirmDelete(BuildContext context, Course course) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Curso'),
        content: Text('¿Estás seguro de eliminar el curso ${course.nombre}? Esta acción no se puede deshacer.'),
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
      await context.read<CourseController>().deleteCourse(course.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Curso eliminado exitosamente')),
        );
      }
    }
  }
}

class _CourseListTile extends StatelessWidget {
  final Course course;
  final VoidCallback onConfirmDelete;

  const _CourseListTile({required this.course, required this.onConfirmDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFEF4444), Color(0xFF0F172A)], // Red neon gradient
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFFEF4444).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.book, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.nombre,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.qr_code_outlined, size: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                          const SizedBox(width: 4),
                          Text(course.codigo, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 13)),
                          const SizedBox(width: 12),
                          Icon(Icons.credit_score_outlined, size: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                          const SizedBox(width: 4),
                          Text('${course.creditos} créd.', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ),
                if (context.watch<AuthController>().currentUser?.rol == 'Administrador')
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    onSelected: (value) {
                      if (value == 'edit') {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => CourseFormScreen(course: course)));
                      } else if (value == 'delete') {
                        onConfirmDelete();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 20), SizedBox(width: 12), Text('Editar')])),
                      PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 20, color: Theme.of(context).colorScheme.error), const SizedBox(width: 12), Text('Eliminar', style: TextStyle(color: Theme.of(context).colorScheme.error))])),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            // Action buttons row
            Row(
              children: [
                _ActionChip(
                  icon: Icons.grading_outlined,
                  label: 'Notas',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => GradesScreen(cursoId: course.id!))),
                ),
                const SizedBox(width: 8),
                _ActionChip(
                  icon: Icons.fact_check_outlined,
                  label: 'Asistencia',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AttendanceScreen(cursoId: course.id!))),
                ),
                const SizedBox(width: 8),
                _ActionChip(
                  icon: Icons.schedule_outlined,
                  label: 'Horarios',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SchedulesScreen(cursoId: course.id!))),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionChip({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.primary.withOpacity(0.06),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
