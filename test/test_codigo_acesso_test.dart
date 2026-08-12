import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:projetoeleitoral/screens/tela_ativacao.dart';
import 'package:projetoeleitoral/services/billing_service.dart';

const _CODIGO = 'MCS-GF369IB7CQ12';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    BillingService.resetParaTeste();
  });

  Future<void> abrirDialogCodigo(WidgetTester tester) async {
    final botao = find.text('Tenho um código de acesso');
    await tester.ensureVisible(botao);
    await tester.pumpAndSettle();
    await tester.tap(botao);
    await tester.pumpAndSettle();
  }

  testWidgets('Código correto desbloqueia o app (mostra o child)', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TelaAtivacao(
          child: const Scaffold(body: Text('MENU_LIBERADO')),
        ),
      ),
    );

    expect(find.text('App Bloqueado'), findsOneWidget);

    await abrirDialogCodigo(tester);

    await tester.enterText(find.byType(TextField), _CODIGO);
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    expect(find.text('MENU_LIBERADO'), findsOneWidget);
    expect(find.text('App Bloqueado'), findsNothing);
  });

  testWidgets('Código errado não desbloqueia e mostra erro', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TelaAtivacao(
          child: const Scaffold(body: Text('MENU_LIBERADO')),
        ),
      ),
    );

    await abrirDialogCodigo(tester);

    await tester.enterText(find.byType(TextField), 'CODIGO_ERRADO');
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    expect(find.text('App Bloqueado'), findsOneWidget);
    expect(find.text('MENU_LIBERADO'), findsNothing);
    expect(find.text('Código inválido. Verifique e tente novamente.'), findsOneWidget);
  });

  testWidgets('liberarPorCodigo persiste o acesso (sobrevive a reinício)', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final ok = await BillingService.liberarPorCodigo(_CODIGO);
    expect(ok, true);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('acesso_vitalicio_comprado'), true);

    await tester.pumpWidget(
      MaterialApp(
        home: TelaAtivacao(
          child: const Scaffold(body: Text('MENU_LIBERADO')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('MENU_LIBERADO'), findsOneWidget);
  });

  test('código com espaços é aceito (trim)', () async {
    SharedPreferences.setMockInitialValues({});
    final ok = await BillingService.liberarPorCodigo('  $_CODIGO  ');
    expect(ok, true);
    expect(BillingService.isComprado, true);
  });

  test('código vazio ou errado retorna false', () async {
    SharedPreferences.setMockInitialValues({});
    expect(await BillingService.liberarPorCodigo(''), false);
    expect(await BillingService.liberarPorCodigo('qualquer coisa'), false);
    expect(BillingService.isComprado, false);
  });
}
