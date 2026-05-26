import 'package:flutter/material.dart';
import 'package:test_tcc/core/theme/app_colors.dart';

class GerenciarGrupoPage extends StatelessWidget {
  final String acao; // 'Criar' ou 'Entrar'
  final String tipo; // 'Privado' ou 'Público'

  const GerenciarGrupoPage({
    super.key,
    required this.acao,
    required this.tipo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fundoLeve,
      appBar: AppBar(
        backgroundColor: AppColors.verdePrincipal,
        elevation: 0,
        title: Text(
          '$acao Grupo $tipo',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              acao == 'Criar'
                  ? 'Preencha os dados para criar o seu novo grupo de caronas.'
                  : 'Busque ou insira o código para entrar no grupo.',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            if (acao == 'Criar') ...[
              const Text(
                'Nome do Grupo',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Ex: Unoesc Noturno - Eng. Computação',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Rota Principal',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Ex: Campos Novos -> Joaçaba',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ] else ...[
              Text(
                tipo == 'Privado' ? 'Código do Convite' : 'Buscar Rota/Nome',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: InputDecoration(
                  hintText: tipo == 'Privado'
                      ? 'Insira o código de 6 dígitos'
                      : 'Digite o nome da faculdade ou cidade',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(
                    tipo == 'Privado' ? Icons.lock : Icons.search,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.verdePrincipal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  acao == 'Criar' ? 'Confirmar Criação' : 'Buscar Grupo',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
