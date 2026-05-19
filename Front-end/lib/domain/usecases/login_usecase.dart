import 'package:test_tcc/domain/entities/user.dart';
import 'package:test_tcc/domain/failures/auth_failure.dart';
import 'package:test_tcc/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  const LoginUseCase(this.repository);

  Future<User> call({required String identifier, required String password}) {
    final id = identifier.trim().toLowerCase();
    if (id.isEmpty || password.isEmpty) {
      throw const EmptyFieldsFailure();
    }
    return repository.login(identifier: id, password: password);
  }
}
