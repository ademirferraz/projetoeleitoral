import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Tempo de resposta deve ser menor que 2 segundos', () async {
    final stopwatch = Stopwatch()..start();

    // Simulação de operação pesada
    await Future.delayed(Duration(milliseconds: 1500));

    stopwatch.stop();
    expect(stopwatch.elapsedMilliseconds < 2000, true);
  });
}
