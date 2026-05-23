import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/routes.dart';
import '../../models/empresa_model.dart';
import '../../services/empresa_service.dart';

class EmpresaDetalleScreen extends StatefulWidget {
  final String empresaId; // en este contexto recibe la categoría
  const EmpresaDetalleScreen({super.key, required this.empresaId});

  @override
  State<EmpresaDetalleScreen> createState() => _EmpresaDetalleScreenState();
}

class _EmpresaDetalleScreenState extends State<EmpresaDetalleScreen> {
  final EmpresaService _service = EmpresaService();
  List<EmpresaModel> _empresas  = [];
  bool _cargando                = true;

  // ── Imagen provisional ─────────────────────────────────────────────────
  static const String _headerUrl =
      'https://raw.githubusercontent.com/flutter/website/main/src/assets/images/docs/tools/devtools/cpu_profiler_flame_chart.png';

  @override
  void initState() {
    super.initState();
    _cargarEmpresas();
  }

  Future<void> _cargarEmpresas() async {
    final lista =
        await _service.obtenerPorCategoria(widget.empresaId);
    setState(() {
      _empresas  = lista;
      _cargando  = false;
    });
  }

  Color _colorCategoria(String categoria) {
    switch (categoria) {
      case 'Tecnología': return const Color(0xFF1565C0);
      case 'Energía':    return const Color(0xFFF57F17);
      case 'Salud':      return const Color(0xFF2E7D32);
      case 'Finanzas':   return const Color(0xFF6A1B9A);
      default:           return AppConstants.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorCategoria(widget.empresaId);

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header con imagen ────────────────────────────────────────
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
                      color:  color.withOpacity(0.2),
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
                    color: color.withOpacity(0.7),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.empresaId,
                        style: const TextStyle(
                          color:      Colors.white,
                          fontSize:   26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_empresas.length} empresas disponibles',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Selecciona una empresa',
                style: TextStyle(
                  fontSize:   16,
                  fontWeight: FontWeight.bold,
                  color:      color,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // ── Lista de empresas ────────────────────────────────────────
            Expanded(
              child: _cargando
                  ? const Center(child: CircularProgressIndicator())
                  : _empresas.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.business_outlined,
                                  size: 64,
                                  color: color.withOpacity(0.3)),
                              const SizedBox(height: 12),
                              const Text(
                                'No hay empresas en esta categoría.\nCárgalas desde el panel admin.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 4),
                          itemCount: _empresas.length,
                          itemBuilder: (context, index) {
                            final empresa = _empresas[index];
                            return _tarjetaEmpresa(
                                context, empresa, color);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tarjetaEmpresa(
      BuildContext context, EmpresaModel empresa, Color color) {
    final subida = empresa.variacion >= 0;
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.invertir,
        arguments: empresa.id,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
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
            // Icono empresa
            Container(
              width:  48,
              height: 48,
              decoration: BoxDecoration(
                color:        color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  empresa.simbolo.length >= 2
                      ? empresa.simbolo.substring(0, 2)
                      : empresa.simbolo,
                  style: TextStyle(
                    color:      color,
                    fontWeight: FontWeight.bold,
                    fontSize:   14,
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
                    empresa.nombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize:   14,
                    ),
                  ),
                  Text(
                    empresa.simbolo,
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            // Precio y variación
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${empresa.precioAccion.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize:   15,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: subida
                        ? AppConstants.successColor.withOpacity(0.1)
                        : AppConstants.errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${subida ? '+' : ''}${empresa.variacion.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: subida
                          ? AppConstants.successColor
                          : AppConstants.errorColor,
                      fontSize:   11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}