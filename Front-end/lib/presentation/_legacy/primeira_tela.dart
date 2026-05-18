import 'package:flutter/material.dart';
import 'package:test_tcc/domain/entities/user.dart';

class UserDashboard extends StatelessWidget {
  final User usuario; // Recebe o usuário que acabou de logar

  const UserDashboard({super.key, required this.usuario});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Olá, ${usuario.name}'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                usuario.tipo == TipoUsuario.carona
                    ? Icons.person
                    : usuario.tipo == TipoUsuario.motorista
                    ? Icons.directions_car
                    : Icons.swap_horiz,
                size: 100,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 24),
              const Text(
                'Bem-vindo ao aplicativo!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Seu perfil atual é: ${usuario.tipo.name.toUpperCase()}',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                icon: const Icon(Icons.search),
                label: const Text('Procurar Viagens'),
                onPressed: () {
                  // Aqui vai entrar a lógica futura do seu app
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
