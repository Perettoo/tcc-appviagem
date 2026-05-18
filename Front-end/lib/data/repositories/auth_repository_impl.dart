import 'package:test_tcc/data/datasources/user_local_datasource.dart';
import 'package:test_tcc/domain/entities/user.dart';
import 'package:test_tcc/domain/failures/auth_failure.dart';
import 'package:test_tcc/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final UserLocalDatasource datasource;

  const AuthRepositoryImpl(this.datasource);

  @override
  Future<User> login({
    required String identifier,
    required String password,
  }) async {
    final user = datasource.findByIdentifierAndPassword(identifier, password);
    if (user == null) {
      throw const InvalidCredentialsFailure();
    }
    return user;
  }

  @override
  Future<User> register({
    required String name,
    required String email,
    required String password,
    required TipoUsuario tipo,
  }) async {
    if (datasource.existsByEmail(email)) {
      throw const EmailInUseFailure();
    }
    final user = User(name: name, email: email, password: password, tipo: tipo);
    datasource.add(user);
    return user;
  }
}
