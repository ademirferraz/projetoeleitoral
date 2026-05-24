import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:projetoeleitoral/services/services.dart';
import 'package:projetoeleitoral/utils/report_helper.dart';

class TelaPesquisador extends StatefulWidget {
  const TelaPesquisador({super.key});

  @override
  State<TelaPesquisador> createState() => _TelaPesquisadorState();
}

class _TelaPesquisadorState extends State<TelaPesquisador> {
  List<Candidato> _cands = [];
  final Map<String, List<Map<String, dynamic>>> _opinioesLocais = {};
  String _candSelecionadoId = '';
  String _opcaoSelecionada = '';
  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  String? _ultimoRelatorioHtml;
  bool _autenticado = false;
  final _senhaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cands = DatabaseService.getCandidatos();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  int _getContagem(String candidatoId, String opcao) {
    final opinioes = _opinioesLocais[candidatoId];
    if (opinioes == null) return 0;
    return opinioes.where((o) => o['opcao'] == opcao).length;
  }

  Map<String, Map<String, int>> _getConsolidadoLocal() {
    final result = <String, Map<String, int>>{};
    for (final entry in _opinioesLocais.entries) {
      final contagem = <String, int>{'INTERESSADO': 0, 'NAO_INTERESSADO': 0, 'OUTRO': 0};
      for (final o in entry.value) {
        contagem[o['opcao'] as String] = (contagem[o['opcao'] as String] ?? 0) + 1;
      }
      result[entry.key] = contagem;
    }
    return result;
  }

  void _gravarOpiniao() {
    if (_candSelecionadoId.isEmpty || _opcaoSelecionada.isEmpty) return;
    _opinioesLocais.putIfAbsent(_candSelecionadoId, () => []);
    _opinioesLocais[_candSelecionadoId]!.add({
      'opcao': _opcaoSelecionada,
      'nome': _nomeController.text.isNotEmpty ? _nomeController.text : null,
      'cpf': _cpfController.text.isNotEmpty ? _cpfController.text : null,
    });
    _nomeController.clear();
    _cpfController.clear();
    _opcaoSelecionada = '';
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opinião registrada!'), backgroundColor: Colors.green),
    );
  }

  Future<void> _salvarRelatorio() async {
    final consolidado = _getConsolidadoLocal();
    if (consolidado.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhuma opinião registrada nesta sessão.'), backgroundColor: Colors.orange),
      );
      return;
    }
    final relatorio = DatabaseService.gerarRelatorioFromData(consolidado, _cands);
    final dataStr = DateTime.now().toIso8601String().split('T')[0];
    try {
      await ReportHelper.downloadReport('relatorio_pesquisador_$dataStr.html', relatorio);
      _ultimoRelatorioHtml = relatorio;
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Relatório baixado com sucesso!'), backgroundColor: Colors.green),
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
        const SnackBar(content: Text('Nenhum relatório salvo ainda.'), backgroundColor: Colors.orange),
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

  void _verificarSenha() {
    final senhaCorreta = DatabaseService.getQpgSenha();
    if (senhaCorreta == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhuma senha QGP foi gerada pelo Admin.'), backgroundColor: Colors.red),
      );
      return;
    }
    if (_senhaController.text == senhaCorreta) {
      setState(() => _autenticado = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Senha incorreta.'), backgroundColor: Colors.red),
      );
    }
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

  @override
  Widget build(BuildContext context) {
    if (!_autenticado) {
      return _buildLoginScreen();
    }
    return _buildQGPScreen();
  }

  Widget _buildLoginScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text('ACESSO PESQUISADOR', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.vpn_key, size: 80, color: Colors.cyanAccent),
              const SizedBox(height: 24),
              const Text('Digite a senha QGP gerada pelo Admin', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white70), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              TextField(
                controller: _senhaController,
                obscureText: true,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.cyanAccent, letterSpacing: 8),
                decoration: InputDecoration(
                  hintText: '000000',
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.number,
                maxLength: 6,
                onSubmitted: (_) => _verificarSenha(),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _verificarSenha,
                icon: const Icon(Icons.login),
                label: const Text('ENTRAR', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(200, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQGPScreen() {
    final consolidado = _getConsolidadoLocal();
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text('COLETA QGP - PESQUISADOR', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('QGP — OPINIÃO POR CANDIDATO', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.cyanAccent)),
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
                        final sel = _candSelecionadoId == c.id;
                        return GestureDetector(
                          onTap: () => setState(() => _candSelecionadoId = c.id),
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
              controller: _nomeController,
              decoration: const InputDecoration(labelText: 'Nome (Opcional)', border: OutlineInputBorder(), filled: true, fillColor: Color(0xFF1E1E1E)),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _cpfController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'CPF (Opcional)', border: OutlineInputBorder(), filled: true, fillColor: Color(0xFF1E1E1E)),
            ),
            const SizedBox(height: 16),
            // Botões de classificação
            const Text('DECISÃO:', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white70)),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _botaoOpcao('Interessado', Colors.blue, _opcaoSelecionada == 'INTERESSADO', () => setState(() => _opcaoSelecionada = 'INTERESSADO'))),
              const SizedBox(width: 6),
              Expanded(child: _botaoOpcao('Não\nInteressado', Colors.red, _opcaoSelecionada == 'NAO_INTERESSADO', () => setState(() => _opcaoSelecionada = 'NAO_INTERESSADO'))),
              const SizedBox(width: 6),
              Expanded(child: _botaoOpcao('Outros', Colors.grey, _opcaoSelecionada == 'OUTRO', () => setState(() => _opcaoSelecionada = 'OUTRO'))),
            ]),
            const SizedBox(height: 16),
            // Gravar
            Row(children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: (_candSelecionadoId.isEmpty || _opcaoSelecionada.isEmpty) ? null : _gravarOpiniao,
                  icon: const Icon(Icons.save),
                  label: const Text('GRAVAR', style: TextStyle(fontWeight: FontWeight.w900)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF008F39), minimumSize: const Size.fromHeight(50)),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            if (_candSelecionadoId.isNotEmpty) ...[
              const Text('ACUMULADO (SESSÃO):', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 4),
              Row(children: [
                _chipContador('Interessado', _getContagem(_candSelecionadoId, 'INTERESSADO'), Colors.blue),
                const SizedBox(width: 8),
                _chipContador('Não Interessado', _getContagem(_candSelecionadoId, 'NAO_INTERESSADO'), Colors.red),
                const SizedBox(width: 8),
                _chipContador('Outros', _getContagem(_candSelecionadoId, 'OUTRO'), Colors.grey),
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
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Dados locais — não persistidos no banco central.',
                style: TextStyle(fontSize: 11, color: Colors.white38, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
