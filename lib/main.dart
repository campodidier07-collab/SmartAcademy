import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/controlador_auth.dart';
import 'controllers/controlador_estudiantes.dart';
import 'controllers/controlador_profesores.dart';
import 'controllers/controlador_cursos.dart';
import 'controllers/controlador_calificaciones.dart';
import 'controllers/controlador_asistencias.dart';
import 'controllers/controlador_horarios.dart';
import 'controllers/controlador_dashboard.dart';

import 'theme/app_theme.dart';
import 'screens/pantalla_carga.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://klhramhdlkvxfbpnjoca.supabase.co',
    // ignore: deprecated_member_use
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtsaHJhbWhkbGt2eGZicG5qb2NhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTEzOTgyMzIsImV4cCI6MjEwNjk3NDIzMn0.CQALcq7LcciFbNqR9xBjKsNaVl3WzB_Rku7mQMt6aKY',
  );

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
        themeMode: ThemeMode.dark,
        home: const SplashScreen(),
      ),
    );
  }
}
