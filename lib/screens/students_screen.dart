import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/student_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/models.dart';
import 'student_form_screen.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentController>().loadStudents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Directorio de Estudiantes'),
        centerTitle: false,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar por documento, nombre o correo...',
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
            child: Consumer<StudentController>(
              builder: (context, controller, child) {
                if (controller.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final filteredStudents = controller.students.where((student) {
                  return student.nombre.toLowerCase().contains(_searchQuery) ||
                         student.apellido.toLowerCase().contains(_searchQuery) ||
                         student.documento.toLowerCase().contains(_searchQuery) ||
                         student.correo.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filteredStudents.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_off_outlined, size: 64, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        Text('No se encontraron estudiantes.', style: Theme.of(context).textTheme.bodyLarge),
                      ],
                    ),
                  ).animate().fade();
                }

                return ListView.separated(
                  itemCount: filteredStudents.length,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final student = filteredStudents[index];
                    return _StudentListTile(student: student, onConfirmDelete: () => _confirmDelete(context, student))
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
                    builder: (context) => const StudentFormScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Nuevo Estudiante'),
            ).animate().fade(delay: 500.ms).scale()
          : null,
    );
  }

  Future<void> _confirmDelete(BuildContext context, Student student) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Estudiante'),
        content: Text('¿Estás seguro de eliminar a ${student.nombre} ${student.apellido}? Esta acción no se puede deshacer.'),
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
      await context.read<StudentController>().deleteStudent(student.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Estudiante eliminado exitosamente')),
        );
      }
    }
  }
}

class _StudentListTile extends StatelessWidget {
  final Student student;
  final VoidCallback onConfirmDelete;

  const _StudentListTile({required this.student, required this.onConfirmDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          child: Text(
            student.nombre.substring(0, 1).toUpperCase(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        title: Text(
          '${student.nombre} ${student.apellido}',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.white),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.email_outlined, size: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      student.correo, 
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.book_outlined, size: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${student.programa} - Semestre ${student.semestre}', 
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
                color: student.estado == 'Activo' 
                    ? const Color(0xFF10B981).withOpacity(0.2) // Neon green
                    : const Color(0xFFEF4444).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                student.estado,
                style: TextStyle(
                  color: student.estado == 'Activo' 
                      ? const Color(0xFF10B981)
                      : const Color(0xFFEF4444),
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
            Navigator.push(context, MaterialPageRoute(builder: (context) => StudentFormScreen(student: student)));
          }
        },
      ),
    );
  }
}
