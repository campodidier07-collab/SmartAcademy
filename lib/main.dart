import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/auth_controller.dart';
import 'controllers/student_controller.dart';
import 'controllers/teacher_controller.dart';
import 'controllers/course_controller.dart';
import 'controllers/grade_controller.dart';
import 'controllers/attendance_controller.dart';
import 'controllers/schedule_controller.dart';
import 'controllers/dashboard_controller.dart';

import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SmartAcademyApp());
}

class SmartAcademyApp extends StatelessWidget {
  const SmartAcademyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => StudentController()),
        ChangeNotifierProvider(create: (_) => TeacherController()),
        ChangeNotifierProvider(create: (_) => CourseController()),
        ChangeNotifierProvider(create: (_) => GradeController()),
        ChangeNotifierProvider(create: (_) => AttendanceController()),
        ChangeNotifierProvider(create: (_) => ScheduleController()),
        ChangeNotifierProvider(create: (_) => DashboardController()),
      ],
      child: MaterialApp(
        title: 'SmartAcademy',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const SplashScreen(),
      ),
    );
  }
}
