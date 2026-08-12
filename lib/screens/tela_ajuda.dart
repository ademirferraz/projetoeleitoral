import 'package:flutter/material.dart';

class TelaAjuda extends StatelessWidget {
  const TelaAjuda({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Guia de Uso"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section("Nota de Responsabilidade",
              "Este aplicativo atua em conformidade com as diretrizes do TSE. "
              "O uso e a gestão dos dados são de responsabilidade exclusiva do adquirente, "
              "devendo este respeitar rigorosamente a LGPD.",
              Icons.shield, Colors.orange),
          _section("Passo 1: Acesso Inicial",
              "Ao abrir o app, você verá três opções:\n"
              "• Administrador: Painel de controle e gestão do sistema. No primeiro acesso, você define a senha do administrador.\n"
              "• Pesquisador: Coleta de opiniões em campo.\n"
              "• Cadastre-se: Registro de eleitores para votação.",
              Icons.login, Colors.blue),
          _section("Passo 2: Configuração do Cenário (Filtro)",
              "Antes de cadastrar candidatos, defina a região de atuação:\n"
              "• Estado: Selecione a UF desejada.\n"
              "• Cidade: Digite para campanhas municipais (deixe em branco para âmbito estadual).\n"
              "• Relatórios: Só exibem dados após coleta de votos ou pesquisas.",
              Icons.filter_alt, Colors.teal),
          _section("Passo 3: Cadastro de Candidatos",
              "O sistema usa leitura inteligente do nome do arquivo da foto.\n"
              "• Formato: Nome_Numero_Sigla_Cargo.png\n"
              "  Ex: Ademir_12345_PPPP_Deputado.png\n"
              "• Clique em Adicionar Candidatos, selecione as fotos e cadastre.\n"
              "• Limite: até 6 candidatos por cargo.",
              Icons.person_add, Colors.green),
          _section("Passo 4: Pesquisa de Campo (QGP)",
              "Ferramenta para o Pesquisador de Campo:\n"
              "• Campos de Nome e CPF (opcionais, respeitando privacidade).\n"
              "• Clique na foto do candidato → Interessado / Não Interessado / Outros → Gravar.\n"
              "• Salvar Relatório gera um documento com o termômetro de aceitação.",
              Icons.assessment, Colors.purple),
          _section("Passo 5: Simulações e Testes",
              "Área exclusiva do Admin:\n"
              "• Injeção de votos aleatórios ou manuais.\n"
              "• Resultados em gráficos imediatos.\n"
              "• Botão Limpar Tudo: apaga todos os dados permanentemente!",
              Icons.science, Colors.red),
          _section("Passo 6: Fluxo do Eleitor",
              "Regras eleitorais aplicadas automaticamente:\n"
              "• Não pode votar em dois prefeitos.\n"
              "• Não pode votar em candidatos de outros estados (exceto presidente).\n"
              "• Menores de 16 anos não votam.\n"
              "• Mesma pessoa não vota duas vezes.\n"
              "• Não pode votar em dois estaduais nem dois federais.",
              Icons.how_to_vote, Colors.amber),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              "Professor Dr. Ademir Ferraz\n"
              "Mestrado e doutorado em Matemática\n"
              "Pós-doutorado em Ensino de Matemática a Distância\n"
              "Especialista em Estatística e Computação",
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, String content, IconData icon, Color color) {
    return Card(
      color: Colors.grey.shade900,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(title,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(content,
                style: const TextStyle(fontSize: 13, color: Colors.white70),
                textAlign: TextAlign.start),
          ],
        ),
      ),
    );
  }
}
