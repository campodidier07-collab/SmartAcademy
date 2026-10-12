import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
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

  final client = supa.Supabase.instance.client;

  Future<void> loadDashboardStats(User? user) async {
    _isLoading = true;
    notifyListeners();

    List<String> days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    String today = days[DateTime.now().weekday - 1];
    
    try {
      if (user?.rol == 'Administrador') {
        totalStudents = (await client.from('estudiantes').select('id')).length;
        totalTeachers = (await client.from('profesores').select('id')).length;
        totalCourses = (await client.from('cursos').select('id')).length;
        
        classesToday = (await client.from('horarios').select('id').eq('dia', today)).length;
        
        for (String day in days) {
          clasesPorDia[day] = (await client.from('horarios').select('id').eq('dia', day)).length;
        }
      } else if (user?.rol == 'Profesor') {
        final teacherMaps = await client.from('profesores').select('id').eq('correo', user!.correo).limit(1);
        int? teacherId = teacherMaps.isNotEmpty ? (teacherMaps.first['id'] as int) : null;
        
        var cursosDelProfesor = teacherId != null 
            ? await client.from('cursos').select('id, nombre').eq('profesor_id', teacherId)
            : [];
            
        if (cursosDelProfesor.isEmpty) {
          cursosDelProfesor = await client.from('cursos').select('id, nombre');
        }
        totalCourses = cursosDelProfesor.length;
        
        final allStudents = await client.from('estudiantes').select('id');
        totalStudents = allStudents.length;

        if (teacherId != null) {
          classesToday = (await client.from('horarios').select('id, cursos!inner(id, profesor_id)').eq('dia', today).eq('cursos.profesor_id', teacherId)).length;
          for (String day in days) {
            clasesPorDia[day] = (await client.from('horarios').select('id, cursos!inner(id, profesor_id)').eq('dia', day).eq('cursos.profesor_id', teacherId)).length;
          }
        }
      } else {
        // Lógica de Estudiante
        final studentMaps = await client.from('estudiantes').select('programa').eq('correo', user!.correo).limit(1);
        if (studentMaps.isNotEmpty) {
          final programa = studentMaps.first['programa'] as String;
          
          totalCourses = (await client.from('cursos').select('id').eq('nombre', programa)).length;
          
          classesToday = (await client.from('horarios').select('id, cursos!inner(id, nombre)').eq('dia', today).eq('cursos.nombre', programa)).length;
          
          for (String day in days) {
            clasesPorDia[day] = (await client.from('horarios').select('id, cursos!inner(id, nombre)').eq('dia', day).eq('cursos.nombre', programa)).length;
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading dashboard stats: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}
