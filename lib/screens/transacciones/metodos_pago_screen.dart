import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/transaccion_service.dart';
import '../../services/firestore_service.dart';

class MetodosPagoScreen extends StatefulWidget {
  const MetodosPagoScreen({super.key});

  @override
  State<MetodosPagoScreen> createState() => _MetodosPagoScreenState();
}

class _MetodosPagoScreenState extends State<MetodosPagoScreen> {
  static const String _headerUrl =
      'https://raw.githubusercontent.com/flutter/website/main/src/assets/images/docs/tools/devtools/inspector_screenshot.png';

  final TransaccionService _transService   = TransaccionService();
  final FirestoreService   _firestoreService = FirestoreService();

  final _montoController   = TextEditingController();
  final _tarjetaController = TextEditingController();
  final _tipoController    = TextEditingController();

  @override
  void dispose() {
    _montoController.dispose();
    _tarjetaController.dispose();
    _tipoController.dispose();
    super.dispose();
  }

  // ── Depositar ────────────────────────────────────────────────────────────
  void _mostrarDialogDepositar(UserModel usuario) {
    _montoController.clear();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Depositar dinero'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (usuario.numeroTarjeta != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Tarjeta: **** ${usuario.numeroTarjeta}',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
            TextField(
              controller:  _montoController,
              keyboardType: const TextInputType.numberWithOptions(
                  decimal: true),
              decoration: InputDecoration(
                labelText:   'Monto a depositar',
                prefixText:  '\$',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final monto = double.tryParse(_montoController.text);
              if (monto == null || monto <= 0) {
                _snack('Ingresa un monto válido',
                    AppConstants.errorColor);
                return;
              }
              Navigator.pop(context);
              await _transService.depositar(
                uidUsuario: usuario.uid,
                monto:      monto,
              );
              await context.read<AuthProvider>().refrescarUsuario();
              if (!mounted) return;
              _snack('Depósito de \$${monto.toStringAsFixed(2)} exitoso',
                  AppConstants.successColor);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.successColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Depositar'),
          ),
        ],
      ),
    );
  }

  // ── Retirar ──────────────────────────────────────────────────────────────
  void _mostrarDialogRetirar(UserModel usuario) {
    _montoController.clear();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Retirar dinero'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Disponible: \$${usuario.fondos.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller:  _montoController,
              keyboardType: const TextInputType.numberWithOptions(
                  decimal: true),
              decoration: InputDecoration(
                labelText:  'Monto a retirar',
                prefixText: '\$',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final monto = double.tryParse(_montoController.text);
              if (monto == null || monto <= 0) {
                _snack('Ingresa un monto válido',
                    AppConstants.errorColor);
                return;
              }
              if (monto > usuario.fondos) {
                _snack('Fondos insuficientes',
                    AppConstants.errorColor);
                return;
              }
              Navigator.pop(context);
              await _transService.retirar(
                uidUsuario:     usuario.uid,
                monto:          monto,
                fondosActuales: usuario.fondos,
              );
              await context.read<AuthProvider>().refrescarUsuario();
              if (!mounted) return;
              _snack('Retiro de \$${monto.toStringAsFixed(2)} exitoso',
                  AppConstants.primaryColor);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.errorColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Retirar'),
          ),
        ],
      ),
    );
  }

  // ── Cambiar tarjeta ──────────────────────────────────────────────────────
  void _mostrarDialogTarjeta(UserModel usuario) {
    _tarjetaController.clear();
    _tipoController.clear();
    String tipoSeleccionado = 'Visa';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: const Text('Cambiar tarjeta'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tipo de tarjeta
              DropdownButtonFormField<String>(
                value: tipoSeleccionado,
                decoration: InputDecoration(
                  labelText: 'Tipo de tarjeta',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                items: ['Visa', 'Mastercard', 'American Express']
                    .map((t) => DropdownMenuItem(
                          value: t,
                          child: Text(t),
                        ))
                    .toList(),
                onChanged: (v) =>
                    setStateDialog(() => tipoSeleccionado = v!),
              ),
              const SizedBox(height: 12),
              // Últimos 4 dígitos
              TextField(
                controller:  _tarjetaController,
                keyboardType: TextInputType.number,
                maxLength:   4,
                decoration: InputDecoration(
                  labelText:  'Últimos 4 dígitos',
                  prefixText: '**** **** **** ',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final digitos = _tarjetaController.text.trim();
                if (digitos.length != 4) {
                  _snack('Ingresa exactamente 4 dígitos',
                      AppConstants.errorColor);
                  return;
                }
                Navigator.pop(ctx);
                await _firestoreService.actualizarDocumento(
                  AppConstants.colUsers,
                  usuario.uid,
                  {
                    'numeroTarjeta': digitos,
                    'tipoTarjeta':   tipoSeleccionado,
                  },
                );
                await context.read<AuthProvider>().refrescarUsuario();
                if (!mounted) return;
                _snack('Tarjeta actualizada correctamente',
                    AppConstants.successColor);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<AuthProvider>().usuario;

    if (usuario == null) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    final tieneTarjeta = usuario.numeroTarjeta != null;

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header imagen ────────────────────────────────────────
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
                      height: 140,
                      fit:    BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 140,
                        color:  AppConstants.primaryColor.withOpacity(0.2),
                      ),
                    ),
                  ),
                  Container(
                    height: 140,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        bottomLeft:  Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                      color: AppConstants.primaryColor.withOpacity(0.75),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios,
                          color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const Positioned(
                    bottom: 20,
                    left:   20,
                    child:  Text(
                      'Métodos de Pago',
                      style: TextStyle(
                        color:      Colors.white,
                        fontSize:   22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Tarjeta visual ───────────────────────────────────
                    Container(
                      width:   double.infinity,
                      height:  180,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: tieneTarjeta
                              ? [
                                  AppConstants.primaryColor,
                                  AppConstants.secondaryColor,
                                ]
                              : [Colors.grey.shade400, Colors.grey.shade600],
                          begin: Alignment.topLeft,
                          end:   Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color:  Colors.black.withOpacity(0.15),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                usuario.tipoTarjeta ?? 'Sin tarjeta',
                                style: const TextStyle(
                                  color:      Colors.white,
                                  fontSize:   16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Icon(Icons.credit_card,
                                  color: Colors.white70, size: 28),
                            ],
                          ),
                          Text(
                            tieneTarjeta
                                ? '**** **** **** ${usuario.numeroTarjeta}'
                                : 'No hay tarjeta registrada',
                            style: const TextStyle(
                              color:    Colors.white,
                              fontSize: 18,
                              letterSpacing: 2,
                            ),
                          ),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                usuario.nombre,
                                style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13),
                              ),
                              Text(
                                '\$${usuario.fondos.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color:      Colors.white,
                                  fontSize:   16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Botones de acción ────────────────────────────────
                    const Text(
                      'Acciones',
                      style: TextStyle(
                        fontSize:   16,
                        fontWeight: FontWeight.bold,
                        color:      AppConstants.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Depositar
                    _botonAccion(
                      icono:    Icons.add_circle_outline,
                      label:    'Depositar dinero',
                      sublabel: 'Agrega fondos a tu cuenta',
                      color:    AppConstants.successColor,
                      onTap:    () => _mostrarDialogDepositar(usuario),
                    ),
                    const SizedBox(height: 10),

                    // Retirar
                    _botonAccion(
                      icono:    Icons.remove_circle_outline,
                      label:    'Retirar dinero',
                      sublabel:
                          'Disponible: \$${usuario.fondos.toStringAsFixed(2)}',
                      color:    AppConstants.errorColor,
                      onTap:    () => _mostrarDialogRetirar(usuario),
                    ),
                    const SizedBox(height: 10),

                    // Cambiar tarjeta
                    _botonAccion(
                      icono:    Icons.credit_card_outlined,
                      label:    tieneTarjeta
                          ? 'Cambiar tarjeta'
                          : 'Agregar tarjeta',
                      sublabel: tieneTarjeta
                          ? 'Tarjeta actual: **** ${usuario.numeroTarjeta}'
                          : 'No tienes tarjeta registrada',
                      color:    AppConstants.primaryColor,
                      onTap:    () => _mostrarDialogTarjeta(usuario),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _botonAccion({
    required IconData     icono,
    required String       label,
    required String       sublabel,
    required Color        color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:        Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color:  Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width:  46,
              height: 46,
              decoration: BoxDecoration(
                color:        color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icono, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize:   14,
                    ),
                  ),
                  Text(
                    sublabel,
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}