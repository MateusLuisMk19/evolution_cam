import 'package:evolution_cam/components/inner_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _img(String id, DateTime date) => {
      'id': id,
      'url': 'https://example.invalid/$id.jpg',
      'createdAt': date,
    };

void main() {
  final images = [
    _img('a', DateTime(2025, 1, 1, 10)),
    _img('b', DateTime(2025, 2, 1, 10)),
    _img('c', DateTime(2025, 3, 1, 10)),
  ];

  Widget host(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('ShowChangesSlide', () {
    testWidgets('mostra mensagem quando não há fotos selecionadas',
        (tester) async {
      await tester.pumpWidget(host(ShowChangesSlide(imageUrls: const [])));
      expect(
          find.textContaining('Selecione pelo menos uma foto'), findsOneWidget);
    });

    testWidgets('avança pelas fotos e volta ao início', (tester) async {
      await tester.pumpWidget(host(SingleChildScrollView(
        child: ShowChangesSlide(imageUrls: images, timerSeconds: 1),
      )));
      expect(find.text('1/3'), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));
      expect(find.text('2/3'), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('1/3'), findsOneWidget);
    });

    testWidgets('pausa e retoma', (tester) async {
      // O slideshow é um quadrado da largura do ecrã; precisa de altura.
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(host(SingleChildScrollView(
        child: ShowChangesSlide(imageUrls: images, timerSeconds: 1),
      )));

      await tester.tap(find.byIcon(Icons.pause));
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      expect(find.text('1/3'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('2/3'), findsOneWidget);
    });

    testWidgets('reconstruir com as mesmas fotos não volta à primeira',
        (tester) async {
      Widget build() => host(SingleChildScrollView(
            child:
                ShowChangesSlide(imageUrls: List.of(images), timerSeconds: 1),
          ));
      await tester.pumpWidget(build());
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('2/3'), findsOneWidget);

      await tester.pumpWidget(build());
      expect(find.text('2/3'), findsOneWidget);
    });
  });

  group('BeforeAfterSlider', () {
    testWidgets('mostra os dois rótulos com as datas', (tester) async {
      await tester.pumpWidget(host(BeforeAfterSlider(
        before: images.first,
        after: images.last,
        height: 300,
      )));
      expect(find.text('Antes · 01/01/2025'), findsOneWidget);
      expect(find.text('Depois · 01/03/2025'), findsOneWidget);
    });

    testWidgets('arrastar move a linha de comparação', (tester) async {
      await tester.pumpWidget(host(BeforeAfterSlider(
        before: images.first,
        after: images.last,
        height: 300,
      )));
      final handle = find.byIcon(Icons.swap_horiz);
      final start = tester.getCenter(handle).dx;

      await tester.drag(handle, const Offset(150, 0));
      await tester.pump();

      expect(tester.getCenter(handle).dx, greaterThan(start + 100));
    });
  });

  group('ImageGallery', () {
    testWidgets('marcar e desmarcar uma foto avisa o pai', (tester) async {
      Set<String> selected = {'a', 'b', 'c'};
      await tester.pumpWidget(host(StatefulBuilder(
        builder: (context, setState) => CustomScrollView(slivers: [
          ImageGallery(
            images: images,
            selectedIds: selected,
            onSelectionChanged: (ids) => setState(() => selected = ids),
            onOpen: (_) {},
            onDelete: (_) {},
          ),
        ]),
      )));

      await tester.tap(find.byKey(const ValueKey('select-c')));
      await tester.pump();
      expect(selected, {'a', 'b'});

      await tester.tap(find.byKey(const ValueKey('select-c')));
      await tester.pump();
      expect(selected, {'a', 'b', 'c'});
    });

    testWidgets('o menu de uma foto pede para excluir essa foto',
        (tester) async {
      Map<String, dynamic>? deleted;
      await tester.pumpWidget(host(CustomScrollView(slivers: [
        ImageGallery(
          images: images,
          selectedIds: const {},
          onSelectionChanged: (_) {},
          onOpen: (_) {},
          onDelete: (image) => deleted = image,
        ),
      ])));

      await tester.tap(find.byTooltip('Opções da foto').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Excluir'));
      await tester.pumpAndSettle();

      // A grelha mostra a mais recente primeiro.
      expect(deleted?['id'], 'c');
    });
  });
}
