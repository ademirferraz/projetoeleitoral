import 'package:flutter/material.dart';

// =========================
// TELA VOTAÇÃO
// =========================
class Tela2Votacao extends StatelessWidget {
  const Tela2Votacao({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Votação')),
      body: const Center(child: Text('URNA ELETRÔNICA')),
    );
  }
}