import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/services.dart';
import 'services/billing_service.dart';
import 'screens/tela_login.dart';
import 'screens/tela_ativacao.dart';

class SimpleProvider extends ChangeNotifier {}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    try {
      await Firebase.initializeApp();
    } catch (_) {}
  }
  try {
    await DatabaseService.init();
  } catch (_) {}
  try {
    await BillingService.init();
  } catch (_) {}

  runApp(
    ChangeNotifierProvider(
      create: (context) => SimpleProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EleicaoaapkFluxo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.green,
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: TelaAtivacao(child: const TelaLogin()),
    );
  }
}
