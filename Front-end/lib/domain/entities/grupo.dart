class Grupo {
  final int idGrupo;
  final String nome;
  final bool isPrivado;

  /// Se o usuário autenticado é administrador deste grupo.
  final bool isAdm;

  const Grupo({
    required this.idGrupo,
    required this.nome,
    required this.isPrivado,
    required this.isAdm,
  });
}
