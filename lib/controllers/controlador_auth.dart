import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../models/models.dart';

class AuthController extends ChangeNotifier {
  User? _currentUser;
  User? get currentUser => _currentUser;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final client = supa.Supabase.instance.client;

  Future<bool> login(String correo, String contrasena) async {
    _isLoading = true;
    notifyListeners();

    final hashedPassword = sha256.convert(utf8.encode(contrasena)).toString();

    final response = await client.from('usuarios').select().eq('correo', correo).eq('contrasena', hashedPassword);

    if (response.isNotEmpty) {
      _currentUser = User.fromMap(response.first);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', _currentUser!.id!);
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      // Fallback para contraseñas antiguas
      final plainResponse = await client.from('usuarios').select().eq('correo', correo).eq('contrasena', contrasena);

      if (plainResponse.isNotEmpty) {
        _currentUser = User.fromMap(plainResponse.first);
        // Migramos la contraseña a hash en la DB
        await client.from('usuarios').update({'contrasena': hashedPassword}).eq('id', _currentUser!.id!);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('userId', _currentUser!.id!);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register(String nombre, String correo, String contrasena, String rol) async {
    _isLoading = true;
    notifyListeners();

    try {
      final existing = await client.from('usuarios').select().eq('correo', correo);
      if (existing.isNotEmpty) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final hashedPassword = sha256.convert(utf8.encode(contrasena)).toString();

      final response = await client.from('usuarios').insert({
        'nombre': nombre,
        'correo': correo,
        'contrasena': hashedPassword,
        'rol': rol,
      }).select().single();
      
      final id = response['id'] as int;
      if (id > 0) {
        _currentUser = User(
          id: id,
          nombre: nombre,
          correo: correo,
          contrasena: contrasena, // Note: storing plaintext locally might not be ideal but matches old behavior
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

  Future<bool> registerUserWithoutLogin(String nombre, String correo, String contrasena, String rol) async {
    try {
      final existing = await client.from('usuarios').select().eq('correo', correo);
      if (existing.isNotEmpty) return false;

      final hashedPassword = sha256.convert(utf8.encode(contrasena)).toString();
      final response = await client.from('usuarios').insert({
        'nombre': nombre,
        'correo': correo,
        'contrasena': hashedPassword,
        'rol': rol,
      }).select().single();
      
      return response['id'] != null;
    } catch (e) {
      debugPrint("Error registering user: $e");
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    notifyListeners();
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    if (_currentUser == null) return false;
    
    final hashedCurrent = sha256.convert(utf8.encode(currentPassword)).toString();
    final hashedNew = sha256.convert(utf8.encode(newPassword)).toString();

    final response = await client.from('usuarios').select().eq('id', _currentUser!.id!).eq('contrasena', hashedCurrent);

    if (response.isEmpty) return false; 

    await client.from('usuarios').update({'contrasena': hashedNew}).eq('id', _currentUser!.id!);
    return true;
  }

  Future<bool> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (userId != null) {
      final response = await client.from('usuarios').select().eq('id', userId);
      if (response.isNotEmpty) {
        _currentUser = User.fromMap(response.first);
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  Future<List<User>> getAllUsers() async {
    final response = await client.from('usuarios').select().order('rol', ascending: true).order('nombre', ascending: true);
    return response.map((map) => User.fromMap(map)).toList();
  }

  Future<bool> deleteUser(int id) async {
    try {
      await client.from('usuarios').delete().eq('id', id);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> resetUserPassword(int id, String newPassword) async {
    try {
      final hashedNew = sha256.convert(utf8.encode(newPassword)).toString();
      await client.from('usuarios').update({'contrasena': hashedNew}).eq('id', id);
      return true;
    } catch (e) {
      return false;
    }
  }
}
