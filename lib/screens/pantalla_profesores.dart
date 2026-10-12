import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../controllers/controlador_profesores.dart';
import '../controllers/controlador_auth.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_header.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/custom_empty_state.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_dialog.dart';
import '../widgets/custom_snackbar.dart';
import 'formulario_profesores.dart';

class TeachersScreen extends StatefulWidget {
  const TeachersScreen({super.key});

  @override
  State<TeachersScreen> createState() => _TeachersScreenState();
}

class _TeachersScreenState extends State<TeachersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeacherController>().loadTeachers();
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
                      builder: (context) => const TeacherFormScreen(),
                    ),
                  );
                },
                backgroundColor: AppTheme.secondaryPurple,
                elevation: 4,
                icon: const Icon(LucideIcons.userPlus, color: Colors.white, size: 18),
                label: Text(
                  'Nuevo Profesor',
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
              title: 'Directorio de Profesores',
              subtitle: 'Gestiona la planta docente y sus asignaturas',
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
              child: CustomSearchBar(
                hint: 'Buscar por documento, nombre o especialidad...',
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),
            Expanded(
              child: Consumer<TeacherController>(
                builder: (context, controller, child) {
                  final isLoading = controller.isLoading;
                  final filteredTeachers = controller.teachers.where((teacher) {
                    return teacher.nombre.toLowerCase().contains(_searchQuery) ||
                        teacher.especialidad.toLowerCase().contains(_searchQuery) ||
                        teacher.documento.toLowerCase().contains(_searchQuery);
                  }).toList();

                  if (!isLoading && filteredTeachers.isEmpty) {
                    return CustomEmptyState(
                      icon: LucideIcons.graduationCap,
                      title: 'No se encontraron profesores',
                      description: _searchQuery.isEmpty
                          ? 'Comienza registrando docentes con el botón inferior.'
                          : 'No hay resultados para "$_searchQuery".',
                      buttonText: _searchQuery.isNotEmpty ? 'Limpiar búsqueda' : null,
                      onButtonPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    );
                  }

                  final displayTeachers = isLoading
                      ? List.generate(
                          4,
                          (index) => Teacher(
                            id: index,
                            nombre: 'Cargando Docente',
                            especialidad: 'Especialidad',
                            documento: '1000000',
                            correo: 'docente@academia.com',
                            telefono: '3000000000',
                          ),
                        )
                      : filteredTeachers;

                  return Skeletonizer(
                    enabled: isLoading,
                    child: ListView.separated(
                      itemCount: displayTeachers.length,
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final teacher = displayTeachers[index];
                        return _TeacherCard(
                          teacher: teacher,
                          isAdmin: isAdmin,
                          onConfirmDelete: () => _confirmDelete(context, teacher),
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

  Future<void> _confirmDelete(BuildContext context, Teacher teacher) async {
    final confirm = await CustomDialog.show<bool>(
      context,
      title: 'Eliminar Profesor',
      message:
          '¿Estás seguro de eliminar al profesor ${teacher.nombre}? Esta acción no se puede deshacer.',
      primaryButtonText: 'Eliminar',
      onPrimaryPressed: () => Navigator.of(context).pop(true),
      secondaryButtonText: 'Cancelar',
      iconColor: AppTheme.error,
      icon: LucideIcons.trash2,
    );

    if (confirm == true && context.mounted) {
      await context.read<TeacherController>().deleteTeacher(teacher.id!);
      if (context.mounted) {
        CustomSnackbar.show(
          context,
          message: 'Profesor eliminado exitosamente',
          type: SnackbarType.success,
        );
      }
    }
  }
}

class _TeacherCard extends StatelessWidget {
  final Teacher teacher;
  final VoidCallback onConfirmDelete;
  final bool isAdmin;

  const _TeacherCard({
    required this.teacher,
    required this.onConfirmDelete,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      borderRadius: 14,
      onTap: isAdmin
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TeacherFormScreen(teacher: teacher),
                ),
              );
            }
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.secondaryPurple.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  teacher.nombre.isNotEmpty ? teacher.nombre[0].toUpperCase() : 'P',
                  style: GoogleFonts.outfit(
                    color: AppTheme.secondaryPurple,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            teacher.nombre,
                            style: GoogleFonts.outfit(
                              color: AppTheme.textMain,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.success.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.success.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            'Activo',
                            style: GoogleFonts.outfit(
                              color: AppTheme.success,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Doc: ${teacher.documento} • ${teacher.especialidad}',
                      style: GoogleFonts.outfit(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: AppTheme.borderLight),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(LucideIcons.mail, size: 13, color: AppTheme.textMuted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  teacher.correo,
                  style: GoogleFonts.outfit(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (teacher.telefono.isNotEmpty) ...[
                const SizedBox(width: 8),
                Row(
                  children: [
                    const Icon(LucideIcons.phone, size: 13, color: AppTheme.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      teacher.telefono,
                      style: GoogleFonts.outfit(
                        color: AppTheme.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
              if (isAdmin) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(LucideIcons.trash2, color: AppTheme.error, size: 18),
                  tooltip: 'Eliminar',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: onConfirmDelete,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
