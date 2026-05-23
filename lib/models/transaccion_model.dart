class TransaccionModel {
  final String   id;
  final String   uidUsuario;
  final String   tipo;          // 'compra', 'deposito', 'retiro'
  final double   monto;
  final DateTime fecha;
  final String?  empresaId;
  final String?  empresaNombre;
  final int?     acciones;

  TransaccionModel({
    required this.id,
    required this.uidUsuario,
    required this.tipo,
    required this.monto,
    required this.fecha,
    this.empresaId,
    this.empresaNombre,
    this.acciones,
  });

  factory TransaccionModel.fromMap(Map<String, dynamic> map, String id) {
    return TransaccionModel(
      id:            id,
      uidUsuario:    map['uidUsuario']    ?? '',
      tipo:          map['tipo']          ?? '',
      monto:         (map['monto']        ?? 0).toDouble(),
      fecha:         DateTime.parse(map['fecha']),
      empresaId:     map['empresaId'],
      empresaNombre: map['empresaNombre'],
      acciones:      map['acciones'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uidUsuario':    uidUsuario,
      'tipo':          tipo,
      'monto':         monto,
      'fecha':         fecha.toIso8601String(),
      'empresaId':     empresaId,
      'empresaNombre': empresaNombre,
      'acciones':      acciones,
    };
  }
}