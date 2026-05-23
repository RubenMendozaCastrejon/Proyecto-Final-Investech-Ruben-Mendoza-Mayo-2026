import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/empresas/empresas_screen.dart';
import '../screens/empresas/empresa_detalle_screen.dart';
import '../screens/empresas/invertir_screen.dart';
import '../screens/transacciones/transacciones_screen.dart';
import '../screens/transacciones/metodos_pago_screen.dart';
import '../screens/portafolios/portafolios_screen.dart';
import '../screens/portafolios/portafolio_detalle_screen.dart';
import '../screens/perfil/perfil_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/admin_tabla_screen.dart';
import '../screens/main_shell.dart';

class AppRoutes {
  static const String splash             = '/';
  static const String login              = '/login';
  static const String register           = '/register';
  static const String home               = '/home';
  static const String empresas           = '/empresas';
  static const String empresaDetalle     = '/empresa-detalle';
  static const String invertir           = '/invertir';
  static const String transacciones      = '/transacciones';
  static const String metodosPago        = '/metodos-pago';
  static const String portafolios        = '/portafolios';
  static const String portafolioDetalle  = '/portafolio-detalle';
  static const String perfil             = '/perfil';
  static const String adminDashboard     = '/admin';
  static const String adminTabla         = '/admin-tabla';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _build(const SplashScreen());
      case login:
        return _build(const LoginScreen());
      case register:
        return _build(const RegisterScreen());
      case home:
        return _build(const MainShell());
      case empresas:
        return _build(const EmpresasScreen());
      case empresaDetalle:
        return _build(EmpresaDetalleScreen(
            empresaId: settings.arguments as String));
      case invertir:
        return _build(InvertirScreen(
            empresaId: settings.arguments as String));
      case transacciones:
        return _build(const TransaccionesScreen());
      case metodosPago:
        return _build(const MetodosPagoScreen());
      case portafolios:
        return _build(const PortafoliosScreen());
      case portafolioDetalle:
        return _build(PortafolioDetalleScreen(
            portafolioId: settings.arguments as String));
      case perfil:
        return _build(const PerfilScreen());
      case adminDashboard:
        return _build(const AdminDashboardScreen());
      case adminTabla:
        return _build(AdminTablaScreen(
            coleccion: settings.arguments as String));
      default:
        return _build(const LoginScreen());
    }
  }

  static MaterialPageRoute _build(Widget page) {
    return MaterialPageRoute(builder: (_) => page);
  }
}