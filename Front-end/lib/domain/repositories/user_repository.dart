import 'package:test_tcc/domain/entities/user.dart';

abstract class UserRepository {
  Future<List<User>> listAll();

  Future<void> deleteByEmail(String email);
}
