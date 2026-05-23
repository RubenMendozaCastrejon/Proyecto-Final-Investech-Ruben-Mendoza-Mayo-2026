import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants.dart';
import '../models/empresa_model.dart';

class EmpresaService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Obtener todas las empresas (stream) ─────────────────────────────────
  Stream<List<EmpresaModel>> streamEmpresas() {
    return _db
        .collection(AppConstants.colEmpresas)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EmpresaModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // ── Obtener empresas por categoría ──────────────────────────────────────
  Future<List<EmpresaModel>> obtenerPorCategoria(String categoria) async {
    final snapshot = await _db
        .collection(AppConstants.colEmpresas)
        .where('categoria', isEqualTo: categoria)
        .get();

    return snapshot.docs
        .map((doc) => EmpresaModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // ── Obtener empresa por ID ───────────────────────────────────────────────
  Future<EmpresaModel?> obtenerEmpresa(String id) async {
    final doc = await _db
        .collection(AppConstants.colEmpresas)
        .doc(id)
        .get();

    if (!doc.exists) return null;
    return EmpresaModel.fromMap(doc.data()!, doc.id);
  }

  // ── Poblar empresas iniciales en Firestore ───────────────────────────────
  // Llama esto UNA sola vez desde el admin para cargar las 20 empresas
  Future<void> poblarEmpresas() async {
    final empresas = [
      // Tecnología
      {'nombre': 'Apple Inc.',       'simbolo': 'AAPL', 'categoria': 'Tecnología', 'precioAccion': 189.50, 'variacion': 1.2,  'descripcion': 'Empresa líder en tecnología y dispositivos.',       'logoUrl': ''},
      {'nombre': 'Microsoft',        'simbolo': 'MSFT', 'categoria': 'Tecnología', 'precioAccion': 415.20, 'variacion': 0.8,  'descripcion': 'Software, nube y servicios empresariales.',          'logoUrl': ''},
      {'nombre': 'Alphabet (Google)','simbolo': 'GOOGL','categoria': 'Tecnología', 'precioAccion': 175.30, 'variacion': -0.5, 'descripcion': 'Búsqueda, publicidad y servicios en la nube.',        'logoUrl': ''},
      {'nombre': 'NVIDIA',           'simbolo': 'NVDA', 'categoria': 'Tecnología', 'precioAccion': 875.00, 'variacion': 3.1,  'descripcion': 'Chips gráficos e inteligencia artificial.',          'logoUrl': ''},
      {'nombre': 'Meta Platforms',   'simbolo': 'META', 'categoria': 'Tecnología', 'precioAccion': 520.40, 'variacion': 1.5,  'descripcion': 'Redes sociales y metaverso.',                        'logoUrl': ''},
      // Energía
      {'nombre': 'ExxonMobil',       'simbolo': 'XOM',  'categoria': 'Energía',    'precioAccion': 112.30, 'variacion': -1.1, 'descripcion': 'Petróleo y gas a nivel global.',                     'logoUrl': ''},
      {'nombre': 'Chevron',          'simbolo': 'CVX',  'categoria': 'Energía',    'precioAccion': 158.70, 'variacion': 0.3,  'descripcion': 'Energía integrada y petroquímica.',                  'logoUrl': ''},
      {'nombre': 'NextEra Energy',   'simbolo': 'NEE',  'categoria': 'Energía',    'precioAccion': 74.50,  'variacion': 2.0,  'descripcion': 'Energía renovable: solar y eólica.',                 'logoUrl': ''},
      {'nombre': 'Shell',            'simbolo': 'SHEL', 'categoria': 'Energía',    'precioAccion': 68.20,  'variacion': -0.8, 'descripcion': 'Energía y petroquímica a escala mundial.',           'logoUrl': ''},
      {'nombre': 'BP',               'simbolo': 'BP',   'categoria': 'Energía',    'precioAccion': 35.10,  'variacion': 0.6,  'descripcion': 'Petróleo, gas y transición energética.',             'logoUrl': ''},
      // Salud
      {'nombre': 'Johnson & Johnson','simbolo': 'JNJ',  'categoria': 'Salud',      'precioAccion': 147.80, 'variacion': 0.4,  'descripcion': 'Farmacéutica y dispositivos médicos.',               'logoUrl': ''},
      {'nombre': 'UnitedHealth',     'simbolo': 'UNH',  'categoria': 'Salud',      'precioAccion': 492.30, 'variacion': -1.3, 'descripcion': 'Seguros y servicios de salud.',                      'logoUrl': ''},
      {'nombre': 'Pfizer',           'simbolo': 'PFE',  'categoria': 'Salud',      'precioAccion': 28.60,  'variacion': 1.1,  'descripcion': 'Investigación y fabricación farmacéutica.',          'logoUrl': ''},
      {'nombre': 'Abbott Labs',      'simbolo': 'ABT',  'categoria': 'Salud',      'precioAccion': 118.40, 'variacion': 0.9,  'descripcion': 'Diagnósticos, nutrición y dispositivos.',            'logoUrl': ''},
      {'nombre': 'Medtronic',        'simbolo': 'MDT',  'categoria': 'Salud',      'precioAccion': 82.70,  'variacion': -0.2, 'descripcion': 'Tecnología médica e implantes.',                     'logoUrl': ''},
      // Finanzas
      {'nombre': 'JPMorgan Chase',   'simbolo': 'JPM',  'categoria': 'Finanzas',   'precioAccion': 198.50, 'variacion': 0.7,  'descripcion': 'Banco de inversión y servicios financieros.',        'logoUrl': ''},
      {'nombre': 'Visa',             'simbolo': 'V',    'categoria': 'Finanzas',   'precioAccion': 275.30, 'variacion': 1.0,  'descripcion': 'Pagos digitales a nivel mundial.',                   'logoUrl': ''},
      {'nombre': 'Goldman Sachs',    'simbolo': 'GS',   'categoria': 'Finanzas',   'precioAccion': 448.20, 'variacion': -0.6, 'descripcion': 'Banca de inversión y gestión de activos.',           'logoUrl': ''},
      {'nombre': 'BlackRock',        'simbolo': 'BLK',  'categoria': 'Finanzas',   'precioAccion': 812.60, 'variacion': 1.8,  'descripcion': 'Gestión de inversiones más grande del mundo.',       'logoUrl': ''},
      {'nombre': 'American Express', 'simbolo': 'AXP',  'categoria': 'Finanzas',   'precioAccion': 225.90, 'variacion': 0.5,  'descripcion': 'Tarjetas de crédito y servicios financieros.',       'logoUrl': ''},
    ];

    final batch = _db.batch();
    for (final empresa in empresas) {
      final ref = _db.collection(AppConstants.colEmpresas).doc();
      batch.set(ref, empresa);
    }
    await batch.commit();
  }
}