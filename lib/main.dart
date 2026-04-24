import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:file_picker/file_picker.dart';
import 'services/services.dart';

void logDebug(String msg) => debugPrint('[DEBUG] $msg');
void logError(String msg, Object e) => debugPrint('[ERROR] $msg: $e');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Consulta Especializada',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF8A2BE2),
          secondary: Color(0xFF0D47A1),
          surface: Color(0xFF1E1E1E),
          error: Color(0xFFB24040),
          tertiary: Color(0xFF008F39),
        ),
      ),
      home: Builder(
        builder: (ctx) => Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFF1E1E1E),
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Row(children: [
              TextButton(onPressed: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const Tela1Cadastro())), child: const Text('Cadastro', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))),
              TextButton(onPressed: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const TelaResultados(estado: null, cidade: ''))), child: const Text('Resultados', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))),
              TextButton(onPressed: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const TelaQGP())), child: const Text('QGP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))),
              TextButton(onPressed: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const TelaAdmin())), child: const Text('Gestao de Dados', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))),
              const Spacer(),
              TextButton(onPressed: () => Navigator.of(ctx).popUntil((route) => route.isFirst), child: const Text('Sair do App', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 14))),
            ]),
          ),
          body: const TelaLogin(),
        ),
      ),
    );
  }
}

class Disclaimer extends StatelessWidget {
  const Disclaimer({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.2), border: Border.all(color: Colors.amber), borderRadius: BorderRadius.circular(8)), child: const Text('Enquete simulada para fins educativos.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12)));
  }
}

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});
  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  String _tipoUsuario = 'eleitor';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sistema de Pesquisa'), backgroundColor: const Color(0xFF8A2BE2), foregroundColor: Colors.white),
      body: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [const Color(0xFF8A2BE2), Colors.purple[800]!], begin: Alignment.topCenter, end: Alignment.bottomCenter)), child: SafeArea(child: Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.how_to_vote, size: 80, color: Colors.white),
        const SizedBox(height: 20),
        const Text('Sistema de Pesquisa Eleitoral', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 30),
        const Disclaimer(),
        const SizedBox(height: 30),
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
          const Text('Selecione o tipo de acesso:', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 10),
          SegmentedButton<String>(segments: const [
            ButtonSegment(value: 'eleitor', label: Text('Eleitor'), icon: Icon(Icons.person)),
            ButtonSegment(value: 'admin', label: Text('Admin'), icon: Icon(Icons.admin_panel_settings)),
            ButtonSegment(value: 'pesquisador', label: Text('Pesquisador'), icon: Icon(Icons.search)),
          ], selected: {_tipoUsuario}, onSelectionChanged: (s) => setState(() => _tipoUsuario = s.first)),
        ]))),
        const SizedBox(height: 20),
        if (_tipoUsuario == 'eleitor')
          ElevatedButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Tela1Cadastro())), icon: const Icon(Icons.person_add), label: const Text('Cadastre-se'), style: ElevatedButton.styleFrom(minimumSize: const Size(200, 50)))
        else if (_tipoUsuario == 'admin')
          ElevatedButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TelaAdminLogin())), icon: const Icon(Icons.admin_panel_settings), label: const Text('Admin'), style: ElevatedButton.styleFrom(minimumSize: const Size(200, 50), backgroundColor: Colors.amber))
        else
          ElevatedButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TelaPesquisador())), icon: const Icon(Icons.search), label: const Text('Pesquisador'), style: ElevatedButton.styleFrom(minimumSize: const Size(200, 50), backgroundColor: Colors.blueGrey)),
      ])))),
    );
  }
}

class Tela1Cadastro extends StatefulWidget {
  const Tela1Cadastro({super.key});
  @override
  State<Tela1Cadastro> createState() => _Tela1CadastroState();
}

class _Tela1CadastroState extends State<Tela1Cadastro> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _dataController = TextEditingController();
  final _bairroController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Cadastro de Eleitor'), backgroundColor: const Color(0xFF008F39), foregroundColor: Colors.white), body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const Disclaimer(), const SizedBox(height: 20),
      TextFormField(controller: _nomeController, decoration: const InputDecoration(labelText: 'Nome', border: OutlineInputBorder()), validator: (v) => v?.isEmpty ?? true ? 'Nome obrigatorio' : null),
      const SizedBox(height: 16),
      TextFormField(controller: _cpfController, decoration: const InputDecoration(labelText: 'CPF', border: OutlineInputBorder(), hintText: '000.000.000-00'), keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly, _CpfMask()], maxLength: 14, validator: (v) { if (v == null || v.isEmpty) return 'CPF obrigatorio'; final cpf = v.replaceAll(RegExp(r'[^0-9]'), ''); if (cpf.length != 11) return 'CPF invalido'; return null; }),
      const SizedBox(height: 16),
      TextFormField(controller: _dataController, decoration: const InputDecoration(labelText: 'Data de Nascimento', border: OutlineInputBorder(), hintText: 'DD/MM/AAAA'), keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly, _DataMask()], maxLength: 10, validator: (v) { if (v == null || v.isEmpty) return 'Data obrigatoria'; if (v.length != 10) return 'Data invalida'; return null; }),
      const SizedBox(height: 16),
      TextFormField(controller: _bairroController, decoration: const InputDecoration(labelText: 'Bairro onde mora', border: OutlineInputBorder()), validator: (v) => v?.isEmpty ?? true ? 'Bairro obrigatorio' : null),
      const SizedBox(height: 24),
      ElevatedButton(onPressed: _cadastrar, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF008F39), foregroundColor: Colors.white, minimumSize: const Size.fromHeight(50)), child: const Text('Cadastrar', style: TextStyle(fontSize: 18))),
    ]))));
  }

  void _cadastrar() {
    if (!_formKey.currentState!.validate()) return;
    final parts = _dataController.text.split('/');
    final data = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
    final idade = ValidadorService.calcularIdade(data);
    if (idade < 16) { showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text('Acesso Negado'), content: const Text('Idade minima: 16 anos'), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))])); return; }
    final eleitor = Eleitor(id: DateTime.now().millisecondsSinceEpoch.toString(), nome: _nomeController.text, cpf: _cpfController.text.replaceAll(RegExp(r'[^0-9]'), ''), dataNascimento: data, bairro: _bairroController.text);
    DatabaseService.saveEleitor(eleitor);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Tela2Votacao(eleitor: eleitor)));
  }
}

class _CpfMask extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue o, TextEditingValue n) {
    var t = n.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (t.length > 11) t = t.substring(0, 11);
    var r = '';
    for (int i = 0; i < t.length; i++) { if (i == 3 || i == 6) r += '.'; if (i == 9) r += '-'; r += t[i]; }
    return TextEditingValue(text: r, selection: TextSelection.collapsed(offset: r.length));
  }
}

class _DataMask extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue o, TextEditingValue n) {
    var t = n.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (t.length > 8) t = t.substring(0, 8);
    var r = '';
    for (int i = 0; i < t.length; i++) { if (i == 2 || i == 4) r += '/'; r += t[i]; }
    return TextEditingValue(text: r, selection: TextSelection.collapsed(offset: r.length));
  }
}

class Tela2Votacao extends StatefulWidget {
  final Eleitor eleitor;
  const Tela2Votacao({super.key, required this.eleitor});
  @override
  State<Tela2Votacao> createState() => _Tela2VotacaoState();
}

class _Tela2VotacaoState extends State<Tela2Votacao> {
  String? _candSel;
  String _tipo = 'presidente';
  final _cands = DatabaseService.getCandidatos();

  @override
  Widget build(BuildContext context) {
    final hash = DatabaseService.hashCpf(widget.eleitor.cpf);
    final jaVotou = DatabaseService.jaVotou(hash);
    return Scaffold(appBar: AppBar(title: const Text('Votacao'), backgroundColor: const Color(0xFF008F39), foregroundColor: Colors.white), body: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
      const Disclaimer(), const SizedBox(height: 16),
      Text('Eleitor: ${widget.eleitor.nome}'), Text('Bairro: ${widget.eleitor.bairro}'), const SizedBox(height: 10),
      SegmentedButton<String>(segments: const [
        ButtonSegment(value: 'presidente', label: Text('Presidente')),
        ButtonSegment(value: 'deputado_estadual', label: Text('Dep. Est.')),
        ButtonSegment(value: 'deputado_federal', label: Text('Dep. Fed.')),
        ButtonSegment(value: 'senador', label: Text('Senador')),
        ButtonSegment(value: 'prefeito', label: Text('Prefeito')),
      ], selected: {_tipo}, onSelectionChanged: (s) => setState(() => _tipo = s.first)),
      const SizedBox(height: 20),
      Expanded(child: ListView.builder(itemCount: _cands.length, itemBuilder: (ctx, i) { final c = _cands[i]; return Card(child: RadioListTile<String>(value: c.id, groupValue: _candSel, onChanged: jaVotou ? null : (v) => setState(() => _candSel = v), title: Text(c.nome + ' - ' + c.partido), subtitle: Text('Numero: ${c.numero}'))); })),
      const SizedBox(height: 16),
      ElevatedButton(onPressed: _candSel == null || jaVotou ? null : _votar, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF008F39), foregroundColor: Colors.white, minimumSize: const Size.fromHeight(50)), child: const Text('Votar', style: TextStyle(fontSize: 18))),
    ])));
  }

  void _votar() async {
    final hash = DatabaseService.hashCpf(widget.eleitor.cpf);
    if (DatabaseService.jaVotou(hash)) { if (mounted) showDialog(context: context, builder: (ctx) => AlertDialog(content: const Text('Ja votou!'), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))])); return; }
    await DatabaseService.saveVoto(Voto(idEleitor: widget.eleitor.id, idCandidato: _candSel!, tipoVoto: _tipo, dataVoto: DateTime.now()));
    if (mounted) { HapticFeedback.heavyImpact(); showDialog(context: context, barrierDismissible: false, builder: (ctx) => AlertDialog(title: const Text('Voto Confirmado!'), content: const Text('Obrigado!'), actions: [TextButton(onPressed: () { Navigator.pop(ctx); Navigator.of(context).popUntil((r) => r.isFirst); }, child: const Text('OK'))])); }
  }
}

class TelaAdminLogin extends StatefulWidget {
  const TelaAdminLogin({super.key});
  @override
  State<TelaAdminLogin> createState() => _TelaAdminLoginState();
}

class _TelaAdminLoginState extends State<TelaAdminLogin> {
  final _senhaController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Login Admin'), backgroundColor: Colors.amber[700]), body: Padding(padding: const EdgeInsets.all(16), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text('Digite a senha', style: TextStyle(fontSize: 18)), const SizedBox(height: 16),
      TextField(controller: _senhaController, obscureText: true, decoration: const InputDecoration(labelText: 'Senha', border: OutlineInputBorder())), const SizedBox(height: 16),
      ElevatedButton(onPressed: _login, style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, minimumSize: const Size(200, 50)), child: const Text('Entrar')),
    ])));
  }
  void _login() { if (_senhaController.text == 'admin123') Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TelaAdmin())); else ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Senha incorreta'))); }
}

class TelaAdmin extends StatefulWidget {
  const TelaAdmin({super.key});
  @override
  State<TelaAdmin> createState() => _TelaAdminState();
}

class _TelaAdminState extends State<TelaAdmin> {
  List<Candidato> _cands = [];
  String? _estado;
  final _cidadeController = TextEditingController();
  final _nomeController = TextEditingController();
  final _numeroController = TextEditingController();
  final _partidoController = TextEditingController();
  Uint8List? _bytesFoto;
  static const _estados = ['AC','AL','AP','AM','BA','CE','DF','ES','GO','MA','MT','MS','MG','PA','PB','PR','PE','PI','RJ','RN','RS','RO','RR','SC','SP','SE','TO'];

  @override
  void initState() { super.initState(); _cands = DatabaseService.getCandidatos(); }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(length: 4, child: Scaffold(appBar: AppBar(title: const Text('Painel Admin'), backgroundColor: Colors.amber[700], bottom: const TabBar(tabs: [Tab(text: 'Filtros'), Tab(text: 'Candidatos'), Tab(text: 'QGP'), Tab(text: 'Testes')])), body: TabBarView(children: [_tabFiltros(), _tabCandidatos(), _tabQGP(), _tabTestes()])));
  }

  Widget _tabFiltros() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Filtros para Resultados', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          const Text('Estado:'),
          DropdownButtonFormField<String>(
            value: _estado,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: _estados.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() => _estado = v)
          ),
          const SizedBox(height: 16),
          const Text('Cidade:'),
          TextField(controller: _cidadeController, decoration: const InputDecoration(border: OutlineInputBorder())),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TelaResultados(estado: _estado, cidade: _cidadeController.text))),
            icon: const Icon(Icons.bar_chart),
            label: const Text('Ver Resultados'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1))
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TelaQGP())),
            icon: const Icon(Icons.pie_chart),
            label: const Text('Ver QGP'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8A2BE2))
          ),
        ],
      ),
    );
  }

Widget _tabCandidatos() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('CANDIDATOS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _importarFoto,
              icon: const Icon(Icons.add_photo_alternate, color: Colors.white),
              label: const Text('Adicionar Candidato', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8A2BE2)),
            ),
          ],
        ),
        if (_bytesFoto != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                image: DecorationImage(image: MemoryImage(_bytesFoto!), fit: BoxFit.cover),
                border: Border.all(color: const Color(0xFF8A2BE2), width: 3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        if (_nomeController.text.isNotEmpty || _numeroController.text.isNotEmpty || _partidoController.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(child: Text('Nome: ${_nomeController.text}', style: const TextStyle(fontSize: 14))),
                const SizedBox(width: 8),
                Expanded(child: Text('Numero: ${_numeroController.text}', style: const TextStyle(fontSize: 14))),
                const SizedBox(width: 8),
                Expanded(child: Text('Partido: ${_partidoController.text}', style: const TextStyle(fontSize: 14))),
              ],
            ),
          ),
        Row(
          children: [
            ElevatedButton(onPressed: _injectVotes, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF008F39)), child: const Text('Injetar Votos')),
            const SizedBox(width: 8),
            ElevatedButton(onPressed: _clearVotes, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB24040)), child: const Text('Limpar Votos')),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: _cands.length,
            itemBuilder: (ctx, i) {
              final c = _cands[i];
              return ListTile(
                leading: const Icon(Icons.person, color: Color(0xFF8A2BE2)),
                title: Text(c.nome + ' - ${c.numero}'),
                subtitle: Text(c.partido + ' - ' + c.sigla),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Color(0xFFB24040)),
                  onPressed: () => _delCandidate(c.id),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _importarFoto() async {
    logDebug('Abrindo seletor...');
    try {
      FilePickerResult? r = await FilePicker.platform.pickFiles(type: FileType.image, allowMultiple: false);
      if (r != null && r.files.isNotEmpty) {
        String nome = r.files.first.name;
        _bytesFoto = r.files.first.bytes;
        logDebug('Arquivo: $nome');
        String semExt = nome.split('.').first;
        List<String> d = semExt.split('_');
        logDebug('Dados: $d');
        if (d.length >= 3) {
          _nomeController.text = d[0].trim();
          _numeroController.text = d[1].trim();
          _partidoController.text = d[2].trim();
          logDebug('OK -> ${d[0].trim()} / ${d[1].trim()} / ${d[2].trim()}');
          _addCandidato();
        }
      }
    } catch (e) { logError('Erro', e); }
    setState(() {});
  }

  Widget _tabQGP() {
    return Padding(padding: const EdgeInsets.all(16), child: Column(children: [const Text('Grafico QGP', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 20), _buildChart()]));
  }

  Widget _buildChart() {
    final c = DatabaseService.getCandidatos();
    final t = DatabaseService.getTotalVotos();
    if (c.isEmpty) return const Center(child: Text('Nenhum candidato'));
    final max = t > 0 ? c.map((x) => x.votos.toDouble()).reduce((a, b) => a > b ? a : b) * 1.2 : 10.0;
    return SizedBox(height: 300, child: BarChart(BarChartData(alignment: BarChartAlignment.spaceAround, maxY: max, barTouchData: BarTouchData(enabled: true), titlesData: FlTitlesData(show: true, bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) { final i = v.toInt(); if (i >= 0 && i < c.length) return Padding(padding: const EdgeInsets.only(top: 8), child: Text(c[i].nome, style: const TextStyle(fontSize: 10))); return const Text(''); })), leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)), topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false))), borderData: FlBorderData(show: false), barGroups: c.asMap().entries.map((e) => BarChartGroupData(x: e.key, barRods: [BarChartRodData(toY: e.value.votos.toDouble(), color: const Color(0xFF8A2BE2), width: 30, borderRadius: const BorderRadius.vertical(top: Radius.circular(5)))])).toList())));
  }

  Widget _tabTestes() {
    return Padding(padding: const EdgeInsets.all(16), child: Column(children: [const Text('GERADORES', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 20),
      ElevatedButton.icon(onPressed: _gerarEleitores, icon: const Icon(Icons.people), label: const Text('Gerar Eleitores'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8A2BE2))),
      const SizedBox(height: 16),
      ElevatedButton.icon(onPressed: _gerarVotos, icon: const Icon(Icons.how_to_vote), label: const Text('Gerar Votos'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF008F39))),
      const SizedBox(height: 16),
      ElevatedButton.icon(onPressed: _limpar, icon: const Icon(Icons.delete_forever), label: const Text('Limpar Tudo'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB24040)))]));
  }

  void _addCandidato() { if (_nomeController.text.isEmpty || _numeroController.text.isEmpty || _partidoController.text.isEmpty) return; String p = _partidoController.text; String s = p.split(' ').length > 1 ? p.split(' ').map((x) => x[0]).join('').toUpperCase() : p.substring(0, p.length >= 2 ? 2 : p.length).toUpperCase(); DatabaseService.saveCandidato(Candidato(id: DateTime.now().millisecondsSinceEpoch.toString(), nome: _nomeController.text, numero: int.tryParse(_numeroController.text) ?? 0, partido: p, sigla: s)); _nomeController.clear(); _numeroController.clear(); _partidoController.clear(); _bytesFoto = null; setState(() => _cands = DatabaseService.getCandidatos()); }
  void _delCandidate(String id) { DatabaseService.deleteCandidato(id); setState(() => _cands = DatabaseService.getCandidatos()); }
  void _injectVotes() { for (var c in _cands) DatabaseService.saveCandidato(c.copyWith(votos: c.votos + 10)); setState(() => _cands = DatabaseService.getCandidatos()); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Votos injetados!'))); }
  void _clearVotes() { for (var c in _cands) DatabaseService.saveCandidato(c.copyWith(votos: 0)); setState(() => _cands = DatabaseService.getCandidatos()); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Votos limpos!'))); }
  void _gerarEleitores() { for (int i = 0; i < 50; i++) DatabaseService.saveEleitor(Eleitor(id: 't_$i', nome: 'E $i', cpf: '0000000000$i', dataNascimento: DateTime(1990,1,1), bairro: 'Centro')); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('50 gerados!'))); }
  void _gerarVotos() { if (_cands.isEmpty) return; for (int i = 0; i < 30; i++) { var c = _cands[i % _cands.length]; DatabaseService.saveVoto(Voto(idEleitor: 't_$i', idCandidato: c.id, tipoVoto: 'presidente', dataVoto: DateTime.now())); } setState(() => _cands = DatabaseService.getCandidatos()); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('30 votos gerados!'))); }
  void _limpar() { DatabaseService.clearAllData(); setState(() => _cands = DatabaseService.getCandidatos()); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dados limpos!'))); }
}

class TelaResultados extends StatefulWidget {
  final String? estado;
  final String cidade;
  const TelaResultados({super.key, this.estado, required this.cidade});
  @override
  State<TelaResultados> createState() => _TelaResultadosState();
}

class _TelaResultadosState extends State<TelaResultados> {
  @override
  Widget build(BuildContext context) {
    final c = DatabaseService.getCandidatos();
    final t = DatabaseService.getTotalVotos();
    return Scaffold(appBar: AppBar(title: const Text('Resultados'), backgroundColor: const Color(0xFF0D47A1), foregroundColor: Colors.white), body: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
      const Disclaimer(), const SizedBox(height: 10),
      if (widget.estado != null) Text('Estado: ${widget.estado}'),
      if (widget.cidade.isNotEmpty) Text('Cidade: ${widget.cidade}'),
      Text('Total: $t', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 20),
      Expanded(child: c.isEmpty ? const Center(child: Text('Nenhum candidate')) : SizedBox(height: 300, child: BarChart(BarChartData(alignment: BarChartAlignment.spaceAround, maxY: t > 0 ? c.map((x) => x.votos.toDouble()).reduce((a, b) => a > b ? a : b) * 1.2 : 10, barTouchData: BarTouchData(enabled: true), titlesData: FlTitlesData(show: true, bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) { final i = v.toInt(); if (i >= 0 && i < c.length) return Padding(padding: const EdgeInsets.only(top: 8), child: Text(c[i].nome, style: const TextStyle(fontSize: 10))); return const Text(''); })), leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)), topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false))), borderData: FlBorderData(show: false), barGroups: c.asMap().entries.map((e) => BarChartGroupData(x: e.key, barRods: [BarChartRodData(toY: e.value.votos.toDouble(), color: const Color(0xFF0D47A1), width: 30, borderRadius: const BorderRadius.vertical(top: Radius.circular(5)))])).toList())))),
      const SizedBox(height: 20),
      Expanded(child: ListView.builder(itemCount: c.length, itemBuilder: (ctx, i) { final x = c[i]; final p = t > 0 ? (x.votos / t * 100) : 0.0; return ListTile(title: Text('${x.nome} (${x.numero})'), subtitle: LinearProgressIndicator(value: p / 100, color: const Color(0xFF0D47A1)), trailing: Text('${p.toStringAsFixed(1)}% (${x.votos} votos)')); })),
    ])));
  }
}

class TelaQGP extends StatelessWidget {
  const TelaQGP({super.key});
  @override
  Widget build(BuildContext context) {
    final c = DatabaseService.getCandidatos();
    final t = DatabaseService.getTotalVotos();
    final p = DatabaseService.getVotosPesquisa();
    return Scaffold(appBar: AppBar(title: const Text('QGP'), backgroundColor: const Color(0xFF8A2BE2), foregroundColor: Colors.white), body: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
      const Disclaimer(), const SizedBox(height: 10), const Text('GRAFICOS', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 20),
      Expanded(child: c.isEmpty ? const Center(child: Text('Nenhum')) : SizedBox(height: 300, child: BarChart(BarChartData(alignment: BarChartAlignment.spaceAround, maxY: t > 0 ? c.map((x) => x.votos.toDouble()).reduce((a, b) => a > b ? a : b) * 1.2 : 10, barTouchData: BarTouchData(enabled: true), titlesData: FlTitlesData(show: true, bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) { final i = v.toInt(); if (i >= 0 && i < c.length) return Padding(padding: const EdgeInsets.only(top: 8), child: Text(c[i].nome, style: const TextStyle(fontSize: 10))); return const Text(''); })), leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)), topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false))), borderData: FlBorderData(show: false), barGroups: c.asMap().entries.map((e) => BarChartGroupData(x: e.key, barRods: [BarChartRodData(toY: e.value.votos.toDouble(), color: const Color(0xFF8A2BE2), width: 30, borderRadius: const BorderRadius.vertical(top: Radius.circular(5)))])).toList())))),
      const SizedBox(height: 20), const Text('PESQUISA', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 10),
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        Column(children: [const Icon(Icons.thumb_down, color: Color(0xFFB24040), size: 40), Text('Outro: ${p['vermelho'] ?? 0}')]),
        Column(children: [const Icon(Icons.thumb_up, color: Color(0xFF008F39), size: 40), Text('Favor: ${p['verde'] ?? 0}')]),
        Column(children: [const Icon(Icons.question_mark, color: Colors.white, size: 40), Text('Indec: ${p['branco'] ?? 0}')]),
      ]),
    ])));
  }
}

class TelaPesquisador extends StatefulWidget {
  const TelaPesquisador({super.key});
  @override
  State<TelaPesquisador> createState() => _TelaPesquisadorState();
}

class _TelaPesquisadorState extends State<TelaPesquisador> {
  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Pesquisador'), backgroundColor: Colors.blueGrey[700], foregroundColor: Colors.white), body: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
      const Disclaimer(), const SizedBox(height: 20), const Text('DADOS (OPCIONAL)', style: TextStyle(fontSize: 16)), const SizedBox(height: 10),
      TextField(controller: _nomeController, decoration: const InputDecoration(labelText: 'Nome', border: OutlineInputBorder())), const SizedBox(height: 10),
      TextField(controller: _cpfController, decoration: const InputDecoration(labelText: 'CPF', border: OutlineInputBorder()), keyboardType: TextInputType.number), const SizedBox(height: 30), const Text('OPINIAO'), const SizedBox(height: 20),
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        ElevatedButton.icon(onPressed: () => _registrar('vermelho'), icon: const Icon(Icons.thumb_down), label: const Text('Outro'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB24040), minimumSize: const Size(100, 50))),
        ElevatedButton.icon(onPressed: () => _registrar('verde'), icon: const Icon(Icons.thumb_up), label: const Text('Favor'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF008F39), minimumSize: const Size(100, 50))),
        ElevatedButton.icon(onPressed: () => _registrar('branco'), icon: const Icon(Icons.question_mark), label: const Text('Indec'), style: ElevatedButton.styleFrom(backgroundColor: Colors.grey, minimumSize: const Size(100, 50))),
      ]),
    ])));
  }

  void _registrar(String tipo) { DatabaseService.savePesquisa(PesquisaCampo(nome: _nomeController.text.isNotEmpty ? _nomeController.text : null, cpf: _cpfController.text.isNotEmpty ? _cpfController.text : null, tipo: tipo, data: DateTime.now())); _nomeController.clear(); _cpfController.clear(); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registrado: $tipo'))); }
}