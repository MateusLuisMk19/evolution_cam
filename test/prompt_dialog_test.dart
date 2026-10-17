import 'package:evolution_cam/components/feedback.dart';
import 'package:evolution_cam/configs/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('promptDialog devolve o texto e fecha sem erros', (tester) async {
    String? result;
    await tester.pumpWidget(MaterialApp(
      theme: lightTheme,
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () async {
                result = await promptDialog(context,
                    title: 'Nova categoria', label: 'Nome');
              },
              child: const Text('abrir'),
            ),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Teste');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(result, 'Teste');
    expect(tester.takeException(), isNull);
  });
}
