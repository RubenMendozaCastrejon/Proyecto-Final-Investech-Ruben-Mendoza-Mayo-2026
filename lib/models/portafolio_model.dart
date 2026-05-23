class PortafolioModel {
  final String       id;
  final String       uidUsuario;
  final String       nombre;
  final List<String> activoIds;   // IDs de documentos en colección 'activos'
  final DateTime     fechaCreacion;

  PortafolioModel({
    required this.id,
    required this.uidUsuario,
    required this.nombre,
    this.activoIds    = const [],
    required this.fechaCreacion,
  });

  factory PortafolioModel.fromMap(Map<String, dynamic> map, String id) {
    return PortafolioModel(
      id:            id,
      uidUsuario:    map['uidUsuario']    ?? '',
      nombre:        map['nombre']        ?? '',
      activoIds:     List<String>.from(map['activoIds'] ?? []),
      fechaCreacion: DateTime.parse(map['fechaCreacion']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uidUsuario':    uidUsuario,
      'nombre':        nombre,
      'activoIds':     activoIds,
      'fechaCreacion': fechaCreacion.toIso8601String(),
    };
  }

  PortafolioModel copyWith({String? nombre, List<String>? activoIds}) {
    return PortafolioModel(
      id:            id,
      uidUsuario:    uidUsuario,
      nombre:        nombre     ?? this.nombre,
      activoIds:     activoIds  ?? this.activoIds,
      fechaCreacion: fechaCreacion,
    );
  }
}