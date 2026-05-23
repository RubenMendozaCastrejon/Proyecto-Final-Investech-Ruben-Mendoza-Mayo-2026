class UserModel {
  final String uid;
  final String nombre;
  final String correo;
  final double fondos;
  final String? numeroTarjeta; // últimos 4 dígitos
  final String? tipoTarjeta;   // 'Visa', 'Mastercard', etc.

  UserModel({
    required this.uid,
    required this.nombre,
    required this.correo,
    this.fondos = 0.0,
    this.numeroTarjeta,
    this.tipoTarjeta,
  });

  // Firestore → objeto
  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid:           uid,
      nombre:        map['nombre']        ?? '',
      correo:        map['correo']        ?? '',
      fondos:        (map['fondos']       ?? 0).toDouble(),
      numeroTarjeta: map['numeroTarjeta'],
      tipoTarjeta:   map['tipoTarjeta'],
    );
  }

  // objeto → Firestore
  Map<String, dynamic> toMap() {
    return {
      'nombre':        nombre,
      'correo':        correo,
      'fondos':        fondos,
      'numeroTarjeta': numeroTarjeta,
      'tipoTarjeta':   tipoTarjeta,
    };
  }

  UserModel copyWith({
    String?  nombre,
    double?  fondos,
    String?  numeroTarjeta,
    String?  tipoTarjeta,
  }) {
    return UserModel(
      uid:           uid,
      nombre:        nombre        ?? this.nombre,
      correo:        correo,
      fondos:        fondos        ?? this.fondos,
      numeroTarjeta: numeroTarjeta ?? this.numeroTarjeta,
      tipoTarjeta:   tipoTarjeta   ?? this.tipoTarjeta,
    );
  }
}