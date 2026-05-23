import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/routes.dart';
import '../../providers/auth_provider.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  static const String _headerUrl =
      'https://raw.githubusercontent.com/flutter/website/main/src/assets/images/docs/tools/devtools/dark-theme-flow-screenshot.png';

  static const List<Map<String, dynamic>> _colecciones = [
    {
      'nombre':      AppConstants.colUsers,
      'label':       'Usuarios',
      'icono':       Icons.people_outline,
      'color':       Color(0xFF1565C0),
      'descripcion': 'Gestiona los usuarios registrados',
    },
    {
      'nombre':      AppConstants.colEmpresas,
      'label':       'Empresas',
      'icono':       Icons.business_outlined,
      'color':       Color(0xFFF57F17),
      'descripcion': 'Administra las empresas e inversiones',
    },
    {
      'nombre':      AppConstants.colActivos,
      'label':       'Activos',
      'icono':       Icons.trending_up,
      'color':       Color(0xFF2E7D32),
      'descripcion': 'Acciones compradas por usuarios',
    },
    {
      'nombre':      AppConstants.colTransacciones,
      'label':       'Transacciones',
      'icono':       Icons.receipt_long_outlined,
      'color':       Color(0xFF6A1B9A),
      'descripcion': 'Historial de movimientos financieros',
    },
    {
      'nombre':      AppConstants.colPortafolios,
      'label':       'Portafolios',
      'icono':       Icons.work_outline,
      'color':       Color(0xFFD84315),
      'descripcion': 'Portafolios creados por usuarios',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header imagen ──────────────────────────────────────────
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft:  Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  child: Image.network(
                    _headerUrl,
                    width:  double.infinity,
                    height: 160,
                    fit:    BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 160,
                      color:  Colors.deepOrange.withOpacity(0.3),
                    ),
                  ),
                ),
                Container(
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft:  Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                    color: const Color(0xFF1A1A2E).withOpacity(0.7),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left:   20,
                  right:  20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.admin_panel_settings,
                                color: Colors.deepOrange,
                                size:  22,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Panel Admin',
                                style: TextStyle(
                                  color:      Colors.white,
                                  fontSize:   22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Text(
                            'Investech — Control total de la base de datos',
                            style: TextStyle(
                                color: Colors.white60, fontSize: 11),
                          ),
                        ],
                      ),
                      // Cerrar sesión
                      IconButton(
                        icon: const Icon(Icons.logout,
                            color: Colors.deepOrange),
                        onPressed: () async {
                          await context
                              .read<AuthProvider>()
                              .logout();
                          if (!context.mounted) return;
                          Navigator.pushReplacementNamed(
                              context, AppRoutes.login);
                        },
                        tooltip: 'Cerrar sesión',
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Colecciones de Firestore',
                style: TextStyle(
                  color:      Colors.white70,
                  fontSize:   13,
                  letterSpacing: 1.2,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Lista de colecciones ─────────────────────────────────
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _colecciones.length,
                itemBuilder: (context, index) {
                  final col = _colecciones[index];
                  return _tarjetaColeccion(context, col);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tarjetaColeccion(
      BuildContext context, Map<String, dynamic> col) {
    final color = col['color'] as Color;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.adminTabla,
        arguments: col['nombre'] as String,
      ),
      child: Container(
        margin:  const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:        const Color(0xFF16213E),
          borderRadius: BorderRadius.circular(16),
          border:       Border.all(
              color: color.withOpacity(0.3), width: 1),
        ),
        child: Row(
          children: [
            // Icono
            Container(
              width:  50,
              height: 50,
              decoration: BoxDecoration(
                color:        color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                col['icono'] as IconData,
                color: color,
                size:  26,
              ),
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    col['label'] as String,
                    style: const TextStyle(
                      color:      Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize:   15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    col['descripcion'] as String,
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    col['nombre'] as String,
                    style: TextStyle(
                      color:    color.withOpacity(0.8),
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: color.withOpacity(0.6)),
          ],
        ),
      ),
    );
  }
}