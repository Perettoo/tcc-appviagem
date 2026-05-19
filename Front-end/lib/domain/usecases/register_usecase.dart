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
    required String cpf,
    required DateTime? dataNascimento,
    required TipoUsuario tipo,
  }) async {
    final trimmedName = name.trim();
    final trimmedEmail = email.trim();
    final cpfDigits = cpf.replaceAll(RegExp(r'\D'), '');

    if (trimmedName.isEmpty ||
        trimmedEmail.isEmpty ||
        password.isEmpty ||
        cpfDigits.isEmpty ||
        dataNascimento == null) {
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
    if (cpfDigits.length != 11) {
      throw const InvalidCpfFailure();
    }
    if (_idade(dataNascimento) < 18) {
      throw const UnderageFailure();
    }

    return repository.register(
      name: trimmedName,
      email: trimmedEmail,
      password: password,
      cpf: cpfDigits,
      dataNascimento: dataNascimento,
      tipo: tipo,
    );
  }

  int _idade(DateTime nasc) {
    final hoje = DateTime.now();
    var idade = hoje.year - nasc.year;
    final aniversarioPassou = hoje.month > nasc.month ||
        (hoje.month == nasc.month && hoje.day >= nasc.day);
    if (!aniversarioPassou) idade--;
    return idade;
  }
}
