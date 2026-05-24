import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';


class DatabaseService {
  static const String _eleitoresKey = 'eleitores';
  static const String _candidatosKey = 'candidatos';
  static const String _votosKey = 'votos';
  static const String _votosPesquisaKey = 'votos_pesquisa';
  static const String _adminPhonesKey = 'admin_phones';
  static const String _adminPhonesInactiveKey = 'admin_phones_inactive';
  static const String _opinioesCandidatosKey = 'opinioes_candidatos';
  static const String _contatosAdminKey = 'contatos_admin';
  static const String _ultimoEnvioKey = 'ultimo_envio';
  static const String _qpgSenhaKey = 'qpg_senha';

  static Uint8List? _storageData;
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final String? data = _prefs!.getString('storageData');
    if (data != null) {
      _storageData = Uint8List.fromList(utf8.encode(data));
    }
  }

  static List<Eleitor> getEleitores() {
    if (_storageData == null) return [];
    try {
      final data = utf8.decode(_storageData!);
      final Map<String, dynamic> json = jsonDecode(data);
      final list = json[_eleitoresKey] as List? ?? [];
      return list.map((e) => Eleitor.fromJson(e)).toList();
    } catch (_) { return []; }
  }

  static Future<bool> saveEleitor(Eleitor eleitor) async {
    final electors = getEleitores();
    final exists = electors.any((e) => e.cpf == eleitor.cpf);
    if (exists) return false;
    final index = electors.indexWhere((e) => e.id == eleitor.id);
    if (index >= 0) {
      electors[index] = eleitor;
    } else {
      electors.add(eleitor);
    }
    _saveData({_eleitoresKey: electors.map((e) => e.toJson()).toList()});
    return true;
  }

  static void setEleitorVotou(String cpfHash) {
    final electors = getEleitores();
    for (int i = 0; i < electors.length; i++) {
      if (hashCpf(electors[i].cpf) == cpfHash) {
        electors[i] = electors[i].copyWith(votou: true, dataVoto: DateTime.now());
        break;
      }
    }
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
    return [];
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
    final String jsonString = jsonEncode(existing);
    _storageData = Uint8List.fromList(utf8.encode(jsonString));
    _prefs?.setString('storageData', jsonString);
  }

  static String hashCpf(String cpf) {
    final bytes = utf8.encode(cpf);
    return sha256.convert(bytes).toString();
  }

  static bool cpfRegistrado(String cpfHash) {
    return getEleitores().any((e) => hashCpf(e.cpf) == cpfHash);
  }
  static int getTotalVotos() => getVotos().length;

  static Map<String, int> getVotosPorBairro() {
    final Map<String, int> result = {};
    for (final eleitor in getEleitores().where((e) => e.votou)) {
      result[eleitor.bairro] = (result[eleitor.bairro] ?? 0) + 1;
    }
    return result;
  }

  static List<String> getAdminPhones() {
    if (_storageData == null) return [];
    try {
      final data = utf8.decode(_storageData!);
      final Map<String, dynamic> json = jsonDecode(data);
      return List<String>.from(json[_adminPhonesKey] ?? []);
    } catch (_) { return []; }
  }

  static void saveAdminPhone(String number) {
    final phones = getAdminPhones();
    if (!phones.contains(number)) {
      phones.add(number);
      _saveData({_adminPhonesKey: phones});
    }
  }

  static void deleteAdminPhone(String number) {
    final phones = getAdminPhones();
    phones.remove(number);
    final inactive = getInactiveAdminPhones();
    inactive.remove(number);
    _saveData({_adminPhonesKey: phones, _adminPhonesInactiveKey: inactive});
  }

  static List<String> getInactiveAdminPhones() {
    if (_storageData == null) return [];
    try {
      final data = utf8.decode(_storageData!);
      final Map<String, dynamic> json = jsonDecode(data);
      return List<String>.from(json[_adminPhonesInactiveKey] ?? []);
    } catch (_) { return []; }
  }

  static void toggleAdminPhone(String number) {
    final active = getAdminPhones();
    final inactive = getInactiveAdminPhones();
    if (active.contains(number)) {
      active.remove(number);
      inactive.add(number);
    } else if (inactive.contains(number)) {
      inactive.remove(number);
      active.add(number);
    }
    _saveData({_adminPhonesKey: active, _adminPhonesInactiveKey: inactive});
  }

  // ──────────── OPINIÕES POR CANDIDATO ────────────

  static void saveOpiniaoCandidato(OpiniaoCandidato opiniao) {
    final list = getOpinioesCandidatos();
    list.add(opiniao);
    _saveData({_opinioesCandidatosKey: list.map((o) => o.toJson()).toList()});
  }

  static List<OpiniaoCandidato> getOpinioesCandidatos() {
    if (_storageData == null) return [];
    try {
      final data = utf8.decode(_storageData!);
      final Map<String, dynamic> json = jsonDecode(data);
      final list = json[_opinioesCandidatosKey] as List? ?? [];
      return list.map((e) => OpiniaoCandidato.fromJson(e)).toList();
    } catch (_) { return []; }
  }

  static Map<String, Map<String, int>> getConsolidadoOpinioes() {
    final opinioes = getOpinioesCandidatos();
    final Map<String, Map<String, int>> result = {};
    for (final o in opinioes) {
      result.putIfAbsent(o.candidatoId, () => {'INTERESSADO': 0, 'NAO_INTERESSADO': 0, 'OUTRO': 0});
      result[o.candidatoId]![o.opcao] = (result[o.candidatoId]![o.opcao] ?? 0) + 1;
    }
    return result;
  }

  // ──────────── CONTATOS ADMIN (telefone/email) ────────────

  static List<ContatoAdmin> getContatosAdmin() {
    if (_storageData == null) return [];
    try {
      final data = utf8.decode(_storageData!);
      final Map<String, dynamic> json = jsonDecode(data);
      final list = json[_contatosAdminKey] as List? ?? [];
      return list.map((e) => ContatoAdmin.fromJson(e)).toList();
    } catch (_) { return []; }
  }

  static void saveContatoAdmin(ContatoAdmin contato) {
    final list = getContatosAdmin();
    final exists = list.any((c) => c.contato == contato.contato);
    if (!exists) {
      list.add(contato);
      _saveData({_contatosAdminKey: list.map((c) => c.toJson()).toList()});
    }
  }

  static void toggleContatoAdmin(String contato) {
    final list = getContatosAdmin();
    for (final c in list) {
      if (c.contato == contato) {
        c.ativo = !c.ativo;
        break;
      }
    }
    _saveData({_contatosAdminKey: list.map((c) => c.toJson()).toList()});
  }

  static void deleteContatoAdmin(String contato) {
    final list = getContatosAdmin();
    list.removeWhere((c) => c.contato == contato);
    _saveData({_contatosAdminKey: list.map((c) => c.toJson()).toList()});
  }

  static List<ContatoAdmin> getContatosAtivos() {
    return getContatosAdmin().where((c) => c.ativo).toList();
  }

  // ──────────── ÚLTIMO ENVIO DE RELATÓRIO ────────────

  static DateTime? getUltimoEnvio() {
    if (_storageData == null) return null;
    try {
      final data = utf8.decode(_storageData!);
      final Map<String, dynamic> json = jsonDecode(data);
      final v = json[_ultimoEnvioKey];
      return v != null ? DateTime.parse(v) : null;
    } catch (_) { return null; }
  }

  static void setUltimoEnvio(DateTime dt) {
    _saveData({_ultimoEnvioKey: dt.toIso8601String()});
  }

  static bool precisaEnvioAutomatico() {
    final ultimo = getUltimoEnvio();
    if (ultimo == null) return true;
    return DateTime.now().difference(ultimo).inHours >= 24;
  }

  // ──────────── QGP SENHA ────────────

  static void setQpgSenha(String senha) {
    _saveData({_qpgSenhaKey: senha});
  }

  static String? getQpgSenha() {
    if (_storageData == null) return null;
    try {
      final data = utf8.decode(_storageData!);
      final Map<String, dynamic> json = jsonDecode(data);
      return json[_qpgSenhaKey] as String?;
    } catch (_) { return null; }
  }

  // ──────────── RELATÓRIOS ────────────

  static String _escapeHtml(String s) {
    return s.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;').replaceAll('"', '&quot;');
  }

  static String gerarRelatorio() {
    final consolidado = getConsolidadoOpinioes();
    final candidatos = getCandidatos();
    final dataStr = DateTime.now().toLocal().toString().split('.')[0];
    int totalGeralInter = 0, totalGeralNao = 0, totalGeralOutros = 0;
    for (final row in consolidado.values) {
      totalGeralInter += (row['INTERESSADO'] as int);
      totalGeralNao += (row['NAO_INTERESSADO'] as int);
      totalGeralOutros += (row['OUTRO'] as int);
    }

    final buf = StringBuffer();
    buf.writeln('''<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>RELATÓRIO DE OPINIÕES - $dataStr</title>
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { font-family: Arial, sans-serif; background: #121212; color: #e0e0e0; padding: 20px; }
    .container { max-width: 900px; margin: 0 auto; }
    h1 { color: #ffc107; text-align: center; margin-bottom: 8px; font-size: 26px; }
    .data { text-align: center; color: #888; font-size: 14px; margin-bottom: 24px; }
    .candidato-card { background: #1e1e1e; border-radius: 12px; padding: 20px; margin-bottom: 24px; border: 1px solid #333; }
    .candidato-card h2 { color: #00bcd4; margin-bottom: 12px; font-size: 20px; }
    table { width: 100%; border-collapse: collapse; margin-bottom: 16px; }
    th, td { padding: 10px 12px; text-align: left; border-bottom: 1px solid #333; }
    th { background: #2c2c2c; color: #ffc107; font-weight: bold; }
    td { color: #e0e0e0; }
    .pct { font-weight: bold; }
    .pct-verde { color: #4caf50; }
    .pct-vermelho { color: #f44336; }
    .pct-cinza { color: #9e9e9e; }
    .grafico-wrapper { max-width: 500px; margin: 0 auto 8px; }
    .geral-section { background: #1e1e1e; border-radius: 12px; padding: 20px; border: 1px solid #333; }
    .geral-section h2 { color: #ffc107; margin-bottom: 12px; }
    .footer { text-align: center; color: #555; font-size: 12px; margin-top: 24px; }
  </style>
</head>
<body>
<div class="container">
  <h1>RELATÓRIO DE OPINIÕES</h1>
  <p class="data">Gerado em: $dataStr</p>''');

    // ─── Per-candidate ───
    int chartIndex = 0;
    for (final c in candidatos) {
      final row = consolidado[c.id];
      if (row == null) continue;
      final interessados = row['INTERESSADO'] as int;
      final naoInteressados = row['NAO_INTERESSADO'] as int;
      final outros = row['OUTRO'] as int;
      final total = interessados + naoInteressados + outros;
      if (total == 0) continue;

      final pInter = (interessados / total * 100).toStringAsFixed(1);
      final pNao = (naoInteressados / total * 100).toStringAsFixed(1);
      final pOut = (outros / total * 100).toStringAsFixed(1);
      final nomeEscaped = _escapeHtml(c.nome);
      final ci = chartIndex;

      buf.writeln('''
  <div class="candidato-card">
    <h2>${nomeEscaped}</h2>
    <table>
      <tr><th>Categoria</th><th>Quantidade</th><th>Percentual</th></tr>
      <tr><td>Interessado</td><td>$interessados</td><td class="pct pct-verde">${pInter}%</td></tr>
      <tr><td>Não Interessado</td><td>$naoInteressados</td><td class="pct pct-vermelho">${pNao}%</td></tr>
      <tr><td>Outros</td><td>$outros</td><td class="pct pct-cinza">${pOut}%</td></tr>
    </table>
    <div class="grafico-wrapper">
      <canvas id="chart$ci" width="400" height="220"></canvas>
    </div>
  </div>
  <script>
    (function(){
      var ctx = document.getElementById('chart$ci').getContext('2d');
      new Chart(ctx, {
        type: 'bar',
        data: {
          labels: ['Interessado', 'Não Interessado', 'Outros'],
          datasets: [{
            label: '${nomeEscaped}',
            data: [$interessados, $naoInteressados, $outros],
            backgroundColor: ['#4caf50', '#f44336', '#9e9e9e'],
            borderRadius: 4
          }]
        },
        options: {
          responsive: true,
          plugins: { legend: { display: false } },
          scales: {
            y: { beginAtZero: true, ticks: { stepSize: 1, color: '#aaa' }, grid: { color: '#333' } },
            x: { ticks: { color: '#aaa' } }
          }
        }
      });
    })();
  </script>''');
      chartIndex++;
    }

    // ─── QGP geral ───
    buf.writeln('''
  <div class="geral-section">
    <h2>QGP — Coleta Geral</h2>
    <table>
      <tr><th>Opção</th><th>Total</th></tr>
      <tr><td>Interessados</td><td>$totalGeralInter</td></tr>
      <tr><td>Não Interessados</td><td>$totalGeralNao</td></tr>
      <tr><td>Outros</td><td>$totalGeralOutros</td></tr>
    </table>
    <div class="grafico-wrapper">
      <canvas id="chartGeral" width="400" height="220"></canvas>
    </div>
  </div>
  <script>
    (function(){
      var ctx = document.getElementById('chartGeral').getContext('2d');
      new Chart(ctx, {
        type: 'bar',
        data: {
          labels: ['Interessados', 'Não Interessados', 'Outros'],
          datasets: [{
            label: 'Geral',
            data: [$totalGeralInter, $totalGeralNao, $totalGeralOutros],
            backgroundColor: ['#4caf50', '#f44336', '#9e9e9e'],
            borderRadius: 4
          }]
        },
        options: {
          responsive: true,
          plugins: { legend: { display: false } },
          scales: {
            y: { beginAtZero: true, ticks: { stepSize: 1, color: '#aaa' }, grid: { color: '#333' } },
            x: { ticks: { color: '#aaa' } }
          }
        }
      });
    })();
  </script>
  <p class="footer">Relatório gerado automaticamente pelo sistema eleitoral.</p>
</div>
</body>
</html>''');

    setUltimoEnvio(DateTime.now());
    return buf.toString();
  }

  static String gerarRelatorioFromData(Map<String, Map<String, int>> consolidado, List<Candidato> candidatos) {
    final dataStr = DateTime.now().toLocal().toString().split('.')[0];
    int totalGeralInter = 0, totalGeralNao = 0, totalGeralOutros = 0;
    for (final row in consolidado.values) {
      totalGeralInter += (row['INTERESSADO'] as int);
      totalGeralNao += (row['NAO_INTERESSADO'] as int);
      totalGeralOutros += (row['OUTRO'] as int);
    }

    final buf = StringBuffer();
    buf.writeln('''<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>RELATÓRIO PESQUISADOR - $dataStr</title>
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { font-family: Arial, sans-serif; background: #121212; color: #e0e0e0; padding: 20px; }
    .container { max-width: 900px; margin: 0 auto; }
    h1 { color: #ffc107; text-align: center; margin-bottom: 8px; font-size: 26px; }
    .data { text-align: center; color: #888; font-size: 14px; margin-bottom: 24px; }
    .candidato-card { background: #1e1e1e; border-radius: 12px; padding: 20px; margin-bottom: 24px; border: 1px solid #333; }
    .candidato-card h2 { color: #00bcd4; margin-bottom: 12px; font-size: 20px; }
    table { width: 100%; border-collapse: collapse; margin-bottom: 16px; }
    th, td { padding: 10px 12px; text-align: left; border-bottom: 1px solid #333; }
    th { background: #2c2c2c; color: #ffc107; font-weight: bold; }
    td { color: #e0e0e0; }
    .pct { font-weight: bold; }
    .pct-verde { color: #4caf50; }
    .pct-vermelho { color: #f44336; }
    .pct-cinza { color: #9e9e9e; }
    .grafico-wrapper { max-width: 500px; margin: 0 auto 8px; }
    .geral-section { background: #1e1e1e; border-radius: 12px; padding: 20px; border: 1px solid #333; }
    .geral-section h2 { color: #ffc107; margin-bottom: 12px; }
    .footer { text-align: center; color: #555; font-size: 12px; margin-top: 24px; }
  </style>
</head>
<body>
<div class="container">
  <h1>RELATÓRIO DO PESQUISADOR</h1>
  <p class="data">Gerado em: $dataStr</p>''');

    int chartIndex = 0;
    for (final c in candidatos) {
      final row = consolidado[c.id];
      if (row == null) continue;
      final interessados = row['INTERESSADO'] as int;
      final naoInteressados = row['NAO_INTERESSADO'] as int;
      final outros = row['OUTRO'] as int;
      final total = interessados + naoInteressados + outros;
      if (total == 0) continue;

      final pInter = (interessados / total * 100).toStringAsFixed(1);
      final pNao = (naoInteressados / total * 100).toStringAsFixed(1);
      final pOut = (outros / total * 100).toStringAsFixed(1);
      final nomeEscaped = _escapeHtml(c.nome);
      final ci = chartIndex;

      buf.writeln('''
  <div class="candidato-card">
    <h2>${nomeEscaped}</h2>
    <table>
      <tr><th>Categoria</th><th>Quantidade</th><th>Percentual</th></tr>
      <tr><td>Interessado</td><td>$interessados</td><td class="pct pct-verde">${pInter}%</td></tr>
      <tr><td>Não Interessado</td><td>$naoInteressados</td><td class="pct pct-vermelho">${pNao}%</td></tr>
      <tr><td>Outros</td><td>$outros</td><td class="pct pct-cinza">${pOut}%</td></tr>
    </table>
    <div class="grafico-wrapper">
      <canvas id="chart$ci" width="400" height="220"></canvas>
    </div>
  </div>
  <script>
    (function(){
      var ctx = document.getElementById('chart$ci').getContext('2d');
      new Chart(ctx, {
        type: 'bar',
        data: {
          labels: ['Interessado', 'Não Interessado', 'Outros'],
          datasets: [{
            label: '${nomeEscaped}',
            data: [$interessados, $naoInteressados, $outros],
            backgroundColor: ['#4caf50', '#f44336', '#9e9e9e'],
            borderRadius: 4
          }]
        },
        options: {
          responsive: true,
          plugins: { legend: { display: false } },
          scales: {
            y: { beginAtZero: true, ticks: { stepSize: 1, color: '#aaa' }, grid: { color: '#333' } },
            x: { ticks: { color: '#aaa' } }
          }
        }
      });
    })();
  </script>''');
      chartIndex++;
    }

    buf.writeln('''
  <div class="geral-section">
    <h2>QGP — Coleta Geral</h2>
    <table>
      <tr><th>Opção</th><th>Total</th></tr>
      <tr><td>Interessados</td><td>$totalGeralInter</td></tr>
      <tr><td>Não Interessados</td><td>$totalGeralNao</td></tr>
      <tr><td>Outros</td><td>$totalGeralOutros</td></tr>
    </table>
    <div class="grafico-wrapper">
      <canvas id="chartGeral" width="400" height="220"></canvas>
    </div>
  </div>
  <script>
    (function(){
      var ctx = document.getElementById('chartGeral').getContext('2d');
      new Chart(ctx, {
        type: 'bar',
        data: {
          labels: ['Interessados', 'Não Interessados', 'Outros'],
          datasets: [{
            label: 'Geral',
            data: [$totalGeralInter, $totalGeralNao, $totalGeralOutros],
            backgroundColor: ['#4caf50', '#f44336', '#9e9e9e'],
            borderRadius: 4
          }]
        },
        options: {
          responsive: true,
          plugins: { legend: { display: false } },
          scales: {
            y: { beginAtZero: true, ticks: { stepSize: 1, color: '#aaa' }, grid: { color: '#333' } },
            x: { ticks: { color: '#aaa' } }
          }
        }
      });
    })();
  </script>
  <p class="footer">Relatório gerado pelo pesquisador — dados não persistidos no banco central.</p>
</div>
</body>
</html>''');

    return buf.toString();
  }

  static Future<void> clearAllData() async {
    _storageData = null;
    await _prefs?.remove('storageData');
  }

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

  static bool podeVotar(int idade) => idade >= 16;

  static bool cpfValido(String cpf, Set<String> cpfsJaVotaram) => !cpfsJaVotaram.contains(cpf);

  static List<String> candidatosPorCidade(String cidade, Map<String, List<String>> base) => base[cidade] ?? [];

  // ─── Regras de votação ───

  static String? validarVoto(Candidato candidato, Set<String> cargosSelecionados, Eleitor eleitor) {
    final cargo = candidato.cargo;
    if (cargo == null) return null;

    if (cargosSelecionados.contains(cargo)) {
      switch (cargo) {
        case 'Prefeito':
          return 'Você já selecionou um prefeito. Só é permitido um.';
        case 'Presidente':
          return 'Você já selecionou um presidente. Só é permitido um.';
        case 'Senador':
          return 'Você já selecionou um senador. Só é permitido um.';
        case 'Deputado Federal':
          return 'Você já selecionou um deputado federal. Só é permitido um.';
        case 'Deputado Estadual':
          return 'Você já selecionou um deputado estadual. Só é permitido um.';
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

  static String? validarCargosSelecionados(Set<Candidato> selecionados, Eleitor eleitor) {
    final cargos = <String>{};
    for (final c in selecionados) {
      final cargo = c.cargo;
      if (cargo == null) continue;
      if (cargos.contains(cargo)) {
        switch (cargo) {
          case 'Prefeito': return 'Você já selecionou um prefeito. Só é permitido um.';
          case 'Presidente': return 'Você já selecionou um presidente. Só é permitido um.';
          case 'Senador': return 'Você já selecionou um senador. Só é permitido um.';
          case 'Deputado Federal': return 'Você já selecionou um deputado federal. Só é permitido um.';
          case 'Deputado Estadual': return 'Você já selecionou um deputado estadual. Só é permitido um.';
        }
      }
      cargos.add(cargo);

      if (cargo == 'Prefeito') {
        final cidadeEleitor = eleitor.cidade?.toLowerCase().trim() ?? '';
        final cidadeCand = c.cidade?.toLowerCase().trim() ?? '';
        if (cidadeEleitor.isEmpty || cidadeCand.isEmpty || cidadeCand != cidadeEleitor) {
          return 'Você só pode votar em um candidato a prefeito da sua cidade.';
        }
      }

      if (cargo == 'Senador' || cargo == 'Deputado Federal' || cargo == 'Deputado Estadual') {
        final estadoEleitor = eleitor.estado?.toLowerCase().trim() ?? '';
        final estadoCand = c.estado?.toLowerCase().trim() ?? '';
        if (estadoEleitor.isEmpty || estadoCand.isEmpty || estadoCand != estadoEleitor) {
          return 'Você só pode votar em candidatos do seu estado.';
        }
      }
    }
    return null;
  }
}

class Eleitor {
  final String id;
  final String nome;
  final String cpf;
  final DateTime dataNascimento;
  final String bairro;
  final String? cidade;
  final String? estado;
  final bool votou;
  final DateTime? dataVoto;

  Eleitor({required this.id, required this.nome, required this.cpf, required this.dataNascimento, required this.bairro, this.cidade, this.estado, this.votou = false, this.dataVoto});

  Map<String, dynamic> toJson() => {'id': id, 'nome': nome, 'cpf': cpf, 'dataNascimento': dataNascimento.toIso8601String(), 'bairro': bairro, 'cidade': cidade, 'estado': estado, 'votou': votou, 'dataVoto': dataVoto?.toIso8601String()};

  factory Eleitor.fromJson(Map<String, dynamic> json) => Eleitor(
    id: json['id'], nome: json['nome'], cpf: json['cpf'], dataNascimento: DateTime.parse(json['dataNascimento']), bairro: json['bairro'], cidade: json['cidade'], estado: json['estado'], votou: json['votou'] ?? false, dataVoto: json['dataVoto'] != null ? DateTime.parse(json['dataVoto']) : null,
  );

  Eleitor copyWith({String? id, String? nome, String? cpf, DateTime? dataNascimento, String? bairro, String? cidade, String? estado, bool? votou, DateTime? dataVoto}) {
    return Eleitor(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      cpf: cpf ?? this.cpf,
      dataNascimento: dataNascimento ?? this.dataNascimento,
      bairro: bairro ?? this.bairro,
      cidade: cidade ?? this.cidade,
      estado: estado ?? this.estado,
      votou: votou ?? this.votou,
      dataVoto: dataVoto ?? this.dataVoto,
    );
  }
}

class Candidato {
  final String id;
  final String nome;
  final int numero;
  final String partido;
  final String sigla;
  final String? fotoPath;
  final String? estado;
  final String? cidade;
  final String? cargo;
  int votos;

  Candidato({required this.id, required this.nome, required this.numero, required this.partido, required this.sigla, this.fotoPath, this.estado, this.cidade, this.cargo, this.votos = 0});

  Map<String, dynamic> toJson() => {'id': id, 'nome': nome, 'numero': numero, 'partido': partido, 'sigla': sigla, 'fotoPath': fotoPath, 'estado': estado, 'cidade': cidade, 'cargo': cargo, 'votos': votos};

  factory Candidato.fromJson(Map<String, dynamic> json) => Candidato(
        id: json['id'], nome: json['nome'], numero: json['numero'], partido: json['partido'], sigla: json['sigla'], fotoPath: json['fotoPath'], estado: json['estado'], cidade: json['cidade'], cargo: json['cargo'], votos: json['votos'] ?? 0,
      );

  Candidato copyWith({String? id, String? nome, int? numero, String? partido, String? sigla, String? fotoPath, String? estado, String? cidade, String? cargo, int? votos}) {
    return Candidato(id: id ?? this.id, nome: nome ?? this.nome, numero: numero ?? this.numero, partido: partido ?? this.partido, sigla: sigla ?? this.sigla, fotoPath: fotoPath ?? this.fotoPath, estado: estado ?? this.estado, cidade: cidade ?? this.cidade, cargo: cargo ?? this.cargo, votos: votos ?? this.votos);
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

class OpiniaoCandidato {
  final String candidatoId;
  final String? nome;
  final String? cpf;
  final String opcao;
  final DateTime data;

  OpiniaoCandidato({required this.candidatoId, this.nome, this.cpf, required this.opcao, required this.data});

  Map<String, dynamic> toJson() => {'candidatoId': candidatoId, 'nome': nome, 'cpf': cpf, 'opcao': opcao, 'data': data.toIso8601String()};

  factory OpiniaoCandidato.fromJson(Map<String, dynamic> json) => OpiniaoCandidato(
    candidatoId: json['candidatoId'], nome: json['nome'], cpf: json['cpf'], opcao: json['opcao'], data: DateTime.parse(json['data']),
  );
}

class ContatoAdmin {
  final String id;
  final String contato;
  final String tipo;
  bool ativo;
  final DateTime criadoEm;

  ContatoAdmin({required this.id, required this.contato, required this.tipo, this.ativo = true, DateTime? criadoEm}) : criadoEm = criadoEm ?? DateTime.now();

  Map<String, dynamic> toJson() => {'id': id, 'contato': contato, 'tipo': tipo, 'ativo': ativo, 'criadoEm': criadoEm.toIso8601String()};

  factory ContatoAdmin.fromJson(Map<String, dynamic> json) => ContatoAdmin(
    id: json['id'], contato: json['contato'], tipo: json['tipo'], ativo: json['ativo'] ?? true, criadoEm: DateTime.parse(json['criadoEm']),
  );
}