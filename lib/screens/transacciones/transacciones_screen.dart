import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/routes.dart';
import '../../models/transaccion_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/transaccion_service.dart';

class TransaccionesScreen extends StatelessWidget {
  const TransaccionesScreen({super.key});

  static const String _headerUrl =
      'https://raw.githubusercontent.com/flutter/website/main/src/assets/images/docs/tools/devtools/logging_screen_dark.png';

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<AuthProvider>().usuario;

    if (usuario == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
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
                    height: 130,
                    fit:    BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 130,
                      color:  AppConstants.primaryColor.withOpacity(0.2),
                    ),
                  ),
                ),
                Container(
                  height: 130,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft:  Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                    color: AppConstants.primaryColor.withOpacity(0.75),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left:   20,
                  right:  20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Transacciones',
                        style: TextStyle(
                          color:      Colors.white,
                          fontSize:   22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.pushNamed(
                            context, AppRoutes.metodosPago),
                        icon: const Icon(Icons.credit_card,
                            color: Colors.white, size: 16),
                        label: const Text(
                          'Pagos',
                          style: TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white54),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Text(
                    'Historial',
                    style: TextStyle(
                      fontSize:   16,
                      fontWeight: FontWeight.bold,
                      color:      AppConstants.primaryColor,
                    ),
                  ),
                  const Spacer(),
                  // Chip de fondos
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color:        AppConstants.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Fondos: \$${(usuario.fondos).toStringAsFixed(2)}',
                      style: const TextStyle(
                        color:      AppConstants.primaryColor,
                        fontSize:   12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ── Lista de transacciones ───────────────────────────────────
            Expanded(
              child: StreamBuilder<List<TransaccionModel>>(
                stream: TransaccionService()
                    .streamTransacciones(usuario.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }

                  final lista = snapshot.data ?? [];

                  if (lista.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size:  64,
                            color: AppConstants.primaryColor
                                .withOpacity(0.3),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Aún no tienes transacciones',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Invierte en una empresa para empezar',
                            style: TextStyle(
                                color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 4),
                    itemCount: lista.length,
                    itemBuilder: (context, index) {
                      return _tarjetaTransaccion(lista[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tarjetaTransaccion(TransaccionModel t) {
    final esCompra   = t.tipo == 'compra';
    final esDeposito = t.tipo == 'deposito';
    final esRetiro   = t.tipo == 'retiro';

    Color color;
    IconData icono;
    String titulo;

    if (esCompra) {
      color  = AppConstants.primaryColor;
      icono  = Icons.trending_up;
      titulo = t.empresaNombre ?? 'Inversión';
    } else if (esDeposito) {
      color  = AppConstants.successColor;
      icono  = Icons.add_circle_outline;
      titulo = 'Depósito';
    } else {
      color  = AppConstants.errorColor;
      icono  = Icons.remove_circle_outline;
      titulo = 'Retiro';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color:  Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icono
          Container(
            width:  44,
            height: 44,
            decoration: BoxDecoration(
              color:        color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icono, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize:   14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  esCompra
                      ? '${t.acciones} acción(es) · ${t.tipo}'
                      : t.tipo,
                  style: const TextStyle(
                      color: Colors.grey, fontSize: 12),
                ),
                Text(
                  _formatFecha(t.fecha),
                  style: const TextStyle(
                      color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
          // Monto
          Text(
            '${esRetiro || esCompra ? '-' : '+'}\$${t.monto.toStringAsFixed(2)}',
            style: TextStyle(
              color:      esDeposito
                  ? AppConstants.successColor
                  : AppConstants.errorColor,
              fontWeight: FontWeight.bold,
              fontSize:   15,
            ),
          ),
        ],
      ),
    );
  }

  String _formatFecha(DateTime fecha) {
    final meses = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    return '${fecha.day} ${meses[fecha.month - 1]} ${fecha.year}  '
        '${fecha.hour.toString().padLeft(2, '0')}:'
        '${fecha.minute.toString().padLeft(2, '0')}';
  }
}