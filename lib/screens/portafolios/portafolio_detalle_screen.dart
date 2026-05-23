import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../models/activo_model.dart';
import '../../models/portafolio_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/portafolio_service.dart';
import '../../services/transaccion_service.dart';

class PortafolioDetalleScreen extends StatefulWidget {
  final String portafolioId;
  const PortafolioDetalleScreen({super.key, required this.portafolioId});

  @override
  State<PortafolioDetalleScreen> createState() =>
      _PortafolioDetalleScreenState();
}

class _PortafolioDetalleScreenState
    extends State<PortafolioDetalleScreen> {
  static const String _headerUrl =
      'https://raw.githubusercontent.com/flutter/website/main/src/assets/images/docs/tools/devtools/performance_overlay_green.png';

  final PortafolioService  _portafolioService  = PortafolioService();
  final TransaccionService _transaccionService = TransaccionService();

  PortafolioModel?      _portafolio;
  List<ActivoModel>     _activosUsuario = [];
  bool                  _cargando       = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final uid = context.read<AuthProvider>().usuario?.uid;
    if (uid == null) return;

    // Escuchar portafolio en tiempo real
    _portafolioService
        .streamPortafolios(uid)
        .listen((lista) {
      final encontrado = lista.where(
          (p) => p.id == widget.portafolioId);
      if (encontrado.isNotEmpty && mounted) {
        setState(() => _portafolio = encontrado.first);
      }
    });

    // Escuchar activos del usuario
    _transaccionService.streamActivos(uid).listen((lista) {
      if (mounted) setState(() => _activosUsuario = lista);
    });

    setState(() => _cargando = false);
  }

  // Activos ya en el portafolio
  List<ActivoModel> get _activosEnPortafolio {
    if (_portafolio == null) return [];
    return _activosUsuario
        .where((a) => _portafolio!.activoIds.contains(a.id))
        .toList();
  }

  // Activos que NO están en el portafolio
  List<ActivoModel> get _activosDisponibles {
    if (_portafolio == null) return _activosUsuario;
    return _activosUsuario
        .where((a) => !_portafolio!.activoIds.contains(a.id))
        .toList();
  }

  void _mostrarDialogAgregarActivo() {
    final disponibles = _activosDisponibles;

    if (disponibles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'No tienes activos disponibles para agregar'),
          backgroundColor: AppConstants.primaryColor,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Agregar activo'),
        content: SizedBox(
          width:      double.maxFinite,
          height:     300,
          child: ListView.builder(
            itemCount: disponibles.length,
            itemBuilder: (context, index) {
              final activo = disponibles[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      AppConstants.primaryColor.withOpacity(0.1),
                  child: Text(
                    activo.empresaSimbolo.length >= 2
                        ? activo.empresaSimbolo.substring(0, 2)
                        : activo.empresaSimbolo,
                    style: const TextStyle(
                      color:    AppConstants.primaryColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title:    Text(activo.empresaNombre),
                subtitle: Text(
                    '${activo.accionesCompradas} acción(es)'),
                onTap: () async {
                  Navigator.pop(context);
                  await _portafolioService.agregarActivo(
                    portafolioId: widget.portafolioId,
                    activoId:     activo.id,
                  );
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          '${activo.empresaNombre} agregado'),
                      backgroundColor: AppConstants.successColor,
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  Future<void> _removerActivo(ActivoModel activo) async {
    await _portafolioService.removerActivo(
      portafolioId: widget.portafolioId,
      activoId:     activo.id,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:         Text('${activo.empresaNombre} removido'),
        backgroundColor: AppConstants.errorColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando || _portafolio == null) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    final activosEnPortafolio = _activosEnPortafolio;
    final valorTotal = activosEnPortafolio.fold<double>(
        0, (sum, a) => sum + a.valorTotal);

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _mostrarDialogAgregarActivo,
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        icon:  const Icon(Icons.add),
        label: const Text('Agregar activo'),
      ),
      body: SafeArea(
        child: Column(
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
                      color:  AppConstants.primaryColor.withOpacity(0.2),
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
                    color: AppConstants.primaryColor.withOpacity(0.8),
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
                  left:   20,
                  right:  20,
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              _portafolio!.nombre,
                              style: const TextStyle(
                                color:      Colors.white,
                                fontSize:   20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${activosEnPortafolio.length} activo(s)',
                              style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Valor total',
                            style: TextStyle(
                                color: Colors.white60,
                                fontSize: 11),
                          ),
                          Text(
                            '\$${valorTotal.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color:      Colors.white,
                              fontSize:   18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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
                    'Activos en este portafolio',
                    style: TextStyle(
                      fontSize:   15,
                      fontWeight: FontWeight.bold,
                      color:      AppConstants.primaryColor,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${activosEnPortafolio.length} activo(s)',
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ── Lista de activos ─────────────────────────────────────
            Expanded(
              child: activosEnPortafolio.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_chart,
                            size:  64,
                            color: AppConstants.primaryColor
                                .withOpacity(0.25),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Portafolio vacío',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize:   16),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Toca "Agregar activo" para incluir\ntus inversiones aquí',
                            style: TextStyle(
                                color: Colors.grey, fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                          20, 0, 20, 100),
                      itemCount: activosEnPortafolio.length,
                      itemBuilder: (context, index) {
                        final activo = activosEnPortafolio[index];
                        return _tarjetaActivo(activo);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tarjetaActivo(ActivoModel activo) {
    return Container(
      margin:  const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color:  Colors.black.withOpacity(0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          // Icono
          Container(
            width:  46,
            height: 46,
            decoration: BoxDecoration(
              color:        AppConstants.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                activo.empresaSimbolo.length >= 2
                    ? activo.empresaSimbolo.substring(0, 2)
                    : activo.empresaSimbolo,
                style: const TextStyle(
                  color:      AppConstants.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize:   13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activo.empresaNombre,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize:   14,
                  ),
                ),
                Text(
                  '${activo.accionesCompradas} acción(es) · \$${activo.precioCompra.toStringAsFixed(2)} c/u',
                  style: const TextStyle(
                      color: Colors.grey, fontSize: 12),
                ),
                Text(
                  'Valor: \$${activo.valorTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color:      AppConstants.successColor,
                    fontSize:   12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Botón remover
          IconButton(
            icon:      const Icon(Icons.remove_circle_outline,
                color: AppConstants.errorColor),
            onPressed: () => _removerActivo(activo),
          ),
        ],
      ),
    );
  }
}