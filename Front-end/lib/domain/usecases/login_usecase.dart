import 'package:test_tcc/domain/entities/user.dart';
import 'package:test_tcc/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  const LoginUseCase(this.repository);

  Future<User> call({required String identifier, required String password}) {
    return repository.login(identifier: identifier, password: password);
  }
}
