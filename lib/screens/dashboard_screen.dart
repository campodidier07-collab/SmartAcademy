import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/auth_controller.dart';
import '../controllers/dashboard_controller.dart';
import 'login_screen.dart';
import 'students_screen.dart';
import 'teachers_screen.dart';
import 'courses_screen.dart';
import 'profile_screen.dart';
import '../theme/app_theme.dart';

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
        case 0: return const _DashboardContent();
        case 1: return const StudentsScreen();
        case 2: return const TeachersScreen();
        case 3: return const CoursesScreen();
        case 4: return const ProfileScreen();
        default: return const _DashboardContent();
      }
    } else if (rol == 'Profesor') {
      switch (index) {
        case 0: return const _DashboardContent();
        case 1: return const CoursesScreen(); // Mis Cursos
        case 2: return const StudentsScreen(); // Mis Estudiantes
        case 3: return const ProfileScreen();
        default: return const _DashboardContent();
      }
    } else {
      // Estudiante
      switch (index) {
        case 0: return const _DashboardContent();
        case 1: return const CoursesScreen(); // Mis Cursos
        case 2: return const ProfileScreen();
        default: return const _DashboardContent();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().currentUser;
    final isDesktop = MediaQuery.of(context).size.width > 800;

    final adminDestinations = [
      const NavigationRailDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: Text('Dashboard')),
      const NavigationRailDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: Text('Estudiantes')),
      const NavigationRailDestination(icon: Icon(Icons.co_present_outlined), selectedIcon: Icon(Icons.co_present), label: Text('Profesores')),
      const NavigationRailDestination(icon: Icon(Icons.book_outlined), selectedIcon: Icon(Icons.book), label: Text('Cursos')),
      const NavigationRailDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: Text('Perfil')),
    ];

    final teacherDestinations = [
      const NavigationRailDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: Text('Dashboard')),
      const NavigationRailDestination(icon: Icon(Icons.book_outlined), selectedIcon: Icon(Icons.book), label: Text('Mis Cursos')),
      const NavigationRailDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: Text('Mis Estudiantes')),
      const NavigationRailDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: Text('Perfil')),
    ];

    final studentDestinations = [
      const NavigationRailDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: Text('Dashboard')),
      const NavigationRailDestination(icon: Icon(Icons.book_outlined), selectedIcon: Icon(Icons.book), label: Text('Mis Cursos')),
      const NavigationRailDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: Text('Perfil')),
    ];

    List<NavigationRailDestination> destinations;
    if (user?.rol == 'Administrador') {
      destinations = adminDestinations;
    } else if (user?.rol == 'Profesor') {
      destinations = teacherDestinations;
    } else {
      destinations = studentDestinations;
    }

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.only(bottom: 24, top: 16),
                child: Image.asset('lib/assets/imagenes/logo.png', width: 40, height: 40),
              ),
              destinations: destinations,
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: IconButton(
                      icon: const Icon(Icons.logout, color: Colors.red),
                      onPressed: () async {
                        await context.read<AuthController>().logout();
                        if (context.mounted) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: _getScreenForIndex(_selectedIndex, user?.rol),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: _getScreenForIndex(_selectedIndex, user?.rol),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: destinations.map((d) => BottomNavigationBarItem(
          icon: d.icon,
          activeIcon: d.selectedIcon,
          label: (d.label as Text).data,
        )).toList(),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  List<Widget> _buildStatCards(BuildContext context, DashboardController dashboard) {
    return [
      _ModernStatCard(
        title: 'Estudiantes',
        value: dashboard.totalStudents.toString(),
        icon: Icons.people,
        gradientStart: AppTheme.cardBlueStart,
        gradientEnd: AppTheme.cardBlueEnd,
      ).animate().fade(delay: 200.ms).scale(),
      _ModernStatCard(
        title: 'Profesores',
        value: dashboard.totalTeachers.toString(),
        icon: Icons.co_present,
        gradientStart: AppTheme.cardPurpleStart,
        gradientEnd: AppTheme.cardPurpleEnd,
      ).animate().fade(delay: 300.ms).scale(),
      _ModernStatCard(
        title: 'Cursos',
        value: dashboard.totalCourses.toString(),
        icon: Icons.book,
        gradientStart: AppTheme.cardRedStart,
        gradientEnd: AppTheme.cardRedEnd,
      ).animate().fade(delay: 400.ms).scale(),
      _ModernStatCard(
        title: 'Clases Hoy',
        value: dashboard.classesToday.toString(),
        icon: Icons.calendar_today,
        gradientStart: AppTheme.cardGreenStart,
        gradientEnd: AppTheme.cardGreenEnd,
      ).animate().fade(delay: 500.ms).scale(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().currentUser;
    final dashboard = context.watch<DashboardController>();

    if (dashboard.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () => context.read<DashboardController>().loadDashboardStats(user),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Visión General'),
          backgroundColor: Colors.transparent,
        ),
        body: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hola, ${user?.nombre ?? 'Usuario'} 👋',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32),
              ).animate().fade().slideY(begin: -0.1),
              const SizedBox(height: 8),
              Text(
                'Aquí tienes un resumen actualizado de la academia.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ).animate().fade(delay: 100.ms).slideY(begin: -0.1),
              const SizedBox(height: 32),
              
              // Estadísticas (Dashboard Grid)
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 600;
                  if (isWide) {
                    return GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: constraints.maxWidth > 800 ? 4 : 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.6,
                      physics: const NeverScrollableScrollPhysics(),
                      children: _buildStatCards(context, dashboard),
                    );
                  }
                  // En móvil: Column sencilla, sin aspect ratio restrictivo
                  return Column(
                    children: _buildStatCards(context, dashboard)
                        .map((card) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: card,
                            ))
                        .toList(),
                  );
                }
              ),
              if (user?.rol == 'Administrador') ...[
                const SizedBox(height: 32),
                Text(
                  'Métricas Globales',
                  style: Theme.of(context).textTheme.titleLarge,
                ).animate().fade(delay: 600.ms),
                const SizedBox(height: 16),
                
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 800;
                    
                    final pieChart = SizedBox(
                      height: 300,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Distribución de Usuarios', style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 24),
                              Expanded(
                                child: PieChart(
                                  PieChartData(
                                    sectionsSpace: 2,
                                    centerSpaceRadius: 40,
                                    sections: [
                                      PieChartSectionData(
                                        color: AppTheme.neonBlue,
                                        value: dashboard.totalStudents.toDouble(),
                                        title: 'Est.',
                                        radius: 50,
                                        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                      PieChartSectionData(
                                        color: AppTheme.neonPurple,
                                        value: dashboard.totalTeachers.toDouble(),
                                        title: 'Prof.',
                                        radius: 50,
                                        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fade(delay: 700.ms).slideY(),
                    );
                    
                    final barChart = SizedBox(
                      height: 300,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Clases por Día', style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 24),
                              Expanded(
                                child: BarChart(
                                  BarChartData(
                                    alignment: BarChartAlignment.spaceAround,
                                    maxY: 10,
                                    barTouchData: BarTouchData(enabled: true),
                                    titlesData: FlTitlesData(
                                      show: true,
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (double value, TitleMeta meta) {
                                            const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 12);
                                            final days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
                                            if (value.toInt() >= 0 && value.toInt() < days.length) {
                                              return SideTitleWidget(meta: meta, child: Text(days[value.toInt()], style: style));
                                            }
                                            return const SizedBox.shrink();
                                          },
                                        ),
                                      ),
                                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    ),
                                    gridData: FlGridData(
                                      show: true,
                                      drawVerticalLine: false,
                                      getDrawingHorizontalLine: (value) => FlLine(
                                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                                        strokeWidth: 1,
                                      ),
                                    ),
                                    borderData: FlBorderData(show: false),
                                    barGroups: [
                                      for (int i = 0; i < 7; i++)
                                        BarChartGroupData(
                                          x: i,
                                          barRods: [
                                            BarChartRodData(
                                              toY: dashboard.clasesPorDia.values.elementAt(i).toDouble(),
                                              color: AppTheme.neonBlue,
                                              width: 16,
                                              borderRadius: BorderRadius.circular(4),
                                            )
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fade(delay: 800.ms).slideY(),
                    );
                    
                    if (isWide) {
                      return Row(
                        children: [
                          Expanded(child: pieChart),
                          const SizedBox(width: 16),
                          Expanded(flex: 2, child: barChart),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          pieChart,
                          const SizedBox(height: 16),
                          barChart,
                        ],
                      );
                    }
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ModernStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color gradientStart;
  final Color gradientEnd;

  const _ModernStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradientStart,
    required this.gradientEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [gradientStart, gradientEnd],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
        boxShadow: [
          BoxShadow(
            color: gradientStart.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
