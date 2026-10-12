import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../controllers/controlador_asistencias.dart';
import '../controllers/controlador_cursos.dart';
import '../controllers/controlador_estudiantes.dart';
import '../controllers/controlador_auth.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_header.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_dropdown.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/custom_empty_state.dart';
import 'pantalla_escaner.dart';

class AttendanceScreen extends StatefulWidget {
  final int? cursoId;
  const AttendanceScreen({super.key, this.cursoId});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int? _selectedCourseId;
  late String _selectedDate;
  final Map<int, String> _attendanceMap = {}; 
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedCourseId = widget.cursoId;
    _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _dateController.text = _selectedDate;
    
    Future.microtask(() {
      if (!mounted) return;
      context.read<CourseController>().loadCourses();
      context.read<StudentController>().loadStudents();
      context.read<AttendanceController>().loadAttendances(_selectedCourseId);
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _onCourseChanged(int? courseId) {
    setState(() {
      _selectedCourseId = courseId;
      _attendanceMap.clear();
    });
    context.read<AttendanceController>().loadAttendances(courseId);
  }

  void _saveAttendance() async {
    if (_selectedCourseId == null) {
      CustomSnackbar.show(context, message: 'Selecciona un curso primero', type: SnackbarType.warning);
      return;
    }

    if (_attendanceMap.isEmpty) {
      CustomSnackbar.show(context, message: 'No hay asistencias marcadas', type: SnackbarType.warning);
      return;
    }

    final controller = context.read<AttendanceController>();
    for (var entry in _attendanceMap.entries) {
      final attendance = Attendance(
        cursoId: _selectedCourseId!,
        estudianteId: entry.key,
        fecha: _selectedDate,
        estado: entry.value,
      );
      await controller.saveAttendance(attendance);
    }
    
    if (mounted) {
      CustomSnackbar.show(context, message: 'Asistencia guardada exitosamente', type: SnackbarType.success);
      controller.loadAttendances(_selectedCourseId);
    }
  }

  String _formatAttendanceDateTime(String rawDate) {
    try {
      if (rawDate.contains('T')) {
        final dt = DateTime.parse(rawDate).toLocal();
        return DateFormat('dd MMM yyyy • hh:mm a').format(dt);
      } else if (rawDate.contains('-')) {
        final dt = DateTime.parse(rawDate);
        return DateFormat('dd MMM yyyy').format(dt);
      }
      return rawDate;
    } catch (_) {
      return rawDate;
    }
  }

  bool _isScannedAttendance(String rawDate) {
    return rawDate.contains('T') && rawDate.contains(':');
  }

  @override
  Widget build(BuildContext context) {
    final userRole = context.watch<AuthController>().currentUser?.rol;
    final canScan = userRole == 'Profesor' || userRole == 'Administrador';

    return Scaffold(
      backgroundColor: AppTheme.backgroundMain,
      floatingActionButton: canScan ? FloatingActionButton.extended(
        onPressed: () async {
          final attCtrl = context.read<AttendanceController>();
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AttendanceScannerScreen(cursoId: _selectedCourseId)),
          );
          if (mounted) {
            attCtrl.loadAttendances(_selectedCourseId);
          }
        },
        backgroundColor: AppTheme.primaryBlue,
        elevation: 4,
        icon: const Icon(LucideIcons.qrCode, color: Colors.white, size: 20),
        label: Text(
          'Escanear QR',
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ) : null,
      body: SafeArea(
        child: Column(
          children: [
            CustomHeader(
              title: 'Control de Asistencias',
              subtitle: 'Historial y registro diario de asistencia',
              showBackButton: true,
              trailing: canScan
                  ? IconButton(
                      icon: const Icon(LucideIcons.refreshCw, color: AppTheme.textMuted, size: 20),
                      tooltip: 'Actualizar lista',
                      onPressed: () {
                        context.read<AttendanceController>().loadAttendances(_selectedCourseId);
                        CustomSnackbar.show(context, message: 'Asistencias actualizadas', type: SnackbarType.info);
                      },
                    )
                  : null,
            ),

            // Selector de Pestañas (Tabs)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: AppTheme.primaryBlue,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: AppTheme.textMuted,
                  labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
                  unselectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w500, fontSize: 13),
                  tabs: const [
                    Tab(
                      iconMargin: EdgeInsets.zero,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.history, size: 15),
                          SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Historial',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Tab(
                      iconMargin: EdgeInsets.zero,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.clipboardCheck, size: 15),
                          SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Pase de Lista',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Contenido de las pestañas
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildHistoryTab(),
                  _buildManualRegisterTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 1: HISTORIAL DE ASISTENCIAS (LISTA POR FECHAS Y HORAS)
  // ==========================================
  Widget _buildHistoryTab() {
    return Consumer3<AttendanceController, CourseController, StudentController>(
      builder: (context, attendanceCtrl, courseCtrl, studentCtrl, child) {
        if (attendanceCtrl.isLoading) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue));
        }

        final attendances = attendanceCtrl.attendances;

        return Column(
          children: [
            // Filtro por curso en el historial
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: CustomCard(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                                'Todos los cursos (${attendances.length} registros)',
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
                          onChanged: _onCourseChanged,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Resumen de conteos
            if (attendances.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: _buildAttendanceLiveStats(attendances),
              ),

            // Lista cronológica
            Expanded(
              child: attendances.isEmpty
                  ? const CustomEmptyState(
                      icon: LucideIcons.calendarOff,
                      title: 'Sin Asistencias Registradas',
                      description: 'Escanea el carnet de los estudiantes o realiza un pase de lista para ver aquí el registro con fecha y hora.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 90),
                      itemCount: attendances.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final attendance = attendances[index];

                        // Buscar estudiante
                        Student? student;
                        try {
                          student = studentCtrl.students.firstWhere((s) => s.id == attendance.estudianteId);
                        } catch (_) {
                          student = null;
                        }

                        // Buscar curso
                        Course? course;
                        try {
                          course = courseCtrl.courses.firstWhere((c) => c.id == attendance.cursoId);
                        } catch (_) {
                          course = null;
                        }

                        final studentName = student != null 
                            ? '${student.nombre} ${student.apellido}' 
                            : 'Estudiante #${attendance.estudianteId}';

                        final studentDoc = student?.documento ?? 'Doc: ${attendance.estudianteId}';
                        final courseName = course != null ? '${course.codigo} - ${course.nombre}' : 'Curso #${attendance.cursoId}';
                        final isScanned = _isScannedAttendance(attendance.fecha);
                        final formattedDate = _formatAttendanceDateTime(attendance.fecha);

                        return CustomCard(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              // Avatar con inicial
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      _getStatusColor(attendance.estado).withValues(alpha: 0.25),
                                      AppTheme.primaryBlue.withValues(alpha: 0.15),
                                    ],
                                  ),
                                  border: Border.all(
                                    color: _getStatusColor(attendance.estado).withValues(alpha: 0.4),
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  studentName.isNotEmpty ? studentName[0].toUpperCase() : 'E',
                                  style: GoogleFonts.outfit(
                                    color: _getStatusColor(attendance.estado),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),

                              // Datos del estudiante y fecha
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      studentName,
                                      style: GoogleFonts.outfit(
                                        color: AppTheme.textPrimary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Text(
                                          courseName,
                                          style: GoogleFonts.outfit(
                                            color: AppTheme.primaryBlue,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(width: 6),
                                        Text('•', style: TextStyle(color: AppTheme.textMuted, fontSize: 10)),
                                        const SizedBox(width: 6),
                                        Text(
                                          studentDoc,
                                          style: GoogleFonts.outfit(
                                            color: AppTheme.textMuted,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(
                                          isScanned ? LucideIcons.qrCode : LucideIcons.clipboardCheck,
                                          size: 13,
                                          color: isScanned ? AppTheme.secondaryPurple : AppTheme.textMuted,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          formattedDate,
                                          style: GoogleFonts.outfit(
                                            color: AppTheme.textMuted,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Badge de estado
                              _buildStatusBadge(attendance.estado),
                            ],
                          ),
                        ).animate().fade(delay: (index * 30).ms).slideX(begin: 0.03);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  // ==========================================
  // TAB 2: PASE DE ASISTENCIA MANUAL POR CURSO
  // ==========================================
  Widget _buildManualRegisterTab() {
    return Column(
      children: [
        // Filtros Superiores
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: CustomCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Consumer<CourseController>(
                  builder: (context, controller, child) {
                    if (controller.isLoading) {
                      return const LinearProgressIndicator(
                        color: AppTheme.primaryBlue,
                        backgroundColor: AppTheme.surfaceCard,
                      );
                    }
                    return CustomDropdown<int>(
                      label: 'Curso Asignado',
                      value: _selectedCourseId,
                      items: controller.courses.map((c) {
                        return DropdownMenuItem(
                          value: c.id, 
                          child: Text(
                            '${c.codigo} - ${c.nombre}',
                            style: GoogleFonts.outfit(color: AppTheme.textPrimary, fontSize: 14),
                          ),
                        );
                      }).toList(),
                      onChanged: _onCourseChanged,
                    );
                  },
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.parse(_selectedDate),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: AppTheme.primaryBlue,
                              onPrimary: Colors.white,
                              surface: AppTheme.surfaceCard,
                              onSurface: AppTheme.textPrimary,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (date != null) {
                      setState(() {
                        _selectedDate = DateFormat('yyyy-MM-dd').format(date);
                        _dateController.text = _selectedDate;
                        _attendanceMap.clear();
                      });
                    }
                  },
                  child: AbsorbPointer(
                    child: CustomTextField(
                      controller: _dateController,
                      label: 'Fecha de la Sesión',
                      icon: LucideIcons.calendar,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Lista de Estudiantes para pase de lista
        Expanded(
          child: _selectedCourseId == null
              ? const CustomEmptyState(
                  icon: LucideIcons.listChecks,
                  title: 'Selecciona un Curso',
                  description: 'Elige un curso en el panel superior para desplegar la lista de estudiantes.',
                )
              : Consumer2<StudentController, AttendanceController>(
                  builder: (context, studentCtrl, attendanceCtrl, child) {
                    if (studentCtrl.isLoading) {
                      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue));
                    }
                    
                    final students = studentCtrl.students;
                    
                    if (students.isEmpty) {
                      return const CustomEmptyState(
                        icon: LucideIcons.users,
                        title: 'No hay estudiantes',
                        description: 'No hay estudiantes registrados en el sistema.',
                      );
                    }

                    // Auto-precargar asistencias existentes para la fecha seleccionada
                    for (var student in students) {
                      if (!_attendanceMap.containsKey(student.id)) {
                        // Buscar si ya tiene asistencia hoy en Supabase
                        final match = attendanceCtrl.attendances.where((a) => 
                          a.estudianteId == student.id && 
                          a.cursoId == _selectedCourseId && 
                          a.fecha.startsWith(_selectedDate)
                        );
                        if (match.isNotEmpty) {
                          _attendanceMap[student.id!] = match.first.estado;
                        } else {
                          _attendanceMap[student.id!] = 'Ausente';
                        }
                      }
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      itemCount: students.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final student = students[index];
                        final currentStatus = _attendanceMap[student.id] ?? 'Ausente';

                        return CustomCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          AppTheme.primaryBlue.withValues(alpha: 0.25),
                                          AppTheme.secondaryPurple.withValues(alpha: 0.2),
                                        ],
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      student.nombre.isNotEmpty ? student.nombre[0].toUpperCase() : '?',
                                      style: GoogleFonts.outfit(
                                        color: AppTheme.primaryBlue,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${student.nombre} ${student.apellido}', 
                                          style: GoogleFonts.outfit(
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.textPrimary,
                                            fontSize: 15,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          'Doc: ${student.documento}',
                                          style: GoogleFonts.outfit(
                                            color: AppTheme.textMuted,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              _buildStatusSelector(student.id!, currentStatus),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
        ),

        // Botón Guardar Asistencia
        if (_selectedCourseId != null)
          Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLowest.withValues(alpha: 0.95),
              border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
            ),
            child: CustomButton(
              text: 'Guardar Sesión de Asistencia',
              icon: LucideIcons.save,
              onPressed: _saveAttendance,
            ),
          ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Presente': return AppTheme.success;
      case 'Ausente': return AppTheme.error;
      case 'Retardo':
      case 'Tarde': return AppTheme.warning;
      default: return AppTheme.textMuted;
    }
  }

  Widget _buildStatusBadge(String status) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6, height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            status,
            style: GoogleFonts.outfit(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceLiveStats(List<Attendance> attendances) {
    int presentes = 0;
    int ausentes = 0;
    int retardos = 0;

    for (var a in attendances) {
      if (a.estado == 'Presente') {
        presentes++;
      } else if (a.estado == 'Ausente') {
        ausentes++;
      } else {
        retardos++;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildCountBadge('Total', attendances.length, AppTheme.primaryBlue),
          Container(width: 1, height: 20, color: Colors.white.withValues(alpha: 0.08)),
          _buildCountBadge('Presentes', presentes, AppTheme.success),
          Container(width: 1, height: 20, color: Colors.white.withValues(alpha: 0.08)),
          _buildCountBadge('Ausentes', ausentes, AppTheme.error),
          Container(width: 1, height: 20, color: Colors.white.withValues(alpha: 0.08)),
          _buildCountBadge('Retardos', retardos, AppTheme.warning),
        ],
      ),
    );
  }

  Widget _buildCountBadge(String label, int count, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7, height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          '$label: ',
          style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.textMuted),
        ),
        Text(
          '$count',
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSelector(int studentId, String currentStatus) {
    return SegmentedButton<String>(
      showSelectedIcon: false,
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            if (currentStatus == 'Presente') return AppTheme.success.withValues(alpha: 0.22);
            if (currentStatus == 'Ausente') return AppTheme.error.withValues(alpha: 0.22);
            return AppTheme.warning.withValues(alpha: 0.22);
          }
          return AppTheme.surfaceCardElevated;
        }),
        foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            if (currentStatus == 'Presente') return AppTheme.success;
            if (currentStatus == 'Ausente') return AppTheme.error;
            return AppTheme.warning;
          }
          return AppTheme.textMuted;
        }),
        side: WidgetStateProperty.resolveWith<BorderSide>((states) {
          if (states.contains(WidgetState.selected)) {
            Color borderCol = AppTheme.success;
            if (currentStatus == 'Ausente') borderCol = AppTheme.error;
            if (currentStatus == 'Retardo') borderCol = AppTheme.warning;
            return BorderSide(color: borderCol.withValues(alpha: 0.4), width: 1);
          }
          return BorderSide(color: Colors.white.withValues(alpha: 0.06), width: 1);
        }),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      segments: [
        ButtonSegment(
          value: 'Presente',
          icon: const Icon(LucideIcons.check, size: 14),
          label: Text('Presente', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600)),
        ),
        ButtonSegment(
          value: 'Ausente',
          icon: const Icon(LucideIcons.x, size: 14),
          label: Text('Ausente', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600)),
        ),
        ButtonSegment(
          value: 'Retardo',
          icon: const Icon(LucideIcons.clock, size: 14),
          label: Text('Retardo', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600)),
        ),
      ],
      selected: {currentStatus},
      onSelectionChanged: (Set<String> newSelection) {
        setState(() {
          _attendanceMap[studentId] = newSelection.first;
        });
      },
    );
  }
}
