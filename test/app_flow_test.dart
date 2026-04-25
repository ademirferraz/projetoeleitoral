import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projetoeleitoral/main.dart';

void main() {
  testWidgets('Fluxo completo sem alterar app', (WidgetTester tester) async {
    
    // Inicia app
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // =========================
    // SELECIONAR ADMIN
    // =========================
    final adminSegment = find.text('Admin');
    expect(adminSegment, findsWidgets);
    await tester.tap(adminSegment.first);
    await tester.pumpAndSettle();

    // =========================
    // CLICAR BOTÃO ADMIN
    // =========================
    final botaoAdmin = find.widgetWithText(ElevatedButton, 'Admin');
    expect(botaoAdmin, findsOneWidget);
    await tester.tap(botaoAdmin);
    await tester.pumpAndSettle();

    // =========================
    // DIGITAR SENHA
    // =========================
    final campoSenha = find.byType(TextField);
    expect(campoSenha, findsOneWidget);
    await tester.enterText(campoSenha, 'admin123');
    await tester.pumpAndSettle();

    // =========================
    // CLICAR ENTRAR
    // =========================
    final botaoEntrar = find.widgetWithText(ElevatedButton, 'Entrar');
    expect(botaoEntrar, findsOneWidget);
    await tester.tap(botaoEntrar);
    await tester.pumpAndSettle();

    // =========================
    // VALIDAR PAINEL ADMIN
    // =========================
    expect(find.text('Painel Admin'), findsOneWidget);

    // =========================
    // IR PARA ABA CANDIDATOS
    // =========================
    final abaCandidatos = find.text('Candidatos');
    expect(abaCandidatos, findsOneWidget);
    await tester.tap(abaCandidatos);
    await tester.pumpAndSettle();

    // =========================
    // INJETAR VOTOS (usa Semantics que você já tem)
    // =========================
    final botaoInjetar = find.bySemanticsLabel('botao_injetar_votos');
    expect(botaoInjetar, findsOneWidget);
    await tester.tap(botaoInjetar);
    await tester.pumpAndSettle();

    // =========================
    // IR PARA RESULTADOS
    // =========================
    final botaoResultados = find.bySemanticsLabel('botao_ver_resultados');
    expect(botaoResultados, findsOneWidget);
    await tester.tap(botaoResultados);
    await tester.pumpAndSettle();

    // =========================
    // VALIDAR AUDITORIA
    // =========================
    final auditoria = find.bySemanticsLabel('dados_auditoria');
    expect(auditoria, findsOneWidget);

    // =========================
    // VOLTAR
    // =========================
    await tester.pageBack();
    await tester.pumpAndSettle();

    // =========================
    // DELETAR (se existir)
    // =========================
    final deletar = find.byIcon(Icons.delete);
    if (deletar.evaluate().isNotEmpty) {
      await tester.tap(deletar.first);
      await tester.pumpAndSettle();
    }
  });
}