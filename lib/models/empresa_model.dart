class EmpresaModel {
  final String id;
  final String nombre;
  final String categoria;
  final double precioAccion;
  final String descripcion;
  final String simbolo;      // ej: AAPL, GOOGL
  final double variacion;    // % de cambio del día
  final String logoUrl;

  EmpresaModel({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.precioAccion,
    required this.descripcion,
    required this.simbolo,
    this.variacion = 0.0,
    this.logoUrl   = '',
  });

  factory EmpresaModel.fromMap(Map<String, dynamic> map, String id) {
    return EmpresaModel(
      id:           id,
      nombre:       map['nombre']       ?? '',
      categoria:    map['categoria']    ?? '',
      precioAccion: (map['precioAccion'] ?? 0).toDouble(),
      descripcion:  map['descripcion']  ?? '',
      simbolo:      map['simbolo']      ?? '',
      variacion:    (map['variacion']   ?? 0).toDouble(),
      logoUrl:      map['logoUrl']      ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre':       nombre,
      'categoria':    categoria,
      'precioAccion': precioAccion,
      'descripcion':  descripcion,
      'simbolo':      simbolo,
      'variacion':    variacion,
      'logoUrl':      logoUrl,
    };
  }
}