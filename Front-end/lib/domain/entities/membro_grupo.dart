import 'package:test_tcc/domain/entities/user.dart';

/// Um membro de um grupo (vindo de grupo_usuario + usuario).
class MembroGrupo {
  final int idUsuario;
  final String nome;
  final TipoUsuario tipo;
  final bool isAdm;

  const MembroGrupo({
    required this.idUsuario,
    required this.nome,
    required this.tipo,
    required this.isAdm,
  });
}
