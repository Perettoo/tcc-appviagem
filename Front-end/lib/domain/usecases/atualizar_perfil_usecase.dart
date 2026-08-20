import 'package:test_tcc/core/config/app_constants.dart';
import 'package:test_tcc/core/utils/email_validator.dart';
import 'package:test_tcc/domain/entities/user.dart';
import 'package:test_tcc/domain/failures/auth_failure.dart';
import 'package:test_tcc/domain/repositories/auth_repository.dart';

/// Edita o próprio perfil (e-mail, data de nascimento e/ou saldo). Valida no
/// cliente antes de chamar o backend (que revalida e checa unicidade do e-mail).
class AtualizarPerfilUseCase {
  final AuthRepository repository;

  const AtualizarPerfilUseCase(this.repository);

  Future<User> call({
    String? email,
    DateTime? dataNascimento,
    double? valor,
  }) async {
    if (email == null && dataNascimento == null && valor == null) {
      throw const EmptyFieldsFailure();
    }

    String? emailLimpo;
    if (email != null) {
      emailLimpo = email.trim();
      if (!isValidEmail(emailLimpo)) {
        throw const InvalidEmailFailure();
      }
    }

    if (dataNascimento != null && _idade(dataNascimento) < 18) {
      throw const UnderageFailure();
    }

    // Saldo é só um número informado pelo usuário; a única regra é a faixa.
    if (valor != null &&
        (valor < AppConstants.saldoMin || valor > AppConstants.saldoMax)) {
      throw const InvalidSaldoFailure();
    }

    return repository.atualizarPerfil(
      email: emailLimpo,
      dataNascimento: dataNascimento,
      valor: valor,
    );
  }

  int _idade(DateTime nasc) {
    final hoje = DateTime.now();
    var idade = hoje.year - nasc.year;
    final aniversarioPassou = hoje.month > nasc.month ||
        (hoje.month == nasc.month && hoje.day >= nasc.day);
    if (!aniversarioPassou) idade--;
    return idade;
  }
}
