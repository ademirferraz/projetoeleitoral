import 'package:flutter_test/flutter_test.dart';
bool cpfValido(String cpf, Set<String> cpfsJaVotaram) {
  return !cpfsJaVotaram.contains(cpf);
}
void main() {
  test('Mesmo CPF não pode votar duas vezes', () {
    expect(cpfValido("12345678900", {"12345678900"}), false);
  });
  test('CPF novo pode votar', () {
    expect(cpfValido("98765432100", {"12345678900"}), true);
  });
}
