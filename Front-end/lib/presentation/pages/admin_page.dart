import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_tcc/core/theme/app_colors.dart';
import 'package:test_tcc/domain/entities/user.dart';
import 'package:test_tcc/domain/usecases/delete_user_usecase.dart';
import 'package:test_tcc/domain/usecases/list_users_usecase.dart';
import 'package:test_tcc/presentation/controllers/auth_controller.dart';
import 'package:test_tcc/presentation/pages/login_page.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  List<User> _usuarios = const [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final listUsers = context.read<ListUsersUseCase>();
    final users = await listUsers();
    if (!mounted) return;
    setState(() => _usuarios = users);
  }

  Future<void> _deletar(User user) async {
    final deleteUser = context.read<DeleteUserUseCase>();
    await deleteUser(user.email);
    await _refresh();
  }

  Future<void> _logout() async {
    await context.read<AuthController>().logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel Admin'),
        backgroundColor: AppColors.verdePrincipal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Sair',
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configurações do App',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Manutenção do Sistema'),
                trailing: Switch(value: true, onChanged: (val) {}),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Usuários Cadastrados',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: _usuarios.isEmpty
                  ? const Center(child: Text('Nenhum usuário cadastrado.'))
                  : ListView.builder(
                      itemCount: _usuarios.length,
                      itemBuilder: (context, index) {
                        final user = _usuarios[index];
                        return Card(
                          child: ListTile(
                            leading: const Icon(
                              Icons.person,
                              color: AppColors.verdePrincipal,
                            ),
                            title: Text(user.name),
                            subtitle:
                                Text('${user.email} - ${user.tipo.name}'),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              onPressed: () => _deletar(user),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
