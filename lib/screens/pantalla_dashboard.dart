import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:intl/intl.dart';
import '../controllers/controlador_auth.dart';
import '../controllers/controlador_dashboard.dart';
import '../controllers/controlador_asistencias.dart';
import '../controllers/controlador_calificaciones.dart';
import '../controllers/controlador_cursos.dart';
import '../controllers/controlador_estudiantes.dart';
import '../models/models.dart';
import 'pantalla_login.dart';
import 'pantalla_estudiantes.dart';
import 'pantalla_profesores.dart';
import 'pantalla_cursos.dart';
import 'pantalla_perfil.dart';
import 'formulario_estudiantes.dart';
import 'pantalla_horarios.dart';
import 'pantalla_escaner.dart';
import 'pantalla_asistencias.dart';
import 'pantalla_calificaciones.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_header.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthController>().currentUser;
      context.read<DashboardController>().loadDashboardStats(user);
    });
  }

  Widget _getScreenForIndex(int index, String? rol) {
    if (rol == 'Administrador') {
      switch (index) {
        case 0:
          return const _DashboardContent();
        case 1:
          return const StudentsScreen();
        case 2:
          return const TeachersScreen();
        case 3:
          return const CoursesScreen();
        case 4:
          return const ProfileScreen();
        default:
          return const _DashboardContent();
      }
    } else if (rol == 'Profesor') {
      switch (index) {
        case 0:
          return const _TeacherDashboardContent();
        case 1:
          return const CoursesScreen();
        case 2:
          return const StudentsScreen();
        case 3:
          return const SchedulesScreen();
        case 4:
          return const ProfileScreen();
        default:
          return const _TeacherDashboardContent();
      }
    } else {
      switch (index) {
        case 0:
          return const _StudentDashboardContent();
        case 1:
          return const CoursesScreen();
        case 2:
          return const SchedulesScreen();
        case 3:
          return const ProfileScreen();
        default:
          return const _StudentDashboardContent();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().currentUser;
    final isDesktop = MediaQuery.of(context).size.width > 800;

    final adminNav = [
      CustomBottomNavItem(icon: LucideIcons.layoutDashboard, label: 'Inicio'),
      CustomBottomNavItem(icon: LucideIcons.users, label: 'Alumnos'),
      CustomBottomNavItem(icon: LucideIcons.graduationCap, label: 'Profes'),
      CustomBottomNavItem(icon: LucideIcons.bookOpen, label: 'Cursos'),
      CustomBottomNavItem(icon: LucideIcons.user, label: 'Perfil'),
    ];

    final teacherNav = [
      CustomBottomNavItem(icon: LucideIcons.layoutDashboard, label: 'Inicio'),
      CustomBottomNavItem(icon: LucideIcons.bookOpen, label: 'Cursos'),
      CustomBottomNavItem(icon: LucideIcons.users, label: 'Alumnos'),
      CustomBottomNavItem(icon: LucideIcons.calendar, label: 'Horario'),
      CustomBottomNavItem(icon: LucideIcons.user, label: 'Perfil'),
    ];

    final studentNav = [
      CustomBottomNavItem(icon: LucideIcons.layoutDashboard, label: 'Inicio'),
      CustomBottomNavItem(icon: LucideIcons.bookOpen, label: 'Notas'),
      CustomBottomNavItem(icon: LucideIcons.calendar, label: 'Horario'),
      CustomBottomNavItem(icon: LucideIcons.user, label: 'Perfil'),
    ];

    List<CustomBottomNavItem> destinations;
    if (user?.rol == 'Administrador') {
      destinations = adminNav;
    } else if (user?.rol == 'Profesor') {
      destinations = teacherNav;
    } else {
      destinations = studentNav;
    }

    if (isDesktop) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundMain,
        body: Row(
          children: [
            Container(
              width: 250,
              decoration: const BoxDecoration(
                color: AppTheme.backgroundSecondary,
                border: Border(right: BorderSide(color: AppTheme.borderLight)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(28.0),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.cardElevated,
                            border: Border.all(color: AppTheme.borderLight),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'lib/assets/imagenes/logo.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                LucideIcons.graduationCap,
                                color: AppTheme.primaryBlue,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'SmartAcademy',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textMain,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: destinations.length,
                      itemBuilder: (context, index) {
                        final item = destinations[index];
                        final isSelected = index == _selectedIndex;
                        return ListTile(
                          leading: Icon(
                            item.icon,
                            color: isSelected ? AppTheme.primaryBlue : AppTheme.textSecondary,
                            size: 20,
                          ),
                          title: Text(
                            item.label,
                            style: GoogleFonts.outfit(
                              color: isSelected ? AppTheme.primaryBlue : AppTheme.textSecondary,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          selected: isSelected,
                          onTap: () => setState(() => _selectedIndex = index),
                          selectedTileColor: AppTheme.primaryBlue.withValues(alpha: 0.12),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: ListTile(
                      leading: const Icon(LucideIcons.logOut, color: AppTheme.error, size: 20),
                      title: Text(
                        'Cerrar sesión',
                        style: GoogleFonts.outfit(
                          color: AppTheme.error,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      onTap: () async {
                        await context.read<AuthController>().logout();
                        if (context.mounted) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          );
                        }
                      },
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _getScreenForIndex(_selectedIndex, user?.rol),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundMain,
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _getScreenForIndex(_selectedIndex, user?.rol),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: destinations,
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().currentUser;
    final dashboard = context.watch<DashboardController>();

    return RefreshIndicator(
      onRefresh: () => context.read<DashboardController>().loadDashboardStats(user),
      child: Scaffold(
        backgroundColor: AppTheme.backgroundMain,
        body: Skeletonizer(
          enabled: dashboard.isLoading,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: CustomHeader(
                  title: '¡Hola, ${user?.nombre ?? 'Administrador'}!',
                  subtitle: user?.rol ?? 'Panel Administrativo',
                  hasNotification: true,
                ).animate().fade().slideY(begin: -0.05),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Hero Banner Responsive
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: _HeroBanner(
                    title: 'SmartAcademy',
                    subtitle: 'Gestión académica centralizada en tiempo real.',
                    gradientColors: const [AppTheme.primaryBlue, AppTheme.secondaryPurple],
                    stats: [
                      _HeroStatData(value: dashboard.totalStudents.toString(), label: 'Alumnos'),
                      _HeroStatData(value: dashboard.totalTeachers.toString(), label: 'Profes'),
                      _HeroStatData(value: dashboard.totalCourses.toString(), label: 'Cursos'),
                    ],
                  ).animate().fade(delay: 80.ms).slideY(begin: 0.08),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 18)),

              // Acciones Rápidas
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: LayoutBuilder(builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 600;
                    if (isMobile) {
                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _QuickActionButton(
                                  color: AppTheme.success,
                                  icon: LucideIcons.userPlus,
                                  label: 'Nuevo Alumno',
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const StudentFormScreen()),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _QuickActionButton(
                                  color: AppTheme.primaryBlue,
                                  icon: LucideIcons.filePenLine,
                                  label: 'Registrar Nota',
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const CoursesScreen()),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _QuickActionButton(
                                  color: AppTheme.secondaryPurple,
                                  icon: LucideIcons.bookPlus,
                                  label: 'Nuevo Curso',
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const CoursesScreen()),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _QuickActionButton(
                                  color: AppTheme.warning,
                                  icon: LucideIcons.calendarClock,
                                  label: 'Horarios',
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const SchedulesScreen()),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }
                    return Row(
                      children: [
                        Expanded(
                          child: _QuickActionButton(
                            color: AppTheme.success,
                            icon: LucideIcons.userPlus,
                            label: 'Nuevo Alumno',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const StudentFormScreen()),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickActionButton(
                            color: AppTheme.primaryBlue,
                            icon: LucideIcons.filePenLine,
                            label: 'Registrar Nota',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const CoursesScreen()),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickActionButton(
                            color: AppTheme.secondaryPurple,
                            icon: LucideIcons.bookPlus,
                            label: 'Nuevo Curso',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const CoursesScreen()),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickActionButton(
                            color: AppTheme.warning,
                            icon: LucideIcons.calendarClock,
                            label: 'Horarios',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SchedulesScreen()),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).animate().fade(delay: 150.ms).slideY(begin: 0.08),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 18)),

              // Mini Stats Cards
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: LayoutBuilder(builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 600;

                    final studentsCard = _MiniStatCard(
                      title: 'Alumnos Activos',
                      icon: LucideIcons.users,
                      value: dashboard.totalStudents.toString(),
                      percentage: '+12%',
                      isPositive: true,
                      child: SizedBox(
                        height: 38,
                        child: LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: false),
                            titlesData: const FlTitlesData(show: false),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: const [
                                  FlSpot(0, 1),
                                  FlSpot(1, 1.5),
                                  FlSpot(2, 1.4),
                                  FlSpot(3, 2),
                                  FlSpot(4, 2.5),
                                  FlSpot(5, 2.2),
                                  FlSpot(6, 3)
                                ],
                                isCurved: true,
                                color: AppTheme.success,
                                barWidth: 2.5,
                                dotData: const FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: AppTheme.success.withValues(alpha: 0.1),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );

                    final teachersCard = _MiniStatCard(
                      title: 'Docentes',
                      icon: LucideIcons.graduationCap,
                      value: dashboard.totalTeachers.toString(),
                      percentage: '+5%',
                      isPositive: true,
                    );

                    final coursesCard = _MiniStatCard(
                      title: 'Cursos Activos',
                      icon: LucideIcons.bookOpen,
                      value: dashboard.totalCourses.toString(),
                      percentage: '+8%',
                      isPositive: true,
                    );

                    if (isMobile) {
                      return Column(
                        children: [
                          studentsCard,
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: teachersCard),
                              const SizedBox(width: 12),
                              Expanded(child: coursesCard),
                            ],
                          ),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(flex: 2, child: studentsCard),
                        const SizedBox(width: 12),
                        Expanded(child: teachersCard),
                        const SizedBox(width: 12),
                        Expanded(child: coursesCard),
                      ],
                    );
                  }).animate().fade(delay: 220.ms).slideY(begin: 0.08),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 18)),

              // Activity & Events
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: LayoutBuilder(builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 600;

                    final activityWidget = CustomCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(LucideIcons.activity,
                                      color: AppTheme.primaryBlue, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Actividad reciente',
                                    style: GoogleFonts.outfit(
                                      color: AppTheme.textMain,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'Ver todo',
                                style: GoogleFonts.outfit(
                                  color: AppTheme.primaryBlue,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const _TimelineItem(
                            color: AppTheme.success,
                            icon: LucideIcons.userPlus,
                            title: 'Nuevo estudiante registrado',
                            time: 'Hace 5 min',
                            isLast: false,
                          ),
                          const _TimelineItem(
                            color: AppTheme.primaryBlue,
                            icon: LucideIcons.bookPlus,
                            title: 'Asignatura actualizada',
                            time: 'Hace 25 min',
                            isLast: false,
                          ),
                          const _TimelineItem(
                            color: AppTheme.secondaryPurple,
                            icon: LucideIcons.star,
                            title: 'Calificaciones cargadas',
                            time: 'Hace 1 hora',
                            isLast: true,
                          ),
                        ],
                      ),
                    ).animate().fade(delay: 300.ms).slideX(begin: -0.05);

                    final eventsWidget = CustomCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(LucideIcons.calendar,
                                  color: AppTheme.secondaryPurple, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Próximos eventos',
                                style: GoogleFonts.outfit(
                                  color: AppTheme.textMain,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const _EventItem(
                            day: '17',
                            month: 'Sep',
                            title: 'Evaluación de Cursos',
                            time: '08:00 - 10:00',
                            color: AppTheme.primaryBlue,
                          ),
                          const _EventItem(
                            day: '20',
                            month: 'Sep',
                            title: 'Cierre de Periodo',
                            time: '10:00 - 12:00',
                            color: AppTheme.secondaryPurple,
                          ),
                          const _EventItem(
                            day: '22',
                            month: 'Sep',
                            title: 'Consejo Académico',
                            time: '15:00 - 16:00',
                            color: AppTheme.warning,
                          ),
                        ],
                      ),
                    ).animate().fade(delay: 350.ms).slideX(begin: 0.05);

                    if (isWide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: activityWidget),
                          const SizedBox(width: 12),
                          Expanded(child: eventsWidget),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          activityWidget,
                          const SizedBox(height: 12),
                          eventsWidget,
                        ],
                      );
                    }
                  }),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 110)),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroStatData {
  final String value;
  final String label;

  _HeroStatData({required this.value, required this.label});
}

class _HeroBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Color> gradientColors;
  final List<_HeroStatData> stats;

  const _HeroBanner({
    required this.title,
    required this.subtitle,
    required this.gradientColors,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(LucideIcons.graduationCap, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(stats.length * 2 - 1, (index) {
                if (index.isOdd) {
                  return Container(
                    width: 1,
                    height: 28,
                    color: Colors.white.withValues(alpha: 0.2),
                  );
                }
                final statIndex = index ~/ 2;
                final stat = stats[statIndex];
                return Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        stat.value,
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        stat.label,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.color,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: color.withValues(alpha: 0.2),
        child: Ink(
          height: 86,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: AppTheme.textMain,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String value;
  final String percentage;
  final bool isPositive;
  final Widget? child;

  const _MiniStatCard({
    required this.title,
    required this.icon,
    required this.value,
    required this.percentage,
    required this.isPositive,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = isPositive ? AppTheme.success : AppTheme.error;

    return CustomCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.textSecondary, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: AppTheme.textMain,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                isPositive ? LucideIcons.arrowUpRight : LucideIcons.arrowDownRight,
                color: statusColor,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                percentage,
                style: GoogleFonts.outfit(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (child != null) ...[
                const SizedBox(width: 12),
                Expanded(child: child!),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String time;
  final bool isLast;

  const _TimelineItem({
    required this.color,
    required this.icon,
    required this.title,
    required this.time,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 14),
            ),
            if (!isLast)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                width: 1.5,
                height: 32,
                color: AppTheme.borderLight,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  color: AppTheme.textMain,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                time,
                style: GoogleFonts.outfit(
                  color: AppTheme.textMuted,
                  fontSize: 12,
                ),
              ),
              if (!isLast) const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }
}

class _EventItem extends StatelessWidget {
  final String day;
  final String month;
  final String title;
  final String time;
  final Color color;

  const _EventItem({
    required this.day,
    required this.month,
    required this.title,
    required this.time,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.25)),
            ),
            child: Column(
              children: [
                Text(
                  day,
                  style: GoogleFonts.outfit(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (month.isNotEmpty)
                  Text(
                    month,
                    style: GoogleFonts.outfit(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    color: AppTheme.textMain,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(LucideIcons.clock, color: AppTheme.textMuted, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: GoogleFonts.outfit(
                        color: AppTheme.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(LucideIcons.chevronRight, color: AppTheme.textMuted, size: 16),
        ],
      ),
    );
  }
}

class _StudentDashboardContent extends StatefulWidget {
  const _StudentDashboardContent();

  @override
  State<_StudentDashboardContent> createState() => _StudentDashboardContentState();
}

class _StudentDashboardContentState extends State<_StudentDashboardContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthController>().currentUser;
      context.read<DashboardController>().loadDashboardStats(user);
      context.read<GradeController>().loadGrades();
      context.read<CourseController>().loadCourses();
      context.read<StudentController>().loadStudents();
    });
  }

  Widget _buildStudentGradeChip(String label, double? val) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 2),
        Text(
          val?.toStringAsFixed(1) ?? '-',
          style: GoogleFonts.outfit(color: AppTheme.textMain, fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().currentUser;
    final dashboard = context.watch<DashboardController>();

    return RefreshIndicator(
      onRefresh: () async {
        final dCtrl = context.read<DashboardController>();
        final gCtrl = context.read<GradeController>();
        final cCtrl = context.read<CourseController>();
        final sCtrl = context.read<StudentController>();
        await Future.wait([
          dCtrl.loadDashboardStats(user),
          gCtrl.loadGrades(),
          cCtrl.loadCourses(),
          sCtrl.loadStudents(),
        ]);
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundMain,
        body: Skeletonizer(
          enabled: dashboard.isLoading,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: CustomHeader(
                  title: '¡Hola, ${user?.nombre ?? 'Estudiante'}!',
                  subtitle: 'Panel del Estudiante',
                  hasNotification: true,
                ).animate().fade().slideY(begin: -0.05),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Hero Banner Estudiante
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: _HeroBanner(
                    title: 'Mi Progreso',
                    subtitle: 'Sigue aprendiendo y mejorando cada día.',
                    gradientColors: const [AppTheme.primaryBlue, AppTheme.accentPurple],
                    stats: [
                      _HeroStatData(value: dashboard.totalCourses.toString(), label: 'Mis Cursos'),
                      _HeroStatData(value: dashboard.classesToday.toString(), label: 'Clases Hoy'),
                    ],
                  ).animate().fade(delay: 80.ms).slideY(begin: 0.08),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 18)),

              // Acciones Rápidas Estudiante
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _QuickActionButton(
                          color: AppTheme.primaryBlue,
                          icon: LucideIcons.fileCheck2,
                          label: 'Mis Cursos & Notas',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CoursesScreen()),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickActionButton(
                          color: AppTheme.warning,
                          icon: LucideIcons.calendarClock,
                          label: 'Mi Horario',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SchedulesScreen()),
                          ),
                        ),
                      ),
                    ],
                  ).animate().fade(delay: 150.ms).slideY(begin: 0.08),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 18)),

              // MIS CALIFICACIONES EN VIVO
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Consumer3<GradeController, StudentController, CourseController>(
                    builder: (context, gradeCtrl, studentCtrl, courseCtrl, _) {
                      // Vincular usuario actual con su perfil de estudiante si existe
                      Student? currentStudent;
                      try {
                        currentStudent = studentCtrl.students.firstWhere(
                          (s) => s.correo.toLowerCase() == (user?.correo.toLowerCase() ?? ''),
                        );
                      } catch (_) {
                        currentStudent = studentCtrl.students.isNotEmpty ? studentCtrl.students.first : null;
                      }

                      final myGrades = currentStudent != null
                          ? gradeCtrl.grades.where((g) => g.estudianteId == currentStudent!.id).toList()
                          : gradeCtrl.grades;

                      return CustomCard(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryBlue.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(LucideIcons.fileCheck2, color: AppTheme.primaryBlue, size: 18),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Mis Calificaciones',
                                        style: GoogleFonts.outfit(
                                          color: AppTheme.textMain,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        '${myGrades.length} materias con notas registradas',
                                        style: GoogleFonts.outfit(
                                          color: AppTheme.textMuted,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const CoursesScreen()),
                                  ),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  icon: const Icon(LucideIcons.arrowRight, size: 14, color: AppTheme.primaryBlue),
                                  label: Text(
                                    'Ver cursos',
                                    style: GoogleFonts.outfit(
                                      color: AppTheme.primaryBlue,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            if (myGrades.isEmpty) ...[
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 18.0),
                                  child: Column(
                                    children: [
                                      Icon(LucideIcons.fileText, size: 36, color: AppTheme.textMuted.withValues(alpha: 0.5)),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Sin calificaciones registradas aún',
                                        style: GoogleFonts.outfit(color: AppTheme.textSecondary, fontSize: 14, fontWeight: FontWeight.w500),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Tus profesores cargarán aquí tus evaluaciones periódicas.',
                                        style: GoogleFonts.outfit(color: AppTheme.textMuted, fontSize: 12),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ] else ...[
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: myGrades.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final grade = myGrades[index];
                                  Course? course;
                                  try {
                                    course = courseCtrl.courses.firstWhere((c) => c.id == grade.cursoId);
                                  } catch (_) {
                                    course = null;
                                  }

                                  final courseName = course != null ? '${course.codigo} - ${course.nombre}' : 'Curso #${grade.cursoId}';
                                  final def = grade.definitiva ?? 0.0;
                                  final passed = def >= 3.0;

                                  return Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppTheme.cardElevated,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppTheme.borderLight),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                courseName,
                                                style: GoogleFonts.outfit(
                                                  color: AppTheme.textMain,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
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
                                                  color: passed ? AppTheme.success : AppTheme.error,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            _buildStudentGradeChip('P1 (20%)', grade.parcial1),
                                            _buildStudentGradeChip('P2 (20%)', grade.parcial2),
                                            _buildStudentGradeChip('P3 (20%)', grade.parcial3),
                                            _buildStudentGradeChip('TF (40%)', grade.trabajoFinal),
                                            Container(
                                              width: 1,
                                              height: 28,
                                              color: AppTheme.borderLight,
                                            ),
                                            Column(
                                              children: [
                                                Text('Definitiva', style: GoogleFonts.outfit(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.w600)),
                                                const SizedBox(height: 1),
                                                Text(def.toStringAsFixed(2), style: GoogleFonts.outfit(color: passed ? AppTheme.success : AppTheme.error, fontSize: 16, fontWeight: FontWeight.w800)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ).animate().fade(delay: 200.ms).slideY(begin: 0.05),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 18)),

              // Clases de hoy
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: CustomCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(LucideIcons.calendar,
                                color: AppTheme.primaryBlue, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Clases de hoy',
                              style: GoogleFonts.outfit(
                                color: AppTheme.textMain,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        if (dashboard.classesToday > 0) ...[
                          const _EventItem(
                            day: 'Hoy',
                            month: '',
                            title: 'Tu próxima clase',
                            time: 'Revisa tu horario detallado',
                            color: AppTheme.primaryBlue,
                          ),
                        ] else ...[
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              child: Text(
                                'No tienes clases programadas para hoy',
                                style: GoogleFonts.outfit(
                                  color: AppTheme.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          )
                        ],
                      ],
                    ),
                  ).animate().fade(delay: 240.ms).slideX(begin: 0.05),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 110)),
            ],
          ),
        ),
      ),
    );
  }
}

class _TeacherDashboardContent extends StatefulWidget {
  const _TeacherDashboardContent();

  @override
  State<_TeacherDashboardContent> createState() => _TeacherDashboardContentState();
}

class _TeacherDashboardContentState extends State<_TeacherDashboardContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthController>().currentUser;
      context.read<DashboardController>().loadDashboardStats(user);
      context.read<AttendanceController>().loadAttendances();
      context.read<GradeController>().loadGrades();
      context.read<CourseController>().loadCourses();
      context.read<StudentController>().loadStudents();
    });
  }

  String _formatAttendanceTime(String rawDate) {
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

  Color _getStatusColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'presente':
        return AppTheme.success;
      case 'tarde':
      case 'retardo':
        return AppTheme.warning;
      case 'ausente':
      case 'falta':
        return AppTheme.error;
      case 'justificado':
        return AppTheme.primaryBlue;
      default:
        return AppTheme.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().currentUser;
    final dashboard = context.watch<DashboardController>();

    return RefreshIndicator(
      onRefresh: () async {
        final dCtrl = context.read<DashboardController>();
        final aCtrl = context.read<AttendanceController>();
        final gCtrl = context.read<GradeController>();
        await dCtrl.loadDashboardStats(user);
        await aCtrl.loadAttendances();
        await gCtrl.loadGrades();
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundMain,
        body: Skeletonizer(
          enabled: dashboard.isLoading,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: CustomHeader(
                  title: '¡Hola, Prof. ${user?.nombre ?? ''}!',
                  subtitle: 'Panel Docente',
                  hasNotification: true,
                ).animate().fade().slideY(begin: -0.05),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Hero Banner Docente
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: _HeroBanner(
                    title: 'Mis Clases y Alumnos',
                    subtitle: 'Gestión académica de tus cursos asignados.',
                    gradientColors: const [AppTheme.success, AppTheme.primaryBlue],
                    stats: [
                      _HeroStatData(value: dashboard.totalCourses.toString(), label: 'Mis Cursos'),
                      _HeroStatData(value: dashboard.totalStudents.toString(), label: 'Alumnos'),
                    ],
                  ).animate().fade(delay: 80.ms).slideY(begin: 0.08),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 18)),

              // Acciones Rápidas Docente
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _QuickActionButton(
                              color: AppTheme.primaryBlue,
                              icon: LucideIcons.filePenLine,
                              label: 'Calificaciones',
                              onTap: () async {
                                final gCtrl = context.read<GradeController>();
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const GradesScreen()),
                                );
                                if (mounted) {
                                  gCtrl.loadGrades();
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _QuickActionButton(
                              color: AppTheme.success,
                              icon: LucideIcons.calendarCheck,
                              label: 'Asistencias',
                              onTap: () async {
                                final aCtrl = context.read<AttendanceController>();
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const AttendanceScreen()),
                                );
                                if (mounted) {
                                  aCtrl.loadAttendances();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _QuickActionButton(
                              color: AppTheme.secondaryPurple,
                              icon: LucideIcons.qrCode,
                              label: 'Escanear QR',
                              onTap: () async {
                                final aCtrl = context.read<AttendanceController>();
                                final nav = Navigator.of(context);
                                final res = await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const AttendanceScannerScreen()),
                                );
                                if (mounted) {
                                  await aCtrl.loadAttendances();
                                  if (res == true) {
                                    nav.push(
                                      MaterialPageRoute(builder: (_) => const AttendanceScreen()),
                                    );
                                  }
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _QuickActionButton(
                              color: AppTheme.warning,
                              icon: LucideIcons.calendarClock,
                              label: 'Horarios',
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const SchedulesScreen()),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ).animate().fade(delay: 150.ms).slideY(begin: 0.08),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 18)),

              // CONTROL DE ASISTENCIAS EN VIVO (HISTORIAL POR FECHAS Y HORAS)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Consumer3<AttendanceController, StudentController, CourseController>(
                    builder: (context, attendanceCtrl, studentCtrl, courseCtrl, _) {
                      final attendances = attendanceCtrl.attendances;
                      final recentAttendances = attendances.take(4).toList();

                      return CustomCard(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(7),
                                        decoration: BoxDecoration(
                                          color: AppTheme.success.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Icon(LucideIcons.calendarCheck, color: AppTheme.success, size: 18),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Control de Asistencias',
                                              style: GoogleFonts.outfit(
                                                color: AppTheme.textMain,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              '${attendances.length} asistencias tomadas',
                                              style: GoogleFonts.outfit(
                                                color: AppTheme.textMuted,
                                                fontSize: 12,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                TextButton.icon(
                                  onPressed: () async {
                                    final aCtrl = context.read<AttendanceController>();
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const AttendanceScreen()),
                                    );
                                    if (mounted) {
                                      aCtrl.loadAttendances();
                                    }
                                  },
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  icon: const Icon(LucideIcons.list, size: 14, color: AppTheme.primaryBlue),
                                  label: Text(
                                    'Ver todas',
                                    style: GoogleFonts.outfit(
                                      color: AppTheme.primaryBlue,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            if (attendances.isEmpty) ...[
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 18.0),
                                  child: Column(
                                    children: [
                                      Icon(LucideIcons.calendarOff, size: 36, color: AppTheme.textMuted.withValues(alpha: 0.5)),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Sin asistencias registradas',
                                        style: GoogleFonts.outfit(color: AppTheme.textSecondary, fontSize: 14, fontWeight: FontWeight.w500),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Escanea el QR del estudiante para registrar su asistencia en vivo.',
                                        style: GoogleFonts.outfit(color: AppTheme.textMuted, fontSize: 12),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ] else ...[
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: recentAttendances.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final item = recentAttendances[index];
                                  Student? student;
                                  try {
                                    student = studentCtrl.students.firstWhere((s) => s.id == item.estudianteId);
                                  } catch (_) {
                                    student = null;
                                  }
                                  Course? course;
                                  try {
                                    course = courseCtrl.courses.firstWhere((c) => c.id == item.cursoId);
                                  } catch (_) {
                                    course = null;
                                  }

                                  final studentName = student != null ? '${student.nombre} ${student.apellido}' : 'Estudiante #${item.estudianteId}';
                                  final courseName = course != null ? course.nombre : 'Curso #${item.cursoId}';
                                  final isScanned = item.fecha.contains('T');
                                  final formattedDate = _formatAttendanceTime(item.fecha);
                                  final statusColor = _getStatusColor(item.estado);

                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: AppTheme.cardElevated,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppTheme.borderLight),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: statusColor.withValues(alpha: 0.15),
                                            border: Border.all(color: statusColor.withValues(alpha: 0.35)),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            studentName.isNotEmpty ? studentName[0].toUpperCase() : 'E',
                                            style: GoogleFonts.outfit(
                                              color: statusColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
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
                                                  fontSize: 14,
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
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text('•', style: TextStyle(color: AppTheme.textMuted, fontSize: 10)),
                                                  const SizedBox(width: 6),
                                                  Icon(
                                                    isScanned ? LucideIcons.qrCode : LucideIcons.clipboardCheck,
                                                    size: 11,
                                                    color: isScanned ? AppTheme.secondaryPurple : AppTheme.textMuted,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      formattedDate,
                                                      style: GoogleFonts.outfit(
                                                        color: AppTheme.textMuted,
                                                        fontSize: 11,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: statusColor.withValues(alpha: 0.14),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                                          ),
                                          child: Text(
                                            item.estado,
                                            style: GoogleFonts.outfit(
                                              color: statusColor,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ).animate().fade(delay: 200.ms).slideY(begin: 0.05),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 18)),

              // CONTROL DE CALIFICACIONES (NOTAS RECIENTES)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Consumer3<GradeController, StudentController, CourseController>(
                    builder: (context, gradeCtrl, studentCtrl, courseCtrl, _) {
                      final grades = gradeCtrl.grades;
                      final recentGrades = grades.take(5).toList();

                      return CustomCard(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(7),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryBlue.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Icon(LucideIcons.filePenLine, color: AppTheme.primaryBlue, size: 18),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Registro de Calificaciones',
                                              style: GoogleFonts.outfit(
                                                color: AppTheme.textMain,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              '${grades.length} notas cargadas',
                                              style: GoogleFonts.outfit(
                                                color: AppTheme.textMuted,
                                                fontSize: 12,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                TextButton.icon(
                                  onPressed: () async {
                                    final gCtrl = context.read<GradeController>();
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const GradesScreen()),
                                    );
                                    if (mounted) {
                                      gCtrl.loadGrades();
                                    }
                                  },
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  icon: const Icon(LucideIcons.arrowRight, size: 14, color: AppTheme.primaryBlue),
                                  label: Text(
                                    'Ver todas',
                                    style: GoogleFonts.outfit(
                                      color: AppTheme.primaryBlue,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            if (grades.isEmpty) ...[
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 18.0),
                                  child: Column(
                                    children: [
                                      Icon(LucideIcons.fileCheck2, size: 36, color: AppTheme.textMuted.withValues(alpha: 0.5)),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Sin calificaciones registradas aún',
                                        style: GoogleFonts.outfit(color: AppTheme.textSecondary, fontSize: 14, fontWeight: FontWeight.w500),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Usa la opción "Calificaciones" para registrar evaluaciones a tus alumnos.',
                                        style: GoogleFonts.outfit(color: AppTheme.textMuted, fontSize: 12),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 12),
                                      TextButton.icon(
                                        onPressed: () async {
                                          final gCtrl = context.read<GradeController>();
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (_) => const GradesScreen()),
                                          );
                                          if (mounted) gCtrl.loadGrades();
                                        },
                                        icon: const Icon(LucideIcons.plus, size: 15, color: AppTheme.primaryBlue),
                                        label: Text(
                                          'Registrar primera nota',
                                          style: GoogleFonts.outfit(color: AppTheme.primaryBlue, fontWeight: FontWeight.w600, fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ] else ...[
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: recentGrades.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final grade = recentGrades[index];
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

                                  final studentName = student != null ? '${student.nombre} ${student.apellido}' : 'Estudiante #${grade.estudianteId}';
                                  final courseName = course != null ? course.nombre : 'Curso #${grade.cursoId}';
                                  final def = grade.definitiva ?? 0.0;
                                  final isPassed = def >= 3.0;
                                  final initials = (student != null && student.nombre.isNotEmpty)
                                      ? '${student.nombre[0]}${student.apellido.isNotEmpty ? student.apellido[0] : ''}'.toUpperCase()
                                      : 'E';

                                  return InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () async {
                                      final gCtrl = context.read<GradeController>();
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => GradesScreen(cursoId: grade.cursoId)),
                                      );
                                      if (mounted) gCtrl.loadGrades();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: AppTheme.cardElevated,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: AppTheme.borderLight),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                width: 36,
                                                height: 36,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: AppTheme.primaryBlue.withValues(alpha: 0.15),
                                                  border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.3)),
                                                ),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  initials,
                                                  style: GoogleFonts.outfit(
                                                    color: AppTheme.primaryBlue,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      studentName,
                                                      style: GoogleFonts.outfit(
                                                        color: AppTheme.textMain,
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      '$courseName • Doc: ${student?.documento ?? grade.estudianteId}',
                                                      style: GoogleFonts.outfit(
                                                        color: AppTheme.textMuted,
                                                        fontSize: 11,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    def.toStringAsFixed(2),
                                                    style: GoogleFonts.outfit(
                                                      color: isPassed ? AppTheme.success : AppTheme.error,
                                                      fontSize: 17,
                                                      fontWeight: FontWeight.w800,
                                                    ),
                                                  ),
                                                  Text(
                                                    isPassed ? 'Aprobado' : 'Reprobado',
                                                    style: GoogleFonts.outfit(
                                                      color: isPassed ? AppTheme.success : AppTheme.error,
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: AppTheme.surfaceCardElevated,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                              children: [
                                                Text(
                                                  'P1: ${grade.parcial1?.toStringAsFixed(1) ?? "-"}',
                                                  style: GoogleFonts.outfit(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w500),
                                                ),
                                                Text(
                                                  'P2: ${grade.parcial2?.toStringAsFixed(1) ?? "-"}',
                                                  style: GoogleFonts.outfit(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w500),
                                                ),
                                                Text(
                                                  'P3: ${grade.parcial3?.toStringAsFixed(1) ?? "-"}',
                                                  style: GoogleFonts.outfit(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w500),
                                                ),
                                                Text(
                                                  'TF: ${grade.trabajoFinal?.toStringAsFixed(1) ?? "-"}',
                                                  style: GoogleFonts.outfit(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w500),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ).animate().fade(delay: 240.ms).slideY(begin: 0.05),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 18)),

              // Clases Asignadas
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: CustomCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(LucideIcons.calendar,
                                color: AppTheme.success, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Clases de hoy',
                              style: GoogleFonts.outfit(
                                color: AppTheme.textMain,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        if (dashboard.classesToday > 0) ...[
                          const _EventItem(
                            day: 'Hoy',
                            month: '',
                            title: 'Clases programadas',
                            time: 'Revisa tu horario docente',
                            color: AppTheme.success,
                          ),
                        ] else ...[
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              child: Text(
                                'No tienes clases programadas para hoy',
                                style: GoogleFonts.outfit(
                                  color: AppTheme.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          )
                        ],
                      ],
                    ),
                  ).animate().fade(delay: 280.ms).slideX(begin: 0.05),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 110)),
            ],
          ),
        ),
      ),
    );
  }
}
