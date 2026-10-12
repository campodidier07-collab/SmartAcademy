import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../controllers/controlador_estudiantes.dart';
import '../controllers/controlador_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_header.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/custom_empty_state.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_dialog.dart';
import '../widgets/custom_snackbar.dart';
import '../utils/pdf_generator.dart';
import 'formulario_estudiantes.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentController>().loadStudents();
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
                      builder: (context) => const StudentFormScreen(),
                    ),
                  );
                },
                backgroundColor: AppTheme.primaryBlue,
                elevation: 4,
                icon: const Icon(LucideIcons.userPlus, color: Colors.white, size: 18),
                label: Text(
                  'Nuevo Alumno',
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
              title: 'Directorio de Estudiantes',
              subtitle: 'Gestiona la información y boletines de los alumnos',
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
              child: CustomSearchBar(
                hint: 'Buscar por documento, nombre o correo...',
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),
            Expanded(
              child: Consumer<StudentController>(
                builder: (context, controller, child) {
                  final isLoading = controller.isLoading;
                  final filteredStudents = controller.students.where((student) {
                    return student.nombre.toLowerCase().contains(_searchQuery) ||
                        student.apellido.toLowerCase().contains(_searchQuery) ||
                        student.documento.toLowerCase().contains(_searchQuery) ||
                        student.correo.toLowerCase().contains(_searchQuery);
                  }).toList();

                  if (!isLoading && filteredStudents.isEmpty) {
                    return CustomEmptyState(
                      icon: LucideIcons.users,
                      title: 'No se encontraron estudiantes',
                      description: _searchQuery.isEmpty
                          ? 'Comienza registrando alumnos con el botón de nuevo alumno.'
                          : 'No hay resultados que coincidan con "$_searchQuery".',
                      buttonText: _searchQuery.isNotEmpty ? 'Limpiar búsqueda' : null,
                      onButtonPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    );
                  }

                  final displayStudents = isLoading
                      ? List.generate(
                          5,
                          (index) => Student(
                            id: index,
                            nombre: 'Cargando Alumno',
                            apellido: '...',
                            documento: '1000000',
                            programa: 'Ingeniería',
                            correo: 'cargando@academia.com',
                            telefono: '3000000000',
                            semestre: 1,
                          ),
                        )
                      : filteredStudents;

                  return Skeletonizer(
                    enabled: isLoading,
                    child: ListView.separated(
                      itemCount: displayStudents.length,
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final student = displayStudents[index];
                        return _StudentCard(
                          student: student,
                          isAdmin: isAdmin,
                          onConfirmDelete: () => _confirmDelete(context, student),
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

  Future<void> _confirmDelete(BuildContext context, Student student) async {
    final confirm = await CustomDialog.show<bool>(
      context,
      title: 'Eliminar Estudiante',
      message:
          '¿Estás seguro de eliminar a ${student.nombre} ${student.apellido}? Esta acción no se puede deshacer.',
      primaryButtonText: 'Eliminar',
      onPrimaryPressed: () => Navigator.of(context).pop(true),
      secondaryButtonText: 'Cancelar',
      iconColor: AppTheme.error,
      icon: LucideIcons.trash2,
    );

    if (confirm == true && context.mounted) {
      await context.read<StudentController>().deleteStudent(student.id!);
      if (context.mounted) {
        CustomSnackbar.show(
          context,
          message: 'Estudiante eliminado exitosamente',
          type: SnackbarType.success,
        );
      }
    }
  }
}

class _StudentCard extends StatelessWidget {
  final Student student;
  final VoidCallback onConfirmDelete;
  final bool isAdmin;

  const _StudentCard({
    required this.student,
    required this.onConfirmDelete,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = student.estado == 'Activo';
    final statusColor = isActive ? AppTheme.success : AppTheme.error;

    return CustomCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      borderRadius: 14,
      onTap: isAdmin
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StudentFormScreen(student: student),
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
                  color: AppTheme.primaryBlue.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  student.nombre.isNotEmpty ? student.nombre[0].toUpperCase() : 'A',
                  style: GoogleFonts.outfit(
                    color: AppTheme.primaryBlue,
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
                            '${student.nombre} ${student.apellido}',
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
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            student.estado,
                            style: GoogleFonts.outfit(
                              color: statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Doc: ${student.documento} • ${student.programa} (Sem. ${student.semestre})',
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
                  student.correo,
                  style: GoogleFonts.outfit(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(LucideIcons.fileText, color: AppTheme.primaryBlue, size: 18),
                tooltip: 'Boletín de Notas (PDF)',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: () async {
                  CustomSnackbar.show(
                    context,
                    message: 'Generando boletín PDF...',
                    type: SnackbarType.info,
                  );
                  try {
                    final client = supa.Supabase.instance.client;
                    final gradeMaps =
                        await client.from('notas').select().eq('estudiante_id', student.id!);
                    final grades = gradeMaps.map((map) => Grade.fromMap(map)).toList();
                    final courseMaps = await client.from('cursos').select();
                    final courses = courseMaps.map((map) => Course.fromMap(map)).toList();
                    await PdfGenerator.generateStudentReport(student, grades, courses);
                  } catch (e) {
                    if (!context.mounted) return;
                    CustomSnackbar.show(
                      context,
                      message: 'Error al generar PDF: $e',
                      type: SnackbarType.error,
                    );
                  }
                },
              ),
              if (isAdmin) ...[
                const SizedBox(width: 4),
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
