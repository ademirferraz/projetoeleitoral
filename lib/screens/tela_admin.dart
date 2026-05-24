import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:projetoeleitoral/services/services.dart';
import 'package:projetoeleitoral/utils/report_helper.dart';
import 'tela_resultados.dart';

void logDebug(String msg) => debugPrint('[DEBUG] $msg');
void logError(String msg, Object e) => debugPrint('[ERROR] $msg: $e');

// =========================
// TELA LOGIN ADMIN
// =========================
class TelaAdminLogin extends StatefulWidget {
  const TelaAdminLogin({super.key});

  @override
  State<TelaAdminLogin> createState() => _TelaAdminLoginState();
}

class _TelaAdminLoginState extends State<TelaAdminLogin> {
  final _senhaController = TextEditingController();

  @override
  void dispose() {
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LOGIN ADMIN', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.amber[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Digite a senha de acesso:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            TextField(
              controller: _senhaController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Senha', border: OutlineInputBorder()),
              onSubmitted: (_) => _login(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black, minimumSize: const Size(200, 50)),
              child: const Text('ENTRAR', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        ),
      ),
    );
  }

  void _login() {
    if (_senhaController.text == 'admin123') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TelaAdmin()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Senha incorreta')));
    }
  }
}

// =========================
// TELA ADMIN (PAINEL DE GESTÃO)
// =========================
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
  String? _cargo;
  static const _cargos = ['Prefeito', 'Presidente', 'Deputado Estadual', 'Deputado Federal', 'Senador', 'Vereador'];
  static const _estados = ['AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA', 'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN', 'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO'];

  // Opinião
  final _opiniaoNomeController = TextEditingController();
  final _opiniaoCpfController = TextEditingController();
  String _opiniaoCandSelecionadoId = '';
  String _opiniaoOpcao = '';
  // Senha QGP
  String? _qpgSenha;
  String? _ultimoRelatorioHtml;

  @override
  void initState() {
    super.initState();
    _cands = DatabaseService.getCandidatos();
    _verificarEnvioAutomatico();
  }

  @override
  void dispose() {
    _cityController.dispose();
    _nameController.dispose();
    _numeroController.dispose();
    _partidoController.dispose();
    _opiniaoNomeController.dispose();
    _opiniaoCpfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('PAINEL DE GESTÃO', style: TextStyle(fontWeight: FontWeight.w900)),
          backgroundColor: Colors.amber[700],
          bottom: const TabBar(
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            labelStyle: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Filtros'),
              Tab(text: 'Candidatos'),
              Tab(text: 'QGP'),
            ],
          ),
        ),
        body: TabBarView(children: [_tabFiltros(), _tabCandidatos(), _tabQGP()]),
      ),
    );
  }

  Widget _tabFiltros() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Filtros de Resultados', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.amber)),
          const SizedBox(height: 20),
          const Text('Estado:', style: TextStyle(fontWeight: FontWeight.w900)),
          DropdownButtonFormField<String>(
            value: _estado,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: _estados.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontWeight: FontWeight.w900)))).toList(),
            onChanged: (v) => setState(() => _estado = v),
          ),
          const SizedBox(height: 16),
          const Text('Cidade:', style: TextStyle(fontWeight: FontWeight.w900)),
          TextField(controller: _cityController, decoration: const InputDecoration(border: OutlineInputBorder())),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TelaResultados(estado: _estado, city: _cityController.text))),
            icon: const Icon(Icons.bar_chart),
            label: const Text('VER RESULTADOS', style: TextStyle(fontWeight: FontWeight.w900)),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1), foregroundColor: Colors.white, minimumSize: const Size.fromHeight(50)),
          ),
          const SizedBox(height: 24),
          const Text('VOTOS POR CANDIDATO', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            if (_cands.isEmpty)
              const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('Nenhum candidato cadastrado.', style: TextStyle(color: Colors.white54)))
            else
              ..._cands.map((c) {
                final totalVotos = _cands.fold<int>(0, (s, e) => s + e.votos);
                final pct = totalVotos > 0 ? (c.votos / totalVotos * 100) : 0.0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      SizedBox(width: 120, child: Text(c.nome, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900), overflow: TextOverflow.ellipsis)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: 22,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: pct / 100,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${pct.toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.amber)),
                    ],
                  ),
                );
              }),
          ],
      ),
    );
  }

  Widget _tabCandidatos() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('CADASTRO DE CANDIDATOS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _importarFoto,
                  icon: const Icon(Icons.add_photo_alternate, color: Colors.white),
                  label: const Text('ADICIONAR POR FOTO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8A2BE2), foregroundColor: Colors.white),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _addCandidato,
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text('CADASTRAR', style: TextStyle(fontWeight: FontWeight.w900)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF008F39), foregroundColor: Colors.white),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  image: _bytesFoto != null ? DecorationImage(image: MemoryImage(_bytesFoto!), fit: BoxFit.cover) : null,
                  border: Border.all(color: const Color(0xFF8A2BE2), width: 3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _bytesFoto == null ? const Icon(Icons.person, size: 60, color: Colors.white54) : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Nome do candidato', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _numeroController,
                      decoration: const InputDecoration(labelText: 'Número do candidato', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _partidoController,
                      decoration: const InputDecoration(labelText: 'Sigla do partido', border: OutlineInputBorder()),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonFormField<String>(
            value: _cargo,
            decoration: const InputDecoration(labelText: 'Cargo', border: OutlineInputBorder()),
            items: _cargos.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontWeight: FontWeight.w900)))).toList(),
            onChanged: (v) => setState(() => _cargo = v),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _estado,
                  decoration: const InputDecoration(labelText: 'Estado', border: OutlineInputBorder()),
                  items: _estados.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) => setState(() => _estado = v),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _cityController,
                  decoration: const InputDecoration(labelText: 'Cidade', border: OutlineInputBorder()),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: _cands.length,
            itemBuilder: (ctx, i) {
              final c = _cands[i];
              return ListTile(
                leading: c.fotoPath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(base64Decode(c.fotoPath!), width: 40, height: 40, fit: BoxFit.cover),
                      )
                    : const Icon(Icons.person, color: Color(0xFF8A2BE2)),
                title: Text(c.nome, style: const TextStyle(fontWeight: FontWeight.w900)),
                subtitle: Text('${c.partido} - ${c.numero}${c.estado != null ? ' | ${c.cidade ?? ''}/${c.estado}' : ''}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
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
      FilePickerResult? r = await FilePicker.platform.pickFiles(type: FileType.image, allowMultiple: false, withData: true);
      if (r != null && r.files.isNotEmpty) {
        String name = r.files.first.name;
        _bytesFoto = r.files.first.bytes;
        String semExt = name.split('.').first;
        List<String> d = semExt.split('_');
        if (d.length >= 4) {
          _nameController.text = d[0].trim();
          _numeroController.text = d[1].trim();
          _partidoController.text = d[2].trim();
          String cargo = d[3].trim();
          if (_cargos.contains(cargo)) _cargo = cargo;
        } else if (d.length >= 3) {
          _nameController.text = d[0].trim();
          _numeroController.text = d[1].trim();
          _partidoController.text = d[2].trim();
          if (_cargos.contains(_partidoController.text)) _cargo = _partidoController.text;
        }
      }
    } catch (e) {
      logError('Erro', e);
    }
    setState(() {});
  }


  Widget _botaoOpcao(String label, Color cor, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: selected ? cor.withOpacity(0.3) : cor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? cor : cor.withOpacity(0.3), width: selected ? 3 : 1),
        ),
        child: Center(child: Text(label, textAlign: TextAlign.center, style: TextStyle(color: cor, fontWeight: FontWeight.bold, fontSize: 12))),
      ),
    );
  }

  Widget _chipContador(String label, int valor, Color cor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: cor.withOpacity(0.15), borderRadius: BorderRadius.circular(8), border: Border.all(color: cor.withOpacity(0.4))),
        child: Column(
          children: [
            Text(label, style: TextStyle(fontSize: 10, color: cor, fontWeight: FontWeight.w900)),
            Text('$valor', style: TextStyle(fontSize: 22, color: cor, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }

  // =========================
  // ABA OPINIÃO (por candidato)
  // =========================
  Widget _tabQGP() {
    final consolidado = DatabaseService.getConsolidadoOpinioes();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('QGP — OPINIÃO POR CANDIDATO', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.cyanAccent)),
            const SizedBox(height: 12),
            Row(children: [
              const Text('Clique na foto do candidato:', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white70)),
              const Spacer(),
              if (_qpgSenha == null)
                TextButton.icon(
                  onPressed: () async {
                    final senha = (100000 + DateTime.now().millisecondsSinceEpoch % 900000).toString();
                    setState(() => _qpgSenha = senha);
                    DatabaseService.setQpgSenha(senha);
                    await showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => AlertDialog(
                        backgroundColor: const Color(0xFF1E1E1E),
                        title: const Text('Senha Gerada', style: TextStyle(fontWeight: FontWeight.w900)),
                        content: Column(mainAxisSize: MainAxisSize.min, children: [
                          const Text('Compartilhe esta senha com o pesquisador:'),
                          const SizedBox(height: 16),
                          Text(senha, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.cyanAccent, letterSpacing: 4)),
                        ]),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK', style: TextStyle(fontWeight: FontWeight.w900)),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.vpn_key, size: 18),
                  label: const Text('Gerar Senha', style: TextStyle(fontSize: 12)),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text('Senha: $_qpgSenha', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.cyanAccent, letterSpacing: 2)),
                ),
            ]),
            const SizedBox(height: 12),
            // Fotos dos candidatos
            SizedBox(
              height: 170,
              child: _cands.isEmpty
                  ? const Center(child: Text('Nenhum candidato cadastrado.', style: TextStyle(color: Colors.white54)))
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _cands.length,
                      itemBuilder: (ctx, i) {
                        final c = _cands[i];
                        final sel = _opiniaoCandSelecionadoId == c.id;
                        return GestureDetector(
                          onTap: () => setState(() => _opiniaoCandSelecionadoId = c.id),
                          child: Container(
                            width: 120,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: sel ? Colors.cyanAccent.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: sel ? Colors.cyanAccent : Colors.grey, width: sel ? 3 : 1),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                c.fotoPath != null
                                    ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.memory(base64Decode(c.fotoPath!), width: 70, height: 70, fit: BoxFit.cover))
                                    : const Icon(Icons.person, size: 50, color: Colors.cyanAccent),
                                const SizedBox(height: 4),
                                Text(c.nome, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900), maxLines: 2, overflow: TextOverflow.ellipsis),
                                if (c.cargo != null)
                                  Text(c.cargo!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 8, color: Colors.amber), maxLines: 1, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            // Campos opcionais
            TextField(
              controller: _opiniaoNomeController,
              decoration: const InputDecoration(labelText: 'Nome (Opcional)', border: OutlineInputBorder(), filled: true, fillColor: Color(0xFF1E1E1E)),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _opiniaoCpfController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'CPF (Opcional)', border: OutlineInputBorder(), filled: true, fillColor: Color(0xFF1E1E1E)),
            ),
            const SizedBox(height: 16),
            // Botões de classificação
            const Text('DECISÃO:', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white70)),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _botaoOpcao('Interessado', Colors.blue, _opiniaoOpcao == 'INTERESSADO', () => setState(() => _opiniaoOpcao = 'INTERESSADO'))),
              const SizedBox(width: 6),
              Expanded(child: _botaoOpcao('Não\nInteressado', Colors.red, _opiniaoOpcao == 'NAO_INTERESSADO', () => setState(() => _opiniaoOpcao = 'NAO_INTERESSADO'))),
              const SizedBox(width: 6),
              Expanded(child: _botaoOpcao('Outros', Colors.grey, _opiniaoOpcao == 'OUTRO', () => setState(() => _opiniaoOpcao = 'OUTRO'))),
            ]),
            const SizedBox(height: 16),
            // Gravar
            Row(children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: (_opiniaoCandSelecionadoId.isEmpty || _opiniaoOpcao.isEmpty) ? null : _gravarOpiniao,
                  icon: const Icon(Icons.save),
                  label: const Text('GRAVAR', style: TextStyle(fontWeight: FontWeight.w900)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF008F39), minimumSize: const Size.fromHeight(50)),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            if (_opiniaoCandSelecionadoId.isNotEmpty) ...[
              const Text('ACUMULADO:', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 4),
              Row(children: [
                _chipContador('Interessado', consolidado[_opiniaoCandSelecionadoId]?['INTERESSADO'] ?? 0, Colors.blue),
                const SizedBox(width: 8),
                _chipContador('Não Interessado', consolidado[_opiniaoCandSelecionadoId]?['NAO_INTERESSADO'] ?? 0, Colors.red),
                const SizedBox(width: 8),
                _chipContador('Outros', consolidado[_opiniaoCandSelecionadoId]?['OUTRO'] ?? 0, Colors.grey),
              ]),
            ],
            const SizedBox(height: 14),
            // Relatórios
            Row(children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: consolidado.isEmpty ? null : _salvarRelatorio,
                  icon: const Icon(Icons.save_alt),
                  label: const Text('SALVAR RELATÓRIO', style: TextStyle(fontWeight: FontWeight.w900)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF8C00), minimumSize: const Size.fromHeight(50)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _abrirRelatorio,
                  icon: const Icon(Icons.open_in_browser),
                  label: const Text('ABRIR RELATÓRIO', style: TextStyle(fontWeight: FontWeight.w900)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8A2BE2), minimumSize: const Size.fromHeight(50)),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  void _gravarOpiniao() {
    if (_opiniaoCandSelecionadoId.isEmpty || _opiniaoOpcao.isEmpty) return;
    DatabaseService.saveOpiniaoCandidato(OpiniaoCandidato(
      candidatoId: _opiniaoCandSelecionadoId,
      nome: _opiniaoNomeController.text.isNotEmpty ? _opiniaoNomeController.text : null,
      cpf: _opiniaoCpfController.text.isNotEmpty ? _opiniaoCpfController.text : null,
      opcao: _opiniaoOpcao,
      data: DateTime.now(),
    ));
    _opiniaoNomeController.clear();
    _opiniaoCpfController.clear();
    _opiniaoOpcao = '';
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opinião registrada com sucesso!'), backgroundColor: Colors.green));
  }

  Future<void> _salvarRelatorio() async {
    final relatorio = DatabaseService.gerarRelatorio();
    final dataStr = DateTime.now().toIso8601String().split('T')[0];
    try {
      await ReportHelper.downloadReport('relatorio_$dataStr.html', relatorio);
      _ultimoRelatorioHtml = relatorio;
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Relatório baixado com sucesso!'), backgroundColor: Colors.green, duration: Duration(seconds: 3)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar relatório: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _abrirRelatorio() async {
    final htmlContent = _ultimoRelatorioHtml;
    if (htmlContent == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum relatório salvo ainda. Clique em "SALVAR RELATÓRIO" primeiro.'), backgroundColor: Colors.orange),
      );
      return;
    }
    try {
      await ReportHelper.openReport(htmlContent);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao abrir relatório: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // =========================
  // MÉTODOS AUXILIARES
  // =========================
  void _addCandidato() {
    if (_nameController.text.isEmpty || _numeroController.text.isEmpty || _partidoController.text.isEmpty) return;
    String sigla = _partidoController.text.trim().toUpperCase();
    String? fotoBase64 = _bytesFoto != null ? base64Encode(_bytesFoto!) : null;
    DatabaseService.saveCandidato(
      Candidato(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nome: _nameController.text,
        numero: int.tryParse(_numeroController.text) ?? 0,
        partido: sigla,
        sigla: sigla,
        cargo: _cargo,
        fotoPath: fotoBase64,
        estado: _estado,
        cidade: _cityController.text.isNotEmpty ? _cityController.text : null,
      ),
    );
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

  void _verificarEnvioAutomatico() {
    if (!DatabaseService.precisaEnvioAutomatico()) return;
    final consolidado = DatabaseService.getConsolidadoOpinioes();
    if (consolidado.isEmpty) return;
    DatabaseService.gerarRelatorio();
    debugPrint('[AUTO] Relatório gerado automaticamente.');
  }

}
