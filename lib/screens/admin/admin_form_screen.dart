import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../services/firestore_service.dart';

class AdminFormScreen extends StatefulWidget {
  final String               coleccion;
  final String?              docId;          // null = crear nuevo
  final Map<String, dynamic> datosIniciales;

  const AdminFormScreen({
    super.key,
    required this.coleccion,
    required this.docId,
    required this.datosIniciales,
  });

  @override
  State<AdminFormScreen> createState() => _AdminFormScreenState();
}

class _AdminFormScreenState extends State<AdminFormScreen> {
  static const String _headerUrl =
      'https://raw.githubusercontent.com/flutter/website/main/src/assets/images/docs/tools/devtools/network_screen_dark.png';

  final FirestoreService _service = FirestoreService();
  bool _guardando = false;

  // Campos predefinidos por colección para CREAR nuevos documentos
  Map<String, dynamic> _camposDefecto(String coleccion) {
    switch (coleccion) {
      case AppConstants.colEmpresas:
        return {
          'nombre':       '',
          'simbolo':      '',
          'categoria':    '',
          'precioAccion': 0.0,
          'variacion':    0.0,
          'descripcion':  '',
          'logoUrl':      '',
        };
      case AppConstants.colUsers:
        return {
          'nombre':        '',
          'correo':        '',
          'fondos':        0.0,
          'numeroTarjeta': '',
          'tipoTarjeta':   '',
        };
      case AppConstants.colActivos:
        return {
          'uidUsuario':        '',
          'empresaId':         '',
          'empresaNombre':     '',
          'empresaSimbolo':    '',
          'accionesCompradas': 0,
          'precioCompra':      0.0,
          'fechaCompra':       DateTime.now().toIso8601String(),
        };
      case AppConstants.colTransacciones:
        return {
          'uidUsuario':    '',
          'tipo':          '',
          'monto':         0.0,
          'fecha':         DateTime.now().toIso8601String(),
          'empresaId':     '',
          'empresaNombre': '',
          'acciones':      0,
        };
      case AppConstants.colPortafolios:
        return {
          'uidUsuario':    '',
          'nombre':        '',
          'activoIds':     '',
          'fechaCreacion': DateTime.now().toIso8601String(),
        };
      default:
        return {'campo': ''};
    }
  }

  // Campos que no deben ser editables
  static const List<String> _camposReadOnly = [
    'id', 'uidUsuario', 'uid',
  ];

  late Map<String, dynamic> _datos;
  late Map<String, TextEditingController> _controllers;

  bool get _esEdicion => widget.docId != null;

  @override
  void initState() {
    super.initState();
    _datos = _esEdicion
        ? Map<String, dynamic>.from(widget.datosIniciales)
        : _camposDefecto(widget.coleccion);

    _controllers = {};
    for (final entry in _datos.entries) {
      _controllers[entry.key] = TextEditingController(
        text: entry.value?.toString() ?? '',
      );
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _guardar() async {
    setState(() => _guardando = true);

    // Construir mapa con los valores actuales de los controllers
    final Map<String, dynamic> datosFinales = {};
    for (final entry in _controllers.entries) {
      final key = entry.key;
      final raw = entry.value.text.trim();

      // Intentar parsear números
      final numero = num.tryParse(raw);
      if (numero != null) {
        datosFinales[key] = numero;
      } else {
        datosFinales[key] = raw;
      }
    }

    try {
      if (_esEdicion) {
        await _service.actualizarDocumento(
          widget.coleccion,
          widget.docId!,
          datosFinales,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:         Text('Documento actualizado correctamente'),
            backgroundColor: Colors.amber,
          ),
        );
      } else {
        await _service.crearDocumento(widget.coleccion, datosFinales);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:         Text('Documento creado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:         Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
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
                  right:  20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _esEdicion
                                ? 'Editar documento'
                                : 'Nuevo documento',
                            style: const TextStyle(
                              color:      Colors.white,
                              fontSize:   20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Colección: ${widget.coleccion}',
                            style: const TextStyle(
                              color:    Colors.deepOrangeAccent,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      if (_esEdicion)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color:        Colors.amber.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border:       Border.all(
                                color: Colors.amber.withOpacity(0.5)),
                          ),
                          child: const Text(
                            'Editando',
                            style: TextStyle(
                                color: Colors.amber, fontSize: 11),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Formulario ─────────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                children: [
                  // ID del documento (solo lectura en edición)
                  if (_esEdicion) ...[
                    _campoReadOnly(
                        label: 'ID del documento',
                        valor: widget.docId!),
                    const SizedBox(height: 12),
                  ],

                  // Campos editables
                  ..._controllers.entries.map((entry) {
                    final esReadOnly =
                        _camposReadOnly.contains(entry.key);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: esReadOnly
                          ? _campoReadOnly(
                              label: entry.key,
                              valor: entry.value.text,
                            )
                          : _campoEditable(
                              label:      entry.key,
                              controller: entry.value,
                            ),
                    );
                  }),

                  const SizedBox(height: 20),

                  // ── Botón guardar ──────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _guardando ? null : _guardar,
                      icon: _guardando
                          ? const SizedBox(
                              width:  18,
                              height: 18,
                              child:  CircularProgressIndicator(
                                color:       Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(_esEdicion
                              ? Icons.save_outlined
                              : Icons.add_circle_outline),
                      label: Text(
                        _guardando
                            ? 'Guardando...'
                            : _esEdicion
                                ? 'Guardar cambios'
                                : 'Crear documento',
                        style: const TextStyle(fontSize: 15),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _esEdicion
                            ? Colors.amber
                            : Colors.deepOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Botón cancelar
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white54,
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(
                            vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _campoEditable({
    required String               label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color:    Colors.white60,
            fontSize: 11,
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            filled:      true,
            fillColor:   const Color(0xFF0F3460),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:   BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                  color: Colors.deepOrangeAccent, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _campoReadOnly({
    required String label,
    required String valor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label (solo lectura)',
          style: const TextStyle(
            color:    Colors.white38,
            fontSize: 11,
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width:   double.infinity,
          padding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color:        Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white12),
          ),
          child: Text(
            valor,
            style: const TextStyle(
              color:    Colors.white38,
              fontSize: 13,
              fontFamily: 'monospace',
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}