import 'package:dio/dio.dart';
import 'package:test_tcc/core/config/api_config.dart';
import 'package:test_tcc/data/datasources/token_storage.dart';
import 'package:test_tcc/domain/entities/carona_detalhe.dart';
import 'package:test_tcc/domain/entities/carona_item.dart';
import 'package:test_tcc/domain/entities/carona_resumo.dart';
import 'package:test_tcc/domain/failures/grupo_failure.dart';

/// Acesso REST às caronas do usuário (lista + detalhe).
class CaronaRemoteDatasource {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  CaronaRemoteDatasource({required TokenStorage tokenStorage, Dio? dio})
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

  Future<List<CaronaItem>> listarMinhas() async {
    try {
      final response = await _dio.get('/caronas');
      final list = response.data as List<dynamic>;
      return list
          .map((e) => _itemFromJson(e as Map<String, dynamic>))
          .toList(growable: false);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<CaronaDetalhe> detalhe(int idCarona) async {
    try {
      final response = await _dio.get('/caronas/$idCarona');
      return _detalheFromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  /// Conclui a carona (só motorista). Retorna o novo status.
  Future<StatusCarona> concluir(int idCarona) =>
      _patchStatus('/caronas/$idCarona/concluir');

  /// Cancela a carona (solicitante ou motorista). Retorna o novo status.
  Future<StatusCarona> cancelar(int idCarona) =>
      _patchStatus('/caronas/$idCarona/cancelar');

  Future<StatusCarona> _patchStatus(String path) async {
    try {
      final response = await _dio.patch(path);
      final data = response.data as Map<String, dynamic>;
      return _status(data['status']);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  StatusCarona _status(dynamic raw) => StatusCarona.values.firstWhere(
        (s) => s.name == raw,
        orElse: () => StatusCarona.pendente,
      );

  CaronaItem _itemFromJson(Map<String, dynamic> j) {
    return CaronaItem(
      idCarona: j['idCarona'] as int,
      idGrupo: j['idGrupo'] as int,
      grupoNome: (j['grupoNome'] as String?) ?? 'Grupo',
      status: _status(j['status']),
      data: DateTime.parse(j['data'] as String).toLocal(),
      papel: j['papel'] == 'motorista'
          ? PapelCarona.motorista
          : PapelCarona.passageiro,
      motoristaNome: j['motoristaNome'] as String?,
      totalPassageiros: (j['totalPassageiros'] as int?) ?? 0,
    );
  }

  CaronaDetalhe _detalheFromJson(Map<String, dynamic> j) {
    final motorista = j['motorista'];
    final passageiros = (j['passageiros'] as List<dynamic>? ?? const [])
        .map((e) => e as Map<String, dynamic>)
        .map((p) => PassageiroCarona(
              idUsuario: p['idUsuario'] as int,
              nome: (p['nome'] as String?) ?? 'Usuário',
            ))
        .toList(growable: false);
    return CaronaDetalhe(
      idCarona: j['idCarona'] as int,
      idGrupo: j['idGrupo'] as int,
      grupoNome: (j['grupoNome'] as String?) ?? 'Grupo',
      status: _status(j['status']),
      data: DateTime.parse(j['data'] as String).toLocal(),
      idMotorista: motorista is Map ? motorista['idUsuario'] as int? : null,
      motoristaNome: motorista is Map ? motorista['nome'] as String? : null,
      passageiros: passageiros,
    );
  }

  GrupoFailure _mapError(DioException e) {
    final body = e.response?.data;
    if (body is Map &&
        (body['error'] == 'FORBIDDEN' ||
            body['error'] == 'NOT_FOUND' ||
            body['error'] == 'CONFLICT' ||
            body['error'] == 'VALIDATION')) {
      final msg = body['message'];
      return GrupoOperationFailure(
        msg is String && msg.isNotEmpty ? msg : 'Operação não permitida.',
      );
    }
    return const GrupoOperationFailure(
        'Não foi possível conectar ao servidor. Verifique sua conexão.');
  }
}
