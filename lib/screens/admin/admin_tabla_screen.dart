import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../services/firestore_service.dart';
import 'admin_form_screen.dart';

class AdminTablaScreen extends StatelessWidget {
  final String coleccion;
  const AdminTablaScreen({super.key, required this.coleccion});

  static const String _headerUrl =
      'https://raw.githubusercontent.com/flutter/website/main/src/assets/images/docs/tools/devtools/cpu_profiler_flame_chart.png';

  String get _labelColeccion {
    switch (coleccion) {
      case AppConstants.colUsers:         return 'Usuarios';
      case AppConstants.colEmpresas:      return 'Empresas';
      case AppConstants.colActivos:       return 'Activos';
      case AppConstants.colTransacciones: return 'Transacciones';
      case AppConstants.colPortafolios:   return 'Portafolios';
      default:                            return coleccion;
    }
  }

  // Campos que NO mostramos al usuario (internos)
  static const List<String> _camposOcultos = ['__name__'];

  // Campos que NO se pueden editar directamente
  static const List<String> _camposReadOnly = ['id', 'uidUsuario', 'uid'];

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AdminFormScreen(
              coleccion: coleccion,
              docId:     null,
              datosIniciales: const {},
            ),
          ),
        ),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        icon:  const Icon(Icons.add),
        label: const Text('Nuevo documento'),
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
                    height: 130,
                    fit:    BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 130,
                      color:  Colors.deepOrange.withOpacity(0.2),
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
                    color: const Color(0xFF1A1A2E).withOpacity(0.8),
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
                  bottom: 16,
                  left:   20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _labelColeccion,
                        style: const TextStyle(
                          color:      Colors.white,
                          fontSize:   20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Colección: $coleccion',
                        style: const TextStyle(
                          color:    Colors.deepOrangeAccent,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ── Documentos en tiempo real ────────────────────────────
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: service.streamColeccion(coleccion),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: Colors.deepOrange),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style:
                            const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  final docs = snapshot.data ?? [];

                  if (docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_outlined,
                              size:  64,
                              color: Colors.white24),
                          const SizedBox(height: 12),
                          const Text(
                            'No hay documentos',
                            style: TextStyle(color: Colors.white54),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      // Contador
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20),
                        child: Row(
                          children: [
                            const Icon(Icons.folder_open,
                                color: Colors.deepOrangeAccent,
                                size:  16),
                            const SizedBox(width: 6),
                            Text(
                              '${docs.length} documento(s)',
                              style: const TextStyle(
                                color:    Colors.white60,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Lista
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(
                              20, 0, 20, 100),
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final doc = docs[index];
                            return _tarjetaDocumento(
                                context, doc, service);
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tarjetaDocumento(
    BuildContext context,
    Map<String, dynamic> doc,
    FirestoreService service,
  ) {
    final docId  = doc['id'] as String? ?? '';
    final campos = doc.entries
        .where((e) =>
            !_camposOcultos.contains(e.key) && e.key != 'id')
        .toList();

    return Container(
      margin:  const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: Colors.deepOrange.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ID del documento
          Row(
            children: [
              const Icon(Icons.fingerprint,
                  color: Colors.deepOrangeAccent, size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'ID: $docId',
                  style: const TextStyle(
                    color:    Colors.deepOrangeAccent,
                    fontSize: 10,
                    fontFamily: 'monospace',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const Divider(color: Colors.white12, height: 16),

          // Campos del documento
          ...campos.map((entry) => _filaCampo(entry)),

          const SizedBox(height: 12),

          // Botones CRUD
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Editar
              _botonAdmin(
                label: 'Editar',
                icono: Icons.edit_outlined,
                color: Colors.amber,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AdminFormScreen(
                      coleccion:      coleccion,
                      docId:          docId,
                      datosIniciales: Map<String, dynamic>.from(doc)
                        ..remove('id'),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Eliminar
              _botonAdmin(
                label: 'Eliminar',
                icono: Icons.delete_outline,
                color: Colors.red,
                onTap: () =>
                    _confirmarEliminar(context, docId, service),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filaCampo(MapEntry<String, dynamic> entry) {
    final valor = entry.value?.toString() ?? 'null';
    final esLargo = valor.length > 40;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Clave
          SizedBox(
            width: 110,
            child: Text(
              entry.key,
              style: const TextStyle(
                color:    Colors.white54,
                fontSize: 11,
                fontFamily: 'monospace',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          // Valor
          Expanded(
            child: Text(
              esLargo ? '${valor.substring(0, 40)}…' : valor,
              style: const TextStyle(
                color:    Colors.white,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _botonAdmin({
    required String       label,
    required IconData     icono,
    required Color        color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color:        color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
          border:       Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            Icon(icono, color: color, size: 14),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  void _confirmarEliminar(
    BuildContext context,
    String       docId,
    FirestoreService service,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar documento',
            style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¿Estás seguro? Esta acción no se puede deshacer.',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              'ID: $docId',
              style: const TextStyle(
                color:    Colors.deepOrangeAccent,
                fontSize: 11,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar',
                style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await service.eliminarDocumento(coleccion, docId);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:         Text('Documento eliminado'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
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
}