// Regression: widgets placed in UNBOUNDED-width slots (ListTile trailing,
// toolbar center, plain Rows) must never fail layout — a flex child there
// silently blanks the whole subtree (ODYSSEY_RULEBOOK §4). Caught live by the
// blank-check detector on the first client prototype's Profile screen.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

void main() {
  NeptuneTheme.debugSkipFontLoading = true;
  Widget host(Widget child) => MaterialApp(
        theme: NeptuneTheme.light('proteus'),
        home: Scaffold(body: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(children: [Expanded(child: ListView(children: [child]))]),
        )),
      );

  testWidgets('tile+avatar+badge', (t) async {
    await t.pumpWidget(host(const NeptuneListTile(
      leading: NeptuneAvatar(initials: 'م', size: 48),
      title: 'مو تليسي', subtitle: 'LY83',
      trailing: NeptuneTierBadge(tier: 'Gold'),
    )));
    expect(t.takeException(), isNull);
    expect(find.text('مو تليسي'), findsOneWidget);
  });

  testWidgets('tile+switch', (t) async {
    await t.pumpWidget(host(NeptuneListTile(
      leadingIcon: Icons.dark_mode_outlined, title: 'النمط',
      trailing: NeptuneSwitch(value: false, onChanged: (_) {}),
    )));
    expect(t.takeException(), isNull);
  });

  testWidgets('tile+segmented', (t) async {
    await t.pumpWidget(host(NeptuneListTile(
      leadingIcon: Icons.translate_rounded, title: 'اللغة',
      trailing: NeptuneSegmented<bool>(
        value: true,
        segments: const [NeptuneSegment(value: false, label: 'EN'), NeptuneSegment(value: true, label: 'ع')],
        onChanged: (_) {},
      ),
    )));
    expect(t.takeException(), isNull);
  });

  testWidgets('fill tabs in an unbounded slot fall back to hugging', (t) async {
    // NeptuneTabsWidth.fill puts every tab in an Expanded. Asked for inside a
    // slot that never bounds the width, that is the silent-blank shape — the
    // strip must shrink-wrap and scroll instead.
    await t.pumpWidget(host(Row(children: [
      NeptuneTabs(
        tabs: const ['الأجهزة', 'محاولات الدخول'],
        index: 0,
        width: NeptuneTabsWidth.fill,
        onChanged: (_) {},
      ),
    ])));
    expect(t.takeException(), isNull);
    expect(find.text('الأجهزة'), findsOneWidget);
  });

  testWidgets('full profile column in section', (t) async {
    await t.pumpWidget(host(NeptuneSection(
      title: 'الأمان',
      child: Column(children: [
        NeptuneListTile(leadingIcon: Icons.fingerprint_rounded, title: 'الدخول بالبصمة',
          trailing: NeptuneSwitch(value: true, onChanged: (_) {})),
        NeptuneListTile(leadingIcon: Icons.pin_outlined, title: 'تغيير الرمز',
          trailing: const Icon(Icons.chevron_right), onTap: () {}),
      ]),
    )));
    expect(t.takeException(), isNull);
    expect(find.text('الدخول بالبصمة'), findsOneWidget);
  });
}
