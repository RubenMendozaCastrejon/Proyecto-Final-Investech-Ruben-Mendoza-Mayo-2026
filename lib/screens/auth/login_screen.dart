import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/constants.dart';
import '../../core/routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controladores usuario normal
  final _correoController   = TextEditingController();
  final _passwordController = TextEditingController();

  // Controladores admin
  final _adminCorreoController   = TextEditingController();
  final _adminPasswordController = TextEditingController();

  bool _verPassword      = false;
  bool _verPasswordAdmin = false;
  final _formKey      = GlobalKey<FormState>();
  final _formAdminKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _correoController.dispose();
    _passwordController.dispose();
    _adminCorreoController.dispose();
    _adminPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loginUsuario() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.loginUsuario(
      correo:   _correoController.text.trim(),
      password: _passwordController.text.trim(),
    );
    if (!mounted) return;
    if (ok) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      _mostrarError(auth.error);
    }
  }

  Future<void> _loginAdmin() async {
    if (!_formAdminKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.loginAdmin(
      correo:   _adminCorreoController.text.trim(),
      password: _adminPasswordController.text.trim(),
    );
    if (!mounted) return;
    if (ok) {
      Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
    } else {
      _mostrarError(auth.error);
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: AppConstants.errorColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth      = context.watch<AuthProvider>();
    final cargando  = auth.status == AuthStatus.cargando;

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Logo
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.show_chart,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Investech',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryColor,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Plataforma digital de inversiones',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 32),

              // Tabs
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TabBar(
                      controller: _tabController,
                      labelColor: AppConstants.primaryColor,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: AppConstants.primaryColor,
                      tabs: const [
                        Tab(text: 'Iniciar sesión'),
                        Tab(text: 'Administrador'),
                      ],
                    ),
                    SizedBox(
                      height: 300,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // ── Tab usuario normal ──
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  _campo(
                                    controller: _correoController,
                                    label: 'Correo electrónico',
                                    icono: Icons.email_outlined,
                                    teclado: TextInputType.emailAddress,
                                    validator: (v) => v!.isEmpty
                                        ? 'Ingresa tu correo'
                                        : null,
                                  ),
                                  const SizedBox(height: 16),
                                  _campoPassword(
                                    controller: _passwordController,
                                    label: 'Contraseña',
                                    ver: _verPassword,
                                    onToggle: () => setState(
                                        () => _verPassword = !_verPassword),
                                    validator: (v) => v!.isEmpty
                                        ? 'Ingresa tu contraseña'
                                        : null,
                                  ),
                                  const SizedBox(height: 24),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed:
                                          cargando ? null : _loginUsuario,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            AppConstants.primaryColor,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      child: cargando
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child:
                                                  CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Text('Ingresar'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // ── Tab admin ──
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Form(
                              key: _formAdminKey,
                              child: Column(
                                children: [
                                  _campo(
                                    controller: _adminCorreoController,
                                    label: 'Correo administrador',
                                    icono: Icons.admin_panel_settings_outlined,
                                    teclado: TextInputType.emailAddress,
                                    validator: (v) => v!.isEmpty
                                        ? 'Ingresa el correo'
                                        : null,
                                  ),
                                  const SizedBox(height: 16),
                                  _campoPassword(
                                    controller: _adminPasswordController,
                                    label: 'Contraseña admin',
                                    ver: _verPasswordAdmin,
                                    onToggle: () => setState(() =>
                                        _verPasswordAdmin =
                                            !_verPasswordAdmin),
                                    validator: (v) => v!.isEmpty
                                        ? 'Ingresa la contraseña'
                                        : null,
                                  ),
                                  const SizedBox(height: 24),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed:
                                          cargando ? null : _loginAdmin,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.deepOrange,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      child: cargando
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child:
                                                  CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Text('Acceso Admin'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              // Ir a registro
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('¿No tienes cuenta? ',
                      style: TextStyle(color: Colors.grey)),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(
                        context, AppRoutes.register),
                    child: const Text(
                      'Regístrate',
                      style: TextStyle(
                        color: AppConstants.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _campo({
    required TextEditingController controller,
    required String label,
    required IconData icono,
    TextInputType teclado = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: teclado,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icono, color: AppConstants.primaryColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _campoPassword({
    required TextEditingController controller,
    required String label,
    required bool ver,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !ver,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon:
            const Icon(Icons.lock_outline, color: AppConstants.primaryColor),
        suffixIcon: IconButton(
          icon: Icon(ver ? Icons.visibility_off : Icons.visibility),
          onPressed: onToggle,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}