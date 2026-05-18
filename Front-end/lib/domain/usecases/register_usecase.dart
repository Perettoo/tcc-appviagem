import 'package:test_tcc/core/utils/email_validator.dart';
import 'package:test_tcc/domain/entities/user.dart';
import 'package:test_tcc/domain/failures/auth_failure.dart';
import 'package:test_tcc/domain/repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  const RegisterUseCase(this.repository);

  Future<User> call({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required TipoUsuario tipo,
  }) async {
    final trimmedName = name.trim();
    final trimmedEmail = email.trim();

    if (trimmedName.isEmpty || trimmedEmail.isEmpty || password.isEmpty) {
      throw const EmptyFieldsFailure();
    }
    if (!isValidEmail(trimmedEmail)) {
      throw const InvalidEmailFailure();
    }
    if (password.length < 8) {
      throw const WeakPasswordFailure();
    }
    if (password != confirmPassword) {
      throw const PasswordMismatchFailure();
    }

    return repository.register(
      name: trimmedName,
      email: trimmedEmail,
      password: password,
      tipo: tipo,
    );
  }
}
