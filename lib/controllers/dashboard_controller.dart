import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/models.dart';

class DashboardController extends ChangeNotifier {
  int totalStudents = 0;
  int totalTeachers = 0;
  int totalCourses = 0;
  int classesToday = 0;
  Map<String, int> clasesPorDia = {
    'Lunes': 0, 'Martes': 0, 'Miércoles': 0, 'Jueves': 0, 'Viernes': 0, 'Sábado': 0, 'Domingo': 0
  };

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadDashboardStats(User? user) async {
    _isLoading = true;
    notifyListeners();

    final db = await DatabaseHelper.instance.database;
    
    if (user?.rol == 'Administrador') {
      totalStudents = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM estudiantes')) ?? 0;
      totalTeachers = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM profesores')) ?? 0;
      totalCourses = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM cursos')) ?? 0;
      
      // Get classes today based on current day of week
      List<String> days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
      String today = days[DateTime.now().weekday - 1];
      classesToday = Sqflite.firstIntValue(await db.rawQuery("SELECT COUNT(*) FROM horarios WHERE dia = '$today'")) ?? 0;
      
      // Load all classes per day for charts
      for (String day in days) {
        clasesPorDia[day] = Sqflite.firstIntValue(await db.rawQuery("SELECT COUNT(*) FROM horarios WHERE dia = '$day'")) ?? 0;
      }
    } else if (user?.rol == 'Profesor') {
      // Dummy logic for teacher
      totalStudents = 0;
      totalTeachers = 0;
      totalCourses = 0;
      classesToday = 0;
    } else {
      // Dummy logic for student
      totalStudents = 0;
      totalTeachers = 0;
      totalCourses = 0;
      classesToday = 0;
    }

    _isLoading = false;
    notifyListeners();
  }
}
