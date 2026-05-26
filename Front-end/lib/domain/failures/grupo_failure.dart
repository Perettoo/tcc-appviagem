sealed class GrupoFailure implements Exception {
  final String message;
  const GrupoFailure(this.message);

  @override
  String toString() => message;
}

class GrupoNomeObrigatorioFailure extends GrupoFailure {
  const GrupoNomeObrigatorioFailure() : super('Informe o nome do grupo.');
}

/// Erro genérico vindo do backend (validação, conexão, etc).
class GrupoOperationFailure extends GrupoFailure {
  const GrupoOperationFailure(super.message);
}
