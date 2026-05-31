import 'package:dio/dio.dart';
import 'package:test_tcc/core/config/api_config.dart';
import 'package:test_tcc/data/datasources/token_storage.dart';
import 'package:test_tcc/domain/entities/membro_grupo.dart';
import 'package:test_tcc/domain/entities/mensagem.dart';
import 'package:test_tcc/domain/entities/user.dart';
import 'package:test_tcc/domain/entities/usuario_resumo.dart';
import 'package:test_tcc/domain/failures/grupo_failure.dart';

/// Acesso REST ao chat e aos membros de um grupo. O tempo-real (mensagens
/// novas) vem pelo [ChatSocketService]; aqui ficam histórico, membros e envio.
class ChatRemoteDatasource {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  ChatRemoteDatasource({required TokenStorage tokenStorage, Dio? dio})
      : _tokenStorage = tokenStorage,
        _dio = dio ??
            Dio(BaseOptions(
              baseUrl: ApiConfig.baseUrl,
              connectTimeout: const Duration(seconds: 8),
              receiveTimeout: const Duration(seconds: 8),
            )) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _tokenStorage.read();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  Future<List<MembroGrupo>> listarMembros(int idGrupo) async {
    try {
      final response = await _dio.get('/grupos/$idGrupo/membros');
      final list = response.data as List<dynamic>;
      return list
          .map((e) => _membroFromJson(e as Map<String, dynamic>))
          .toList(growable: false);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<List<Mensagem>> listarMensagens(int idGrupo) async {
    try {
      final response = await _dio.get('/grupos/$idGrupo/mensagens');
      final list = response.data as List<dynamic>;
      return list
          .map((e) => mensagemFromJson(e as Map<String, dynamic>))
          .toList(growable: false);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Mensagem> enviar(int idGrupo, String conteudo) async {
    try {
      final response = await _dio.post(
        '/grupos/$idGrupo/mensagens',
        data: {'conteudo': conteudo},
      );
      return mensagemFromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<List<UsuarioResumo>> buscarUsuarios(String termo) async {
    try {
      final response = await _dio.get(
        '/usuarios',
        queryParameters: {'busca': termo},
      );
      final list = response.data as List<dynamic>;
      return list
          .map((e) => _usuarioFromJson(e as Map<String, dynamic>))
          .toList(growable: false);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<MembroGrupo> adicionarMembro(int idGrupo, int idUsuario) async {
    try {
      final response = await _dio.post(
        '/grupos/$idGrupo/membros',
        data: {'idUsuario': idUsuario},
      );
      return _membroFromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  UsuarioResumo _usuarioFromJson(Map<String, dynamic> j) {
    return UsuarioResumo(
      idUsuario: j['idUsuario'] as int,
      nome: j['nome'] as String,
      email: j['email'] as String,
      tipo: TipoUsuario.values.firstWhere(
        (t) => t.name == j['tipo'],
        orElse: () => TipoUsuario.passageiro,
      ),
    );
  }

  MembroGrupo _membroFromJson(Map<String, dynamic> j) {
    return MembroGrupo(
      idUsuario: j['idUsuario'] as int,
      nome: j['nome'] as String,
      tipo: TipoUsuario.values.firstWhere(
        (t) => t.name == j['tipo'],
        orElse: () => TipoUsuario.passageiro,
      ),
      isAdm: j['isAdm'] == true || j['isAdm'] == 1,
    );
  }

  GrupoFailure _mapError(DioException e) {
    final body = e.response?.data;
    if (body is Map && body['error'] == 'VALIDATION') {
      final details = body['details'] as Map?;
      final first = details?.values.first;
      return GrupoOperationFailure(first?.toString() ?? 'Dados inválidos.');
    }
    if (body is Map && body['error'] == 'FORBIDDEN') {
      return const GrupoOperationFailure('Você não é membro deste grupo.');
    }
    if (body is Map && body['error'] == 'NOT_FOUND') {
      return const GrupoOperationFailure('Não encontrado.');
    }
    if (body is Map && body['error'] == 'CONFLICT') {
      return const GrupoOperationFailure('Este usuário já é membro do grupo.');
    }
    return const GrupoOperationFailure(
        'Não foi possível conectar ao servidor. Verifique sua conexão.');
  }
}

/// Converte o payload de mensagem do backend (REST e socket usam o mesmo
/// formato) em [Mensagem]. Exposto fora da classe para o socket reaproveitar.
Mensagem mensagemFromJson(Map<String, dynamic> j) {
  return Mensagem(
    idMensagem: j['idMensagem'] as int,
    idGrupo: j['idGrupo'] as int,
    idAutor: j['idAutor'] as int,
    autorNome: (j['autorNome'] as String?) ?? 'Usuário',
    conteudo: j['conteudo'] as String,
    dataEnvio: DateTime.parse(j['dataEnvio'] as String).toLocal(),
  );
}
