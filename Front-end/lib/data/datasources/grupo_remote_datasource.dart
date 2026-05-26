import 'package:dio/dio.dart';
import 'package:test_tcc/core/config/api_config.dart';
import 'package:test_tcc/data/datasources/token_storage.dart';
import 'package:test_tcc/domain/entities/grupo.dart';
import 'package:test_tcc/domain/failures/grupo_failure.dart';

class GrupoRemoteDatasource {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  GrupoRemoteDatasource({required TokenStorage tokenStorage, Dio? dio})
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

  Future<Grupo> criar({required String nome, required bool isPrivado}) async {
    try {
      final response = await _dio.post(
        '/grupos',
        data: {'nome': nome, 'isPrivado': isPrivado},
      );
      return _fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<List<Grupo>> listarMeus() async {
    try {
      final response = await _dio.get('/grupos');
      final list = response.data as List<dynamic>;
      return list
          .map((e) => _fromJson(e as Map<String, dynamic>))
          .toList(growable: false);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Grupo _fromJson(Map<String, dynamic> j) {
    return Grupo(
      idGrupo: j['idGrupo'] as int,
      nome: j['nome'] as String,
      isPrivado: _asBool(j['isPrivado']),
      isAdm: _asBool(j['isAdm']),
    );
  }

  // MySQL pode devolver BOOLEAN como 0/1; normaliza pra bool.
  bool _asBool(dynamic v) => v == true || v == 1;

  GrupoFailure _mapError(DioException e) {
    final body = e.response?.data;
    if (body is Map && body['error'] == 'VALIDATION') {
      final details = body['details'] as Map?;
      final first = details?.values.first;
      return GrupoOperationFailure(first?.toString() ?? 'Dados inválidos.');
    }
    return const GrupoOperationFailure(
        'Não foi possível conectar ao servidor. Verifique sua conexão.');
  }
}
