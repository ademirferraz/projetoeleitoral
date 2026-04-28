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
        textTheme: const TextTheme(
          labelLarge: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      home: Builder(
        builder: (ctx) => Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFF1E1E1E),
            elevation: 0,
            automaticallyImplyLeading: false,
            title: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                TextButton(onPressed: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const Tela1Cadastro())), child: const Text('CADASTRO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14))),
                TextButton(onPressed: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const TelaResultados(estado: null, city: ''))), child: const Text('RESULTADOS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14))),
                TextButton(onPressed: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const TelaQGP())), child: const Text('QGP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14))),
                TextButton(onPressed: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const TelaAdmin())), child: const Text('GESTÃO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14))),
                const SizedBox(width: 10),
                TextButton(onPressed: () => Navigator.of(ctx).popUntil((route) => route.isFirst), child: const Text('SAIR', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900, fontSize: 14))),
              ]),
            ),
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
    return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.amber.withOpacity(0.2), border: Border.all(color: Colors.amber, width: 2), borderRadius: BorderRadius.circular(8)),
        child: const Text('Enquete simulada para fins educativos.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900)));
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
      appBar: AppBar(title: const Text('SISTEMA DE PESQUISA', style: TextStyle(fontWeight: FontWeight.w900)), backgroundColor: const Color(0xFF8A2BE2), foregroundColor: Colors.white),
      body: Container(
          decoration: BoxDecoration(gradient: LinearGradient(colors: [const Color(0xFF8A2BE2), Colors.purple[800]!], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          child: SafeArea(
              child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.how_to_vote, size: 80, color: Colors.white),
                    const SizedBox(height: 20),
                    const Text('SISTEMA DE PESQUISA ELEITORAL', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
                    const SizedBox(height: 30),
                    const Disclaimer(),
                    const SizedBox(height: 30),
                    Card(
                        child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(children: [
                              const Text('Selecione o tipo de acesso:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                              const SizedBox(height: 10),
                              SegmentedButton<String>(
                                  segments: [
                                    ButtonSegment(value: 'eleitor', label: Text('Eleitor', style: TextStyle(fontWeight: FontWeight.bold)), icon: Icon(Icons.person)),
                                    ButtonSegment(value: 'admin', label: Text('Admin', style: TextStyle(fontWeight: FontWeight.bold)), icon: Icon(Icons.admin_panel_settings)),
                                    ButtonSegment(value: 'pesquisador', label: Text('Pesq.', style: TextStyle(fontWeight: FontWeight.bold)), icon: Icon(Icons.search)),
                                  ],
                                  selected: {_tipoUsuario},
                                  onSelectionChanged: (s) => setState(() => _tipoUsuario = s.first)),
                            ]))),
                    const SizedBox(height: 20),
                    if (_tipoUsuario == 'eleitor')
                      ElevatedButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Tela1Cadastro())), icon: const Icon(Icons.person_add), label: const Text('CADASTRE-SE', style: TextStyle(fontWeight: FontWeight.w900)), style: ElevatedButton.styleFrom(minimumSize: const Size(200, 50)))
                    else if (_tipoUsuario == 'admin')
                      ElevatedButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TelaAdminLogin())), icon: const Icon(Icons.admin_panel_settings), label: const Text('ADMINISTRAÇÃO', style: TextStyle(fontWeight: FontWeight.w900)), style: ElevatedButton.styleFrom(minimumSize: const Size(200, 50), backgroundColor: Colors.amber, foregroundColor: Colors.black))
                    else
                      ElevatedButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TelaPesquisador())), icon: const Icon(Icons.search), label: const Text('PESQUISADOR', style: TextStyle(fontWeight: FontWeight.w900)), style: ElevatedButton.styleFrom(minimumSize: const Size(200, 50), backgroundColor: Colors.blueGrey)),
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
  final _nameController = TextEditingController();
  final _cpfController = TextEditingController();
  final _dataController = TextEditingController();
  final _bairroController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('CADASTRO DE ELEITOR', style: TextStyle(fontWeight: FontWeight.w900)), backgroundColor: const Color(0xFF008F39), foregroundColor: Colors.white),
        body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
                key: _formKey,
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  const Disclaimer(),
                  const SizedBox(height: 20),
                  TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'name Completo', labelStyle: TextStyle(fontWeight: FontWeight.w900), border: OutlineInputBorder()), validator: (v) => v?.isEmpty ?? true ? 'name obrigatório' : null),
                  const SizedBox(height: 16),
                  TextFormField(
                      controller: _cpfController,
                      decoration: const InputDecoration(labelText: 'CPF', labelStyle: TextStyle(fontWeight: FontWeight.w900), border: OutlineInputBorder(), hintText: '000.000.000-00'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, _CpfMask()],
                      maxLength: 14,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'CPF obrigatório';
                        final cpf = v.replaceAll(RegExp(r'[^0-9]'), '');
                        if (cpf.length != 11) return 'CPF inválido';
                        return null;
                      }),
                  const SizedBox(height: 16),
                  TextFormField(
                      controller: _dataController,
                      decoration: const InputDecoration(labelText: 'Data de Nascimento', labelStyle: TextStyle(fontWeight: FontWeight.w900), border: OutlineInputBorder(), hintText: 'DD/MM/AAAA'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, _DataMask()],
                      maxLength: 10,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Data obrigatória';
                        if (v.length != 10) return 'Data inválida';
                        return null;
                      }),
                  const SizedBox(height: 16),
                  TextFormField(controller: _bairroController, decoration: const InputDecoration(labelText: 'Bairro onde mora', labelStyle: TextStyle(fontWeight: FontWeight.w900), border: OutlineInputBorder()), validator: (v) => v?.isEmpty ?? true ? 'Bairro obrigatório' : null),
                  const SizedBox(height: 24),
                  ElevatedButton(onPressed: _cadastrar, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF008F39), foregroundColor: Colors.white, minimumSize: const Size.fromHeight(50)), child: const Text('CADASTRAR E VOTAR', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900))),
                ]))));
  }

  void _cadastrar() {
    if (!_formKey.currentState!.validate()) return;
    final parts = _dataController.text.split('/');
    final data = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
    final idade = ValidadorService.calcularIdade(data);
    if (idade < 16) {
      showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text('Acesso Negado'), content: const Text('Idade mínima: 16 anos'), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))]));
      return;
    }
    final eleitor = Eleitor(id: DateTime.now().millisecondsSinceEpoch.toString(), nome: _nameController.text, cpf: _cpfController.text.replaceAll(RegExp(r'[^0-9]'), ''), dataNascimento: data, bairro: _bairroController.text);
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
    for (int i = 0; i < t.length; i++) {
      if (i == 3 || i == 6) r += '.';
      if (i == 9) r += '-';
      r += t[i];
    }
    return TextEditingValue(text: r, selection: TextSelection.collapsed(offset: r.length));
  }
}

class _DataMask extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue o, TextEditingValue n) {
    var t = n.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (t.length > 8) t = t.substring(0, 8);
    var r = '';
    for (int i = 0; i < t.length; i++) {
      if (i == 2 || i == 4) r += '/';
      r += t[i];
    }
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
    return Scaffold(
        appBar: AppBar(title: const Text('VOTAÇÃO', style: TextStyle(fontWeight: FontWeight.w900)), backgroundColor: const Color(0xFF008F39), foregroundColor: Colors.white),
        body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              const Disclaimer(),
              const SizedBox(height: 16),
              Text('Eleitor: ${widget.eleitor.nome}', style: const TextStyle(fontWeight: FontWeight.w900)),
              Text('Bairro: ${widget.eleitor.bairro}', style: const TextStyle(fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SegmentedButton<String>(
                    segments: [
                      ButtonSegment(value: 'presidente', label: Text('Presidente', style: TextStyle(fontWeight: FontWeight.bold))),
                      ButtonSegment(value: 'deputado_estadual', label: Text('Dep. Est.', style: TextStyle(fontWeight: FontWeight.bold))),
                      ButtonSegment(value: 'deputado_federal', label: Text('Dep. Fed.', style: TextStyle(fontWeight: FontWeight.bold))),
                      ButtonSegment(value: 'senador', label: Text('Senador', style: TextStyle(fontWeight: FontWeight.bold))),
                      ButtonSegment(value: 'prefeito', label: Text('Prefeito', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    selected: {_tipo},
                    onSelectionChanged: (s) => setState(() => _tipo = s.first)),
              ),
              const SizedBox(height: 20),
              Expanded(
                  child: ListView.builder(
                      itemCount: _cands.length,
                      itemBuilder: (ctx, i) {
                        final c = _cands[i];
                        return Card(
                            child: RadioListTile<String>(
                                value: c.id,
                                groupValue: _candSel,
                                onChanged: jaVotou ? null : (v) => setState(() => _candSel = v),
                                title: Text(c.nome + ' - ' + c.partido, style: const TextStyle(fontWeight: FontWeight.w900)),
                                subtitle: Text('Número: ${c.numero}', style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white70))));
                      })),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _candSel == null || jaVotou ? null : _votar, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF008F39), foregroundColor: Colors.white, minimumSize: const Size.fromHeight(50)), child: const Text('CONFIRMAR VOTO', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900))),
            ])));
  }

  void _votar() async {
    final hash = DatabaseService.hashCpf(widget.eleitor.cpf);
    if (DatabaseService.jaVotou(hash)) {
      if (mounted) showDialog(context: context, builder: (ctx) => AlertDialog(content: const Text('Você já votou!'), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))]));
      return;
    }
    await DatabaseService.saveVoto(Voto(idEleitor: widget.eleitor.id, idCandidato: _candSel!, tipoVoto: _tipo, dataVoto: DateTime.now()));
    if (mounted) {
      HapticFeedback.heavyImpact();
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
                  title: const Text('VOTO CONFIRMADO!', style: TextStyle(fontWeight: FontWeight.w900)),
                  content: const Text('Obrigado por participar.', style: TextStyle(fontWeight: FontWeight.bold)),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.of(context).popUntil((r) => r.isFirst);
                        },
                        child: const Text('OK', style: TextStyle(fontWeight: FontWeight.w900)))
                  ]));
    }
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
    return Scaffold(
        appBar: AppBar(title: const Text('LOGIN ADMIN', style: TextStyle(fontWeight: FontWeight.w900)), backgroundColor: Colors.amber[700]),
        body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('Digite a senha de acesso:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 16),
              TextField(controller: _senhaController, obscureText: true, decoration: const InputDecoration(labelText: 'Senha', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _login, style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black, minimumSize: const Size(200, 50)), child: const Text('ENTRAR', style: TextStyle(fontWeight: FontWeight.w900))),
            ])));
  }

  void _login() {
    if (_senhaController.text == 'admin123')
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TelaAdmin()));
    else
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Senha incorreta')));
  }
}

class TelaAdmin extends StatefulWidget {
  const TelaAdmin({super.key});
  @override
  State<TelaAdmin> createState() => _TelaAdminState();
}

class _TelaAdminState extends State<TelaAdmin> {
  List<Candidato> _cands = [];
  String? _estado;
  final _cityController = TextEditingController();
  final _nameController = TextEditingController();
  final _numeroController = TextEditingController();
  final _partidoController = TextEditingController();
  Uint8List? _bytesFoto;
  static const _estados = ['AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA', 'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN', 'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO'];

  @override
  void initState() {
    super.initState();
    _cands = DatabaseService.getCandidatos();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 4,
        child: Scaffold(
            appBar: AppBar(title: const Text('PAINEL DE GESTÃO', style: TextStyle(fontWeight: FontWeight.w900)), backgroundColor: Colors.amber[700], bottom: const TabBar(labelStyle: TextStyle(fontWeight: FontWeight.w900), tabs: [Tab(text: 'Filtros'), Tab(text: 'Candidatos'), Tab(text: 'QGP'), Tab(text: 'Testes')])),
            body: TabBarView(children: [_tabFiltros(), _tabCandidatos(), _tabQGP(), _tabTestes()])));
  }

  Widget _tabFiltros() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Filtros de Resultados', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 20),
          const Text('Estado:', style: TextStyle(fontWeight: FontWeight.w900)),
          DropdownButtonFormField<String>(value: _estado, decoration: const InputDecoration(border: OutlineInputBorder()), items: _estados.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontWeight: FontWeight.w900)))).toList(), onChanged: (v) => setState(() => _estado = v)),
          const SizedBox(height: 16),
          const Text('city:', style: TextStyle(fontWeight: FontWeight.w900)),
          TextField(controller: _cityController, decoration: const InputDecoration(border: OutlineInputBorder())),
          const SizedBox(height: 20),
          ElevatedButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TelaResultados(estado: _estado, city: _cityController.text))), icon: const Icon(Icons.bar_chart), label: const Text('VER RESULTADOS', style: TextStyle(fontWeight: FontWeight.w900)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1), minimumSize: const Size.fromHeight(50))),
          const SizedBox(height: 16),
          ElevatedButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TelaQGP())), icon: const Icon(Icons.pie_chart), label: const Text('VER GRÁFICOS QGP', style: TextStyle(fontWeight: FontWeight.w900)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8A2BE2), minimumSize: const Size.fromHeight(50))),
        ],
      ),
    );
  }

  Widget _tabCandidatos() {
    return Column(
      children: [
        const Padding(padding: EdgeInsets.all(16), child: Text('CADASTRO DE CANDIDATOS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white))),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(onPressed: _importarFoto, icon: const Icon(Icons.add_photo_alternate, color: Colors.white), label: const Text('ADICIONAR POR FOTO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8A2BE2))),
          ],
        ),
        if (_bytesFoto != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(width: 120, height: 120, decoration: BoxDecoration(image: DecorationImage(image: MemoryImage(_bytesFoto!), fit: BoxFit.cover), border: Border.all(color: const Color(0xFF8A2BE2), width: 3), borderRadius: BorderRadius.circular(10))),
          ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: _cands.length,
            itemBuilder: (ctx, i) {
              final c = _cands[i];
              return ListTile(
                leading: const Icon(Icons.person, color: Color(0xFF8A2BE2)),
                title: Text(c.nome, style: const TextStyle(fontWeight: FontWeight.w900)),
                subtitle: Text('${c.partido} - ${c.numero}', style: const TextStyle(fontWeight: FontWeight.w900)),
                trailing: IconButton(icon: const Icon(Icons.delete, color: Color(0xFFB24040)), onPressed: () => _delCandidate(c.id)),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _importarFoto() async {
    try {
      FilePickerResult? r = await FilePicker.platform.pickFiles(type: FileType.image, allowMultiple: false);
      if (r != null && r.files.isNotEmpty) {
        String name = r.files.first.name;
        _bytesFoto = r.files.first.bytes;
        String semExt = name.split('.').first;
        List<String> d = semExt.split('_');
        if (d.length >= 3) {
          _nameController.text = d[0].trim();
          _numeroController.text = d[1].trim();
          _partidoController.text = d[2].trim();
          _addCandidato();
        }
      }
    } catch (e) {
      logError('Erro', e);
    }
    setState(() {});
  }

  Widget _tabQGP() {
    return Padding(padding: const EdgeInsets.all(16), child: Column(children: [const Text('DESEMPENHO GERAL', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)), const SizedBox(height: 20), _buildChart()]));
  }

  Widget _buildChart() {
    final c = DatabaseService.getCandidatos();
    final t = DatabaseService.getTotalVotos();
    if (c.isEmpty) return const Center(child: Text('Nenhum candidato cadastrado', style: TextStyle(fontWeight: FontWeight.w900)));
    final max = t > 0 ? c.map((x) => x.votos.toDouble()).reduce((a, b) => a > b ? a : b) * 1.2 : 10.0;
    return SizedBox(
        height: 300,
        child: BarChart(BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: max,
            titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, m) {
                          final i = v.toInt();
                          if (i >= 0 && i < c.length) return Padding(padding: const EdgeInsets.only(top: 8), child: Text(c[i].nome, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900)));
                          return const Text('');
                        })),
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40))),
            barGroups: c.asMap().entries.map((e) => BarChartGroupData(x: e.key, barRods: [BarChartRodData(toY: e.value.votos.toDouble(), color: const Color(0xFF8A2BE2), width: 25, borderRadius: const BorderRadius.vertical(top: Radius.circular(5)))])).toList())));
  }

  Widget _tabTestes() {
    return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          const Text('FERRAMENTAS DE AGILIDADE', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 20),
          ElevatedButton.icon(onPressed: _gerarEleitores, icon: const Icon(Icons.people), label: const Text('GERAR 50 ELEITORES', style: TextStyle(fontWeight: FontWeight.w900)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8A2BE2), minimumSize: const Size.fromHeight(50))),
          const SizedBox(height: 16),
          ElevatedButton.icon(onPressed: _gerarVotos, icon: const Icon(Icons.how_to_vote), label: const Text('GERAR 30 VOTOS', style: TextStyle(fontWeight: FontWeight.w900)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF008F39), minimumSize: const Size.fromHeight(50))),
          const SizedBox(height: 16),
          ElevatedButton.icon(onPressed: _limpar, icon: const Icon(Icons.delete_forever), label: const Text('LIMPAR TODOS OS DADOS', style: TextStyle(fontWeight: FontWeight.w900)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB24040), minimumSize: const Size.fromHeight(50)))
        ]));
  }

  void _addCandidato() {
    if (_nameController.text.isEmpty || _numeroController.text.isEmpty || _partidoController.text.isEmpty) return;
    String p = _partidoController.text;
    String s = p.split(' ').length > 1 ? p.split(' ').map((x) => x[0]).join('').toUpperCase() : p.substring(0, p.length >= 2 ? 2 : p.length).toUpperCase();
    DatabaseService.saveCandidato(Candidato(id: DateTime.now().millisecondsSinceEpoch.toString(), nome: _nameController.text, numero: int.tryParse(_numeroController.text) ?? 0, partido: p, sigla: s));
    _nameController.clear();
    _numeroController.clear();
    _partidoController.clear();
    _bytesFoto = null;
    setState(() => _cands = DatabaseService.getCandidatos());
  }

  void _delCandidate(String id) {
    DatabaseService.deleteCandidato(id);
    setState(() => _cands = DatabaseService.getCandidatos());
  }

  void _gerarEleitores() {
    for (int i = 0; i < 50; i++) DatabaseService.saveEleitor(Eleitor(id: 't_$i', nome: 'Eleitor Teste $i', cpf: '0000000000$i', dataNascimento: DateTime(1990, 1, 1), bairro: 'Bairro Teste'));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('50 Eleitores Gerados!')));
  }

  void _gerarVotos() {
    if (_cands.isEmpty) return;
    for (int i = 0; i < 30; i++) {
      var c = _cands[i % _cands.length];
      DatabaseService.saveVoto(Voto(idEleitor: 't_$i', idCandidato: c.id, tipoVoto: 'presidente', dataVoto: DateTime.now()));
    }
    setState(() => _cands = DatabaseService.getCandidatos());
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('30 Votos Gerados!')));
  }

  void _limpar() {
    DatabaseService.clearAllData();
    setState(() => _cands = DatabaseService.getCandidatos());
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Banco de Dados Limpo!')));
  }
}

class TelaResultados extends StatefulWidget {
  final String? estado;
  final String city;
  const TelaResultados({super.key, this.estado, required this.city});
  @override
  State<TelaResultados> createState() => _TelaResultadosState();
}

class _TelaResultadosState extends State<TelaResultados> {
  @override
  Widget build(BuildContext context) {
    final c = DatabaseService.getCandidatos();
    final t = DatabaseService.getTotalVotos();
    return Scaffold(
        appBar: AppBar(title: const Text('RESULTADOS DA PESQUISA', style: TextStyle(fontWeight: FontWeight.w900)), backgroundColor: const Color(0xFF0D47A1), foregroundColor: Colors.white),
        body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              const Disclaimer(),
              const SizedBox(height: 10),
              if (widget.estado != null) Text('Estado: ${widget.estado}', style: const TextStyle(fontWeight: FontWeight.w900)),
              if (widget.city.isNotEmpty) Text('city: ${widget.city}', style: const TextStyle(fontWeight: FontWeight.w900)),
              Text('Total de Votos: $t', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(height: 20),
              Expanded(
                  child: c.isEmpty
                      ? const Center(child: Text('Nenhum dado disponível', style: TextStyle(fontWeight: FontWeight.w900)))
                      : BarChart(BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: t > 0 ? c.map((x) => x.votos.toDouble()).reduce((a, b) => a > b ? a : b) * 1.2 : 10,
                          titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (v, m) {
                                        final i = v.toInt();
                                        if (i >= 0 && i < c.length) return Padding(padding: const EdgeInsets.only(top: 8), child: Text(c[i].nome, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900)));
                                        return const Text('');
                                      }))),
                          barGroups: c.asMap().entries.map((e) => BarChartGroupData(x: e.key, barRods: [BarChartRodData(toY: e.value.votos.toDouble(), color: const Color(0xFF0D47A1), width: 25, borderRadius: const BorderRadius.vertical(top: Radius.circular(5)))])).toList()))),
              const SizedBox(height: 20),
              Expanded(
                  child: ListView.builder(
                      itemCount: c.length,
                      itemBuilder: (ctx, i) {
                        final x = c[i];
                        final p = t > 0 ? (x.votos / t * 100) : 0.0;
                        return ListTile(
                          title: Text('${x.nome} (${x.numero})', style: const TextStyle(fontWeight: FontWeight.w900)), 
                          subtitle: LinearProgressIndicator(value: p / 100, color: const Color(0xFF0D47A1), minHeight: 8), 
                          trailing: Text('${p.toStringAsFixed(1)}% (${x.votos})', style: const TextStyle(fontWeight: FontWeight.w900))
                        );
                      })),
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
    return Scaffold(
        appBar: AppBar(title: const Text('CENTRAL QGP', style: TextStyle(fontWeight: FontWeight.w900)), backgroundColor: const Color(0xFF8A2BE2), foregroundColor: Colors.white),
        body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              const Disclaimer(),
              const SizedBox(height: 10),
              const Text('MAPA DE DESEMPENHO', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 20),
              Expanded(
                  child: c.isEmpty
                      ? const Center(child: Text('Sem candidatos', style: TextStyle(fontWeight: FontWeight.w900)))
                      : BarChart(BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: t > 0 ? c.map((x) => x.votos.toDouble()).reduce((a, b) => a > b ? a : b) * 1.2 : 10,
                          titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (v, m) {
                                        final i = v.toInt();
                                        if (i >= 0 && i < c.length) return Padding(padding: const EdgeInsets.only(top: 8), child: Text(c[i].nome, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900)));
                                        return const Text('');
                                      }))),
                          barGroups: c.asMap().entries.map((e) => BarChartGroupData(x: e.key, barRods: [BarChartRodData(toY: e.value.votos.toDouble(), color: const Color(0xFF8A2BE2), width: 25, borderRadius: const BorderRadius.vertical(top: Radius.circular(5)))])).toList()))),
              const SizedBox(height: 20),
              const Text('SENTIMENTO DO ELEITOR', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                _sentimentoItem(Icons.thumb_down, 'CONTRÁRIO', p['vermelho'] ?? 0, const Color(0xFFB24040)),
                _sentimentoItem(Icons.thumb_up, 'A FAVOR', p['verde'] ?? 0, const Color(0xFF008F39)),
                _sentimentoItem(Icons.question_mark, 'INDECISO', p['branco'] ?? 0, Colors.white),
              ]),
            ])));
  }

  Widget _sentimentoItem(IconData icon, String label, int valor, Color cor) {
    return Column(children: [
      Icon(icon, color: cor, size: 40), 
      Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900)), 
      Text('$valor', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: cor))
    ]);
  }
}

class TelaPesquisador extends StatefulWidget {
  const TelaPesquisador({super.key});
  @override
  State<TelaPesquisador> createState() => _TelaPesquisadorState();
}

class _TelaPesquisadorState extends State<TelaPesquisador> {
  final _nameController = TextEditingController();
  final _cpfController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('PESQUISADOR DE CAMPO', style: TextStyle(fontWeight: FontWeight.w900)), backgroundColor: Colors.blueGrey[700], foregroundColor: Colors.white),
        body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              const Disclaimer(),
              const SizedBox(height: 20),
              const Text('DADOS DO ENTREVISTADO (OPCIONAL)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'name', labelStyle: TextStyle(fontWeight: FontWeight.w900), border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: _cpfController, decoration: const InputDecoration(labelText: 'CPF', labelStyle: TextStyle(fontWeight: FontWeight.w900), border: OutlineInputBorder()), keyboardType: TextInputType.number),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey, minimumSize: const Size.fromHeight(50)), child: const Text('INICIAR COLETA', style: TextStyle(fontWeight: FontWeight.w900))),
            ])));
  }
}