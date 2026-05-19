import 'package:dio/dio.dart';
import 'package:test_tcc/core/config/api_config.dart';
import 'package:test_tcc/domain/entities/user.dart';
import 'package:test_tcc/domain/failures/auth_failure.dart';

class AuthRemoteDatasource {
  final Dio _dio;

  AuthRemoteDatasource({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: ApiConfig.baseUrl,
              connectTimeout: const Duration(seconds: 8),
              receiveTimeout: const Duration(seconds: 8),
            ));

  Future<User> register({
    required String name,
    required String email,
    required String password,
    required String cpf,
    required DateTime dataNascimento,
    required TipoUsuario tipo,
  }) async {
    try {
      final response = await _dio.post(
        '/usuarios',
        data: {
          'nome': name,
          'email': email,
          'senha': password,
          'cpf': cpf,
          'dataNascimento':
              dataNascimento.toIso8601String().substring(0, 10),
          'tipo': tipo.name,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return User(
        name: data['nome'] as String,
        email: data['email'] as String,
        password: password,
        cpf: cpf,
        dataNascimento: DateTime.parse(data['dataNascimento'] as String),
        tipo: TipoUsuario.values.firstWhere((t) => t.name == data['tipo']),
      );
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  AuthFailure _mapError(DioException e) {
    final body = e.response?.data;
    if (body is Map && body['error'] == 'CONFLICT') {
      final campo = (body['details'] as Map?)?['campo'];
      if (campo == 'email') return const EmailInUseFailure();
      if (campo == 'cpf') return const CpfInUseFailure();
    }
    if (body is Map && body['error'] == 'VALIDATION') {
      final details = body['details'] as Map?;
      final first = details?.values.first;
      return RegistrationFailure(first?.toString() ?? 'Dados invalidos.');
    }
    return const RegistrationFailure(
        'Nao foi possivel conectar ao servidor. Verifique sua conexao.');
  }
}
