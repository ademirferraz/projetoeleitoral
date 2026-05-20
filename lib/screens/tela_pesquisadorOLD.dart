import 'package:flutter/material.dart';

// =========================
// TELA PESQUISADOR
// =========================
class TelaPesquisador extends StatelessWidget {
  const TelaPesquisador({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pesquisador')),
      body: const Center(child: Text('PESQUISA')),
    );
  }
}