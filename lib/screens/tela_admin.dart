import 'package:flutter/material.dart';

// =========================
// TELA ADMIN
// =========================
class TelaAdmin extends StatelessWidget {
  const TelaAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin'),
        backgroundColor: Colors.amber,
      ),
      body: const Center(child: Text('PAINEL ADMIN')),
    );
  }
}