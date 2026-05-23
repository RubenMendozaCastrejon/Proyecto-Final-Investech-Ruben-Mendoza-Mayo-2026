import 'package:flutter/material.dart';

class AppConstants {
  // ── Admin credentials (no se pueden crear desde la app) ──
  static const String adminEmail    = 'admin@investech.com';
  static const String adminPassword = 'Admin1234!';

  // ── Colores principales ──
  static const Color primaryColor   = Color(0xFF1A237E); // Azul oscuro
  static const Color secondaryColor = Color(0xFF283593);
  static const Color accentColor    = Color(0xFF42A5F5); // Azul claro
  static const Color successColor   = Color(0xFF43A047);
  static const Color errorColor     = Color(0xFFE53935);
  static const Color backgroundColor = Color(0xFFF5F7FA);

  // ── Categorías de empresas ──
  static const List<String> categorias = [
    'Tecnología',
    'Energía',
    'Salud',
    'Finanzas',
  ];

  // ── Nombre de colecciones en Firestore ──
  static const String colUsers         = 'users';
  static const String colEmpresas      = 'empresas';
  static const String colActivos       = 'activos';
  static const String colTransacciones = 'transacciones';
  static const String colPortafolios   = 'portafolios';
}