import 'package:test_tcc/data/datasources/user_local_datasource.dart';
import 'package:test_tcc/domain/entities/user.dart';
import 'package:test_tcc/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserLocalDatasource datasource;

  const UserRepositoryImpl(this.datasource);

  @override
  Future<List<User>> listAll() async => datasource.all();

  @override
  Future<void> deleteByEmail(String email) async {
    datasource.deleteByEmail(email);
  }
}
