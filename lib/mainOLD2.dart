import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'services/services.dart';

void main() {
  runApp(const EleicaoFluxoApp());
}

class EleicaoFluxoApp extends StatelessWidget {
  const EleicaoFluxoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EleicaoFluxo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      // Agora a HOME é a tela principal, não o painel direto
      home: const HomePage(), 
    );
  }
}

// --- TELA INICIAL (BASEADA NO VISUAL DO LUMI) ---
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    const TextStyle styleBtn = TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Sistema de Votação", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            
            // Botão que leva ao Admin (Onde está o cadastro por foto)
            _botaoMenu(context, "Acesso Administrativo", Colors.purple, const AdminPanel()),
            
            const SizedBox(height: 20),
            
            // Botão do Tutorial (Objeto de Aprendizagem)
            ElevatedButton(
              onPressed: () { /* Aqui abriria o tutorial */ },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey, minimumSize: const Size(300, 60)),
              child: const Text("💡 Tutorial de Uso", style: styleBtn),
            ),
          ],
        ),
      ),
    );
  }

  Widget _botaoMenu(BuildContext context, String texto, Color cor, Widget destino) {
    return ElevatedButton(
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => destino)),
      style: ElevatedButton.styleFrom(backgroundColor: cor, minimumSize: const Size(300, 60)),
      child: Text(texto, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }
}

// --- PAINEL ADMINISTRATIVO (COM A SETA DE VOLTAR AUTOMÁTICA) ---
class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController numeroController = TextEditingController();
  final TextEditingController siglaController = TextEditingController();

  Future<void> _cadastrarPorFoto() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      String fileName = result.files.single.name;
      List<String> partes = fileName.split('_');
      if (partes.length >= 3) {
        setState(() {
          nomeController.text = partes[0];
          numeroController.text = partes[1];
          siglaController.text = partes[2].split('.').first;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Painel Administrativo", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E1E1E),
        // A seta de voltar aparece sozinha porque usamos Navigator.push
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _cadastrarPorFoto,
              icon: const Icon(Icons.camera_alt),
              label: const Text("CADASTRAR POR FOTO", style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: const Size(double.infinity, 50)),
            ),
            const SizedBox(height: 20),
            TextField(controller: nomeController, decoration: const InputDecoration(labelText: "Nome")),
            TextField(controller: numeroController, decoration: const InputDecoration(labelText: "Número")),
            TextField(controller: siglaController, decoration: const InputDecoration(labelText: "Partido")),
          ],
        ),
      ),
    );
  }
}import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart'; // Para seus gráficos de análise
import 'package:file_picker/file_picker.dart';
import 'services/services.dart'; // Sua conexão com o banco de dados

// Sua função de log para monitorar o comportamento no terminal
void logDebug(String msg) => debugPrint('[DEBUG] $msg');

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EleicaoFluxoApp());
}

class EleicaoFluxoApp extends StatelessWidget {
  const EleicaoFluxoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EleicaoFluxo - QGP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFF1E1E1E),
      ),
      home: const AdminPanel(),
    );
  }
}

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  // Controllers para capturar os dados da foto
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController numeroController = TextEditingController();
  final TextEditingController siglaController = TextEditingController();

  // Função Universal para Cadastro via Foto (Funciona em qualquer PC ou Celular)
  Future<void> _cadastrarPorFoto() async {
    try {
      logDebug("Abrindo seletor de arquivos...");
      
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null) {
        // Captura apenas o nome do arquivo, ignorando o caminho (path) local
        String fileName = result.files.single.name;
        logDebug("Arquivo detectado: $fileName");
        
        // Lógica Ademir: Divisão por sublinhado (_)
        List<String> partes = fileName.split('_');

        if (partes.length >= 3) {
          setState(() {
            nomeController.text = partes[0]; // Nome
            numeroController.text = partes[1]; // Número
            // Pega a sigla e remove a extensão (.jpg, .png, etc)
            siglaController.text = partes[2].split('.').first;
          });
          logDebug("Dados extraídos com sucesso: ${nomeController.text}");
        } else {
          _mostrarMensagem("Erro: O nome da foto deve ser 'Nome_Numero_Sigla'");
        }
      }
    } catch (e) {
      logDebug("Erro crítico no FilePicker: $e");
      _mostrarMensagem("Erro ao abrir seletor de fotos.");
    }
  }

  void _mostrarMensagem(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Definição do Estilo Branco Bold para Agilidade Visual
    const TextStyle estiloBrancoBold = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('PAINEL ADMINISTRATIVO - QGP', style: estiloBrancoBold),
        centerTitle: true,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ÁREA DE IMPORTAÇÃO
            const Text("CADASTRO AUTOMATIZADO", style: estiloBrancoBold),
            const SizedBox(height: 15),
            
            ElevatedButton.icon(
              onPressed: _cadastrarPorFoto,
              icon: const Icon(Icons.add_a_photo, color: Colors.white),
              label: const Text('SELECIONAR FOTO (EXPLORE/GALERIA)', style: estiloBrancoBold),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF008F39), // Verde Sucesso
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            
            const SizedBox(height: 30),
            const Divider(color: Colors.white24),
            const SizedBox(height: 20),

            // FORMULÁRIO PREENCHIDO PELA IA DA FOTO
            _campoEstilizado("Nome do Candidato", nomeController, estiloBrancoBold),
            _campoEstilizado("Número do Candidato", numeroController, estiloBrancoBold),
            _campoEstilizado("Sigla do Partido", siglaController, estiloBrancoBold),

            const SizedBox(height: 30),

            // BOTÃO DE SALVAMENTO NO BANCO (Usa seus Services)
            ElevatedButton(
              onPressed: () {
                logDebug("Iniciando persistência no banco de dados...");
                // Aqui o senhor chamará suas funções do arquivo services.dart
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent[700],
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
              child: const Text('CONFIRMAR E SALVAR CANDIDATO', style: estiloBrancoBold),
            ),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para manter o padrão visual em todos os campos
  Widget _campoEstilizado(String label, TextEditingController controller, TextStyle style) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white, fontSize: 18),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: style,
          filled: true,
          fillColor: const Color(0xFF1E1E1E),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white12)),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        ),
      ),
    );
  }
}