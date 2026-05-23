class ActivoModel {
  final String id;
  final String uidUsuario;
  final String empresaId;
  final String empresaNombre;
  final String empresaSimbolo;
  final int    accionesCompradas;
  final double precioCompra;    // precio por acción al momento de comprar
  final DateTime fechaCompra;

  ActivoModel({
    required this.id,
    required this.uidUsuario,
    required this.empresaId,
    required this.empresaNombre,
    required this.empresaSimbolo,
    required this.accionesCompradas,
    required this.precioCompra,
    required this.fechaCompra,
  });

  double get valorTotal => accionesCompradas * precioCompra;

  factory ActivoModel.fromMap(Map<String, dynamic> map, String id) {
    return ActivoModel(
      id:                 id,
      uidUsuario:         map['uidUsuario']         ?? '',
      empresaId:          map['empresaId']           ?? '',
      empresaNombre:      map['empresaNombre']        ?? '',
      empresaSimbolo:     map['empresaSimbolo']       ?? '',
      accionesCompradas:  (map['accionesCompradas']  ?? 0).toInt(),
      precioCompra:       (map['precioCompra']        ?? 0).toDouble(),
      fechaCompra:        DateTime.parse(map['fechaCompra']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uidUsuario':        uidUsuario,
      'empresaId':         empresaId,
      'empresaNombre':     empresaNombre,
      'empresaSimbolo':    empresaSimbolo,
      'accionesCompradas': accionesCompradas,
      'precioCompra':      precioCompra,
      'fechaCompra':       fechaCompra.toIso8601String(),
    };
  }
}