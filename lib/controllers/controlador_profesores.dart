import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../models/models.dart';

class TeacherController extends ChangeNotifier {
  List<Teacher> _teachers = [];
  List<Teacher> get teachers => _teachers;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final client = supa.Supabase.instance.client;

  Future<void> loadTeachers() async {
    _isLoading = true;
    notifyListeners();

    final response = await client.from('profesores').select();
    _teachers = response.map((map) => Teacher.fromMap(map)).toList();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTeacher(Teacher teacher) async {
    final map = teacher.toMap();
    map.remove('id');
    await client.from('profesores').insert(map);

    // Crear cuenta de usuario para que el profesor pueda iniciar sesión
    final hashedPassword = sha256.convert(utf8.encode(teacher.documento)).toString();
    await client.from('usuarios').insert({
      'nombre': teacher.nombre,
      'correo': teacher.correo,
      'contrasena': hashedPassword,
      'rol': 'Profesor',
    });

    await loadTeachers();
  }

  Future<void> updateTeacher(Teacher teacher) async {
    final map = teacher.toMap();
    map.remove('id');
    await client.from('profesores').update(map).eq('id', teacher.id!);
    await loadTeachers();
  }

  Future<void> deleteTeacher(int id) async {
    await client.from('profesores').delete().eq('id', id);
    await loadTeachers();
  }
}
