// NeptuneTabsWidth: hug (the scrolling, start-aligned default) vs fill (the
// tabs share the width). The strip's own SingleChildScrollView gives its row an
// unbounded width, so `fill` cannot be had by wrapping the widget from the
// outside — it has to be a mode of the widget itself.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

void main() {
  NeptuneTheme.debugSkipFontLoading = true;

  Widget host(Widget child, {TextDirection direction = TextDirection.ltr}) =>
      MaterialApp(
        theme: NeptuneTheme.light('neptune'),
        home: Directionality(
          textDirection: direction,
          child: Scaffold(
            body: SizedBox(width: 400, child: Column(children: [child])),
          ),
        ),
      );

  testWidgets('hug is the default and keeps the tabs at the start',
      (tester) async {
    await tester.pumpWidget(host(NeptuneTabs(
      tabs: const ['Devices', 'Sign-ins'],
      index: 0,
      onChanged: (_) {},
    )));

    expect(find.byType(SingleChildScrollView), findsOneWidget);
    // The tabs sit shoulder to shoulder: the only space between the labels is
    // the two 16dp paddings. Nothing stretches to claim the leftover width.
    final first = tester.getRect(find.text('Devices'));
    final second = tester.getRect(find.text('Sign-ins'));
    expect(second.left - first.right, closeTo(32, 0.5));
  });

  testWidgets('fill splits the width evenly between the tabs', (tester) async {
    await tester.pumpWidget(host(NeptuneTabs(
      tabs: const ['Devices', 'Sign-ins'],
      index: 0,
      width: NeptuneTabsWidth.fill,
      onChanged: (_) {},
    )));

    expect(find.byType(SingleChildScrollView), findsNothing);
    expect(tester.getCenter(find.text('Devices')).dx, closeTo(100, 1));
    expect(tester.getCenter(find.text('Sign-ins')).dx, closeTo(300, 1));
  });

  testWidgets('fill mirrors under RTL', (tester) async {
    await tester.pumpWidget(host(
      NeptuneTabs(
        tabs: const ['الأجهزة', 'محاولات الدخول'],
        index: 0,
        width: NeptuneTabsWidth.fill,
        onChanged: (_) {},
      ),
      direction: TextDirection.rtl,
    ));

    // First tab sits at the trailing (right) half when the direction flips.
    expect(tester.getCenter(find.text('الأجهزة')).dx, closeTo(300, 1));
    expect(tester.getCenter(find.text('محاولات الدخول')).dx, closeTo(100, 1));
  });

  testWidgets('fill ellipsizes a label wider than its share', (tester) async {
    await tester.pumpWidget(host(NeptuneTabs(
      tabs: const [
        'A tab label far too long for two hundred logical pixels',
        'Short',
      ],
      index: 0,
      width: NeptuneTabsWidth.fill,
      onChanged: (_) {},
    )));

    expect(tester.takeException(), isNull);
    final label = tester.widget<Text>(find.text(
      'A tab label far too long for two hundred logical pixels',
    ));
    expect(label.overflow, TextOverflow.ellipsis);
    expect(label.maxLines, 1);
  });

  testWidgets('taps report the right index in fill mode', (tester) async {
    var tapped = -1;
    await tester.pumpWidget(host(NeptuneTabs(
      tabs: const ['Devices', 'Sign-ins'],
      index: 0,
      width: NeptuneTabsWidth.fill,
      onChanged: (i) => tapped = i,
    )));

    await tester.tap(find.text('Sign-ins'));
    expect(tapped, 1);
  });
}
