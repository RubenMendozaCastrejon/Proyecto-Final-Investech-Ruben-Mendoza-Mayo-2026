import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants.dart';
import '../models/transaccion_model.dart';
import '../models/activo_model.dart';

class TransaccionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Stream de transacciones del usuario ─────────────────────────────────
  Stream<List<TransaccionModel>> streamTransacciones(String uidUsuario) {
    return _db
        .collection(AppConstants.colTransacciones)
        .where('uidUsuario', isEqualTo: uidUsuario)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransaccionModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // ── Registrar compra de acciones ────────────────────────────────────────
  Future<void> comprarAcciones({
    required String uidUsuario,
    required String empresaId,
    required String empresaNombre,
    required String empresaSimbolo,
    required int    acciones,
    required double precioUnitario,
  }) async {
    final monto     = acciones * precioUnitario;
    final ahora     = DateTime.now();
    final batch     = _db.batch();

    // 1. Guardar transacción
    final transRef = _db.collection(AppConstants.colTransacciones).doc();
    batch.set(transRef, {
      'uidUsuario':    uidUsuario,
      'tipo':          'compra',
      'monto':         monto,
      'fecha':         ahora.toIso8601String(),
      'empresaId':     empresaId,
      'empresaNombre': empresaNombre,
      'acciones':      acciones,
    });

    // 2. Guardar activo
    final activoRef = _db.collection(AppConstants.colActivos).doc();
    batch.set(activoRef, {
      'uidUsuario':        uidUsuario,
      'empresaId':         empresaId,
      'empresaNombre':     empresaNombre,
      'empresaSimbolo':    empresaSimbolo,
      'accionesCompradas': acciones,
      'precioCompra':      precioUnitario,
      'fechaCompra':       ahora.toIso8601String(),
    });

    // 3. Descontar fondos del usuario
    final userRef = _db.collection(AppConstants.colUsers).doc(uidUsuario);
    batch.update(userRef, {
      'fondos': FieldValue.increment(-monto),
    });

    await batch.commit();
  }

  // ── Depositar dinero ────────────────────────────────────────────────────
  Future<void> depositar({
    required String uidUsuario,
    required double monto,
  }) async {
    final batch  = _db.batch();
    final ahora  = DateTime.now();

    final transRef = _db.collection(AppConstants.colTransacciones).doc();
    batch.set(transRef, {
      'uidUsuario': uidUsuario,
      'tipo':       'deposito',
      'monto':      monto,
      'fecha':      ahora.toIso8601String(),
    });

    final userRef = _db.collection(AppConstants.colUsers).doc(uidUsuario);
    batch.update(userRef, {
      'fondos': FieldValue.increment(monto),
    });

    await batch.commit();
  }

  // ── Retirar dinero ──────────────────────────────────────────────────────
  Future<void> retirar({
    required String uidUsuario,
    required double monto,
    required double fondosActuales,
  }) async {
    if (monto > fondosActuales) {
      throw Exception('Fondos insuficientes para retirar.');
    }

    final batch = _db.batch();
    final ahora = DateTime.now();

    final transRef = _db.collection(AppConstants.colTransacciones).doc();
    batch.set(transRef, {
      'uidUsuario': uidUsuario,
      'tipo':       'retiro',
      'monto':      monto,
      'fecha':      ahora.toIso8601String(),
    });

    final userRef = _db.collection(AppConstants.colUsers).doc(uidUsuario);
    batch.update(userRef, {
      'fondos': FieldValue.increment(-monto),
    });

    await batch.commit();
  }

  // ── Stream de activos del usuario ───────────────────────────────────────
  Stream<List<ActivoModel>> streamActivos(String uidUsuario) {
    return _db
        .collection(AppConstants.colActivos)
        .where('uidUsuario', isEqualTo: uidUsuario)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ActivoModel.fromMap(doc.data(), doc.id))
            .toList());
  }
}