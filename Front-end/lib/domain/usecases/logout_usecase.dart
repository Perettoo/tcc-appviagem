class LogoutUseCase {
  const LogoutUseCase();

  Future<void> call() async {
    // No-op no datasource in-memory; existe para padronizar e ser swappable.
  }
}
