import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../controllers/controlador_cursos.dart';
import '../controllers/controlador_auth.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_header.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/custom_empty_state.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_dialog.dart';
import '../widgets/custom_snackbar.dart';
import 'formulario_cursos.dart';
import 'pantalla_calificaciones.dart';
import 'pantalla_asistencias.dart';
import 'pantalla_horarios.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseController>().loadCourses();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AuthController>().currentUser?.rol == 'Administrador';

    return Scaffold(
      backgroundColor: AppTheme.backgroundMain,
      floatingActionButton: isAdmin
          ? Padding(
              padding: const EdgeInsets.only(bottom: 96.0),
              child: FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CourseFormScreen(),
                    ),
                  );
                },
                backgroundColor: AppTheme.primaryBlue,
                elevation: 4,
                icon: const Icon(LucideIcons.bookPlus, color: Colors.white, size: 18),
                label: Text(
                  'Nuevo Curso',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            const CustomHeader(
              title: 'Directorio de Cursos',
              subtitle: 'Gestiona asignaturas, notas y asistencias',
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
              child: CustomSearchBar(
                hint: 'Buscar por código o nombre de curso...',
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),
            Expanded(
              child: Consumer<CourseController>(
                builder: (context, controller, child) {
                  final isLoading = controller.isLoading;
                  final filteredCourses = controller.courses.where((course) {
                    return course.nombre.toLowerCase().contains(_searchQuery) ||
                        course.codigo.toLowerCase().contains(_searchQuery);
                  }).toList();

                  if (!isLoading && filteredCourses.isEmpty) {
                    return CustomEmptyState(
                      icon: LucideIcons.bookOpen,
                      title: 'No se encontraron cursos',
                      description: _searchQuery.isEmpty
                          ? 'Comienza creando asignaturas con el botón inferior.'
                          : 'No hay cursos que coincidan con "$_searchQuery".',
                      buttonText: _searchQuery.isNotEmpty ? 'Limpiar búsqueda' : null,
                      onButtonPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    );
                  }

                  final displayCourses = isLoading
                      ? List.generate(
                          4,
                          (index) => Course(
                            id: index,
                            codigo: 'CS-101',
                            nombre: 'Cargando Asignatura',
                            descripcion: '...',
                            creditos: 3,
                            profesorId: 1,
                          ),
                        )
                      : filteredCourses;

                  return Skeletonizer(
                    enabled: isLoading,
                    child: ListView.separated(
                      itemCount: displayCourses.length,
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final course = displayCourses[index];
                        return _CourseCard(
                          course: course,
                          isAdmin: isAdmin,
                          onConfirmDelete: () => _confirmDelete(context, course),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Course course) async {
    final confirm = await CustomDialog.show<bool>(
      context,
      title: 'Eliminar Curso',
      message:
          '¿Estás seguro de eliminar el curso ${course.nombre}? Esta acción no se puede deshacer.',
      primaryButtonText: 'Eliminar',
      onPrimaryPressed: () => Navigator.of(context).pop(true),
      secondaryButtonText: 'Cancelar',
      iconColor: AppTheme.error,
      icon: LucideIcons.trash2,
    );

    if (confirm == true && context.mounted) {
      await context.read<CourseController>().deleteCourse(course.id!);
      if (context.mounted) {
        CustomSnackbar.show(
          context,
          message: 'Curso eliminado exitosamente',
          type: SnackbarType.success,
        );
      }
    }
  }
}

class _CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback onConfirmDelete;
  final bool isAdmin;

  const _CourseCard({
    required this.course,
    required this.onConfirmDelete,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.25),
                  ),
                ),
                alignment: Alignment.center,
                child: const Icon(LucideIcons.bookOpen, color: AppTheme.primaryBlue, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.nombre,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppTheme.textMain,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.cardElevated,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppTheme.borderLight),
                          ),
                          child: Text(
                            course.codigo,
                            style: GoogleFonts.outfit(
                              color: AppTheme.primaryBlue,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${course.creditos} Créditos',
                          style: GoogleFonts.outfit(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isAdmin)
                PopupMenuButton<String>(
                  icon: const Icon(LucideIcons.ellipsisVertical,
                      color: AppTheme.textSecondary, size: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppTheme.borderLight),
                  ),
                  color: AppTheme.cardElevated,
                  elevation: 8,
                  onSelected: (value) {
                    if (value == 'edit') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CourseFormScreen(course: course),
                        ),
                      );
                    } else if (value == 'delete') {
                      onConfirmDelete();
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          const Icon(LucideIcons.penLine, size: 16, color: AppTheme.textMain),
                          const SizedBox(width: 10),
                          Text(
                            'Editar',
                            style: GoogleFonts.outfit(color: AppTheme.textMain, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(LucideIcons.trash2, size: 16, color: AppTheme.error),
                          const SizedBox(width: 10),
                          Text(
                            'Eliminar',
                            style: GoogleFonts.outfit(color: AppTheme.error, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: AppTheme.borderLight, height: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _CourseActionButton(
                icon: LucideIcons.filePenLine,
                label: 'Notas',
                color: AppTheme.primaryBlue,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => GradesScreen(cursoId: course.id!)),
                ),
              ),
              _CourseActionButton(
                icon: LucideIcons.calendarCheck,
                label: 'Asistencia',
                color: AppTheme.success,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AttendanceScreen(cursoId: course.id!)),
                ),
              ),
              _CourseActionButton(
                icon: LucideIcons.calendarClock,
                label: 'Horarios',
                color: AppTheme.warning,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SchedulesScreen(cursoId: course.id!)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CourseActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _CourseActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        splashColor: color.withValues(alpha: 0.15),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.outfit(
                  color: AppTheme.textMain,
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
