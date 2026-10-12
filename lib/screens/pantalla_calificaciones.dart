import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../controllers/controlador_calificaciones.dart';
import '../controllers/controlador_auth.dart';
import '../controllers/controlador_estudiantes.dart';
import '../controllers/controlador_cursos.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_header.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_empty_state.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/custom_dialog.dart';
import '../widgets/custom_snackbar.dart';
import '../utils/pdf_generator.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

class GradesScreen extends StatefulWidget {
  final int? cursoId;
  const GradesScreen({super.key, this.cursoId});

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  Course? _currentCourse;
  int? _selectedCourseId;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedCourseId = widget.cursoId;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<CourseController>().loadCourses();
      context.read<StudentController>().loadStudents();
      context.read<GradeController>().loadGrades(_selectedCourseId);
      if (_selectedCourseId != null) {
        final client = supa.Supabase.instance.client;
        final courseMaps = await client.from('cursos').select().eq('id', _selectedCourseId!);
        if (courseMaps.isNotEmpty && mounted) {
          setState(() {
            _currentCourse = Course.fromMap(courseMaps.first);
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userRole = context.read<AuthController>().currentUser?.rol;
    final canEdit = userRole == 'Profesor' || userRole == 'Administrador';
    final courseCtrl = context.watch<CourseController>();
    final studentCtrl = context.watch<StudentController>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundMain,
      body: SafeArea(
        child: Column(
          children: [
            CustomHeader(
              title: _currentCourse != null ? _currentCourse!.nombre : 'Control de Calificaciones',
              subtitle: 'Evaluaciones y notas definitivas por estudiante',
              showBackButton: true,
              trailing: IconButton(
                icon: const Icon(LucideIcons.refreshCw, color: AppTheme.textMuted, size: 20),
                tooltip: 'Actualizar notas',
                onPressed: () {
                  context.read<GradeController>().loadGrades(_selectedCourseId);
                  context.read<StudentController>().loadStudents();
                  CustomSnackbar.show(context, message: 'Notas actualizadas', type: SnackbarType.info);
                },
              ),
            ),
            // Filtro por curso
            if (courseCtrl.courses.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: CustomCard(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.filter, size: 18, color: AppTheme.primaryBlue),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int?>(
                            value: _selectedCourseId,
                            isExpanded: true,
                            dropdownColor: AppTheme.surfaceCardElevated,
                            borderRadius: BorderRadius.circular(14),
                            hint: Text(
                              'Todos los cursos',
                              style: GoogleFonts.outfit(color: AppTheme.textPrimary, fontSize: 14),
                            ),
                            items: [
                              DropdownMenuItem<int?>(
                                value: null,
                                child: Text(
                                  'Todos los cursos',
                                  style: GoogleFonts.outfit(color: AppTheme.textPrimary, fontSize: 14),
                                ),
                              ),
                              ...courseCtrl.courses.map((c) => DropdownMenuItem<int?>(
                                value: c.id,
                                child: Text(
                                  '${c.codigo} - ${c.nombre}',
                                  style: GoogleFonts.outfit(color: AppTheme.textPrimary, fontSize: 14),
                                ),
                              )),
                            ],
                            onChanged: (newId) {
                              setState(() {
                                _selectedCourseId = newId;
                                if (newId != null) {
                                  try {
                                    _currentCourse = courseCtrl.courses.firstWhere((c) => c.id == newId);
                                  } catch (_) {
                                    _currentCourse = null;
                                  }
                                } else {
                                  _currentCourse = null;
                                }
                              });
                              context.read<GradeController>().loadGrades(newId);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Buscador de estudiante
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: CustomSearchBar(
                controller: _searchController,
                hint: 'Buscar estudiante por nombre o documento...',
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.trim().toLowerCase();
                  });
                },
              ),
            ),

            Expanded(
              child: Consumer<GradeController>(
                builder: (context, controller, child) {
                  final isLoading = controller.isLoading;

                  // Filtrar notas por búsqueda si corresponde
                  final allGrades = controller.grades;
                  final filteredGrades = allGrades.where((g) {
                    if (_searchQuery.isEmpty) return true;
                    Student? student;
                    try {
                      student = studentCtrl.students.firstWhere((s) => s.id == g.estudianteId);
                    } catch (_) {
                      student = null;
                    }
                    final sName = student != null ? '${student.nombre} ${student.apellido}'.toLowerCase() : '';
                    final sDoc = student?.documento.toLowerCase() ?? '';
                    return sName.contains(_searchQuery) || sDoc.contains(_searchQuery);
                  }).toList();

                  if (!isLoading && filteredGrades.isEmpty) {
                    return CustomEmptyState(
                      icon: LucideIcons.fileCheck2,
                      title: _searchQuery.isEmpty ? 'No hay notas registradas' : 'Sin resultados',
                      description: _searchQuery.isEmpty
                          ? 'Las calificaciones asignadas a los estudiantes aparecerán listadas aquí.'
                          : 'No se encontraron calificaciones que coincidan con "$_searchQuery".',
                      buttonText: canEdit ? 'Registrar Nota' : null,
                      onButtonPressed: canEdit ? () => _showGradeBottomSheet(context, null) : null,
                    );
                  }

                  final displayGrades = isLoading
                      ? List.generate(
                          3,
                          (index) => Grade(
                            id: index,
                            estudianteId: 1,
                            cursoId: 1,
                            parcial1: 0,
                            parcial2: 0,
                            parcial3: 0,
                            trabajoFinal: 0,
                            definitiva: 0,
                          ),
                        )
                      : filteredGrades;

                  return RefreshIndicator(
                    onRefresh: () async {
                      final gCtrl = context.read<GradeController>();
                      final sCtrl = context.read<StudentController>();
                      await gCtrl.loadGrades(_selectedCourseId);
                      await sCtrl.loadStudents();
                    },
                    child: Skeletonizer(
                      enabled: isLoading,
                      child: ListView.separated(
                        itemCount: displayGrades.length,
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final grade = displayGrades[index];
                          final definitiva = grade.definitiva ?? 0;
                          final passed = definitiva >= 3.0;

                          Student? student;
                          try {
                            student = studentCtrl.students.firstWhere((s) => s.id == grade.estudianteId);
                          } catch (_) {
                            student = null;
                          }

                          Course? course;
                          try {
                            course = courseCtrl.courses.firstWhere((c) => c.id == grade.cursoId);
                          } catch (_) {
                            course = null;
                          }

                          final courseName = course != null ? '${course.codigo} - ${course.nombre}' : 'Curso #${grade.cursoId}';
                          final studentName = student != null ? '${student.nombre} ${student.apellido}' : 'Estudiante #${grade.estudianteId}';
                          final initials = (student != null && student.nombre.isNotEmpty)
                              ? '${student.nombre[0]}${student.apellido.isNotEmpty ? student.apellido[0] : ''}'.toUpperCase()
                              : 'E';

                          return CustomCard(
                            padding: const EdgeInsets.all(16),
                            borderRadius: 16,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryBlue.withValues(alpha: 0.14),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.25)),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        initials,
                                        style: GoogleFonts.outfit(
                                          color: AppTheme.primaryBlue,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            studentName,
                                            style: GoogleFonts.outfit(
                                              color: AppTheme.textMain,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 3),
                                          Wrap(
                                            crossAxisAlignment: WrapCrossAlignment.center,
                                            spacing: 6,
                                            runSpacing: 4,
                                            children: [
                                              Text(
                                                'ID: ${student?.documento ?? grade.estudianteId}',
                                                style: GoogleFonts.outfit(
                                                  color: AppTheme.textSecondary,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              Text('•', style: TextStyle(color: AppTheme.textMuted, fontSize: 10)),
                                              Text(
                                                courseName,
                                                style: GoogleFonts.outfit(
                                                  color: AppTheme.primaryBlue,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1.5),
                                                decoration: BoxDecoration(
                                                  color: (passed ? AppTheme.success : AppTheme.error).withValues(alpha: 0.14),
                                                  borderRadius: BorderRadius.circular(6),
                                                  border: Border.all(
                                                    color: (passed ? AppTheme.success : AppTheme.error).withValues(alpha: 0.35),
                                                  ),
                                                ),
                                                child: Text(
                                                  passed ? 'Aprobado' : 'Reprobado',
                                                  style: GoogleFonts.outfit(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w700,
                                                    color: passed ? AppTheme.success : AppTheme.error,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (canEdit) ...[
                                      IconButton(
                                        icon: const Icon(LucideIcons.pencil, color: AppTheme.primaryBlue, size: 18),
                                        tooltip: 'Editar Nota',
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                        onPressed: () => _showGradeBottomSheet(context, grade),
                                      ),
                                      IconButton(
                                        icon: const Icon(LucideIcons.trash2, color: AppTheme.error, size: 18),
                                        tooltip: 'Eliminar Nota',
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                        onPressed: () async {
                                          final confirm = await CustomDialog.show<bool>(
                                            context,
                                            title: 'Eliminar Calificación',
                                            message: '¿Estás seguro de eliminar las calificaciones registradas para $studentName?',
                                            primaryButtonText: 'Eliminar',
                                            secondaryButtonText: 'Cancelar',
                                            icon: LucideIcons.trash2,
                                            iconColor: AppTheme.error,
                                            onPrimaryPressed: () => Navigator.of(context).pop(true),
                                          );
                                          if (confirm == true && context.mounted) {
                                            final ok = await context.read<GradeController>().deleteGrade(grade.id!);
                                            if (ok && context.mounted) {
                                              CustomSnackbar.show(context, message: 'Calificación eliminada correctamente', type: SnackbarType.info);
                                            }
                                          }
                                        },
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: AppTheme.cardElevated,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppTheme.borderLight),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      _buildCompactGradeInfo('P1 (20%)', grade.parcial1),
                                      _buildCompactGradeInfo('P2 (20%)', grade.parcial2),
                                      _buildCompactGradeInfo('P3 (20%)', grade.parcial3),
                                      _buildCompactGradeInfo('TF (40%)', grade.trabajoFinal),
                                      Container(
                                        width: 1,
                                        height: 32,
                                        color: AppTheme.borderLight,
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            'Definitiva',
                                            style: GoogleFonts.outfit(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.textSecondary,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            grade.definitiva?.toStringAsFixed(2) ?? '-',
                                            style: GoogleFonts.outfit(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w800,
                                              color: passed ? AppTheme.success : AppTheme.error,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fade(delay: (index * 40).ms).slideX(begin: 0.03);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                children: [
                  if (canEdit) ...[
                    CustomButton(
                      text: 'Registrar Nueva Nota',
                      icon: LucideIcons.plus,
                      onPressed: () => _showGradeBottomSheet(context, null),
                    ),
                    const SizedBox(height: 10),
                  ],
                  CustomButton(
                    text: 'Generar Reporte PDF',
                    icon: LucideIcons.fileText,
                    style: CustomButtonStyle.secondary,
                    onPressed: () async {
                      final courses = context.read<CourseController>().courses;
                      final reportCourse = _currentCourse ?? (courses.isNotEmpty ? courses.first : null);
                      if (reportCourse == null) {
                        CustomSnackbar.show(context, message: 'Selecciona o crea un curso primero', type: SnackbarType.warning);
                        return;
                      }
                      final students = context.read<StudentController>().students;
                      final gradesList = context.read<GradeController>().grades;
                      final gradesMap = {for (var g in gradesList) g.estudianteId: g};

                      CustomSnackbar.show(
                        context,
                        message: 'Generando reporte de curso...',
                        type: SnackbarType.info,
                      );
                      await PdfGenerator.generateCourseReport(
                        reportCourse,
                        students,
                        gradesMap,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactGradeInfo(String label, double? value) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppTheme.textMuted,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value?.toStringAsFixed(1) ?? '-',
          style: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppTheme.textMain,
          ),
        ),
      ],
    );
  }

  void _showGradeBottomSheet(BuildContext context, Grade? existingGrade) {
    final effectiveCursoId = existingGrade?.cursoId ??
        _selectedCourseId ??
        (context.read<CourseController>().courses.isNotEmpty
            ? context.read<CourseController>().courses.first.id!
            : 1);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _GradeFormSheet(
        cursoId: effectiveCursoId,
        existingGrade: existingGrade,
        onGradeSaved: () {
          context.read<GradeController>().loadGrades(_selectedCourseId);
        },
      ),
    );
  }
}

class _GradeFormSheet extends StatefulWidget {
  final int cursoId;
  final Grade? existingGrade;
  final VoidCallback? onGradeSaved;

  const _GradeFormSheet({
    required this.cursoId,
    this.existingGrade,
    this.onGradeSaved,
  });

  @override
  State<_GradeFormSheet> createState() => _GradeFormSheetState();
}

class _GradeFormSheetState extends State<_GradeFormSheet> {
  late int selectedCursoId;
  int? selectedEstudianteId;
  late TextEditingController p1Controller;
  late TextEditingController p2Controller;
  late TextEditingController p3Controller;
  late TextEditingController tfController;
  bool _isSaving = false;
  double _previewDefinitiva = 0.0;

  @override
  void initState() {
    super.initState();
    selectedCursoId = widget.existingGrade?.cursoId ?? widget.cursoId;
    selectedEstudianteId = widget.existingGrade?.estudianteId;
    p1Controller = TextEditingController(text: widget.existingGrade?.parcial1?.toString() ?? '');
    p2Controller = TextEditingController(text: widget.existingGrade?.parcial2?.toString() ?? '');
    p3Controller = TextEditingController(text: widget.existingGrade?.parcial3?.toString() ?? '');
    tfController = TextEditingController(text: widget.existingGrade?.trabajoFinal?.toString() ?? '');

    p1Controller.addListener(_calculatePreview);
    p2Controller.addListener(_calculatePreview);
    p3Controller.addListener(_calculatePreview);
    tfController.addListener(_calculatePreview);
    _calculatePreview();
  }

  void _calculatePreview() {
    final p1 = double.tryParse(p1Controller.text);
    final p2 = double.tryParse(p2Controller.text);
    final p3 = double.tryParse(p3Controller.text);
    final tf = double.tryParse(tfController.text);

    double sum = 0;
    int count = 0;
    if (p1 != null) { sum += p1; count++; }
    if (p2 != null) { sum += p2; count++; }
    if (p3 != null) { sum += p3; count++; }
    if (tf != null) { sum += tf; count++; }

    setState(() {
      _previewDefinitiva = count > 0 ? (sum / count) : 0.0;
    });
  }

  @override
  void dispose() {
    p1Controller.dispose();
    p2Controller.dispose();
    p3Controller.dispose();
    tfController.dispose();
    super.dispose();
  }

  void _onStudentSelected(Student selection) {
    setState(() {
      selectedEstudianteId = selection.id;
    });

    // Si el estudiante ya tiene notas registradas para este curso, autocompletar los campos
    final existing = context.read<GradeController>().grades.where(
      (g) => g.estudianteId == selection.id && g.cursoId == selectedCursoId,
    ).firstOrNull;

    if (existing != null) {
      if (existing.parcial1 != null) p1Controller.text = existing.parcial1.toString();
      if (existing.parcial2 != null) p2Controller.text = existing.parcial2.toString();
      if (existing.parcial3 != null) p3Controller.text = existing.parcial3.toString();
      if (existing.trabajoFinal != null) tfController.text = existing.trabajoFinal.toString();
      _calculatePreview();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final courses = context.watch<CourseController>().courses;
    final isPassed = _previewDefinitiva >= 3.0;

    return Container(
      padding: EdgeInsets.only(
        bottom: bottomInset > 0 ? bottomInset + 20 : 24,
        left: 20,
        right: 20,
        top: 20,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.cardBase,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppTheme.borderLight)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppTheme.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              widget.existingGrade == null ? 'Registrar Calificación' : 'Editar Calificación',
              style: GoogleFonts.outfit(
                color: AppTheme.textMain,
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),

            // Selector de curso si hay múltiples y es un nuevo registro
            if (widget.existingGrade == null && courses.isNotEmpty) ...[
              CustomCard(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                child: Row(
                  children: [
                    const Icon(LucideIcons.bookOpen, size: 18, color: AppTheme.primaryBlue),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: courses.any((c) => c.id == selectedCursoId)
                              ? selectedCursoId
                              : courses.first.id,
                          isExpanded: true,
                          dropdownColor: AppTheme.surfaceCardElevated,
                          borderRadius: BorderRadius.circular(14),
                          items: courses.map((c) => DropdownMenuItem<int>(
                            value: c.id,
                            child: Text(
                              '${c.codigo} - ${c.nombre}',
                              style: GoogleFonts.outfit(color: AppTheme.textPrimary, fontSize: 14),
                            ),
                          )).toList(),
                          onChanged: (newId) {
                            if (newId != null) {
                              setState(() {
                                selectedCursoId = newId;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Autocomplete de Estudiante
            if (widget.existingGrade == null)
              Consumer<StudentController>(
                builder: (context, studentController, child) {
                  if (studentController.isLoading) {
                    return const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue));
                  }
                  return Autocomplete<Student>(
                    displayStringForOption: (Student option) =>
                        '${option.nombre} ${option.apellido} (${option.documento})',
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<Student>.empty();
                      }
                      final query = textEditingValue.text.toLowerCase();
                      return studentController.students.where((student) {
                        return student.nombre.toLowerCase().contains(query) ||
                            student.apellido.toLowerCase().contains(query) ||
                            student.documento.toLowerCase().contains(query);
                      });
                    },
                    onSelected: _onStudentSelected,
                    fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                      return CustomTextField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        label: 'Buscar Estudiante',
                        hint: 'Nombre o documento...',
                        icon: LucideIcons.search,
                      );
                    },
                  );
                },
              ),
            if (widget.existingGrade == null) const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: p1Controller,
                    label: 'Parcial 1 (0.0 - 5.0)',
                    hint: '0.0',
                    icon: LucideIcons.fileDigit,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    controller: p2Controller,
                    label: 'Parcial 2 (0.0 - 5.0)',
                    hint: '0.0',
                    icon: LucideIcons.fileDigit,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: p3Controller,
                    label: 'Parcial 3 (0.0 - 5.0)',
                    hint: '0.0',
                    icon: LucideIcons.fileDigit,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    controller: tfController,
                    label: 'Trabajo Final (0.0 - 5.0)',
                    hint: '0.0',
                    icon: LucideIcons.fileCheck2,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Previsualización en tiempo real de la definitiva
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: (isPassed ? AppTheme.success : AppTheme.error).withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: (isPassed ? AppTheme.success : AppTheme.error).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isPassed ? LucideIcons.checkCircle2 : LucideIcons.alertCircle,
                    color: isPassed ? AppTheme.success : AppTheme.error,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Promedio Calculado',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          isPassed ? 'Aprobado (≥ 3.0)' : 'Reprobado (< 3.0)',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: isPassed ? AppTheme.success : AppTheme.error,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _previewDefinitiva.toStringAsFixed(2),
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: isPassed ? AppTheme.success : AppTheme.error,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            CustomButton(
              text: _isSaving ? 'Guardando...' : 'Guardar Calificación',
              icon: _isSaving ? null : LucideIcons.save,
              isLoading: _isSaving,
              onPressed: () => _submitForm(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_isSaving) return;
    if (selectedEstudianteId == null) {
      CustomSnackbar.show(
        context,
        message: 'Por favor, selecciona un estudiante',
        type: SnackbarType.warning,
      );
      return;
    }

    final p1 = double.tryParse(p1Controller.text);
    final p2 = double.tryParse(p2Controller.text);
    final p3 = double.tryParse(p3Controller.text);
    final tf = double.tryParse(tfController.text);

    bool isValid(double? val) => val == null || (val >= 0.0 && val <= 5.0);

    if (!isValid(p1) || !isValid(p2) || !isValid(p3) || !isValid(tf)) {
      CustomSnackbar.show(
        context,
        message: 'Las notas deben estar comprendidas entre 0.0 y 5.0',
        type: SnackbarType.error,
      );
      return;
    }

    setState(() => _isSaving = true);

    final newGrade = Grade(
      id: widget.existingGrade?.id,
      cursoId: selectedCursoId,
      estudianteId: selectedEstudianteId!,
      parcial1: p1,
      parcial2: p2,
      parcial3: p3,
      trabajoFinal: tf,
    );

    final gradeCtrl = context.read<GradeController>();
    final ok = await gradeCtrl.saveGrade(newGrade);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (ok) {
      widget.onGradeSaved?.call();
      Navigator.of(context).pop();
      CustomSnackbar.show(
        context,
        message: 'Calificaciones registradas exitosamente',
        type: SnackbarType.success,
      );
    } else {
      CustomSnackbar.show(
        context,
        message: 'Error al registrar las calificaciones. Intenta nuevamente.',
        type: SnackbarType.error,
      );
    }
  }
}
