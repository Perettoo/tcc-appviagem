// Formatadores de exibição. App armazena/trafega só dígitos;
// estes helpers são usados na camada de apresentação.

String onlyDigits(String input) => input.replaceAll(RegExp(r'\D'), '');

/// 11122233344 → 111.222.333-44
String formatCpf(String raw) {
  final d = onlyDigits(raw);
  if (d.length != 11) return raw;
  return '${d.substring(0, 3)}.${d.substring(3, 6)}.${d.substring(6, 9)}-${d.substring(9, 11)}';
}

/// 11987654321 → (11) 98765-4321
/// 1133334444  → (11) 3333-4444
String formatTelefone(String raw) {
  final d = onlyDigits(raw);
  if (d.length == 11) {
    return '(${d.substring(0, 2)}) ${d.substring(2, 7)}-${d.substring(7, 11)}';
  }
  if (d.length == 10) {
    return '(${d.substring(0, 2)}) ${d.substring(2, 6)}-${d.substring(6, 10)}';
  }
  return raw;
}

/// 01310100 → 01310-100
String formatCep(String raw) {
  final d = onlyDigits(raw);
  if (d.length != 8) return raw;
  return '${d.substring(0, 5)}-${d.substring(5, 8)}';
}

/// DateTime → DD/MM/AAAA
String formatData(DateTime data) {
  final dia = data.day.toString().padLeft(2, '0');
  final mes = data.month.toString().padLeft(2, '0');
  return '$dia/$mes/${data.year}';
}
