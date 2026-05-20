import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/disclaimer.dart';
import 'package:projetoeleitoral/services/services.dart';
import 'tela_login.dart';

class Tela2Votacao extends StatefulWidget {
  final Eleitor eleitor;
  const Tela2Votacao({super.key, required this.eleitor});

  @override
  State<Tela2Votacao> createState() => _Tela2VotacaoState();
}

class _Tela2VotacaoState extends State<Tela2Votacao> {
  final Set<String> _selectedCands = {};
  List<Candidato> _cands = [];
  bool _votando = false;
  bool _votou = false;

  @override
  void initState() {
    super.initState();
    _cands = DatabaseService.getCandidatos();
  }

  @override
  Widget build(BuildContext context) {
    final hash = DatabaseService.hashCpf(widget.eleitor.cpf);
    final jaVotou = DatabaseService.jaVotou(hash);
    return Scaffold(
      appBar: AppBar(
        title: Text(_votou ? 'VOTO CONFIRMADO' : 'VOTAÇÃO  |  ${_selectedCands.length}/6', style: const TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: const Color(0xFF008F39),
        foregroundColor: Colors.white,
      ),
      body: _votou ? _buildResultado() : _buildVotacao(jaVotou),
    );
  }

  Widget _buildVotacao(bool jaVotou) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Disclaimer(),
          const SizedBox(height: 16),
          Text('Eleitor: ${widget.eleitor.nome}', style: const TextStyle(fontWeight: FontWeight.w900)),
          Text('Cidade: ${widget.eleitor.cidade ?? '—'} | Bairro: ${widget.eleitor.bairro}', style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: _selectedCands.length == 6 ? Colors.green.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _selectedCands.length == 6 ? Colors.green : Colors.grey, width: 1),
              ),
              child: Text(
                '${_selectedCands.length}/6 candidatos selecionados',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: _selectedCands.length == 6 ? Colors.green : Colors.white70,
                ),
              ),
            ),
          ),
          if (_cands.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Nenhum candidato cadastrado.', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: _cands.length,
              itemBuilder: (ctx, i) {
                final c = _cands[i];
                final isSelected = _selectedCands.contains(c.id);
                return Card(
                  color: isSelected ? Colors.green.withOpacity(0.1) : null,
                  child: CheckboxListTile(
                    value: isSelected,
                    onChanged: jaVotou ? null : (v) => _toggleCandidato(c.id),
                    secondary: _buildFoto(c.fotoPath),
                    title: Text('${c.nome} - ${c.partido}', style: const TextStyle(fontWeight: FontWeight.w900)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Número: ${c.numero}', style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white70)),
                        if (c.estado != null || c.cidade != null)
                          Text('${c.cidade ?? ''}${c.cidade != null && c.estado != null ? '/' : ''}${c.estado ?? ''}', style: const TextStyle(fontSize: 12, color: Colors.white54)),
                      ],
                    ),
                    activeColor: Colors.green,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _selectedCands.isEmpty || jaVotou || _votando ? null : _votar,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF008F39),
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
            ),
            child: Text(
              'CONFIRMAR ${_selectedCands.length} VOTO(S)',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultado() {
    final todos = DatabaseService.getCandidatos();
    final totalVotos = todos.fold<int>(0, (s, e) => s + e.votos);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 64),
          const SizedBox(height: 12),
          const Text('VOTO CONFIRMADO!', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22)),
          const SizedBox(height: 20),
          const Text('RESULTADO PARCIAL DA VOTAÇÃO', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.blueGrey, fontSize: 13)),
          const Divider(color: Colors.white10),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (todos.isEmpty)
                    const Padding(padding: EdgeInsets.all(8), child: Text('Nenhum candidato.', style: TextStyle(color: Colors.white54)))
                  else
                    ...todos.map((c) {
                      final pct = totalVotos > 0 ? (c.votos / totalVotos * 100) : 0.0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            SizedBox(width: 100, child: Text(c.nome, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900), overflow: TextOverflow.ellipsis)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Container(
                                height: 18,
                                decoration: BoxDecoration(color: Colors.grey.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: pct > 0 ? (pct / 100).clamp(0.01, 1.0) : 0.0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text('${pct.toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.amber)),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const TelaLogin()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF008F39), foregroundColor: Colors.white, minimumSize: const Size.fromHeight(50)),
            child: const Text('VOLTAR AO INÍCIO', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          ),
        ],
      ),
    );
  }

  Widget? _buildFoto(String? fotoPath) {
    if (fotoPath == null) return const Icon(Icons.person, size: 50, color: Color(0xFF8A2BE2));
    try {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.memory(base64Decode(fotoPath), width: 50, height: 50, fit: BoxFit.cover),
      );
    } catch (_) {
      return const Icon(Icons.person, size: 50, color: Color(0xFF8A2BE2));
    }
  }

  void _toggleCandidato(String id) {
    final cand = _cands.firstWhere((c) => c.id == id, orElse: () => _cands.isEmpty ? Candidato(id: '', nome: '', numero: 0, partido: '', sigla: '') : _cands.first);
    if (cand.id.isEmpty) return;

    if (_selectedCands.contains(id)) {
      setState(() => _selectedCands.remove(id));
      return;
    }

    final selecionados = _cands.where((c) => _selectedCands.contains(c.id)).toList();
    final cargosSelecionados = selecionados.map((c) => c.cargo).whereType<String>().toSet();
    final erro = ValidadorService.validarVoto(cand, cargosSelecionados, widget.eleitor);
    if (erro != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(erro), backgroundColor: Colors.red, duration: const Duration(seconds: 3)));
      return;
    }

    setState(() {
      if (_selectedCands.length < 6) {
        _selectedCands.add(id);
      }
    });
  }

  void _votar() async {
    if (_votando) return;
    _votando = true;
    try {
      final hash = DatabaseService.hashCpf(widget.eleitor.cpf);
      if (DatabaseService.jaVotou(hash)) {
        _votando = false;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Você já votou!'), backgroundColor: Colors.red, duration: Duration(seconds: 3)));
        }
        return;
      }

      final selectedNames = _cands.where((c) => _selectedCands.contains(c.id)).toList();
      if (selectedNames.isEmpty) {
        _votando = false;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecione ao menos um candidato.'), backgroundColor: Colors.red, duration: Duration(seconds: 3)));
        }
        return;
      }

      final erro = ValidadorService.validarCargosSelecionados(selectedNames.toSet(), widget.eleitor);
      if (erro != null) {
        _votando = false;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(erro), backgroundColor: Colors.red, duration: const Duration(seconds: 4)));
        }
        return;
      }

      for (final cand in selectedNames) {
        await DatabaseService.saveVoto(Voto(
          idEleitor: widget.eleitor.id,
          idCandidato: cand.id,
          tipoVoto: cand.cargo ?? '',
          dataVoto: DateTime.now(),
        ));
      }

      DatabaseService.setEleitorVotou(hash);

      if (mounted) {
        try { HapticFeedback.heavyImpact(); } catch (_) {}
        _selectedCands.clear();
        setState(() { _votou = true; });
      }
      _votando = false;
    } catch (e) {
      _votando = false;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao registrar voto: $e'), backgroundColor: Colors.red, duration: const Duration(seconds: 5)));
      }
    }
  }
}
