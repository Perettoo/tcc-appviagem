import 'package:test_tcc/domain/entities/user.dart';

/// Resultado enxuto de busca de usuário (para adicionar a um grupo).
class UsuarioResumo {
  final int idUsuario;
  final String nome;
  final String email;
  final TipoUsuario tipo;

  const UsuarioResumo({
    required this.idUsuario,
    required this.nome,
    required this.email,
    required this.tipo,
  });
}
