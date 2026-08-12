import 'package:flutter/material.dart';
import 'package:projetoeleitoral/services/admin_auth_service.dart';

class TelaRecuperarSenha extends StatefulWidget {
  const TelaRecuperarSenha({super.key});

  @override
  State<TelaRecuperarSenha> createState() => _TelaRecuperarSenhaState();
}

class _TelaRecuperarSenhaState extends State<TelaRecuperarSenha> {
  final _respostaController = TextEditingController();
  final _novaSenhaController = TextEditingController();
  final _confirmarController = TextEditingController();
  String? _pergunta;
  bool _carregando = true;
  bool _respostaOk = false;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final pergunta = await AdminAuthService.getPergunta();
    if (mounted) {
      setState(() {
        _pergunta = pergunta;
        _carregando = false;
      });
    }
  }

  @override
  void dispose() {
    _respostaController.dispose();
    _novaSenhaController.dispose();
    _confirmarController.dispose();
    super.dispose();
  }

  Future<void> _verificarResposta() async {
    final ok = await AdminAuthService.validarResposta(_respostaController.text);
    if (!mounted) return;
    if (ok) {
      setState(() => _respostaOk = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Resposta incorreta')));
    }
  }

  Future<void> _salvarNovaSenha() async {
    final nova = _novaSenhaController.text;
    final confirmar = _confirmarController.text;
    if (nova.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Digite a nova senha.')));
      return;
    }
    if (nova != confirmar) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('As senhas não coincidem.')));
      return;
    }
    await AdminAuthService.setSenha(nova);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Senha alterada com sucesso!'), backgroundColor: Colors.green),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RECUPERAR SENHA', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.amber[700],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  const Text('Responda a pergunta de segurança para redefinir a senha do administrador.',
                      style: TextStyle(fontSize: 14, color: Colors.white70)),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.shade700),
                    ),
                    child: Text(
                      _pergunta ?? 'Nenhuma pergunta de segurança configurada.',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _respostaController,
                    decoration: const InputDecoration(labelText: 'Resposta', border: OutlineInputBorder()),
                    onSubmitted: (_) => _verificarResposta(),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _verificarResposta,
                    icon: const Icon(Icons.verified_user),
                    label: const Text('VERIFICAR RESPOSTA', style: TextStyle(fontWeight: FontWeight.w900)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black, minimumSize: const Size.fromHeight(50)),
                  ),
                  if (_respostaOk) ...[
                    const SizedBox(height: 24),
                    const Text('Resposta correta! Defina a nova senha:',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.greenAccent)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _novaSenhaController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Nova senha', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _confirmarController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Confirmar nova senha', border: OutlineInputBorder()),
                      onSubmitted: (_) => _salvarNovaSenha(),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _salvarNovaSenha,
                      icon: const Icon(Icons.lock),
                      label: const Text('SALVAR NOVA SENHA', style: TextStyle(fontWeight: FontWeight.w900)),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF008F39), minimumSize: const Size.fromHeight(50)),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
