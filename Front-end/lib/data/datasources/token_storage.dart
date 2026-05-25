// TokenStorage in-memory.
// Em produção, trocar por flutter_secure_storage (requer Dev Mode no Windows).
class TokenStorage {
  String? _token;

  String? read() => _token;

  void save(String token) {
    _token = token;
  }

  void clear() {
    _token = null;
  }
}
