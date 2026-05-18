import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_tcc/core/theme/app_colors.dart';
import 'package:test_tcc/domain/entities/user.dart';
import 'package:test_tcc/presentation/controllers/auth_controller.dart';
import 'package:test_tcc/presentation/pages/admin_page.dart';
import 'package:test_tcc/presentation/pages/home/ambos_page.dart';
import 'package:test_tcc/presentation/pages/home/carona_page.dart';
import 'package:test_tcc/presentation/pages/home/motorista_page.dart';
import 'package:test_tcc/presentation/pages/register_page.dart';
import 'package:test_tcc/presentation/widgets/campo_formulario.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController loginController = TextEditingController();
  final TextEditingController senhaLoginController = TextEditingController();

  @override
  void dispose() {
    loginController.dispose();
    senhaLoginController.dispose();
    super.dispose();
  }

  Widget _destinoPorTipo(User user) {
    if (user.email == 'admin') return const AdminPage();
    switch (user.tipo) {
      case TipoUsuario.motorista:
        return MotoristaPage(user: user);
      case TipoUsuario.ambos:
        return AmbosPage(user: user);
      case TipoUsuario.carona:
        return CaronaPage(user: user);
    }
  }

  Future<void> _handleLogin() async {
    final auth = context.read<AuthController>();
    final ok = await auth.login(
      identifier: loginController.text,
      password: senhaLoginController.text,
    );
    if (!ok || !mounted) return;
    final user = auth.currentUser!;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => _destinoPorTipo(user)),
    ).then((_) {
      loginController.clear();
      senhaLoginController.clear();
    });
  }

  Future<void> _handleCriarConta() async {
    final novoUsuario = await Navigator.push<User>(
      context,
      MaterialPageRoute(builder: (_) => const RegisterPage()),
    );
    if (!mounted) return;
    if (novoUsuario != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuário cadastrado com sucesso! Faça login.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginError = context.watch<AuthController>().error;

    return Scaffold(
      backgroundColor: AppColors.fundoLeve,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 40),
              decoration: const BoxDecoration(
                color: AppColors.verdePrincipal,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: const Column(
                children: [
                  Icon(Icons.directions_car, size: 56, color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Compartilhe Caronas',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Conecte-se e economize',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Faça seu Login',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.verdePrincipal,
                          ),
                        ),
                        const SizedBox(height: 24),
                        CampoFormulario(
                          label: 'E-mail / Usuário',
                          isPassword: false,
                          controller: loginController,
                          icon: Icons.person,
                        ),
                        const SizedBox(height: 16),
                        CampoFormulario(
                          label: 'Senha',
                          isPassword: true,
                          controller: senhaLoginController,
                          icon: Icons.lock,
                        ),
                        if (loginError != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.red),
                              ),
                              child: Text(
                                loginError,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.verdePrincipal,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Entrar',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Container(height: 1, color: Colors.grey[300]),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'Novo por aqui?',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(height: 1, color: Colors.grey[300]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _handleCriarConta,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: AppColors.verdePrincipal,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.person_add),
                      label: const Text(
                        'Criar nova conta',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
