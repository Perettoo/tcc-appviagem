/// Uma mensagem do chat de um grupo.
class Mensagem {
  final int idMensagem;
  final int idGrupo;
  final int idAutor;
  final String autorNome;
  final String conteudo;
  final DateTime dataEnvio;

  const Mensagem({
    required this.idMensagem,
    required this.idGrupo,
    required this.idAutor,
    required this.autorNome,
    required this.conteudo,
    required this.dataEnvio,
  });
}
