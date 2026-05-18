sealed class AuthFailure implements Exception {
  final String message;
  const AuthFailure(this.message);

  @override
  String toString() => message;
}

class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure() : super('Usuário ou senha inválidos');
}

class EmptyFieldsFailure extends AuthFailure {
  const EmptyFieldsFailure() : super('Preencha todos os campos.');
}

class InvalidEmailFailure extends AuthFailure {
  const InvalidEmailFailure()
      : super('Digite um e-mail válido (ex: nome@email.com).');
}

class EmailInUseFailure extends AuthFailure {
  const EmailInUseFailure()
      : super('Este e-mail já está em uso por outra conta.');
}

class WeakPasswordFailure extends AuthFailure {
  const WeakPasswordFailure() : super('A senha deve ter no mínimo 8 caracteres.');
}

class PasswordMismatchFailure extends AuthFailure {
  const PasswordMismatchFailure() : super('As senhas não coincidem.');
}
