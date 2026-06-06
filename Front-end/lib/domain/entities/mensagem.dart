import 'package:test_tcc/domain/entities/carona_resumo.dart';

/// Tipo de uma mensagem do chat: texto comum ou um pedido de carona
/// (renderizado como card com ação em vez de bolha de texto).
enum TipoMensagem { texto, carona }

/// Uma mensagem do chat de um grupo.
class Mensagem {
  final int idMensagem;
  final int idGrupo;
  final int idAutor;
  final String autorNome;
  final String conteudo;
  final DateTime dataEnvio;
  final TipoMensagem tipo;

  /// Preenchido somente quando [tipo] == [TipoMensagem.carona].
  final CaronaResumo? carona;

  const Mensagem({
    required this.idMensagem,
    required this.idGrupo,
    required this.idAutor,
    required this.autorNome,
    required this.conteudo,
    required this.dataEnvio,
    this.tipo = TipoMensagem.texto,
    this.carona,
  });

  /// Cópia com a carona embutida atualizada (usado quando uma carona é aceita).
  Mensagem copyWith({CaronaResumo? carona}) {
    return Mensagem(
      idMensagem: idMensagem,
      idGrupo: idGrupo,
      idAutor: idAutor,
      autorNome: autorNome,
      conteudo: conteudo,
      dataEnvio: dataEnvio,
      tipo: tipo,
      carona: carona ?? this.carona,
    );
  }
}
