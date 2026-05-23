import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Obtener todos los documentos de una colección (stream) ──────────────
  Stream<List<Map<String, dynamic>>> streamColeccion(String coleccion) {
    return _db.collection(coleccion).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // incluir el ID del documento
        return data;
      }).toList();
    });
  }

  // ── Obtener todos los documentos una vez ────────────────────────────────
  Future<List<Map<String, dynamic>>> obtenerColeccion(String coleccion) async {
    final snapshot = await _db.collection(coleccion).get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  // ── Obtener un documento por ID ─────────────────────────────────────────
  Future<Map<String, dynamic>?> obtenerDocumento(
      String coleccion, String docId) async {
    final doc = await _db.collection(coleccion).doc(docId).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    data['id'] = doc.id;
    return data;
  }

  // ── Crear documento (ID automático) ────────────────────────────────────
  Future<String> crearDocumento(
      String coleccion, Map<String, dynamic> data) async {
    final ref = await _db.collection(coleccion).add(data);
    return ref.id;
  }

  // ── Crear documento con ID específico ──────────────────────────────────
  Future<void> crearDocumentoConId(
      String coleccion, String docId, Map<String, dynamic> data) async {
    await _db.collection(coleccion).doc(docId).set(data);
  }

  // ── Actualizar documento ────────────────────────────────────────────────
  Future<void> actualizarDocumento(
      String coleccion, String docId, Map<String, dynamic> data) async {
    await _db.collection(coleccion).doc(docId).update(data);
  }

  // ── Eliminar documento ──────────────────────────────────────────────────
  Future<void> eliminarDocumento(String coleccion, String docId) async {
    await _db.collection(coleccion).doc(docId).delete();
  }

  // ── Consulta con filtro ─────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> consultarPorCampo({
    required String coleccion,
    required String campo,
    required dynamic valor,
  }) async {
    final snapshot = await _db
        .collection(coleccion)
        .where(campo, isEqualTo: valor)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  // ── Stream con filtro por usuario ───────────────────────────────────────
  Stream<List<Map<String, dynamic>>> streamPorUsuario({
    required String coleccion,
    required String uidUsuario,
  }) {
    return _db
        .collection(coleccion)
        .where('uidUsuario', isEqualTo: uidUsuario)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }
}