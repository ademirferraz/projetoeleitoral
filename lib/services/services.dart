import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

class DatabaseService {
  static const String _eleitoresKey = 'eleitores';
  static const String _candidatosKey = 'candidatos';
  static const String _votosKey = 'votos';
  static const String _votosPesquisaKey = 'votos_pesquisa';
  static const String _mensagensKey = 'mensagens';

  static Uint8List? _storageData;

  static Future<void> init() async {}

  static List<Eleitor> getEleitores() {
    if (_storageData == null) return [];
    try {
      final data = utf8.decode(_storageData!);
      final Map<String, dynamic> json = jsonDecode(data);
      final list = json[_eleitoresKey] as List? ?? [];
      return list.map((e) => Eleitor.fromJson(e)).toList();
    } catch (_) { return []; }
  }

  static Future<void> saveEleitor(Eleitor eleitor) async {
    final electors = getEleitores();
    final index = electors.indexWhere((e) => e.id == eleitor.id);
    if (index >= 0) { electors[index] = eleitor; } else { electors.add(eleitor); }
    _saveData({_eleitoresKey: electors.map((e) => e.toJson()).toList()});
  }

  static List<Candidato> getCandidatos() {
    if (_storageData != null) {
      try {
        final data = utf8.decode(_storageData!);
        final Map<String, dynamic> json = jsonDecode(data);
        final list = json[_candidatosKey] as List? ?? [];
        return list.map((e) => Candidato.fromJson(e)).toList();
      } catch (_) {}
    }
    return _candidatosMock;
  }

  static Future<void> saveCandidato(Candidato candidato) async {
    final candidatos = getCandidatos();
    final index = candidatos.indexWhere((c) => c.id == candidato.id);
    if (index >= 0) { candidatos[index] = candidato; } else { candidatos.add(candidato); }
    _saveData({_candidatosKey: candidatos.map((c) => c.toJson()).toList()});
  }

  static Future<void> deleteCandidato(String id) async {
    final candidatos = getCandidatos();
    candidatos.removeWhere((c) => c.id == id);
    _saveData({_candidatosKey: candidatos.map((c) => c.toJson()).toList()});
  }

  static List<Voto> getVotos() {
    if (_storageData == null) return [];
    try {
      final data = utf8.decode(_storageData!);
      final Map<String, dynamic> json = jsonDecode(data);
      final list = json[_votosKey] as List? ?? [];
      return list.map((e) => Voto.fromJson(e)).toList();
    } catch (_) { return []; }
  }

  static Future<void> saveVoto(Voto voto) async {
    final votos = getVotos();
    votos.add(voto);
    _saveData({_votosKey: votos.map((v) => v.toJson()).toList()});
    
    final candidatos = getCandidatos();
    final index = candidatos.indexWhere((c) => c.id == voto.idCandidato);
    if (index >= 0) {
      candidatos[index].votos++;
      _saveData({_candidatosKey: candidatos.map((c) => c.toJson()).toList()});
    }
  }

  static bool jaVotou(String cpfHash) {
    return getEleitores().any((e) => hashCpf(e.cpf) == cpfHash && e.votou);
  }

  static Map<String, int> getVotosPesquisa() {
    if (_storageData == null) return {};
    try {
      final data = utf8.decode(_storageData!);
      final Map<String, dynamic> json = jsonDecode(data);
      final list = json[_votosPesquisaKey] as List? ?? [];
      final Map<String, int> result = {'verde': 0, 'vermelho': 0, 'branco': 0};
      for (final p in list) {
        final tipo = p['tipo'] as String;
        result[tipo] = (result[tipo] ?? 0) + 1;
      }
      return result;
    } catch (_) { return {'verde': 0, 'vermelho': 0, 'branco': 0}; }
  }

  static Future<void> savePesquisa(PesquisaCampo pesquisa) async {
    final pesquisas = getPesquisas();
    pesquisas.add(pesquisa);
    _saveData({_votosPesquisaKey: pesquisas.map((p) => p.toJson()).toList()});
  }

  static List<PesquisaCampo> getPesquisas() {
    if (_storageData == null) return [];
    try {
      final data = utf8.decode(_storageData!);
      final Map<String, dynamic> json = jsonDecode(data);
      final list = json[_votosPesquisaKey] as List? ?? [];
      return list.map((e) => PesquisaCampo.fromJson(e)).toList();
    } catch (_) { return []; }
  }

  static void _saveData(Map<String, dynamic> data) {
    Map<String, dynamic> existing = {};
    if (_storageData != null) {
      try { existing = jsonDecode(utf8.decode(_storageData!)); } catch (_) {}
    }
    existing.addAll(data);
    _storageData = Uint8List.fromList(utf8.encode(jsonEncode(existing)));
  }

  static String hashCpf(String cpf) {
    final bytes = utf8.encode(cpf);
    return sha256.convert(bytes).toString();
  }

  static int getTotalVotos() {
    return getVotos().length;
  }

  static Map<String, int> getVotosPorBairro() {
    final Map<String, int> result = {};
    for (final eleitor in getEleitores().where((e) => e.votou)) {
      result[eleitor.bairro] = (result[eleitor.bairro] ?? 0) + 1;
    }
    return result;
  }

  static Future<void> clearAllData() async {
    _storageData = null;
  }

  static final List<Candidato> _candidatosMock = [
    Candidato(id: '1', nome: 'Lula', numero: 13, partido: 'PT', sigla: 'PT', votos: 0),
    Candidato(id: '2', nome: 'Bolsonaro', numero: 22, partido: 'PL', sigla: 'PL', votos: 0),
    Candidato(id: '3', nome: 'Simone Tebet', numero: 15, partido: 'MDB', sigla: 'MDB', votos: 0),
    Candidato(id: '4', nome: 'Ciro Gomes', numero: 12, partido: 'PDT', sigla: 'PDT', votos: 0),
    Candidato(id: '5', nome: 'Soraya Thronicke', numero: 44, partido: 'UNIÃO', sigla: 'UNIÃO', votos: 0),
    Candidato(id: '6', nome: 'André Janones', numero: 70, partido: 'AVANTE', sigla: 'AVANTE', votos: 0),
  ];
}

class ValidadorService {
  static bool validarCpf(String cpf) {
    cpf = cpf.replaceAll(RegExp(r'[^0-9]'), '');
    if (cpf.length != 11) return false;
    if (cpf.split('').toSet().length == 1) return false;
    
    int soma = 0;
    for (int i = 0; i < 9; i++) { soma += int.parse(cpf[i]) * (10 - i); }
    int resto = soma % 11;
    int digito1 = resto < 2 ? 0 : 11 - resto;
    
    soma = 0;
    for (int i = 0; i < 10; i++) { soma += int.parse(cpf[i]) * (11 - i); }
    resto = soma % 11;
    int digito2 = resto < 2 ? 0 : 11 - resto;
    
    return cpf[9] == digito1.toString() && cpf[10] == digito2.toString();
  }

  static int calcularIdade(DateTime dataNascimento) {
    final hoje = DateTime.now();
    int idade = hoje.year - dataNascimento.year;
    if (hoje.month < dataNascimento.month || (hoje.month == dataNascimento.month && hoje.day < dataNascimento.day)) { idade--; }
    return idade;
  }
}

class Eleitor {
  final String id;
  final String nome;
  final String cpf;
  final DateTime dataNascimento;
  final String bairro;
  final bool votou;
  final DateTime? dataVoto;

  Eleitor({required this.id, required this.nome, required this.cpf, required this.dataNascimento, required this.bairro, this.votou = false, this.dataVoto});

  Map<String, dynamic> toJson() => {'id': id, 'nome': nome, 'cpf': cpf, 'dataNascimento': dataNascimento.toIso8601String(), 'bairro': bairro, 'votou': votou, 'dataVoto': dataVoto?.toIso8601String()};

  factory Eleitor.fromJson(Map<String, dynamic> json) => Eleitor(
    id: json['id'], nome: json['nome'], cpf: json['cpf'], dataNascimento: DateTime.parse(json['dataNascimento']), bairro: json['bairro'], votou: json['votou'] ?? false, dataVoto: json['dataVoto'] != null ? DateTime.parse(json['dataVoto']) : null,
  );
}

class Candidato {
  final String id;
  final String nome;
  final int numero;
  final String partido;
  final String sigla;
  final String? fotoPath;
  int votos;

  Candidato({required this.id, required this.nome, required this.numero, required this.partido, required this.sigla, this.fotoPath, this.votos = 0});

  Map<String, dynamic> toJson() => {'id': id, 'nome': nome, 'numero': numero, 'partido': partido, 'sigla': sigla, 'fotoPath': fotoPath, 'votos': votos};

  factory Candidato.fromJson(Map<String, dynamic> json) => Candidato(
    id: json['id'], nome: json['nome'], numero: json['numero'], partido: json['partido'], sigla: json['sigla'], fotoPath: json['fotoPath'], votos: json['votos'] ?? 0,
  );

  Candidato copyWith({String? id, String? nome, int? numero, String? partido, String? sigla, String? fotoPath, int? votos}) {
    return Candidato(id: id ?? this.id, nome: nome ?? this.nome, numero: numero ?? this.numero, partido: partido ?? this.partido, sigla: sigla ?? this.sigla, fotoPath: fotoPath ?? this.fotoPath, votos: votos ?? this.votos);
  }
}

class Voto {
  final String idEleitor;
  final String idCandidato;
  final String tipoVoto;
  final DateTime dataVoto;

  Voto({required this.idEleitor, required this.idCandidato, required this.tipoVoto, required this.dataVoto});

  Map<String, dynamic> toJson() => {'idEleitor': idEleitor, 'idCandidato': idCandidato, 'tipoVoto': tipoVoto, 'dataVoto': dataVoto.toIso8601String()};

  factory Voto.fromJson(Map<String, dynamic> json) => Voto(idEleitor: json['idEleitor'], idCandidato: json['idCandidato'], tipoVoto: json['tipoVoto'], dataVoto: DateTime.parse(json['dataVoto']));
}

class PesquisaCampo {
  final String? nome;
  final String? cpf;
  final String tipo;
  final DateTime data;

  PesquisaCampo({this.nome, this.cpf, required this.tipo, required this.data});

  Map<String, dynamic> toJson() => {'nome': nome, 'cpf': cpf, 'tipo': tipo, 'data': data.toIso8601String()};

  factory PesquisaCampo.fromJson(Map<String, dynamic> json) => PesquisaCampo(nome: json['nome'], cpf: json['cpf'], tipo: json['tipo'], data: DateTime.parse(json['data']));
}