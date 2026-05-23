import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthStatus { inicial, cargando, autenticado, noAutenticado, admin, error }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus  _status  = AuthStatus.inicial;
  UserModel?  _usuario;
  String      _error   = '';

  AuthStatus get status  => _status;
  UserModel? get usuario => _usuario;
  String     get error   => _error;
  bool get isAdmin => _status == AuthStatus.admin;

  AuthProvider() {
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _status  = AuthStatus.noAutenticado;
      _usuario = null;
    } else if (firebaseUser.email == 'admin@investech.com') {
      _status  = AuthStatus.admin;
      _usuario = null;
    } else {
      _usuario = await _authService.obtenerUsuario(firebaseUser.uid);
      _status  = AuthStatus.autenticado;
    }
    notifyListeners();
  }

  // ── Registro ────────────────────────────────────────────────────────────
  Future<bool> registrar({
    required String nombre,
    required String correo,
    required String password,
  }) async {
    _status = AuthStatus.cargando;
    _error  = '';
    notifyListeners();

    try {
      _usuario = await _authService.registrar(
        nombre:   nombre,
        correo:   correo,
        password: password,
      );
      _status = AuthStatus.autenticado;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error  = _mensajeError(e.code);
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  // ── Login usuario ───────────────────────────────────────────────────────
  Future<bool> loginUsuario({
    required String correo,
    required String password,
  }) async {
    _status = AuthStatus.cargando;
    _error  = '';
    notifyListeners();

    try {
      _usuario = await _authService.loginUsuario(
        correo:   correo,
        password: password,
      );
      _status = AuthStatus.autenticado;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error  = _mensajeError(e.code);
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  // ── Login admin ─────────────────────────────────────────────────────────
  Future<bool> loginAdmin({
    required String correo,
    required String password,
  }) async {
    _status = AuthStatus.cargando;
    _error  = '';
    notifyListeners();

    try {
      await _authService.loginAdmin(correo: correo, password: password);
      _status = AuthStatus.admin;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error  = _mensajeError(e.code);
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  // ── Logout ──────────────────────────────────────────────────────────────
  Future<void> logout() async {
    await _authService.logout();
    _usuario = null;
    _status  = AuthStatus.noAutenticado;
    notifyListeners();
  }

  // ── Refrescar datos del usuario (ej: después de depositar) ──────────────
  Future<void> refrescarUsuario() async {
    if (_usuario == null) return;
    _usuario = await _authService.obtenerUsuario(_usuario!.uid);
    notifyListeners();
  }

  // ── Mensajes de error legibles ──────────────────────────────────────────
  String _mensajeError(String code) {
    switch (code) {
      case 'user-not-found':       return 'No existe una cuenta con ese correo.';
      case 'wrong-password':       return 'Contraseña incorrecta.';
      case 'email-already-in-use': return 'Ya existe una cuenta con ese correo.';
      case 'weak-password':        return 'La contraseña es muy débil (mínimo 6 caracteres).';
      case 'invalid-email':        return 'El correo no tiene un formato válido.';
      case 'admin-not-allowed':    return 'Usa el acceso de administrador.';
      case 'invalid-admin':        return 'Credenciales de administrador incorrectas.';
      default:                     return 'Ocurrió un error. Intenta de nuevo.';
    }
  }
}