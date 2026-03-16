import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Always authenticated - no login required
  bool _isAuthenticated = true;
  String? _userEmail = 'admin@warehouse.com';
  String? _userName = 'Admin User';

  bool get isAuthenticated => _isAuthenticated;
  String? get userEmail => _userEmail;
  String? get userName => _userName;

  // Login method - always returns true (no auth required)
  Future<bool> login(String email, String password) async {
    return true;
  }

  // Signup method - always returns true (no auth required)
  Future<bool> signup(String name, String email, String password) async {
    return true;
  }

  // Logout method - does nothing (auth always enabled)
  void logout() {
    // No-op - always stay authenticated
  }

  // Check if user is logged in - always true
  Future<void> checkAuthStatus() async {
    _isAuthenticated = true;
    notifyListeners();
  }
}
