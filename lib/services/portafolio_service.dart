import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants.dart';
import '../models/portafolio_model.dart';

class PortafolioService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Stream de portafolios del usuario ───────────────────────────────────
  Stream<List<PortafolioModel>> streamPortafolios(String uidUsuario) {
    return _db
        .collection(AppConstants.colPortafolios)
        .where('uidUsuario', isEqualTo: uidUsuario)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PortafolioModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // ── Crear portafolio ────────────────────────────────────────────────────
  Future<void> crearPortafolio({
    required String uidUsuario,
    required String nombre,
  }) async {
    await _db.collection(AppConstants.colPortafolios).add({
      'uidUsuario':    uidUsuario,
      'nombre':        nombre,
      'activoIds':     [],
      'fechaCreacion': DateTime.now().toIso8601String(),
    });
  }

  // ── Eliminar portafolio ─────────────────────────────────────────────────
  Future<void> eliminarPortafolio(String portafolioId) async {
    await _db
        .collection(AppConstants.colPortafolios)
        .doc(portafolioId)
        .delete();
  }

  // ── Agregar activo a portafolio ─────────────────────────────────────────
  Future<void> agregarActivo({
    required String portafolioId,
    required String activoId,
  }) async {
    await _db
        .collection(AppConstants.colPortafolios)
        .doc(portafolioId)
        .update({
      'activoIds': FieldValue.arrayUnion([activoId]),
    });
  }

  // ── Remover activo de portafolio ────────────────────────────────────────
  Future<void> removerActivo({
    required String portafolioId,
    required String activoId,
  }) async {
    await _db
        .collection(AppConstants.colPortafolios)
        .doc(portafolioId)
        .update({
      'activoIds': FieldValue.arrayRemove([activoId]),
    });
  }
}