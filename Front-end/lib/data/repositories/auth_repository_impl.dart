import 'package:test_tcc/data/datasources/auth_remote_datasource.dart';
import 'package:test_tcc/data/datasources/user_local_datasource.dart';
import 'package:test_tcc/domain/entities/user.dart';
import 'package:test_tcc/domain/failures/auth_failure.dart';
import 'package:test_tcc/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final UserLocalDatasource local;
  final AuthRemoteDatasource remote;

  const AuthRepositoryImpl(this.local, this.remote);

  @override
  Future<User> login({
    required String identifier,
    required String password,
  }) async {
    final user = local.findByIdentifierAndPassword(identifier, password);
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
    required String cpf,
    required DateTime dataNascimento,
    required TipoUsuario tipo,
  }) async {
    return remote.register(
      name: name,
      email: email,
      password: password,
      cpf: cpf,
      dataNascimento: dataNascimento,
      tipo: tipo,
    );
  }
}
