import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_tcc/presentation/controllers/grupo_controller.dart';
import 'package:test_tcc/presentation/pages/home/tabs/inicio_tab.dart';
import 'package:test_tcc/presentation/pages/home/tabs/grupos_tab.dart';
import 'package:test_tcc/presentation/pages/home/tabs/perfil_tab.dart';

/// Casca do app autenticado: barra inferior + as 3 abas reais
/// (Início, Grupos, Perfil). Cada aba é um widget próprio e enxuto.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<GrupoController>().carregar();
    });
  }

  void _irPara(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          InicioTab(onVerGrupos: () => _irPara(1)),
          const GruposTab(),
          const PerfilTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _irPara,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Grupos',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
