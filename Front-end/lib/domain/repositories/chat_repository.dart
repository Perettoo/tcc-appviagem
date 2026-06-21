import 'package:test_tcc/domain/entities/carona_resumo.dart';
import 'package:test_tcc/domain/entities/membro_grupo.dart';
import 'package:test_tcc/domain/entities/mensagem.dart';
import 'package:test_tcc/domain/entities/usuario_resumo.dart';

abstract class ChatRepository {
  Future<List<MembroGrupo>> membros(int idGrupo);

  /// Busca usuários por nome/email (para adicionar ao grupo).
  Future<List<UsuarioResumo>> buscarUsuarios(String termo);

  /// Adiciona um usuário como membro (somente admin). Retorna o membro criado.
  Future<MembroGrupo> adicionarMembro(int idGrupo, int idUsuario);

  Future<List<Mensagem>> historico(int idGrupo);

  Future<Mensagem> enviar(int idGrupo, String conteudo);

  /// Motorista anuncia uma carona no grupo (destino opcional). Retorna a
  /// mensagem-card criada.
  Future<Mensagem> anunciarCarona(int idGrupo, {String? destino});

  /// Stream de mensagens novas (tempo-real) da sala do grupo.
  Stream<Mensagem> conectar(int idGrupo);

  /// Stream de caronas atualizadas (vagas/pedidos/status) da sala conectada.
  Stream<CaronaResumo> get caronaUpdates;

  void desconectar();
}
