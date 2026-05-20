import 'package:flutter/material.dart';

class TelaPesquisador extends StatefulWidget {
  const TelaPesquisador({super.key});

  @override
  State<TelaPesquisador> createState() => _TelaPesquisadorState();
}

class _TelaPesquisadorState extends State<TelaPesquisador> {
  // Contadores para a lógica n + 1
  int interessados = 0;
  int naoInteressados = 0;
  int outros = 0;

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();

  // Função para limpar os campos após registrar, mantendo a agilidade
  void _limparCampos() {
    _nomeController.clear();
    _cpfController.clear();
  }

  @override
  Widget build(BuildContext context) {
    int totalSessao = interessados + naoInteressados + outros;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F), // Fundo escuro profissional
      appBar: AppBar(
        title: const Text('COLETA DE CAMPO - QGP', 
          style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("DADOS DO ELEITOR", 
              style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            
            TextField(
              controller: _nomeController,
              decoration: InputDecoration(
                labelText: 'Nome (Opcional)',
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            
            TextField(
              controller: _cpfController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'CPF (Opcional)',
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            
            const SizedBox(height: 35),
            const Center(
              child: Text("REGISTRAR INTENÇÃO", 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white70)),
            ),
            const SizedBox(height: 20),

            // BOTÕES DE PRESSÃO (SOMA n + 1)
            Row(
              children: [
                _botaoRegistro("INTERESSADO", Colors.blue, () {
                  setState(() => interessados++);
                  _limparCampos();
                }),
                const SizedBox(width: 10),
                _botaoRegistro("NÃO QUER", Colors.red, () {
                  setState(() => naoInteressados++);
                  _limparCampos();
                }),
                const SizedBox(width: 10),
                _botaoRegistro("OUTROS", Colors.grey, () {
                  setState(() => outros++);
                  _limparCampos();
                }),
              ],
            ),

            const SizedBox(height: 45),
            const Text("EVOLUÇÃO DA COLETA (ATUAL)", 
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
            const Divider(color: Colors.white10, height: 30),

            // GRÁFICO DE BARRAS HORIZONTAIS
            _barraProgresso("Interessados", interessados, Colors.blue),
            _barraProgresso("Não Interessados", naoInteressados, Colors.red),
            _barraProgresso("Outros", outros, Colors.grey),
            
            const SizedBox(height: 30),
            Center(
              child: Text("TOTAL COLETADO: $totalSessao", 
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.blueAccent)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _botaoRegistro(String rotulo, Color cor, VoidCallback acao) {
    return Expanded(
      child: InkWell(
        onTap: acao,
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: cor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: cor.withOpacity(0.5), width: 2),
          ),
          child: Center(
            child: Text(rotulo, 
              textAlign: TextAlign.center,
              style: TextStyle(color: cor, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ),
      ),
    );
  }

  Widget _barraProgresso(String titulo, int valor, Color cor) {
    // Cálculo da largura proporcional para a barra não "estourar" a tela
    double larguraBase = MediaQuery.of(context).size.width * 0.5;
    double fatorCrescimento = (valor * 15.0).clamp(5.0, larguraBase);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(width: 110, child: Text(titulo, style: const TextStyle(fontSize: 13))),
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            height: 22,
            width: fatorCrescimento,
            decoration: BoxDecoration(
              color: cor,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [BoxShadow(color: cor.withOpacity(0.3), blurRadius: 8)],
            ),
          ),
          const SizedBox(width: 12),
          Text(valor.toString(), 
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}