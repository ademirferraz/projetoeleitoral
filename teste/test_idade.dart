import 'package:flutter_test/flutter_test.dart';
bool podeVotar(int idade) => idade >= 16;
void main() {
  test('Menor de 16 não pode votar', () {
    expect(podeVotar(15), false);
  });
  test('Maior de 16 pode votar', () {
    expect(podeVotar(20), true);
  });
}
