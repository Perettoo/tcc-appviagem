import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_tcc/domain/entities/user.dart';
import 'package:test_tcc/presentation/controllers/auth_controller.dart';
import 'package:test_tcc/presentation/controllers/grupo_controller.dart';
import 'package:test_tcc/presentation/pages/home/tabs/inicio_tab.dart';
import 'package:test_tcc/presentation/pages/home/tabs/grupos_tab.dart';
import 'package:test_tcc/presentation/pages/home/tabs/caronas_tab.dart';
import 'package:test_tcc/presentation/pages/home/tabs/perfil_tab.dart';

/// Casca do app autenticado: barra inferior + as abas reais. A aba "Caronas"
/// só aparece para motorista/ambos.
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
      if (!mounted) return;
      final grupos = context.read<GrupoController>();
      grupos.carregar();
      // Realtime de sessão: recebe ao vivo grupos em que o usuário for
      // adicionado enquanto está logado. Encerrado no dispose (logout).
      grupos.iniciarSessaoRealtime();
    });
  }

  @override
  void dispose() {
    context.read<GrupoController>().encerrarSessaoRealtime();
    super.dispose();
  }

  void _irPara(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthController>().currentUser;
    final podeSerMotorista = user != null &&
        (user.tipo == TipoUsuario.motorista || user.tipo == TipoUsuario.ambos);

    final tabs = <_TabItem>[
      _TabItem(
        page: InicioTab(onVerGrupos: () => _irPara(1)),
        destino: const NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Início',
        ),
      ),
      const _TabItem(
        page: GruposTab(),
        destino: NavigationDestination(
          icon: Icon(Icons.groups_outlined),
          selectedIcon: Icon(Icons.groups),
          label: 'Grupos',
        ),
      ),
      if (podeSerMotorista)
        const _TabItem(
          page: CaronasTab(),
          destino: NavigationDestination(
            icon: Icon(Icons.directions_car_outlined),
            selectedIcon: Icon(Icons.directions_car),
            label: 'Caronas',
          ),
        ),
      const _TabItem(
        page: PerfilTab(),
        destino: NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ),
    ];

    // Protege contra índice fora do range se o conjunto de abas mudar.
    final index = _index.clamp(0, tabs.length - 1);

    return Scaffold(
      body: IndexedStack(
        index: index,
        children: [for (final t in tabs) t.page],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: _irPara,
        destinations: [for (final t in tabs) t.destino],
      ),
    );
  }
}

class _TabItem {
  final Widget page;
  final NavigationDestination destino;

  const _TabItem({required this.page, required this.destino});
}
