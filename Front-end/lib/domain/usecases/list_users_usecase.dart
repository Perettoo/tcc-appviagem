import 'package:test_tcc/domain/entities/user.dart';
import 'package:test_tcc/domain/repositories/user_repository.dart';

class ListUsersUseCase {
  final UserRepository repository;

  const ListUsersUseCase(this.repository);

  Future<List<User>> call() => repository.listAll();
}
