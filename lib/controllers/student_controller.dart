import 'package:flutter/material.dart';
import '../models/models.dart';
import '../database/database_helper.dart';

class StudentController extends ChangeNotifier {
  List<Student> _students = [];
  List<Student> get students => _students;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadStudents() async {
    _isLoading = true;
    notifyListeners();

    final db = await DatabaseHelper.instance.database;
    final maps = await db.query('estudiantes');
    
    _students = maps.map((map) => Student.fromMap(map)).toList();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addStudent(Student student) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('estudiantes', student.toMap());
    await loadStudents();
  }

  Future<void> updateStudent(Student student) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'estudiantes',
      student.toMap(),
      where: 'id = ?',
      whereArgs: [student.id],
    );
    await loadStudents();
  }

  Future<void> deleteStudent(int id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(
      'estudiantes',
      where: 'id = ?',
      whereArgs: [id],
    );
    await loadStudents();
  }
}
