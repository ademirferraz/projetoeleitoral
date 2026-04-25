import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:file_picker/file_picker.dart';
import 'services/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Consulta Especializada',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Builder(
        builder: (ctx) => Scaffold(
          appBar: AppBar(
            title: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const Tela1Cadastro())),
                    child: const Text(
                      'Cadastro',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const TelaResultados(estado: null, cidade: ''))),
                    child: const Text(
                      'Resultados',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const TelaQGPLogin())),
                    child: const Text(
                      'QGP',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const TelaAdmin())),
                    child: const Text(
                      'Gestão',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: const TelaLogin(),
        ),
      ),
    );
  }
}

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  String _tipoUsuario = 'eleitor';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sistema de Pesquisa')),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: SafeArea(
          child: SingleChildScrollView( // 🔥 CORREÇÃO AQUI
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.how_to_vote, size: 80),
                const SizedBox(height: 20),
                const Text(
                  'Sistema de Pesquisa Eleitoral',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),

                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'eleitor', label: Text('Eleitor')),
                    ButtonSegment(value: 'admin', label: Text('Admin')),
                    ButtonSegment(value: 'pesquisador', label: Text('Pesquisador')),
                  ],
                  selected: {_tipoUsuario},
                  onSelectionChanged: (s) => setState(() => _tipoUsuario = s.first),
                ),

                const SizedBox(height: 30),

                if (_tipoUsuario == 'eleitor')
                  ElevatedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Tela1Cadastro())),
                    child: const Text('Entrar como Eleitor'),
                  ),

                if (_tipoUsuario == 'admin')
                  ElevatedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TelaAdminLogin())),
                    child: const Text('Entrar como Admin'),
                  ),

                if (_tipoUsuario == 'pesquisador')
                  ElevatedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TelaPesquisadorLogin())),
                    child: const Text('Entrar como Pesquisador'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Tela1Cadastro extends StatelessWidget {
  const Tela1Cadastro({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro')),
      body: const Center(child: Text('Tela Cadastro OK')),
    );
  }
}

class TelaAdminLogin extends StatelessWidget {
  const TelaAdminLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin')),
      body: const Center(child: Text('Login Admin')),
    );
  }
}

class TelaPesquisadorLogin extends StatelessWidget {
  const TelaPesquisadorLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pesquisador')),
      body: const Center(child: Text('Login Pesquisador')),
    );
  }
}

class TelaAdmin extends StatelessWidget {
  const TelaAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin')),
      body: const Center(child: Text('Painel Admin')),
    );
  }
}

class TelaResultados extends StatelessWidget {
  final String? estado;
  final String cidade;

  const TelaResultados({super.key, this.estado, required this.cidade});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resultados')),
      body: const Center(child: Text('Resultados OK')),
    );
  }
}

class TelaQGPLogin extends StatelessWidget {
  const TelaQGPLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QGP')),
      body: const Center(child: Text('Login QGP')),
    );
  }
}