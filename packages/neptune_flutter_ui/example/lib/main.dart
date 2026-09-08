// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// A live components gallery built ONLY from neptune_flutter_ui. Cycle the brand
// (neptune / triton / nereid / proteus), flip light/dark, and toggle RTL to see
// the Arabic faces + direction-aware money figures. Every widget below is themed
// purely from the active NeptuneTheme — swap the brand and the whole gallery
// reskins, byte-identically to the web.

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

/// Build with `--dart-define=SHOTS=true` to auto-capture the gallery across
/// brands × modes × scroll positions into SHOTS_DIR, then exit — pixel-exact
/// screenshots rendered by the engine itself (no OS screen permissions).
const bool kShots = bool.fromEnvironment('SHOTS');
const String kShotsDir =
    String.fromEnvironment('SHOTS_DIR', defaultValue: '/tmp/npt_shots');

/// Build with `--dart-define=WELCOME=true` to boot straight into the live
/// Welcome / Sign-in template: "Get started" cycles the brand, the secondary
/// action toggles dark mode.
const bool kWelcome = bool.fromEnvironment('WELCOME');

void main() => runApp(const ExampleApp());

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  static const _brands = ['neptune', 'triton', 'nereid', 'proteus'];
  int _brandIndex = 0;
  ThemeMode _mode = ThemeMode.light;
  bool _rtl = false;

  final GlobalKey _shotKey = GlobalKey();
  final GlobalKey<NavigatorState> _nav = GlobalKey<NavigatorState>();
  final ScrollController _scroll = ScrollController();

  String get _brand => _brands[_brandIndex];

  @override
  void initState() {
    super.initState();
    if (kShots) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _runShots());
    }
  }

  // --- SHOTS harness ---------------------------------------------------------

  Future<void> _runShots() async {
    await Directory(kShotsDir).create(recursive: true);
    // Let the first brand's fonts finish loading.
    await Future<void>.delayed(const Duration(seconds: 2));
    for (var b = 0; b < _brands.length; b++) {
      for (final dark in [false, true]) {
        setState(() {
          _brandIndex = b;
          _mode = dark ? ThemeMode.dark : ThemeMode.light;
          _rtl = false;
        });
        await Future<void>.delayed(const Duration(milliseconds: 900));
        // Sweep the WHOLE gallery, viewport by viewport.
        final maxOff =
            _scroll.hasClients ? _scroll.position.maxScrollExtent : 0.0;
        for (var off = 0.0; off <= maxOff; off += 760.0) {
          if (_scroll.hasClients) _scroll.jumpTo(off.clamp(0.0, maxOff));
          await Future<void>.delayed(const Duration(milliseconds: 250));
          await _capture(
              '$kShotsDir/${_brands[b]}_${dark ? 'dark' : 'light'}_${off.toInt()}.png');
        }
      }
    }
    // Welcome / Sign-in template, per brand (light).
    for (var b = 0; b < _brands.length; b++) {
      setState(() {
        _brandIndex = b;
        _mode = ThemeMode.light;
        _rtl = false;
      });
      await Future<void>.delayed(const Duration(milliseconds: 600));
      _nav.currentState!.push(MaterialPageRoute<void>(
          builder: (_) => WelcomeRoute(brand: _brands[b])));
      await Future<void>.delayed(const Duration(milliseconds: 900));
      await _capture('$kShotsDir/welcome_${_brands[b]}.png');
      _nav.currentState!.pop();
      await Future<void>.delayed(const Duration(milliseconds: 300));
    }

    // States & charts section: scroll to it precisely (it sits right before
    // Feedback) rather than relying on leftover scroll position.
    if (_scroll.hasClients) {
      _scroll.jumpTo(
          (_scroll.position.maxScrollExtent - 1050).clamp(0.0, _scroll.position.maxScrollExtent));
    }
    await Future<void>.delayed(const Duration(milliseconds: 300));
    await _capture('$kShotsDir/states_charts.png');

    // Every composed template (neptune, light).
    setState(() { _brandIndex = 0; _mode = ThemeMode.light; _rtl = false; });
    await Future<void>.delayed(const Duration(milliseconds: 600));
    for (final id in templateBuilders().keys) {
      _nav.currentState!.push(MaterialPageRoute<void>(
          builder: (_) => TemplateRoute(id: id)));
      await Future<void>.delayed(const Duration(milliseconds: 800));
      await _capture('$kShotsDir/template_$id.png');
      _nav.currentState!.pop();
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }

    // Arabic/RTL proof (Triton — Reem Kufi / Tajawal).
    setState(() {
      _brandIndex = 1;
      _mode = ThemeMode.light;
      _rtl = true;
    });
    await Future<void>.delayed(const Duration(seconds: 2));
    if (_scroll.hasClients) _scroll.jumpTo(0);
    await Future<void>.delayed(const Duration(milliseconds: 300));
    await _capture('$kShotsDir/triton_rtl_0.png');
    exit(0);
  }

  Future<void> _capture(String path) async {
    await WidgetsBinding.instance.endOfFrame;
    final ro = _shotKey.currentContext?.findRenderObject();
    if (ro is! RenderRepaintBoundary) return;
    final image = await ro.toImage(pixelRatio: 2);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    if (data != null) {
      await File(path).writeAsBytes(data.buffer.asUint8List());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Neptune Odyssey · Flutter',
      theme: NeptuneTheme.light(_brand, arabic: _rtl),
      darkTheme: NeptuneTheme.dark(_brand, arabic: _rtl),
      themeMode: _mode,
      navigatorKey: _nav,
      // The capture boundary + direction wrap the NAVIGATOR so pushed routes
      // (e.g. the Welcome template) are captured and mirror under RTL too.
      builder: (context, child) => RepaintBoundary(
        key: _shotKey,
        child: Directionality(
          textDirection: _rtl ? TextDirection.rtl : TextDirection.ltr,
          child: child ?? const SizedBox.shrink(),
        ),
      ),
      home: kWelcome
          // Live Welcome / Sign-in demo: primary cycles the brand (watch the
          // whole screen re-skin), secondary toggles dark mode.
          ? Scaffold(
              body: NeptuneWelcome(
                brandInitial: _brand[0].toUpperCase(),
                brandName: _brand[0].toUpperCase() + _brand.substring(1),
                title: 'Banking that',
                emphasis: 'moves with you.',
                supporting:
                    'One account, every currency — send, spend and save across borders, beautifully.',
                primaryAction: NeptuneCta(
                  label: 'Get started',
                  arrow: true,
                  onPressed: () => setState(
                      () => _brandIndex = (_brandIndex + 1) % _brands.length),
                ),
                secondaryAction: NeptuneCta(
                  label: 'I already have an account',
                  tonal: true,
                  onPressed: () => setState(() => _mode =
                      _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light),
                ),
              ),
            )
          : GalleryScreen(
              brand: _brand,
              rtl: _rtl,
              controller: _scroll,
              onCycleBrand: () =>
                  setState(() => _brandIndex = (_brandIndex + 1) % _brands.length),
              onToggleMode: () => setState(() =>
                  _mode = _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light),
              onToggleRtl: () => setState(() => _rtl = !_rtl),
            ),
    );
  }
}

/// The Welcome / Sign-in template route, brand-aware.
class WelcomeRoute extends StatelessWidget {
  final String brand;

  const WelcomeRoute({super.key, required this.brand});

  @override
  Widget build(BuildContext context) {
    final name = brand[0].toUpperCase() + brand.substring(1);
    return Scaffold(
      body: NeptuneWelcome(
        brandInitial: name[0],
        brandName: name,
        title: 'Banking that',
        emphasis: 'moves with you.',
        supporting:
            'One account, every currency — send, spend and save across borders, beautifully.',
        primaryAction: NeptuneCta(
          label: 'Get started',
          arrow: true,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        secondaryAction: NeptuneCta(
          label: 'I already have an account',
          tonal: true,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
    );
  }
}

class GalleryScreen extends StatefulWidget {
  final String brand;
  final bool rtl;
  final VoidCallback onCycleBrand;
  final VoidCallback onToggleMode;
  final VoidCallback onToggleRtl;
  final ScrollController? controller;

  const GalleryScreen({
    super.key,
    required this.brand,
    required this.rtl,
    required this.onCycleBrand,
    required this.onToggleMode,
    required this.onToggleRtl,
    this.controller,
  });

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  int _dock = 0;
  int _rail = 0;
  bool _frozen = false;
  bool _canApprove = true;
  // 2.4.0 widget-set demo state
  int _seg = 0;
  int _tab = 0;
  int _page = 1;
  int _qty = 2;
  bool _check = true;
  bool _switch = true;
  double _slider = 0.4;
  double _rating = 4;
  int _radio = 1;
  String _currency = 'LYD';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      // Content scrolls UNDER the floating dock so its glass blur reads.
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            NeptuneAppBar(
              title: 'Components · ${widget.brand}',
              leading: const CircleAvatar(child: Text('NO')),
              actions: [
                IconButton(
                  onPressed: widget.onToggleRtl,
                  tooltip: 'Toggle RTL',
                  icon: Icon(widget.rtl ? Icons.format_textdirection_r_to_l : Icons.format_textdirection_l_to_r),
                ),
                IconButton(
                  onPressed: widget.onToggleMode,
                  tooltip: 'Toggle dark',
                  icon: const Icon(Icons.brightness_6_outlined),
                ),
                IconButton(
                  onPressed: widget.onCycleBrand,
                  tooltip: 'Cycle brand',
                  icon: const Icon(Icons.palette_outlined),
                ),
              ],
            ),
            Expanded(
              child: ListView(
                controller: widget.controller,
                padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 120),
                children: [
                  // ---- Typography ------------------------------------------
                  _Section(
                    title: 'Typography',
                    description: 'Brand display / text faces + tabular money figures',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Display', style: text.displaySmall),
                        Text('Headline', style: text.headlineSmall),
                        Text('Title — the quick brown fox', style: text.titleMedium),
                        Text('Body — open an account in minutes.', style: text.bodyMedium),
                        const SizedBox(height: 8),
                        Text(
                          'LYD 12,480.50',
                          style: NeptuneTheme.moneyStyle(context, base: text.headlineMedium)
                              .copyWith(color: scheme.onSurface),
                        ),
                      ],
                    ),
                  ),

                  // ---- Cards / finance -------------------------------------
                  _Section(
                    title: 'Cards & balances',
                    child: Column(
                      children: [
                        const NeptuneBalanceCard(
                          label: 'Available balance',
                          amount: 'LYD 12,480.50',
                          caption: '•••• 4821',
                          hero: true,
                        ),
                        const SizedBox(height: 12),
                        const Row(
                          children: [
                            Expanded(child: NeptuneStatCard(label: 'Income', value: '9,120', unit: 'LYD', delta: '+8.2%')),
                            SizedBox(width: 12),
                            Expanded(child: NeptuneStatCard(label: 'Spending', value: '3,540', unit: 'LYD', delta: '-2.1%')),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const NeptuneCardArt(
                          holder: 'LINA ATIYA',
                          last4: '4821',
                          expiry: '08/27',
                          scheme: 'Visa',
                          selected: true,
                        ),
                        const SizedBox(height: 12),
                        NeptuneCardControls(
                          frozen: _frozen,
                          onControl: (action) {
                            if (action == 'freeze') setState(() => _frozen = !_frozen);
                            showNeptuneToast(context, 'Card action: $action');
                          },
                        ),
                        const SizedBox(height: 12),
                        NeptuneAddCard(onTap: () => showNeptuneToast(context, 'Add a card')),
                        const SizedBox(height: 12),
                        const NeptuneAccountTile(
                          name: 'Everyday',
                          maskedNumber: '•••• 4821',
                          balance: 'LYD 12,480.50',
                        ),
                      ],
                    ),
                  ),

                  // ---- Actions ---------------------------------------------
                  _Section(
                    title: 'Actions',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            NeptuneButton(label: 'Filled', onPressed: () {}),
                            NeptuneButton(label: 'Tonal', variant: NeptuneButtonStyle.tonal, onPressed: () {}),
                            NeptuneButton(label: 'Outlined', variant: NeptuneButtonStyle.outlined, icon: Icons.add, onPressed: () {}),
                            NeptuneButton(label: 'Text', variant: NeptuneButtonStyle.text, onPressed: () {}),
                          ],
                        ),
                        const SizedBox(height: 12),
                        NeptuneQuickActions(
                          actions: [
                            NeptuneQuickAction(icon: Icons.north_east, label: 'Send', onTap: () {}),
                            NeptuneQuickAction(icon: Icons.account_balance_wallet_outlined, label: 'Request', onTap: () {}),
                            NeptuneQuickAction(icon: Icons.qr_code_rounded, label: 'Pay', onTap: () {}),
                            NeptuneQuickAction(icon: Icons.add_card_outlined, label: 'Top up', onTap: () {}),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            NeptuneChip(label: 'Selected', selected: true),
                            NeptuneChip(label: 'Default'),
                            NeptuneStatusChip(label: 'Active', tone: NeptuneStatusTone.success),
                            NeptuneStatusChip(label: 'Pending', tone: NeptuneStatusTone.warning),
                            NeptuneStatusChip(label: 'Failed', tone: NeptuneStatusTone.danger),
                          ],
                        ),
                        const SizedBox(height: 12),
                        NeptuneCta(
                          label: 'Get started',
                          arrow: true,
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(builder: (_) => const _WelcomeScreen()),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ---- Money inputs ----------------------------------------
                  _Section(
                    title: 'Money inputs',
                    child: Column(
                      children: [
                        const NeptuneAmountInput(value: '1,250.00', currency: 'LYD'),
                        const SizedBox(height: 12),
                        const NeptuneCurrencyField(amount: '1,250.00', currency: 'LYD', currencies: ['LYD', 'USD', 'EUR']),
                        const SizedBox(height: 12),
                        const NeptuneIbanField(value: 'LY83 0020 0001 2345', valid: true),
                        const SizedBox(height: 12),
                        const NeptuneOtpInput(length: 6),
                        const SizedBox(height: 12),
                        const NeptunePinInput(length: 4),
                        const SizedBox(height: 12),
                        SizedBox(height: 280, child: NeptuneAmountKeypad(onKey: (_) {}, onBackspace: () {})),
                      ],
                    ),
                  ),

                  // ---- Money movement --------------------------------------
                  _Section(
                    title: 'Money movement',
                    child: Column(
                      children: [
                        const NeptuneStepper(steps: ['Amount', 'Review', 'Done'], active: 1),
                        const SizedBox(height: 12),
                        const NeptuneTransferReview(
                          fromLabel: 'Everyday •••• 4821',
                          toLabel: 'Sara N.',
                          amount: '250.00',
                          fee: '0.00',
                          total: '250.00',
                          currency: 'LYD',
                        ),
                        const SizedBox(height: 12),
                        NeptuneMethodRow(icon: Icons.account_balance, title: 'Bank transfer', subtitle: 'NUMO', selected: true, onTap: () {}),
                        NeptuneBeneficiaryTile(name: 'Sara Nuri', account: '•••• 7390', selected: true, onTap: () {}),
                        const SizedBox(height: 12),
                        const NeptuneSuccess(title: 'Sent!', amount: 'LYD 250.00', subtitle: 'To Sara N.'),
                        const SizedBox(height: 12),
                        NeptuneReceipt(
                          title: 'Receipt',
                          rows: const [
                            (label: 'Amount', value: 'LYD 250.00'),
                            (label: 'Fee', value: 'LYD 0.00'),
                            (label: 'Total', value: 'LYD 250.00'),
                          ],
                          onShare: () => showNeptuneToast(context, 'Shared receipt'),
                        ),
                      ],
                    ),
                  ),

                  // ---- Data table + data-viz -------------------------------
                  const _Section(
                    title: 'Data table & charts',
                    child: Column(
                      children: [
                        NeptuneDataTable(
                          caption: 'Recent activity',
                          columns: [
                            NeptuneColumn('Merchant'),
                            NeptuneColumn('Date'),
                            NeptuneColumn('Amount', numeric: true),
                          ],
                          rows: [
                            ['Coffee Bar', 'Today', '4.50'],
                            ['Grocery Market', 'Yesterday', '86.40'],
                            ['Salary', 'Sun', '3,200.00'],
                          ],
                        ),
                        SizedBox(height: 12),
                        SizedBox(width: double.infinity, height: 56, child: NeptuneSparkline(points: [3, 4, 4, 6, 5, 7, 8])),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            NeptuneDonut(segments: [3, 2, 1], centerLabel: '6'),
                            SizedBox(width: 16),
                            Expanded(child: NeptuneLimitMeter(value: 0.62, label: 'Monthly spend', amount: '620 / 1,000 LYD')),
                          ],
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            NeptuneTrend(value: 8.2),
                            SizedBox(width: 16),
                            NeptuneTrend(value: 2.1, down: true),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ---- Corporate -------------------------------------------
                  _Section(
                    title: 'Corporate',
                    child: Column(
                      children: [
                        NeptuneApprovalItem(title: 'Payroll batch', subtitle: '42 payments', amount: 'LYD 18,200', onApprove: () {}, onReject: () {}),
                        const SizedBox(height: 12),
                        const NeptuneBatchCard(title: 'June payroll', count: '42', total: 'LYD 18,200', status: 'Pending'),
                        const SizedBox(height: 12),
                        const NeptuneAuditRow(actor: 'Lina A.', action: 'Approved transfer', time: '12:04'),
                        NeptuneUserRow(name: 'Omar K.', role: 'Approver', status: 'Active', onTap: () {}),
                        NeptunePermissionToggle(
                          label: 'Can approve',
                          description: 'Up to LYD 50k',
                          value: _canApprove,
                          onChanged: (v) => setState(() => _canApprove = v),
                        ),
                        const SizedBox(height: 12),
                        const NeptuneWorkflowStatus(label: 'Review', step: 2, total: 3),
                      ],
                    ),
                  ),

                  // ---- Wallet / pay ----------------------------------------
                  _Section(
                    title: 'Wallet & pay',
                    child: Column(
                      children: [
                        const NeptuneMerchantRow(name: 'Grocery Market', category: 'Card', amount: '-86.40 LYD', time: 'Today'),
                        const SizedBox(height: 12),
                        const NeptuneVoucherCard(title: 'Cashback', value: 'LYD 10', code: 'NPT-10', expiry: 'Aug 27'),
                        const SizedBox(height: 12),
                        const NeptuneQrPay(amount: 'LYD 45.00', merchant: 'Coffee Bar'),
                        const SizedBox(height: 12),
                        NeptuneTopupRow(label: 'Top up', sublabel: 'Card', amount: 'LYD 50', onTap: () {}),
                        const SizedBox(height: 12),
                        const Wrap(spacing: 8, children: [NeptuneTierBadge(tier: 'Gold'), NeptuneTierBadge(tier: 'Silver')]),
                      ],
                    ),
                  ),

                  // ---- Shell & navigation ----------------------------------
                  _Section(
                    title: 'Shell & navigation',
                    child: Column(
                      children: [
                        const NeptunePageHeader(title: 'Accounts', subtitle: 'All your money in one place'),
                        NeptuneToolbar(
                          start: [IconButton(onPressed: () {}, icon: const Icon(Icons.menu))],
                          center: const [NeptuneSearchField(hint: 'Search')],
                          end: [IconButton(onPressed: () {}, icon: const Icon(Icons.tune))],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 280,
                          child: Row(
                            children: [
                              NeptuneNavRail(
                                selectedIndex: _rail,
                                onSelect: (i) => setState(() => _rail = i),
                                items: const [
                                  NeptuneNavRailItem(icon: Icons.home_outlined, selectedIcon: Icons.home, label: 'Home'),
                                  NeptuneNavRailItem(icon: Icons.credit_card, label: 'Cards'),
                                  NeptuneNavRailItem(icon: Icons.bar_chart_outlined, label: 'Stats'),
                                ],
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: NeptuneSideNav(
                                  children: [
                                    NeptuneSideNavItem(icon: Icons.dashboard_outlined, label: 'Dashboard', active: true, onTap: () {}),
                                    NeptuneSideNavItem(
                                      icon: Icons.swap_horiz,
                                      label: 'Transfers',
                                      trailing: const NeptuneStatusChip(label: '3', tone: NeptuneStatusTone.neutral),
                                      onTap: () {},
                                    ),
                                    NeptuneSideNavItem(icon: Icons.people_outline, label: 'Beneficiaries', onTap: () {}),
                                    const NeptuneSideNavItem(icon: Icons.settings_outlined, label: 'Settings (disabled)', enabled: false),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ---- Form fields (2.4.0) ---------------------------------
                  _Section(
                    title: 'Form fields',
                    child: Column(
                      children: [
                        const NeptuneTextField(label: 'Full name', hint: 'Lina Atiya', prefixIcon: Icons.person_outline),
                        const SizedBox(height: 12),
                        NeptuneSelect<String>(
                          label: 'Currency',
                          value: _currency,
                          options: const [
                            NeptuneSelectOption(value: 'LYD', label: 'Libyan Dinar', icon: Icons.payments_outlined),
                            NeptuneSelectOption(value: 'USD', label: 'US Dollar', icon: Icons.attach_money),
                            NeptuneSelectOption(value: 'EUR', label: 'Euro', icon: Icons.euro),
                          ],
                          onChanged: (v) => setState(() => _currency = v ?? 'LYD'),
                        ),
                        const SizedBox(height: 12),
                        NeptuneStepperInput(value: _qty, label: 'Cards', onChanged: (v) => setState(() => _qty = v)),
                        const SizedBox(height: 12),
                        NeptuneDateField(label: 'Expiry', value: DateTime(2027, 8, 1), onChanged: (_) {}),
                      ],
                    ),
                  ),

                  // ---- Selection controls (2.4.0) --------------------------
                  _Section(
                    title: 'Selection controls',
                    child: Column(
                      children: [
                        NeptuneSegmented<int>(
                          value: _seg,
                          segments: const [
                            NeptuneSegment(value: 0, label: 'Day'),
                            NeptuneSegment(value: 1, label: 'Week'),
                            NeptuneSegment(value: 2, label: 'Month'),
                          ],
                          onChanged: (v) => setState(() => _seg = v),
                        ),
                        const SizedBox(height: 12),
                        NeptuneCheckboxTile(label: 'Save beneficiary', description: 'Add to your payees', value: _check, onChanged: (v) => setState(() => _check = v)),
                        const SizedBox(height: 8),
                        NeptuneRadioGroup<int>(
                          value: _radio,
                          options: const [
                            NeptuneRadioOption(value: 1, label: 'Standard', description: 'Free · 1–2 days'),
                            NeptuneRadioOption(value: 2, label: 'Priority', description: 'LYD 2 · instant'),
                          ],
                          onChanged: (v) => setState(() => _radio = v),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            NeptuneSwitch(value: _switch, onChanged: (v) => setState(() => _switch = v)),
                            const SizedBox(width: 12),
                            Text(_switch ? 'Notifications on' : 'Notifications off'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        NeptuneSlider(value: _slider, label: 'Monthly limit', onChanged: (v) => setState(() => _slider = v)),
                      ],
                    ),
                  ),

                  // ---- Navigation & structure (2.4.0) ----------------------
                  _Section(
                    title: 'Navigation & structure',
                    child: Column(
                      children: [
                        NeptuneTabs(tabs: const ['Overview', 'Activity', 'Cards'], index: _tab, onChanged: (v) => setState(() => _tab = v)),
                        const SizedBox(height: 12),
                        // The same strip in fill mode: two tabs dividing the
                        // width, divider spanning it end to end.
                        NeptuneTabs(tabs: const ['Devices', 'Sign-ins'], index: _tab.clamp(0, 1), width: NeptuneTabsWidth.fill, onChanged: (v) => setState(() => _tab = v)),
                        const SizedBox(height: 12),
                        NeptuneBreadcrumbs(crumbs: [NeptuneCrumb('Home', onTap: () {}), NeptuneCrumb('Accounts', onTap: () {}), const NeptuneCrumb('Everyday')]),
                        const SizedBox(height: 12),
                        NeptunePagination(page: _page, pageCount: 6, onChanged: (v) => setState(() => _page = v)),
                        const SizedBox(height: 12),
                        const NeptuneAccordion(panels: [
                          NeptuneAccordionPanel(title: 'How are limits calculated?', child: Text('Limits reset on the 1st of each month.'), initiallyExpanded: true),
                          NeptuneAccordionPanel(title: 'Can I freeze a card?', child: Text('Yes — from the Cards screen, instantly.')),
                        ]),
                      ],
                    ),
                  ),

                  // ---- Display (2.4.0) -------------------------------------
                  _Section(
                    title: 'Display',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const NeptuneAvatar(initials: 'LA'),
                            const SizedBox(width: 12),
                            const NeptuneAvatarGroup(avatars: [NeptuneAvatar(initials: 'A'), NeptuneAvatar(initials: 'B'), NeptuneAvatar(initials: 'C'), NeptuneAvatar(initials: 'D'), NeptuneAvatar(initials: 'E')]),
                            const SizedBox(width: 16),
                            const NeptuneBadge(count: 4, child: Icon(Icons.notifications_outlined)),
                            const SizedBox(width: 16),
                            NeptuneTag(label: 'VIP', icon: Icons.star, onRemove: () {}),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const NeptuneProgressBar(value: 0.62, label: 'Monthly spend'),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const NeptuneProgressRing(value: 0.72, centerLabel: '72%'),
                            const SizedBox(width: 20),
                            NeptuneRating(value: _rating, onChanged: (v) => setState(() => _rating = v.toDouble())),
                          ],
                        ),
                        const SizedBox(height: 12),
                        NeptuneListTile(leadingIcon: Icons.account_balance, title: 'Everyday', subtitle: '•••• 4821', trailing: const Icon(Icons.chevron_right), onTap: () {}),
                        const SizedBox(height: 12),
                        const NeptuneTimeline(entries: [
                          NeptuneTimelineEntry(title: 'Transfer created', time: '12:00', done: true),
                          NeptuneTimelineEntry(title: 'Approved by Omar', time: '12:04', done: true),
                          NeptuneTimelineEntry(title: 'Awaiting settlement', subtitle: 'Usually within minutes'),
                        ]),
                      ],
                    ),
                  ),

                  // ---- Overlays (2.4.0) ------------------------------------
                  _Section(
                    title: 'Overlays',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        NeptuneButton(
                          label: 'Dialog',
                          onPressed: () => showNeptuneDialog(
                            context: context,
                            title: 'Send LYD 250?',
                            message: 'To Sara Nuri · •••• 7390',
                            icon: Icons.north_east,
                            actions: [
                              const NeptuneDialogAction(label: 'Cancel'),
                              NeptuneDialogAction(label: 'Send', primary: true, onPressed: () => showNeptuneToast(context, 'Sent')),
                            ],
                          ),
                        ),
                        NeptuneButton(
                          label: 'Bottom sheet',
                          variant: NeptuneButtonStyle.tonal,
                          onPressed: () => showNeptuneSheet(
                            context: context,
                            title: 'Choose a card',
                            child: Column(
                              children: [
                                NeptuneListTile(leadingIcon: Icons.credit_card, title: 'Everyday debit', subtitle: '•••• 4821', onTap: () => Navigator.of(context).pop()),
                                NeptuneListTile(leadingIcon: Icons.credit_card, title: 'Travel credit', subtitle: '•••• 6642', onTap: () => Navigator.of(context).pop()),
                              ],
                            ),
                          ),
                        ),
                        NeptuneMenu(
                          items: [
                            NeptuneMenuItem(label: 'Edit', icon: Icons.edit_outlined, onSelected: () {}),
                            NeptuneMenuItem(label: 'Share', icon: Icons.ios_share, onSelected: () {}),
                            NeptuneMenuItem(label: 'Delete', icon: Icons.delete_outline, destructive: true, onSelected: () {}),
                          ],
                          child: const NeptuneButton(label: 'Menu', variant: NeptuneButtonStyle.outlined, icon: Icons.more_horiz, onPressed: null),
                        ),
                        const NeptuneTooltip(message: 'Protected by Neptune', child: Icon(Icons.verified_user_outlined, size: 28)),
                      ],
                    ),
                  ),

                  // ---- Fintech (2.4.0) -------------------------------------
                  _Section(
                    title: 'Fintech',
                    child: Column(
                      children: [
                        NeptuneInsightCard(
                          icon: Icons.lightbulb_outline,
                          title: 'You saved 12% this month',
                          message: 'Spending is down LYD 480 vs last month. Keep it up.',
                          actionLabel: 'See breakdown',
                          onAction: () {},
                        ),
                        const SizedBox(height: 12),
                        const NeptuneFxCard(fromCurrency: 'LYD', toCurrency: 'USD', rate: '0.2065', change: '+0.4%'),
                        const SizedBox(height: 12),
                        const Row(
                          children: [
                            NeptuneBudgetRing(spent: 620, limit: 1000, label: 'Groceries'),
                            SizedBox(width: 16),
                            Expanded(child: NeptuneCreditScoreGauge(score: 742, band: 'Very good')),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const NeptuneSpendBreakdown(slices: [
                          NeptuneSpendSlice(label: 'Food', amount: 240, icon: Icons.restaurant),
                          NeptuneSpendSlice(label: 'Bills', amount: 180, icon: Icons.receipt_long),
                          NeptuneSpendSlice(label: 'Transport', amount: 96, icon: Icons.directions_car),
                          NeptuneSpendSlice(label: 'Fun', amount: 64, icon: Icons.celebration),
                        ]),
                      ],
                    ),
                  ),

                  // ---- Motion & templates (2.6.0) --------------------------
                  _Section(
                    title: 'Motion & templates',
                    description: 'Hourglass → outcome motion · animated CTA · Welcome',
                    child: Column(
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            NeptuneStatusMotion(status: NeptuneFlowStatus.loading, size: 84),
                            NeptuneStatusMotion(status: NeptuneFlowStatus.success, size: 84),
                            NeptuneStatusMotion(status: NeptuneFlowStatus.rejected, size: 84),
                          ],
                        ),
                        const SizedBox(height: 16),
                        NeptuneCta(
                          label: 'Get started',
                          arrow: true,
                          onPressed: () {},
                        ),
                        const SizedBox(height: 10),
                        NeptuneCta(
                          label: 'I already have an account',
                          tonal: true,
                          onPressed: () {},
                        ),
                        const SizedBox(height: 12),
                        NeptuneButton(
                          label: 'Open Welcome / Sign-in template',
                          variant: NeptuneButtonStyle.outlined,
                          icon: Icons.smartphone,
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => WelcomeRoute(brand: widget.brand),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ---- States & charts (2.8.0) ------------------------------
                  _Section(
                    title: 'States & charts',
                    description: 'Loading/empty/error contract · insights bar charts',
                    child: Column(
                      children: [
                        const NeptuneSkeletonCard(),
                        const SizedBox(height: 12),
                        const NeptuneSkeletonRow(),
                        const SizedBox(height: 12),
                        NeptuneStateSwitcher(
                          state: NeptuneDataState.error,
                          onRetry: () => showNeptuneToast(context, 'Retrying…'),
                          child: const Text('Loaded content'),
                        ),
                        const SizedBox(height: 12),
                        const NeptuneBarChart(
                          bars: [
                            NeptuneBarData('Jan', 320),
                            NeptuneBarData('Feb', 480),
                            NeptuneBarData('Mar', 260),
                            NeptuneBarData('Apr', 610),
                            NeptuneBarData('May', 540),
                          ],
                          highlightIndex: 3,
                        ),
                        const SizedBox(height: 16),
                        const NeptuneCompareBars(data: [
                          NeptuneCompareData('Food', 430, 510),
                          NeptuneCompareData('Bills', 380, 330),
                          NeptuneCompareData('Transport', 210, 260),
                          NeptuneCompareData('Fun', 90, 140),
                        ]),
                      ],
                    ),
                  ),

                  // ---- Screen templates (2.7.0) ----------------------------
                  _Section(
                    title: 'Screen templates',
                    description: 'All nine templates.html screens, composed',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final id in templateBuilders().keys)
                          NeptuneButton(
                            label: id,
                            variant: NeptuneButtonStyle.tonal,
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                  builder: (_) => TemplateRoute(id: id)),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // ---- Feedback --------------------------------------------
                  _Section(
                    title: 'Feedback',
                    child: Column(
                      children: [
                        const NeptuneAlert(message: 'Transfer completed.', tone: NeptuneAlertTone.success, title: 'Done'),
                        const SizedBox(height: 12),
                        const NeptuneBanner(message: 'Scheduled maintenance tonight.'),
                        const SizedBox(height: 12),
                        const NeptuneEmptyState(icon: Icons.inbox_outlined, title: 'Nothing yet', message: 'Your activity will show here.'),
                        const SizedBox(height: 12),
                        const NeptuneSkeleton(width: 220),
                        const SizedBox(height: 12),
                        NeptuneToast(
                          message: 'Saved to favourites',
                          action: TextButton(onPressed: () {}, child: const Text('Undo')),
                        ),
                        const SizedBox(height: 12),
                        NeptuneButton(
                          label: 'Show toast',
                          variant: NeptuneButtonStyle.tonal,
                          onPressed: () => showNeptuneToast(
                            context,
                            'Transfer sent',
                            action: TextButton(onPressed: () {}, child: const Text('View')),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(14, 0, 14, 14),
        child: NeptuneDock(
          items: [
            NeptuneDockItem(icon: Icons.home_rounded, label: 'Home', active: _dock == 0, onTap: () => setState(() => _dock = 0)),
            NeptuneDockItem(icon: Icons.credit_card, label: 'Cards', active: _dock == 1, onTap: () => setState(() => _dock = 1)),
            NeptuneDockItem(icon: Icons.qr_code_rounded, label: 'Pay', active: _dock == 2, onTap: () => setState(() => _dock = 2)),
            NeptuneDockItem(icon: Icons.person_outline, label: 'Profile', active: _dock == 3, onTap: () => setState(() => _dock = 3)),
          ],
        ),
      ),
    );
  }
}

/// A labelled gallery section, themed via NeptuneSection.
class _Section extends StatelessWidget {
  final String title;
  final String? description;
  final Widget child;

  const _Section({required this.title, this.description, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 8),
      child: NeptuneSection(title: title, description: description, child: child),
    );
  }
}

/// The onboarding / get-started hero, built from NeptuneOnboarding + NeptuneCta.
class _WelcomeScreen extends StatelessWidget {
  const _WelcomeScreen();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: NeptuneOnboarding(
          eyebrow: 'NEPTUNE ODYSSEY',
          headline: RichText(
            text: TextSpan(
              style: text.displaySmall?.copyWith(color: scheme.onSurface),
              children: [
                const TextSpan(text: 'Your money,\n'),
                TextSpan(
                  text: 'everywhere you are.',
                  style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          supporting: 'Open an account in minutes. Send, spend and save across borders — beautifully.',
          steps: 3,
          activeStep: 0,
          cta: NeptuneCta(
            label: 'Get started',
            arrow: true,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }
}


/// Demo instances of every composed template (2.7.0), keyed for routing/SHOTS.
Map<String, Widget Function(BuildContext)> templateBuilders() => {
      'auth': (_) => const NeptuneAuthTemplate(brandInitial: 'N', brandName: 'Neptune'),
      'auth-otp': (_) => const NeptuneAuthTemplate(brandInitial: 'N', brandName: 'Neptune', step: 1),
      'kyc': (_) => const NeptuneKycTemplate(notice: 'Your data is encrypted end-to-end.'),
      'dashboard': (_) => NeptuneDashboardTemplate(
            balanceCaption: '•••• 4821',
            actions: [
              NeptuneQuickAction(icon: Icons.north_east, label: 'Send', onTap: () {}),
              NeptuneQuickAction(icon: Icons.account_balance_wallet_outlined, label: 'Request', onTap: () {}),
              NeptuneQuickAction(icon: Icons.qr_code_rounded, label: 'Pay', onTap: () {}),
              NeptuneQuickAction(icon: Icons.add_card_outlined, label: 'Top up', onTap: () {}),
            ],
            statPair: ('Spending', '3,540', 'LYD', '−2.1%'),
            transactions: const [
              NeptuneTxData('Salary', 'Today · Transfer', '+3,200.00 LYD', credit: true),
              NeptuneTxData('Grocery Market', 'Today · Card', '−86.40 LYD'),
              NeptuneTxData('Coffee Bar', 'Yesterday · Card', '−4.50 LYD'),
            ],
          ),
      'cards': (_) => const NeptuneCardsTemplate(
            cards: [
              NeptuneCardData(holder: 'LINA ATIYA', last4: '4821', expiry: '08/27', scheme: 'VISA'),
              NeptuneCardData(holder: 'LINA ATIYA', last4: '6642', expiry: '01/29', scheme: 'VIRTUAL', virtual: true),
            ],
            transactions: [
              NeptuneTxData('Grocery Market', 'Today · Card', '−86.40 LYD'),
              NeptuneTxData('Coffee Bar', 'Yesterday · Card', '−4.50 LYD'),
            ],
          ),
      'transfer': (_) => NeptuneTransferTemplate(
            payees: const [
              NeptunePayeeData('Sara Nuri', '•••• 7390'),
              NeptunePayeeData('Omar K.', '•••• 1204'),
            ],
            onPayee: (_) {},
            onContinue: () {},
          ),
      'transfer-success': (_) => const NeptuneTransferTemplate(
            step: 2,
            outcome: NeptuneFlowStatus.success,
            payees: [NeptunePayeeData('Sara Nuri', '•••• 7390')],
          ),
      'wallet': (_) => NeptuneWalletTemplate(
            actions: [
              NeptuneQuickAction(icon: Icons.qr_code_rounded, label: 'Pay', onTap: () {}),
              NeptuneQuickAction(icon: Icons.add_card_outlined, label: 'Top up', onTap: () {}),
              NeptuneQuickAction(icon: Icons.receipt_long, label: 'Vouchers', onTap: () {}),
            ],
            merchants: const [
              ('Coffee Bar', 'Card', '−4.50 LYD', 'Today'),
              ('Grocery Market', 'Card', '−86.40 LYD', 'Today'),
            ],
            voucher: ('Cashback', 'LYD 10', 'NPT-10', 'Aug 27'),
          ),
      'corporate': (_) => NeptuneCorporateTemplate(
            subtitle: 'Pending your decision',
            approvals: const [
              NeptuneApprovalData('Payroll batch', '42 payments', 'LYD 18,200'),
              NeptuneApprovalData('Supplier invoice', 'Al-Waha Trading', 'LYD 4,750'),
            ],
            onDecide: (_, __) {},
            batch: ('June payroll', '42', 'LYD 18,200', 'Pending'),
            audit: const [
              ('Lina A.', 'Approved transfer', '12:04'),
              ('Omar K.', 'Rejected invoice', '11:31'),
            ],
          ),
    };

/// Full-screen template route.
class TemplateRoute extends StatelessWidget {
  final String id;

  const TemplateRoute({super.key, required this.id});

  @override
  Widget build(BuildContext context) =>
      Scaffold(body: templateBuilders()[id]!(context));
}
