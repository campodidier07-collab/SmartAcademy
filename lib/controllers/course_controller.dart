import 'package:flutter/material.dart';
import '../models/models.dart';
import '../database/database_helper.dart';

class CourseController extends ChangeNotifier {
  List<Course> _courses = [];
  List<Course> get courses => _courses;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadCourses() async {
    _isLoading = true;
    notifyListeners();

    final db = await DatabaseHelper.instance.database;
    final maps = await db.query('cursos');
    
    _courses = maps.map((map) => Course.fromMap(map)).toList();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addCourse(Course course) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('cursos', course.toMap());
    await loadCourses();
  }

  Future<void> updateCourse(Course course) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'cursos',
      course.toMap(),
      where: 'id = ?',
      whereArgs: [course.id],
    );
    await loadCourses();
  }

  Future<void> deleteCourse(int id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(
      'cursos',
      where: 'id = ?',
      whereArgs: [id],
    );
    await loadCourses();
  }
}
