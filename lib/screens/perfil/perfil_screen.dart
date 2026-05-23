import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/routes.dart';
import '../../providers/auth_provider.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  // ── Imagen provisional (reemplaza por tu link de GitHub) ─────────────────
  static const String _avatarBannerUrl =
      'https://raw.githubusercontent.com/flutter/website/main/src/assets/images/docs/tools/devtools/inspector_screenshot.png';

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<AuthProvider>().usuario;

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── Header con imagen ────────────────────────────────────────
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children: [
                  // Banner
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                    child: Image.network(
                      _avatarBannerUrl,
                      width: double.infinity,
                      height: 140,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 140,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                  ),
                  // Overlay oscuro
                  Container(
                    height: 140,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                      color: AppConstants.primaryColor.withOpacity(0.6),
                    ),
                  ),
                  // Avatar
                  Positioned(
                    bottom: -36,
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 36,
                        backgroundColor: AppConstants.primaryColor,
                        child: Text(
                          (usuario?.nombre.isNotEmpty == true)
                              ? usuario!.nombre[0].toUpperCase()
                              : 'I',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 50),

              // ── Nombre y correo ──────────────────────────────────────────
              Text(
                usuario?.nombre ?? 'Usuario',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                usuario?.correo ?? '',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),

              const SizedBox(height: 24),

              // ── Info tarjeta ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _filaPerfil(
                        icono: Icons.account_balance_wallet_outlined,
                        label: 'Fondos disponibles',
                        valor:
                            '\$${(usuario?.fondos ?? 0).toStringAsFixed(2)}',
                      ),
                      const Divider(height: 20),
                      _filaPerfil(
                        icono: Icons.credit_card_outlined,
                        label: 'Tarjeta registrada',
                        valor: usuario?.numeroTarjeta != null
                            ? '**** ${usuario!.numeroTarjeta}'
                            : 'Ninguna',
                      ),
                      const Divider(height: 20),
                      _filaPerfil(
                        icono: Icons.email_outlined,
                        label: 'Correo',
                        valor: usuario?.correo ?? '',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Opciones ─────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _opcionPerfil(
                        context,
                        icono: Icons.receipt_long_outlined,
                        label: 'Mis transacciones',
                        onTap: () => Navigator.pushNamed(
                            context, AppRoutes.transacciones),
                      ),
                      const Divider(height: 1, indent: 56),
                      _opcionPerfil(
                        context,
                        icono: Icons.credit_card_outlined,
                        label: 'Métodos de pago',
                        onTap: () => Navigator.pushNamed(
                            context, AppRoutes.metodosPago),
                      ),
                      const Divider(height: 1, indent: 56),
                      _opcionPerfil(
                        context,
                        icono: Icons.work_outline,
                        label: 'Mis portafolios',
                        onTap: () => Navigator.pushNamed(
                            context, AppRoutes.portafolios),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Cerrar sesión ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await context.read<AuthProvider>().logout();
                      if (!context.mounted) return;
                      Navigator.pushReplacementNamed(
                          context, AppRoutes.login);
                    },
                    icon: const Icon(Icons.logout,
                        color: AppConstants.errorColor),
                    label: const Text(
                      'Cerrar sesión',
                      style: TextStyle(color: AppConstants.errorColor),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppConstants.errorColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filaPerfil({
    required IconData icono,
    required String label,
    required String valor,
  }) {
    return Row(
      children: [
        Icon(icono, color: AppConstants.primaryColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label,
              style: const TextStyle(color: Colors.grey, fontSize: 13)),
        ),
        Text(
          valor,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppConstants.primaryColor,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _opcionPerfil(
    BuildContext context, {
    required IconData icono,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icono, color: AppConstants.primaryColor),
      title: Text(label, style: const TextStyle(fontSize: 14)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}