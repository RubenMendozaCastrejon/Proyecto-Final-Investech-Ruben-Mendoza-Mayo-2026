import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/routes.dart';
import '../../models/empresa_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/empresa_service.dart';
import '../../services/transaccion_service.dart';

class InvertirScreen extends StatefulWidget {
  final String empresaId;
  const InvertirScreen({super.key, required this.empresaId});

  @override
  State<InvertirScreen> createState() => _InvertirScreenState();
}

class _InvertirScreenState extends State<InvertirScreen> {
  final EmpresaService     _empresaService     = EmpresaService();
  final TransaccionService _transaccionService = TransaccionService();

  EmpresaModel? _empresa;
  bool          _cargando     = true;
  bool          _procesando   = false;
  int           _acciones     = 1;

  // ── Imagen provisional ─────────────────────────────────────────────────
  static const String _headerUrl =
      'https://raw.githubusercontent.com/flutter/website/main/src/assets/images/docs/tools/devtools/network_screen_dark.png';

  @override
  void initState() {
    super.initState();
    _cargarEmpresa();
  }

  Future<void> _cargarEmpresa() async {
    final empresa = await _empresaService.obtenerEmpresa(widget.empresaId);
    setState(() {
      _empresa  = empresa;
      _cargando = false;
    });
  }

  double get _total => (_empresa?.precioAccion ?? 0) * _acciones;

  Future<void> _invertir() async {
    if (_empresa == null) return;

    final auth   = context.read<AuthProvider>();
    final fondos = auth.usuario?.fondos ?? 0;

    if (_total > fondos) {
      _mostrarError(
          'Fondos insuficientes. Tienes \$${fondos.toStringAsFixed(2)} disponibles.');
      return;
    }

    setState(() => _procesando = true);

    try {
      await _transaccionService.comprarAcciones(
        uidUsuario:     auth.usuario!.uid,
        empresaId:      _empresa!.id,
        empresaNombre:  _empresa!.nombre,
        empresaSimbolo: _empresa!.simbolo,
        acciones:       _acciones,
        precioUnitario: _empresa!.precioAccion,
      );

      await auth.refrescarUsuario();

      if (!mounted) return;
      _mostrarExito();
    } catch (e) {
      if (!mounted) return;
      _mostrarError('Error al procesar la inversión. Intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _procesando = false);
    }
  }

  void _mostrarError(String mensaje) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: AppConstants.errorColor),
            SizedBox(width: 8),
            Text('Error', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _mostrarExito() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppConstants.successColor),
            SizedBox(width: 8),
            Text('¡Inversión exitosa!', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Compraste $_acciones acción(es) de ${_empresa!.nombre}.'),
            const SizedBox(height: 8),
            Text(
              'Total invertido: \$${_total.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);           // cierra dialog
              Navigator.pop(context);           // vuelve a lista empresas
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.successColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Ver mis transacciones'),
          ),
        ],
      ),
    ).then((_) {
      if (mounted) {
        Navigator.pushNamed(context, AppRoutes.transacciones);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final fondos = context.watch<AuthProvider>().usuario?.fondos ?? 0;

    if (_cargando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_empresa == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Empresa no encontrada.')),
      );
    }

    final suficiente = _total <= fondos;

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
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
                      height: 170,
                      fit:    BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 170,
                        color:  AppConstants.primaryColor.withOpacity(0.2),
                      ),
                    ),
                  ),
                  Container(
                    height: 170,
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
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color:        Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _empresa!.simbolo.length >= 2
                                ? _empresa!.simbolo.substring(0, 2)
                                : _empresa!.simbolo,
                            style: const TextStyle(
                              color:      Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize:   16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _empresa!.nombre,
                                style: const TextStyle(
                                  color:      Colors.white,
                                  fontSize:   18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _empresa!.categoria,
                                style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Descripción ──────────────────────────────────────
                    const Text(
                      'Acerca de la empresa',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize:   15,
                        color:      AppConstants.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _empresa!.descripcion,
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 13, height: 1.5),
                    ),

                    const SizedBox(height: 20),

                    // ── Info precio ──────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:        Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color:  Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _infoChip(
                            label: 'Precio/acción',
                            valor:
                                '\$${_empresa!.precioAccion.toStringAsFixed(2)}',
                            color: AppConstants.primaryColor,
                          ),
                          Container(
                              width: 1, height: 40, color: Colors.grey.shade200),
                          _infoChip(
                            label: 'Variación',
                            valor:
                                '${_empresa!.variacion >= 0 ? '+' : ''}${_empresa!.variacion.toStringAsFixed(1)}%',
                            color: _empresa!.variacion >= 0
                                ? AppConstants.successColor
                                : AppConstants.errorColor,
                          ),
                          Container(
                              width: 1, height: 40, color: Colors.grey.shade200),
                          _infoChip(
                            label: 'Símbolo',
                            valor: _empresa!.simbolo,
                            color: Colors.deepOrange,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Fondos disponibles ───────────────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color:        AppConstants.primaryColor.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(12),
                        border:       Border.all(
                          color: AppConstants.primaryColor.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.account_balance_wallet_outlined,
                            color: AppConstants.primaryColor,
                            size:  20,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Fondos disponibles:',
                            style: TextStyle(
                                color: Colors.grey, fontSize: 13),
                          ),
                          const Spacer(),
                          Text(
                            '\$${fondos.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color:      AppConstants.primaryColor,
                              fontSize:   15,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Selector de acciones ─────────────────────────────
                    const Text(
                      'Cantidad de acciones',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize:   15,
                        color:      AppConstants.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:        Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color:  Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Botón -
                              _botonCantidad(
                                icono: Icons.remove,
                                onTap: () {
                                  if (_acciones > 1) {
                                    setState(() => _acciones--);
                                  }
                                },
                              ),
                              const SizedBox(width: 24),
                              // Número
                              Column(
                                children: [
                                  Text(
                                    '$_acciones',
                                    style: const TextStyle(
                                      fontSize:   36,
                                      fontWeight: FontWeight.bold,
                                      color:      AppConstants.primaryColor,
                                    ),
                                  ),
                                  const Text(
                                    'acciones',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 12),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 24),
                              // Botón +
                              _botonCantidad(
                                icono: Icons.add,
                                onTap: () =>
                                    setState(() => _acciones++),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Slider
                          Slider(
                            value:    _acciones.toDouble(),
                            min:      1,
                            max:      100,
                            divisions: 99,
                            activeColor: AppConstants.primaryColor,
                            onChanged: (v) =>
                                setState(() => _acciones = v.round()),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Resumen total ────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:        suficiente
                            ? AppConstants.successColor.withOpacity(0.08)
                            : AppConstants.errorColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                        border:       Border.all(
                          color: suficiente
                              ? AppConstants.successColor.withOpacity(0.3)
                              : AppConstants.errorColor.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Total a invertir',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 12),
                              ),
                              Text(
                                '\$${_total.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize:   22,
                                  fontWeight: FontWeight.bold,
                                  color:      suficiente
                                      ? AppConstants.successColor
                                      : AppConstants.errorColor,
                                ),
                              ),
                            ],
                          ),
                          if (!suficiente)
                            const Row(
                              children: [
                                Icon(Icons.warning_amber,
                                    color: AppConstants.errorColor,
                                    size:  18),
                                SizedBox(width: 4),
                                Text(
                                  'Fondos\ninsuficientes',
                                  style: TextStyle(
                                    color:    AppConstants.errorColor,
                                    fontSize: 11,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Botón invertir ───────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed:
                            (!suficiente || _procesando) ? null : _invertir,
                        icon: _procesando
                            ? const SizedBox(
                                width:  18,
                                height: 18,
                                child:  CircularProgressIndicator(
                                  color:       Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.trending_up),
                        label: Text(
                          _procesando ? 'Procesando...' : 'Confirmar inversión',
                          style: const TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: suficiente
                              ? AppConstants.primaryColor
                              : Colors.grey,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ── Botón depositar si no tiene fondos ───────────────
                    if (!suficiente)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pushNamed(
                              context, AppRoutes.metodosPago),
                          icon: const Icon(Icons.add_card),
                          label: const Text('Depositar fondos'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppConstants.primaryColor,
                            side: const BorderSide(
                                color: AppConstants.primaryColor),
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
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

  Widget _infoChip({
    required String label,
    required String valor,
    required Color  color,
  }) {
    return Column(
      children: [
        Text(
          valor,
          style: TextStyle(
            color:      color,
            fontWeight: FontWeight.bold,
            fontSize:   16,
          ),
        ),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }

  Widget _botonCantidad({
    required IconData    icono,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width:  44,
        height: 44,
        decoration: BoxDecoration(
          color:        AppConstants.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icono, color: AppConstants.primaryColor),
      ),
    );
  }
}