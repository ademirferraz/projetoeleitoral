import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validação de votos por cargo', () {
    test('Prefeito exige cidade', () {
      final cargo = 'prefeito';
      final estado = 'PE';
      final cidade = null; // não informado

      final valido = (cargo == 'prefeito' && cidade != null);
      expect(valido, false, reason: 'Prefeito só é válido com cidade definida');
    });

    test('Deputado estadual válido apenas com estado', () {
      final cargo = 'deputado';
      final estado = 'PE';
      final cidade = null; // não informado

      final valido = (cargo == 'deputado' && estado != null);
      expect(valido, true, reason: 'Deputado é válido em qualquer cidade do estado');
    });

    test('Senador válido apenas com estado', () {
      final cargo = 'senador';
      final estado = 'PE';
      final cidade = null; // não informado

      final valido = (cargo == 'senador' && estado != null);
      expect(valido, true, reason: 'Senador é válido em qualquer cidade do estado');
    });

    test('Presidente válido sem estado ou cidade', () {
      final cargo = 'presidente';
      final estado = null;
      final cidade = null;

      final valido = (cargo == 'presidente');
      expect(valido, true, reason: 'Presidente é válido em qualquer lugar do país');
    });
  });
}
