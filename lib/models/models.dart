class Eleitor {
  final String id;
  final String nome;
  final String cpf;
  final DateTime dataNascimento;
  final String bairro;
  final bool votou;
  final DateTime? dataVoto;

  Eleitor({
    required this.id,
    required this.nome,
    required this.cpf,
    required this.dataNascimento,
    required this.bairro,
    this.votou = false,
    this.dataVoto,
  });

  int get idade {
    final hoje = DateTime.now();
    int idade = hoje.year - dataNascimento.year;
    if (hoje.month < dataNascimento.month ||
        (hoje.month == dataNascimento.month && hoje.day < dataNascimento.day)) {
      idade--;
    }
    return idade;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'cpf': cpf,
        'dataNascimento': dataNascimento.toIso8601String(),
        'bairro': bairro,
        'votou': votou,
        'dataVoto': dataVoto?.toIso8601String(),
      };

  factory Eleitor.fromJson(Map<String, dynamic> json) => Eleitor(
        id: json['id'],
        nome: json['nome'],
        cpf: json['cpf'],
        dataNascimento: DateTime.parse(json['dataNascimento']),
        bairro: json['bairro'],
        votou: json['votou'] ?? false,
        dataVoto: json['dataVoto'] != null ? DateTime.parse(json['dataVoto']) : null,
      );
}

class Candidato {
  final String id;
  final String nome;
  final int numero;
  final String? fotoPath;
  final String? estado;
  final String? cidade;
  int votos;

  Candidato({
    required this.id,
    required this.nome,
    required this.numero,
    this.fotoPath,
    this.estado,
    this.cidade,
    this.votos = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'numero': numero,
        'fotoPath': fotoPath,
        'estado': estado,
        'cidade': cidade,
        'votos': votos,
      };

  factory Candidato.fromJson(Map<String, dynamic> json) => Candidato(
        id: json['id'],
        nome: json['nome'],
        numero: json['numero'],
        fotoPath: json['fotoPath'],
        estado: json['estado'],
        cidade: json['cidade'],
        votos: json['votos'] ?? 0,
      );

  Candidato copyWith({
    String? id,
    String? nome,
    int? numero,
    String? fotoPath,
    String? estado,
    String? cidade,
    int? votos,
  }) {
    return Candidato(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      numero: numero ?? this.numero,
      fotoPath: fotoPath ?? this.fotoPath,
      estado: estado ?? this.estado,
      cidade: cidade ?? this.cidade,
      votos: votos ?? this.votos,
    );
  }
}

class Voto {
  final String idEleitor;
  final String idCandidato;
  final DateTime dataVoto;

  Voto({
    required this.idEleitor,
    required this.idCandidato,
    required this.dataVoto,
  });

  Map<String, dynamic> toJson() => {
        'idEleitor': idEleitor,
        'idCandidato': idCandidato,
        'dataVoto': dataVoto.toIso8601String(),
      };
}

class MensagemComemorativa {
  final String id;
  final String tipo;
  final String mensagem;
  final DateTime? dataEspecifica;

  MensagemComemorativa({
    required this.id,
    required this.tipo,
    required this.mensagem,
    this.dataEspecifica,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'tipo': tipo,
        'mensagem': mensagem,
        'dataEspecifica': dataEspecifica?.toIso8601String(),
      };

  factory MensagemComemorativa.fromJson(Map<String, dynamic> json) =>
      MensagemComemorativa(
        id: json['id'],
        tipo: json['tipo'],
        mensagem: json['mensagem'],
        dataEspecifica: json['dataEspecifica'] != null
            ? DateTime.parse(json['dataEspecifica'])
            : null,
      );
}