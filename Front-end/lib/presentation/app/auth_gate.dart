import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_tcc/presentation/controllers/auth_controller.dart';
import 'package:test_tcc/presentation/pages/admin/admin_page.dart';
import 'package:test_tcc/presentation/pages/auth/login_page.dart';
import 'package:test_tcc/presentation/pages/home/home_shell.dart';

/// Decide a tela raiz a partir do estado de autenticação.
/// Login/logout passam a ser reativos — sem Navigator manual.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    if (!auth.isAuthenticated) return const LoginPage();
    if (auth.isAdmin) return const AdminPage();
    return const HomeShell();
  }
}
