import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/disclaimer.dart';
import 'package:projetoeleitoral/services/services.dart';
import 'tela_votacao.dart';

class Tela1Cadastro extends StatefulWidget {
  const Tela1Cadastro({super.key});

  @override
  State<Tela1Cadastro> createState() => _Tela1CadastroState();
}

class _Tela1CadastroState extends State<Tela1Cadastro> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cpfController = TextEditingController();
  final _dataController = TextEditingController();
  final _bairroController = TextEditingController();
  final _cidadeController = TextEditingController();
  String? _estado;

  static const _estados = [
    'AC','AL','AP','AM','BA','CE','DF','ES','GO','MA','MT','MS','MG',
    'PA','PB','PR','PE','PI','RJ','RN','RS','RO','RR','SC','SP','SE','TO'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _cpfController.dispose();
    _dataController.dispose();
    _bairroController.dispose();
    _cidadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CADASTRO DE ELEITOR', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: const Color(0xFF008F39),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Disclaimer(),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome Completo',
                  labelStyle: TextStyle(fontWeight: FontWeight.w900),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Nome obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cpfController,
                decoration: const InputDecoration(
                  labelText: 'CPF',
                  labelStyle: TextStyle(fontWeight: FontWeight.w900),
                  border: OutlineInputBorder(),
                  hintText: '000.000.000-00',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, _CpfMask()],
                maxLength: 14,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'CPF obrigatório';
                  final cpf = v.replaceAll(RegExp(r'[^0-9]'), '');
                  if (cpf.length != 11) return 'CPF inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dataController,
                decoration: const InputDecoration(
                  labelText: 'Data de Nascimento',
                  labelStyle: TextStyle(fontWeight: FontWeight.w900),
                  border: OutlineInputBorder(),
                  hintText: 'DD/MM/AAAA',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, _DataMask()],
                maxLength: 10,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Data obrigatória';
                  if (v.length != 10) return 'Data inválida';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bairroController,
                decoration: const InputDecoration(
                  labelText: 'Bairro onde mora',
                  labelStyle: TextStyle(fontWeight: FontWeight.w900),
                  border: OutlineInputBorder(),
                ),
              validator: (v) => v?.isEmpty ?? true ? 'Bairro obrigatório' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cidadeController,
              decoration: const InputDecoration(
                labelText: 'Cidade',
                labelStyle: TextStyle(fontWeight: FontWeight.w900),
                border: OutlineInputBorder(),
              ),
              validator: (v) => v?.isEmpty ?? true ? 'Cidade obrigatória' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _estado,
              decoration: const InputDecoration(
                labelText: 'Estado',
                labelStyle: TextStyle(fontWeight: FontWeight.w900),
                border: OutlineInputBorder(),
              ),
              items: _estados.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontWeight: FontWeight.w900)))).toList(),
              onChanged: (v) => setState(() => _estado = v),
              validator: (v) => v == null ? 'Estado obrigatório' : null,
            ),
            const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _cadastrar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF008F39),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text('CADASTRAR E VOTAR', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _cadastrar() async {
    if (!_formKey.currentState!.validate()) return;
    final cleanedCpf = _cpfController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final cpfHash = DatabaseService.hashCpf(cleanedCpf);
    if (DatabaseService.cpfRegistrado(cpfHash)) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('CPF já registrado'),
          content: const Text('Um eleitor com este CPF já está cadastrado.'),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
        ),
      );
      return;
    }
    final parts = _dataController.text.split('/');
    final data = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
    final idade = ValidadorService.calcularIdade(data);
    if (idade < 16) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Acesso Negado'),
          content: const Text('Idade mínima: 16 anos'),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
        ),
      );
      return;
    }
    final eleitor = Eleitor(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nome: _nameController.text,
      cpf: cleanedCpf,
      dataNascimento: data,
      bairro: _bairroController.text,
      cidade: _cidadeController.text,
      estado: _estado,
    );
    final saved = await DatabaseService.saveEleitor(eleitor);
    if (!saved) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('CPF já cadastrado!'), backgroundColor: Colors.red, duration: Duration(seconds: 3)));
      }
      return;
    }
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Tela2Votacao(eleitor: eleitor)));
  }
}

class _CpfMask extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue o, TextEditingValue n) {
    var t = n.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (t.length > 11) t = t.substring(0, 11);
    var r = '';
    for (int i = 0; i < t.length; i++) {
      if (i == 3 || i == 6) r += '.';
      if (i == 9) r += '-';
      r += t[i];
    }
    return TextEditingValue(text: r, selection: TextSelection.collapsed(offset: r.length));
  }
}

class _DataMask extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue o, TextEditingValue n) {
    var t = n.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (t.length > 8) t = t.substring(0, 8);
    var r = '';
    for (int i = 0; i < t.length; i++) {
      if (i == 2 || i == 4) r += '/';
      r += t[i];
    }
    return TextEditingValue(text: r, selection: TextSelection.collapsed(offset: r.length));
  }
}
