import 'package:test_tcc/domain/repositories/user_repository.dart';

class DeleteUserUseCase {
  final UserRepository repository;

  const DeleteUserUseCase(this.repository);

  Future<void> call(String email) => repository.deleteByEmail(email);
}
