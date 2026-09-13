import 'package:flutter/material.dart';
import '../models/models.dart';
import '../database/database_helper.dart';

class TeacherController extends ChangeNotifier {
  List<Teacher> _teachers = [];
  List<Teacher> get teachers => _teachers;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadTeachers() async {
    _isLoading = true;
    notifyListeners();

    final db = await DatabaseHelper.instance.database;
    final maps = await db.query('profesores');
    
    _teachers = maps.map((map) => Teacher.fromMap(map)).toList();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTeacher(Teacher teacher) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('profesores', teacher.toMap());
    await loadTeachers();
  }

  Future<void> updateTeacher(Teacher teacher) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'profesores',
      teacher.toMap(),
      where: 'id = ?',
      whereArgs: [teacher.id],
    );
    await loadTeachers();
  }

  Future<void> deleteTeacher(int id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(
      'profesores',
      where: 'id = ?',
      whereArgs: [id],
    );
    await loadTeachers();
  }
}
