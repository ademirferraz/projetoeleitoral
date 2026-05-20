import 'package:flutter/material.dart';
import 'tela_cadastro.dart';
import 'tela_admin.dart';
import 'tela_pesquisador.dart';

class TelaLogin extends StatelessWidget {
  const TelaLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.purpleAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.how_to_vote, size: 120, color: Colors.white),
            const SizedBox(height: 20),
            const Text(
              "Sistema de Pesquisa Eleitoral",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              "Enquete simulada para fins educativos",
              style: TextStyle(fontSize: 18, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  Card(
                    color: Colors.white,
                    elevation: 6,
                    child: InkWell(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Tela1Cadastro())),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(25),
                        child: const Row(
                          children: [
                            Icon(Icons.person, color: Colors.deepPurple, size: 30),
                            SizedBox(width: 20),
                            Text("Eleitor", style: TextStyle(fontSize: 24, color: Colors.black87, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    color: Colors.white,
                    elevation: 6,
                    child: InkWell(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TelaAdminLogin())),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(25),
                        child: const Row(
                          children: [
                            Icon(Icons.admin_panel_settings, color: Colors.deepPurple, size: 30),
                            SizedBox(width: 20),
                            Text("Admin", style: TextStyle(fontSize: 24, color: Colors.black87, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    color: Colors.white,
                    elevation: 6,
                    child: InkWell(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TelaPesquisador())),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(25),
                        child: const Row(
                          children: [
                            Icon(Icons.search, color: Colors.deepPurple, size: 30),
                            SizedBox(width: 20),
                            Text("Pesquisador", style: TextStyle(fontSize: 24, color: Colors.black87, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
