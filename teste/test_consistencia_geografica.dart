import 'package:flutter_test/flutter_test.dart';
List<String> candidatosPorCidade(String cidade, Map<String, List<String>> base) {
  return base[cidade] ?? [];
}
void main() {
  final base = {
    "CidadeA": ["Prefeito A1", "Prefeito A2"],
    "CidadeB": ["Prefeito B1"]
  };
  test('Eleitor de Cidade A só vê candidatos de Cidade A', () {
    expect(candidatosPorCidade("CidadeA", base), ["Prefeito A1", "Prefeito A2"]);
  });
  test('Eleitor de Cidade B só vê candidatos de Cidade B', () {
    expect(candidatosPorCidade("CidadeB", base), ["Prefeito B1"]);
  });
}
