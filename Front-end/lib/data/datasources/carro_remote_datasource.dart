import 'package:dio/dio.dart';
import 'package:test_tcc/core/config/api_config.dart';
import 'package:test_tcc/data/datasources/token_storage.dart';
import 'package:test_tcc/domain/entities/carro.dart';
import 'package:test_tcc/domain/failures/carro_failure.dart';

/// Acesso REST aos carros do usuário (CRUD + seleção do ativo).
class CarroRemoteDatasource {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  CarroRemoteDatasource({required TokenStorage tokenStorage, Dio? dio})
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

  Future<List<Carro>> listar() async {
    try {
      final response = await _dio.get('/carros');
      final list = response.data as List<dynamic>;
      return list
          .map((e) => _fromJson(e as Map<String, dynamic>))
          .toList(growable: false);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Carro> criar({
    required String marca,
    required String modelo,
    required int anoFabricacao,
    required String cor,
    required String placa,
  }) async {
    try {
      final response = await _dio.post('/carros', data: {
        'marca': marca,
        'modelo': modelo,
        'anoFabricacao': anoFabricacao,
        'cor': cor,
        'placa': placa,
      });
      return _fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Carro> atualizar({
    required int idCarro,
    required String marca,
    required String modelo,
    required int anoFabricacao,
    required String cor,
    required String placa,
  }) async {
    try {
      final response = await _dio.patch('/carros/$idCarro', data: {
        'marca': marca,
        'modelo': modelo,
        'anoFabricacao': anoFabricacao,
        'cor': cor,
        'placa': placa,
      });
      return _fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> excluir(int idCarro) async {
    try {
      await _dio.delete('/carros/$idCarro');
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Carro> ativar(int idCarro) async {
    try {
      final response = await _dio.patch('/carros/$idCarro/ativar');
      return _fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Carro _fromJson(Map<String, dynamic> j) {
    return Carro(
      idCarro: j['idCarro'] as int,
      marca: j['marca'] as String,
      modelo: j['modelo'] as String,
      anoFabricacao: j['anoFabricacao'] as int,
      cor: j['cor'] as String,
      placa: j['placa'] as String,
      ativo: j['ativo'] == true || j['ativo'] == 1,
    );
  }

  CarroFailure _mapError(DioException e) {
    final body = e.response?.data;
    if (body is Map && body['error'] == 'VALIDATION') {
      final details = body['details'] as Map?;
      final first = details?.values.first;
      return CarroOperationFailure(first?.toString() ?? 'Dados inválidos.');
    }
    // FORBIDDEN/NOT_FOUND/CONFLICT já trazem mensagem amigável do backend.
    if (body is Map &&
        (body['error'] == 'FORBIDDEN' ||
            body['error'] == 'NOT_FOUND' ||
            body['error'] == 'CONFLICT')) {
      final msg = body['message'];
      return CarroOperationFailure(
        msg is String && msg.isNotEmpty ? msg : 'Operação não permitida.',
      );
    }
    return const CarroOperationFailure(
        'Não foi possível conectar ao servidor. Verifique sua conexão.');
  }
}
