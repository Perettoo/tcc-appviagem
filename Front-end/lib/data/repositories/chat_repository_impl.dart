import 'package:test_tcc/data/datasources/chat_remote_datasource.dart';
import 'package:test_tcc/data/datasources/chat_socket_service.dart';
import 'package:test_tcc/domain/entities/membro_grupo.dart';
import 'package:test_tcc/domain/entities/mensagem.dart';
import 'package:test_tcc/domain/entities/usuario_resumo.dart';
import 'package:test_tcc/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDatasource remote;
  final ChatSocketService socket;

  const ChatRepositoryImpl({required this.remote, required this.socket});

  @override
  Future<List<MembroGrupo>> membros(int idGrupo) => remote.listarMembros(idGrupo);

  @override
  Future<List<UsuarioResumo>> buscarUsuarios(String termo) =>
      remote.buscarUsuarios(termo);

  @override
  Future<MembroGrupo> adicionarMembro(int idGrupo, int idUsuario) =>
      remote.adicionarMembro(idGrupo, idUsuario);

  @override
  Future<List<Mensagem>> historico(int idGrupo) => remote.listarMensagens(idGrupo);

  @override
  Future<Mensagem> enviar(int idGrupo, String conteudo) =>
      remote.enviar(idGrupo, conteudo);

  @override
  Stream<Mensagem> conectar(int idGrupo) => socket.conectar(idGrupo);

  @override
  void desconectar() => socket.desconectar();
}
