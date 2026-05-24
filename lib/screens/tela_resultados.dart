import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/disclaimer.dart';
import 'package:projetoeleitoral/services/services.dart';

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
    final todos = DatabaseService.getCandidatos();
    final filtrados = _filtrar(todos);
    final totalVotos = filtrados.fold<int>(0, (s, e) => s + e.votos);
    return Scaffold(
      appBar: AppBar(
        title: const Text('RESULTADOS DA PESQUISA', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Disclaimer(),
            const SizedBox(height: 10),
            if (widget.estado != null) Text('Estado: ${widget.estado}', style: const TextStyle(fontWeight: FontWeight.w900)),
            if (widget.city.isNotEmpty) Text('Cidade: ${widget.city}', style: const TextStyle(fontWeight: FontWeight.w900)),
            Text('Total de Votos: $totalVotos', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 20),
            Expanded(
              child: filtrados.isEmpty
                  ? const Center(child: Text('Nenhum dado disponível para o filtro selecionado.', style: TextStyle(fontWeight: FontWeight.w900)))
                  : BarChart(BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: totalVotos > 0 ? filtrados.map((x) => x.votos.toDouble()).reduce((a, b) => a > b ? a : b) * 1.2 : 10,
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, m) {
                              final i = v.toInt();
                              if (i >= 0 && i < filtrados.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(filtrados[i].nome, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                      ),
                      barGroups: filtrados.asMap().entries.map((e) => BarChartGroupData(
                        x: e.key,
                        barRods: [BarChartRodData(toY: e.value.votos.toDouble(), color: const Color(0xFF0D47A1), width: 25, borderRadius: const BorderRadius.vertical(top: Radius.circular(5)))],
                      )).toList(),
                    )),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: filtrados.length,
                itemBuilder: (ctx, i) {
                  final x = filtrados[i];
                  final p = totalVotos > 0 ? (x.votos / totalVotos * 100) : 0.0;
                  return ListTile(
                    title: Text('${x.nome} (${x.numero})', style: const TextStyle(fontWeight: FontWeight.w900)),
                    subtitle: LinearProgressIndicator(value: p / 100, color: const Color(0xFF0D47A1), minHeight: 8),
                    trailing: Text('${p.toStringAsFixed(1)}% (${x.votos})', style: const TextStyle(fontWeight: FontWeight.w900)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Candidato> _filtrar(List<Candidato> todos) {
    final estado = widget.estado?.trim().toLowerCase();
    final cidade = widget.city.trim().toLowerCase();
    if ((estado == null || estado.isEmpty) && cidade.isEmpty) return todos;
    return todos.where((c) {
      if (c.cargo == 'Presidente') return true;
      if (cidade.isNotEmpty && c.cargo == 'Prefeito') {
        return c.cidade?.toLowerCase() == cidade;
      }
      if (estado != null && estado.isNotEmpty && (c.cargo == 'Senador' || c.cargo == 'Deputado Federal' || c.cargo == 'Deputado Estadual')) {
        return c.estado?.toLowerCase() == estado;
      }
      if (cidade.isNotEmpty && c.cargo == 'Prefeito') {
        return c.cidade?.toLowerCase() == cidade;
      }
      return true;
    }).toList();
  }
}
