sealed class CarroFailure implements Exception {
  final String message;
  const CarroFailure(this.message);

  @override
  String toString() => message;
}

/// Erro vindo do backend (validação, regra, conexão). A mensagem já é amigável.
class CarroOperationFailure extends CarroFailure {
  const CarroOperationFailure(super.message);
}
