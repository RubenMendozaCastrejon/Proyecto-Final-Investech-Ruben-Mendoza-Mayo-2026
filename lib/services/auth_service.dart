import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth    _auth      = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream del usuario autenticado actualmente
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Usuario actual
  User? get currentUser => _auth.currentUser;

  // ── Registro de usuario normal ──────────────────────────────────────────
  Future<UserModel?> registrar({
    required String nombre,
    required String correo,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email:    correo,
      password: password,
    );

    final user = UserModel(
      uid:    credential.user!.uid,
      nombre: nombre,
      correo: correo,
      fondos: 0.0,
    );

    await _firestore
        .collection(AppConstants.colUsers)
        .doc(user.uid)
        .set(user.toMap());

    return user;
  }

  // ── Login usuario normal ────────────────────────────────────────────────
  Future<UserModel?> loginUsuario({
    required String correo,
    required String password,
  }) async {
    // Bloquear login con credenciales de admin desde flujo normal
    if (correo.trim() == AppConstants.adminEmail) {
      throw FirebaseAuthException(
        code:    'admin-not-allowed',
        message: 'Usa el acceso de administrador.',
      );
    }

    final credential = await _auth.signInWithEmailAndPassword(
      email:    correo,
      password: password,
    );

    final doc = await _firestore
        .collection(AppConstants.colUsers)
        .doc(credential.user!.uid)
        .get();

    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!, doc.id);
  }

  // ── Login administrador ─────────────────────────────────────────────────
  Future<bool> loginAdmin({
    required String correo,
    required String password,
  }) async {
    if (correo.trim() != AppConstants.adminEmail ||
        password != AppConstants.adminPassword) {
      throw FirebaseAuthException(
        code:    'invalid-admin',
        message: 'Credenciales de administrador incorrectas.',
      );
    }

    await _auth.signInWithEmailAndPassword(
      email:    correo,
      password: password,
    );
    return true;
  }

  // ── Cerrar sesión ───────────────────────────────────────────────────────
  Future<void> logout() async {
    await _auth.signOut();
  }

  // ── Obtener datos del usuario desde Firestore ───────────────────────────
  Future<UserModel?> obtenerUsuario(String uid) async {
    final doc = await _firestore
        .collection(AppConstants.colUsers)
        .doc(uid)
        .get();

    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!, doc.id);
  }
}