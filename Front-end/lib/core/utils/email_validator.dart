// Validação simples de e-mail (mesma regra do backend: algo@algo.dominio).
final _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

bool isValidEmail(String email) => _emailRegex.hasMatch(email.trim());
