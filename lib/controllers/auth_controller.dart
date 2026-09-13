import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../database/database_helper.dart';

class AuthController extends ChangeNotifier {
  User? _currentUser;
  User? get currentUser => _currentUser;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<bool> login(String correo, String contrasena) async {
    _isLoading = true;
    notifyListeners();

    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'usuarios',
      where: 'correo = ? AND contrasena = ?',
      whereArgs: [correo, contrasena],
    );

    if (maps.isNotEmpty) {
      _currentUser = User.fromMap(maps.first);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', _currentUser!.id!);
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register(String nombre, String correo, String contrasena, String rol) async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = await DatabaseHelper.instance.database;
      
      // Check if user already exists
      final existing = await db.query(
        'usuarios',
        where: 'correo = ?',
        whereArgs: [correo],
      );

      if (existing.isNotEmpty) {
        _isLoading = false;
        notifyListeners();
        return false; // Email already in use
      }

      final newUser = User(
        nombre: nombre,
        correo: correo,
        contrasena: contrasena,
        rol: rol,
      );

      final id = await db.insert('usuarios', newUser.toMap());
      
      if (id > 0) {
        _currentUser = User(
          id: id,
          nombre: nombre,
          correo: correo,
          contrasena: contrasena,
          rol: rol,
        );
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('userId', id);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint("Error registering user: $e");
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    notifyListeners();
  }

  Future<bool> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (userId != null) {
      final db = await DatabaseHelper.instance.database;
      final maps = await db.query(
        'usuarios',
        where: 'id = ?',
        whereArgs: [userId],
      );
      if (maps.isNotEmpty) {
        _currentUser = User.fromMap(maps.first);
        notifyListeners();
        return true;
      }
    }
    return false;
  }
}
