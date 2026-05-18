import 'package:test_tcc/domain/entities/user.dart';

abstract class AuthRepository {
  Future<User> login({required String identifier, required String password});

  Future<User> register({
    required String name,
    required String email,
    required String password,
    required TipoUsuario tipo,
  });
}
