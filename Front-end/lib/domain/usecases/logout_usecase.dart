import 'package:test_tcc/data/datasources/token_storage.dart';

class LogoutUseCase {
  final TokenStorage tokenStorage;

  const LogoutUseCase(this.tokenStorage);

  Future<void> call() async {
    tokenStorage.clear();
  }
}
