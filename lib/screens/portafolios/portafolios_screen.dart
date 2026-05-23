import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/routes.dart';
import '../../models/portafolio_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/portafolio_service.dart';

class PortafoliosScreen extends StatefulWidget {
  const PortafoliosScreen({super.key});

  @override
  State<PortafoliosScreen> createState() => _PortafoliosScreenState();
}

class _PortafoliosScreenState extends State<PortafoliosScreen> {
  static const String _headerUrl =
      'https://raw.githubusercontent.com/flutter/website/main/src/assets/images/docs/tools/devtools/memory_analysis_tab.png';

  final PortafolioService _service     = PortafolioService();
  final _nombreController              = TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  void _mostrarDialogCrear(String uid) {
    _nombreController.clear();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Nuevo portafolio'),
        content: TextField(
          controller:     _nombreController,
          autofocus:      true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText:   'Nombre del portafolio',
            hintText:    'Ej: Tecnología 2025',
            prefixIcon:  const Icon(Icons.work_outline),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final nombre = _nombreController.text.trim();
              if (nombre.isEmpty) return;
              Navigator.pop(context);
              await _service.crearPortafolio(
                  uidUsuario: uid, nombre: nombre);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:         Text('Portafolio creado'),
                  backgroundColor: AppConstants.successColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  void _confirmarEliminar(
      BuildContext context, PortafolioModel portafolio) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar portafolio'),
        content: Text(
            '¿Eliminar "${portafolio.nombre}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _service.eliminarPortafolio(portafolio.id);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:         Text('Portafolio eliminado'),
                  backgroundColor: AppConstants.errorColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.errorColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<AuthProvider>().usuario;

    if (usuario == null) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarDialogCrear(usuario.uid),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        icon:  const Icon(Icons.add),
        label: const Text('Nuevo portafolio'),
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
                const Positioned(
                  bottom: 20,
                  left:   20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Portafolios',
                        style: TextStyle(
                          color:      Colors.white,
                          fontSize:   22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Agrupa y gestiona tus inversiones',
                        style: TextStyle(
                            color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Lista de portafolios ─────────────────────────────────────
            Expanded(
              child: StreamBuilder<List<PortafolioModel>>(
                stream: _service.streamPortafolios(usuario.uid),
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
                            Icons.work_outline,
                            size:  72,
                            color: AppConstants.primaryColor
                                .withOpacity(0.25),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No tienes portafolios aún',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize:   16),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Toca el botón para crear tu primer portafolio',
                            style:     TextStyle(
                                color: Colors.grey, fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    itemCount: lista.length,
                    itemBuilder: (context, index) {
                      final p = lista[index];
                      return _tarjetaPortafolio(context, p);
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

  Widget _tarjetaPortafolio(
      BuildContext context, PortafolioModel portafolio) {
    final colores = [
      AppConstants.primaryColor,
      AppConstants.successColor,
      Colors.deepOrange,
      const Color(0xFF6A1B9A),
    ];
    final color =
        colores[portafolio.nombre.length % colores.length];

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.portafolioDetalle,
        arguments: portafolio.id,
      ),
      child: Container(
        margin:  const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:        Colors.white,
          borderRadius: BorderRadius.circular(16),
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
            // Icono
            Container(
              width:  50,
              height: 50,
              decoration: BoxDecoration(
                color:        color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.work, color: color, size: 26),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    portafolio.nombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize:   15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${portafolio.activoIds.length} activo(s)',
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 12),
                  ),
                  Text(
                    'Creado el ${_formatFecha(portafolio.fechaCreacion)}',
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
            ),
            // Eliminar
            IconButton(
              icon:  const Icon(Icons.delete_outline,
                  color: AppConstants.errorColor),
              onPressed: () =>
                  _confirmarEliminar(context, portafolio),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  String _formatFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }
}