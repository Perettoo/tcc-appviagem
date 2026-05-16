import 'package:flutter/material.dart';
import 'package:test_tcc/user.dart';

class AdminDashboard extends StatefulWidget {
  final List<User> usuarios;
  const AdminDashboard({super.key, required this.usuarios});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel Admin'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
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
              child: widget.usuarios.isEmpty
                  ? const Center(child: Text('Nenhum usuário cadastrado.'))
                  : ListView.builder(
                      itemCount: widget.usuarios.length,
                      itemBuilder: (context, index) {
                        final user = widget.usuarios[index];
                        return Card(
                          child: ListTile(
                            leading: Icon(
                              Icons.person,
                              color: Theme.of(context).primaryColor,
                            ),
                            title: Text(user.name),
                            subtitle: Text('${user.email} - ${user.tipo.name}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() => widget.usuarios.removeAt(index));
                              },
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
