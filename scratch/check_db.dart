import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  final client = SupabaseClient(
    'https://klhramhdlkvxfbpnjoca.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtsaHJhbWhkbGt2eGZicG5qb2NhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTEzOTgyMzIsImV4cCI6MjEwNjk3NDIzMn0.CQALcq7LcciFbNqR9xBjKsNaVl3WzB_Rku7mQMt6aKY'
  );

  print('=== USUARIOS ===');
  final users = await client.from('usuarios').select();
  for (var u in users) {
    print(u);
  }

  print('\n=== PROFESORES / DOCENTES ===');
  try {
    final teachers = await client.from('docentes').select();
    for (var t in teachers) {
      print(t);
    }
  } catch (e) {
    print('docentes err: $e');
  }

  print('\n=== CURSOS ===');
  final courses = await client.from('cursos').select();
  for (var c in courses) {
    print(c);
  }

  print('\n=== ESTUDIANTES ===');
  final students = await client.from('estudiantes').select();
  for (var s in students) {
    print(s);
  }

  print('\n=== ASISTENCIAS ===');
  final assist = await client.from('asistencias').select();
  for (var a in assist) {
    print(a);
  }

  print('\n=== CALIFICACIONES ===');
  final grades = await client.from('calificaciones').select();
  for (var g in grades) {
    print(g);
  }
}
