import 'package:flutter/material.dart';

// =========================
// TELA QGP
// =========================
class TelaQGP extends StatelessWidget {
  const TelaQGP({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QGP'),
        backgroundColor: const Color(0xFF8A2BE2),
      ),
      body: const Center(child: Text('QGP GRÁFICOS')),
    );
  }
}