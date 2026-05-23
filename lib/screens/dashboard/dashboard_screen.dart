import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/routes.dart';
import '../../providers/auth_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // ── URL de imagen provisional (reemplaza por tu link de GitHub) ──────────
  static const String _bannerUrl =
      'https://raw.githubusercontent.com/flutter/website/main/src/assets/images/docs/tools/devtools/dark-theme-flow-screenshot.png';

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<AuthProvider>().usuario;

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hola, ${usuario?.nombre.split(' ').first ?? 'Inversor'} 👋',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                      const Text(
                        'Bienvenido a Investech',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    backgroundColor: AppConstants.primaryColor,
                    child: Text(
                      (usuario?.nombre.isNotEmpty == true)
                          ? usuario!.nombre[0].toUpperCase()
                          : 'I',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── Imagen banner provisional ────────────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  _bannerUrl,
                  width: double.infinity,
                  height: 160,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: double.infinity,
                    height: 160,
                    color: AppConstants.primaryColor.withOpacity(0.1),
                    child: const Center(
                      child: Icon(Icons.image_outlined,
                          size: 48, color: Colors.grey),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Tarjeta de fondos ────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppConstants.primaryColor,
                      AppConstants.secondaryColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fondos disponibles',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${(usuario?.fondos ?? 0).toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      usuario?.numeroTarjeta != null
                          ? '**** **** **** ${usuario!.numeroTarjeta}'
                          : 'Sin tarjeta registrada',
                      style: const TextStyle(
                          color: Colors.white60, fontSize: 12),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Acceso rápido ────────────────────────────────────────────
              const Text(
                'Acceso rápido',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryColor,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _tarjetaAcceso(
                    context,
                    icono: Icons.business,
                    label: 'Empresas',
                    color: AppConstants.accentColor,
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.empresas),
                  ),
                  const SizedBox(width: 12),
                  _tarjetaAcceso(
                    context,
                    icono: Icons.receipt_long,
                    label: 'Transacciones',
                    color: AppConstants.successColor,
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.transacciones),
                  ),
                  const SizedBox(width: 12),
                  _tarjetaAcceso(
                    context,
                    icono: Icons.work,
                    label: 'Portafolios',
                    color: Colors.deepOrange,
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.portafolios),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── Botón principal ir a Empresas ────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.empresas),
                  icon: const Icon(Icons.trending_up),
                  label: const Text(
                    'Explorar Empresas e Invertir',
                    style: TextStyle(fontSize: 15),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tarjetaAcceso(
    BuildContext context, {
    required IconData icono,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icono, color: color, size: 28),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}