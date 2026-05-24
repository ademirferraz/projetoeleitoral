import 'package:flutter_test/flutter_test.dart';

class Candidato {
  final String id;
  final String nome;
  final String? cargo;
  final String? cidade;
  final String? estado;
  Candidato({required this.id, required this.nome, this.cargo, this.cidade, this.estado});
}

class Eleitor {
  final String? cidade;
  final String? estado;
  Eleitor({this.cidade, this.estado});
}

String? validarVoto(Candidato candidato, Set<String> cargosSelecionados, Eleitor eleitor) {
  final cargo = candidato.cargo;
  if (cargo == null) return null;

  if (cargosSelecionados.contains(cargo)) {
    switch (cargo) {
      case 'Prefeito':
        return 'Você só pode votar em um candidato a prefeito da sua cidade.';
      case 'Presidente':
        return 'Você só pode votar em um candidato a presidente.';
      case 'Senador':
      case 'Deputado Federal':
      case 'Deputado Estadual':
        return 'Você só pode votar em candidatos do seu estado.';
    }
  }

  if (cargo == 'Prefeito') {
    final cidadeEleitor = eleitor.cidade?.toLowerCase().trim() ?? '';
    final cidadeCand = candidato.cidade?.toLowerCase().trim() ?? '';
    if (cidadeEleitor.isEmpty || cidadeCand.isEmpty || cidadeCand != cidadeEleitor) {
      return 'Você só pode votar em um candidato a prefeito da sua cidade.';
    }
  }

  if (cargo == 'Senador' || cargo == 'Deputado Federal' || cargo == 'Deputado Estadual') {
    final estadoEleitor = eleitor.estado?.toLowerCase().trim() ?? '';
    final estadoCand = candidato.estado?.toLowerCase().trim() ?? '';
    if (estadoEleitor.isEmpty || estadoCand.isEmpty || estadoCand != estadoEleitor) {
      return 'Você só pode votar em candidatos do seu estado.';
    }
  }

  return null;
}

void main() {
  final eleitorSP = Eleitor(cidade: 'São Paulo', estado: 'SP');
  final prefeitoSP = Candidato(id: 'p1', nome: 'Prefeito SP', cargo: 'Prefeito', cidade: 'São Paulo', estado: 'SP');
  final prefeitoOutraCidade = Candidato(id: 'p2', nome: 'Prefeito Outra', cargo: 'Prefeito', cidade: 'Campinas', estado: 'SP');
  final presidente1 = Candidato(id: 'pr1', nome: 'Presidente A', cargo: 'Presidente');
  final senadorSP = Candidato(id: 's1', nome: 'Senador SP', cargo: 'Senador', estado: 'SP');
  final senadorOutroEstado = Candidato(id: 's2', nome: 'Senador RJ', cargo: 'Senador', estado: 'RJ');

  group('Regra: Prefeito', () {
    test('Eleitor de SP pode selecionar prefeito de SP', () {
      expect(validarVoto(prefeitoSP, {}, eleitorSP), isNull);
    });

    test('Eleitor de SP NÃO pode selecionar prefeito de outra cidade', () {
      expect(validarVoto(prefeitoOutraCidade, {}, eleitorSP), isNotNull);
    });

    test('Eleitor NÃO pode selecionar dois prefeitos', () {
      expect(validarVoto(prefeitoSP, {'Prefeito'}, eleitorSP), isNotNull);
    });
  });

  group('Regra: Presidente', () {
    test('Eleitor pode selecionar presidente sem restrição', () {
      expect(validarVoto(presidente1, {}, eleitorSP), isNull);
    });

    test('Eleitor NÃO pode selecionar dois presidentes', () {
      expect(validarVoto(presidente1, {'Presidente'}, eleitorSP), isNotNull);
    });
  });

  group('Regra: Senador', () {
    test('Eleitor de SP pode selecionar senador de SP', () {
      expect(validarVoto(senadorSP, {}, eleitorSP), isNull);
    });

    test('Eleitor de SP NÃO pode selecionar senador de outro estado', () {
      expect(validarVoto(senadorOutroEstado, {}, eleitorSP), isNotNull);
    });

    test('Eleitor NÃO pode selecionar dois senadores', () {
      expect(validarVoto(senadorSP, {'Senador'}, eleitorSP), isNotNull);
    });
  });

  group('Regra: Deputado Federal', () {
    final depFedSP = Candidato(id: 'df1', nome: 'Dep Fed SP', cargo: 'Deputado Federal', estado: 'SP');
    test('Eleitor de SP pode selecionar Dep Federal de SP', () {
      expect(validarVoto(depFedSP, {}, eleitorSP), isNull);
    });
    test('Eleitor NÃO pode selecionar dois Dep Federais', () {
      expect(validarVoto(depFedSP, {'Deputado Federal'}, eleitorSP), isNotNull);
    });
  });

  group('Regra: Deputado Estadual', () {
    final depEstSP = Candidato(id: 'de1', nome: 'Dep Est SP', cargo: 'Deputado Estadual', estado: 'SP');
    test('Eleitor de SP pode selecionar Dep Estadual de SP', () {
      expect(validarVoto(depEstSP, {}, eleitorSP), isNull);
    });
    test('Eleitor NÃO pode selecionar dois Dep Estaduais', () {
      expect(validarVoto(depEstSP, {'Deputado Estadual'}, eleitorSP), isNotNull);
    });
  });
}
