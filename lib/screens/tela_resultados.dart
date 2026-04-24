import 'package:flutter/material.dart';

// =========================
// TELA RESULTADOS
// =========================
class TelaResultados extends StatelessWidget {
  const TelaResultados({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultados'),
        backgroundColor: const Color(0xFF0D47A1),
      ),
      body: const Center(child: Text('GRÁFICOS')),
    );
  }
}