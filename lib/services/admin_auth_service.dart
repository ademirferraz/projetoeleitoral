import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminAuthService {
  static const String _senhaKey = 'admin_senha_hash';
  static const String _perguntaKey = 'admin_pergunta';
  static const String _respostaHashKey = 'admin_resposta_hash';
  static const String _salt = 'eleitoral_salt_v1';

  static const String opcaoPersonalizada = '__custom__';

  static const List<String> perguntasPadrao = [
    'Nome da sua primeira escola?',
    'Cidade onde nasceu?',
    'Nome do seu candidato favorito?',
    'Nome do seu primeiro animal de estimação?',
  ];

  static Future<bool> hasSenha() async {
    final prefs = await SharedPreferences.getInstance();
    final hash = prefs.getString(_senhaKey);
    return hash != null && hash.isNotEmpty;
  }

  static Future<void> setSenha(String senha) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_senhaKey, _hash(senha));
  }

  static Future<bool> validarSenha(String senha) async {
    final prefs = await SharedPreferences.getInstance();
    final hash = prefs.getString(_senhaKey);
    if (hash == null || hash.isEmpty) return false;
    return hash == _hash(senha);
  }

  static Future<void> setPerguntaSeguranca(String pergunta, String resposta) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_perguntaKey, pergunta);
    await prefs.setString(_respostaHashKey, _hash(resposta));
  }

  static Future<String?> getPergunta() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_perguntaKey);
  }

  static Future<bool> temPerguntaSeguranca() async {
    final pergunta = await getPergunta();
    if (pergunta == null || pergunta.isEmpty) return false;
    final prefs = await SharedPreferences.getInstance();
    final hash = prefs.getString(_respostaHashKey);
    return hash != null && hash.isNotEmpty;
  }

  static Future<bool> validarResposta(String resposta) async {
    final prefs = await SharedPreferences.getInstance();
    final hash = prefs.getString(_respostaHashKey);
    if (hash == null || hash.isEmpty) return false;
    return hash == _hash(resposta);
  }

  static String _hash(String senha) {
    final bytes = utf8.encode('$_salt:$senha');
    return sha256.convert(bytes).toString();
  }
}
