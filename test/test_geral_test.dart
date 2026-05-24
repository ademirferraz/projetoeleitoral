import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

class Resultado {
  final String cargo;
  final String candidato;
  final int percentual;
  Resultado(this.cargo, this.candidato, this.percentual);
}

// Função para gerar HTML com tabela + gráfico
String gerarRelatorioHTML(List<Resultado> resultados) {
  final rows = resultados.map((r) =>
    "<tr><td>${r.cargo}</td><td>${r.candidato}</td><td>${r.percentual}%</td></tr>"
  ).join();

  final labels = resultados.map((r) => "'${r.candidato}'").join(",");
  final data = resultados.map((r) => "${r.percentual}").join(",");

  return """
  <html>
    <head>
      <title>Relatório Geral</title>
      <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    </head>
    <body>
      <h1>Relatório Geral de Votos</h1>
      <table border="1" cellpadding="10">
        <tr><th>Cargo</th><th>Candidato</th><th>Percentual</th></tr>
        $rows
      </table>

      <canvas id="grafico" width="600" height="300"></canvas>
      <script>
        var ctx = document.getElementById('grafico').getContext('2d');
        var chart = new Chart(ctx, {
          type: 'bar',
          data: {
            labels: [$labels],
            datasets: [{
              label: 'Percentuais (%)',
              data: [$data],
              backgroundColor: ['blue','green','red','orange','purple','gray']
            }]
          }
        });
      </script>
    </body>
  </html>
  """;
}

void salvarRelatorio(String html) async {
  final dir = Directory("C:/RELATORIO");
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }
  final file = File("${dir.path}/relatorio_geral.html");
  await file.writeAsString(html);
}

void main() {
  test('Geração de relatório geral com percentuais', () async {
    final resultados = [
      Resultado("Prefeito", "Capitão Boanerges", 14),
      Resultado("Prefeito", "Daniel Godoy", 20),
      Resultado("Deputado Estadual", "Danilo Godoy", 30),
      Resultado("Senador", "Mendonça Filho", 10),
      Resultado("Presidente", "Flávio Bolsonaro", 30),
      Resultado("Presidente", "Luiz Inácio", 20),
    ];

    final html = gerarRelatorioHTML(resultados);
    salvarRelatorio(html);

    // Verificação simples: HTML contém nomes e símbolo %
    expect(html.contains("Capitão Boanerges"), true);
    expect(html.contains("Daniel Godoy"), true);
    expect(html.contains("%"), true);
  });
}
