import 'package:test_tcc/domain/entities/user.dart';

class UserLocalDatasource {
  final List<User> _users = [
    User(
      name: 'Daniel',
      email: 'admin',
      password: 'admin',
      cpf: '00000000000',
      dataNascimento: DateTime(2000, 1, 1),
      tipo: TipoUsuario.ambos,
    ),
  ];

  List<User> all() => List.unmodifiable(_users);

  User? findByIdentifierAndPassword(String identifier, String password) {
    final id = identifier.toLowerCase();
    for (final u in _users) {
      final matchesId =
          u.email.toLowerCase() == id || u.name.toLowerCase() == id;
      if (matchesId && u.password == password) return u;
    }
    return null;
  }

  bool existsByEmail(String email) {
    final e = email.toLowerCase();
    for (final u in _users) {
      if (u.email.toLowerCase() == e) return true;
    }
    return false;
  }

  void add(User user) => _users.add(user);

  void deleteByEmail(String email) {
    _users.removeWhere((u) => u.email == email);
  }
}
