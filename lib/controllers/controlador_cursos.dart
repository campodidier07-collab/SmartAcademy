import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../models/models.dart';

class CourseController extends ChangeNotifier {
  List<Course> _courses = [];
  List<Course> get courses => _courses;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final client = supa.Supabase.instance.client;

  Future<void> loadCourses() async {
    _isLoading = true;
    notifyListeners();

    final response = await client.from('cursos').select();
    _courses = response.map((map) => Course.fromMap(map)).toList();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addCourse(Course course) async {
    final map = course.toMap();
    map.remove('id');
    await client.from('cursos').insert(map);
    await loadCourses();
  }

  Future<void> updateCourse(Course course) async {
    final map = course.toMap();
    map.remove('id');
    await client.from('cursos').update(map).eq('id', course.id!);
    await loadCourses();
  }

  Future<void> deleteCourse(int id) async {
    await client.from('cursos').delete().eq('id', id);
    await loadCourses();
  }
}
