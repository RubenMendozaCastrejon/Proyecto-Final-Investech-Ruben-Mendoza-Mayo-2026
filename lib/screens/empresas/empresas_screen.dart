import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/routes.dart';

class EmpresasScreen extends StatelessWidget {
  const EmpresasScreen({super.key});

  // ── Imagen provisional ────────────────────────────────────────────────
  static const String _headerUrl =
      'https://raw.githubusercontent.com/flutter/website/main/src/assets/images/docs/tools/devtools/performance_overlay_green.png';

  static const List<Map<String, dynamic>> _categorias = [
    {'nombre': 'Tecnología', 'icono': Icons.computer,     'color': Color(0xFF1565C0)},
    {'nombre': 'Energía',    'icono': Icons.bolt,         'color': Color(0xFFF57F17)},
    {'nombre': 'Salud',      'icono': Icons.local_hospital,'color': Color(0xFF2E7D32)},
    {'nombre': 'Finanzas',   'icono': Icons.attach_money, 'color': Color(0xFF6A1B9A)},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Empresas',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryColor,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Selecciona una categoría para invertir',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 16),

              // ── Imagen header ─────────────────────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  _headerUrl,
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Icon(Icons.image_outlined,
                          size: 48, color: Colors.grey),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                'Categorías',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryColor,
                ),
              ),
              const SizedBox(height: 12),

              // ── Grid de categorías ────────────────────────────────────
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.4,
                ),
                itemCount: _categorias.length,
                itemBuilder: (context, index) {
                  final cat = _categorias[index];
                  return GestureDetector(
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.empresaDetalle,
                      arguments: cat['nombre'] as String,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: (cat['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color:
                              (cat['color'] as Color).withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            cat['icono'] as IconData,
                            color: cat['color'] as Color,
                            size: 36,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            cat['nombre'] as String,
                            style: TextStyle(
                              color: cat['color'] as Color,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '5 empresas',
                            style: TextStyle(
                              color: (cat['color'] as Color)
                                  .withOpacity(0.7),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}