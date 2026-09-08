## 2.22.0

- **`NeptuneTabs.width`** (`NeptuneTabsWidth.hug` | `.fill`): the tabs can now share the available width instead of hugging their labels at the start edge. A host could not do this from the outside at any price — the strip wraps its `Row` in a horizontal `SingleChildScrollView`, which hands that row an UNBOUNDED width, so `SizedBox(width: double.infinity)`, `Expanded` and `CrossAxisAlignment.stretch` all stop at the viewport and the divider kept ending with the last label. `fill` drops the scroll view and puts each tab in an `Expanded`; labels wider than their share ellipsize. Default is `hug`, so every existing call site is unchanged. Flutter only for now — the web `<npt-tabs>` keeps its current single behaviour.
- `fill` self-adapts in unbounded-width slots (falls back to the hugging strip) rather than blanking the subtree, the rulebook §4 rule `NeptuneSegmented` already follows; covered in `unbounded_slots_regression_test.dart`.

## 2.21.1

- **`NeptuneCardArt`: removed the tiled arc motif from the card face.** At full strength on a compact 1.586-ratio card, the repeating micro-pattern read as busy/cheap rather than premium. Checked against the category (Mercury, Chase, Monzo, N26, Chime, Airwallex, Brex, PayPal, Revolut Business): every one uses a clean flat/gradient card face with zero repeating texture. The brand gradient + typography now carry the identity alone, matching every reference.

## 2.21.0

- `NeptuneTheme.withHostFont()`: re-applies a host's bundled font across the text theme AND every component theme carrying its own `textStyle`. Hosts patching `theme.textTheme.apply(...)` by hand left `filledButtonTheme`/`outlinedButtonTheme` holding the family captured at assembly, so BUTTON LABELS rendered in a different face than the rest of the screen — invisible in a widget test, obvious on a device.

## 2.20.0

- **Dark mode: the brand colour stops washing out.** The dark ramp put primary at OKLCH L 0.80, where the sRGB gamut caps chroma near 0.10 for a blue hue — a brand seed of 0.209 lost ~40% of its saturation and rendered as a pale, washed blue. Primary is now L 0.66 / chroma x0.85 (tertiary 0.70, secondary 0.76), where the full brand chroma survives. Contrast measures ~5.9:1 against both the dark surface and on-primary, comfortably past WCAG AA. Changed in `neptune_tokens` (the cross-platform source of truth) and regenerated, so all 13 platform packages inherit it identically.

## 2.19.0

- `NeptuneNumeral`: text that always reads left-to-right whatever the locale, for account numbers, IBANs, card numbers, amounts and references. Forces only the INTERNAL direction, so RTL layouts stay mirrored. `NeptuneNumeral.isolated()` wraps a value in LRI/PDI isolate marks for safe interpolation into a translated sentence — stronger than a bare LRM, which lets adjacent weak characters merge with the run.

## 2.18.1

- **Fix release-build breakage**: `NeptunePageTransitionsBuilder.theme` no longer names `CupertinoPageTransitionsBuilder`. That symbol moved between Flutter versions and a newer stable failed with "Method not found", breaking Android release builds. iOS/macOS now inherit the framework defaults by spreading `const PageTransitionsTheme().builders` — same behaviour, version-proof.

## 2.18.0

- `NeptunePageTransitionsBuilder` + wired into every generated theme: M3 fade-through with a gentle upward settle on push, receding lift-and-dim on the covered page, natural reverse on pop. iOS keeps `CupertinoPageTransitionsBuilder` so the native edge-swipe back gesture survives. Reduced motion falls back to a plain cross-fade — position never animates.

## 2.17.0

- Dark mode overhaul: neutral floor raised to M3's dark-surface level (OKLCH L 0.13 → 0.18) with the container ladder re-spaced, neutral chroma halved to kill the primary-hue cast on dark ground.
- Card-art gradient is now mode-aware: dark gets a deeper, slightly desaturated ramp instead of the light-seed gradient glaring on dark surfaces.

## 2.16.0

- `NeptuneUnlockReveal.background`: hosts can replace the generic motif wash on the unlock sheet with their own brand canvas, keeping one background language across splash, unlock, and home.

# Changelog

## 2.15.0 — white-label icon slots + a host FAB gap in the dock

White-label was only half-true in the chrome: `NeptuneDock`, `NeptuneQuickAction`
and `NeptuneAccountTile` accepted **only** Material `IconData`, so every bank
built on Odyssey wore the same glyphs no matter which icon set its designers had
drawn. Each of the three now takes an optional `iconWidget` alongside `icon`,
and the dock can reserve a hole for a host-owned centre FAB. Fully additive —
every existing call site compiles and renders unchanged.

- **`iconWidget` on `NeptuneDockItem`, `NeptuneQuickAction` and
  `NeptuneAccountTile`.** Pass any widget — a per-brand SVG, an `ImageIcon`, a
  lettermark — and it replaces the Material glyph. `icon` is now optional
  (`IconData?`) with a constructor assert requiring one of the two; the
  `NeptuneAccountTile` wallet default is untouched, so its call sites need
  nothing.
- **The supplied widget inherits the state tint.** A mark gets the exact colour
  the `Icon` would have received — the dock's `onPrimary` when raised-active vs
  `onSurfaceVariant` when idle, `onSecondaryContainer` in a quick-action chip,
  `onPrimaryContainer` in an account tile — published to its subtree as an
  `IconTheme` **and** a `DefaultTextStyle`, plus the same square the glyph
  occupied (22dp in the dock, the ambient icon size elsewhere). The tint is
  deliberately **not** forced through a colour filter, so a brand's multi-colour
  mark stays multi-colour; a monochrome SVG should inherit `currentColor`
  (i.e. read `IconTheme.of(context).color`) to follow the active/inactive
  treatment.
- **`NeptuneDock.centerGap` / `centerGapWidth`** (default `false` / `72`)
  reserve inert space in the middle of the item row so an app with a centre
  floating action button can adopt the dock — the host stacks and owns the
  button, the dock just leaves room. The glass pane, hairline, elevation and the
  raised-active spring are all untouched, item cells stay equal-width, and with
  an even item count the hole straddles the dock's centre line.
- **Fix — the raised-active spring crashed on a real selection change.** The
  key-light was `active ? [shadow] : null`, so `BoxDecoration.lerp` padded the
  shorter list with `BoxShadow.scale(1 - t)`; the brand spring overshoots
  outside `0..1`, the factor went negative, and `dart:ui` asserted on a negative
  blur radius. Latent because every test and shot built the dock with a fixed
  active item. Both states now emit one shadow with identical geometry and
  animate alpha only (`Color.lerp` clamps, `BoxShadow.scale` does not).

flutter analyze clean · 128 tests pass (13 new) · CI no-literals gate green.

## 2.14.0 — NeptuneUnlockReveal: swipe-up unlock ritual

**`NeptuneUnlockReveal`** — the "swipe up to open" unlock ritual for a
returning-user lock screen (canvas pill cutout reveals gradient + motif).
Odyssey-original, beyond the web set.

- A full-bleed canvas in the brand `primary` hides the 135° primary → tertiary
  gradient overlaid with the signature motif (`NeptuneMotifLayer` in
  `onPrimary` at a quiet ~0.15-alpha ink wash). A vertical pill-shaped cutout
  near the bottom reveals a sliver of it, capped by a circular arrow chip
  (60dp, inside a ≥48dp interactive zone).
- Dragging the pill (or chip) upward grows the cutout, its top edge tracking
  the finger; releasing past ~60% progress completes the reveal on the brand's
  emphasized curve and fires `onUnlock` exactly once; releasing earlier
  settles back on the brand spring. An upward fling completes regardless of
  progress, and a tap on the chip unlocks too (doubling as the accessible
  activation — the zone is a labelled semantic button).
- Optional `label` under the pill (in `onPrimary`) and `logo` in the upper
  canvas area; both yield as the reveal grows.
- Reduced motion: no growth animation — tap/drag-complete cross-fades straight
  to the revealed state, then fires `onUnlock`.
- Theme-only (colour, motion and elevation all from the active brandprint),
  RTL-safe, reduced-motion safe.

flutter analyze clean · 115 tests pass (6 new) · CI no-literals gate green.

## 2.13.1 — docs + pub.dev screenshot refresh

No code changes. Adds a new pub.dev/README screenshot (`r6_additions.png`, real
`RepaintBoundary.toImage` engine render) showing the 2.13.0 additions — the loader family,
`NeptuneSplashScreen`, and `NeptuneAppBar`'s medium variant — and updates install snippets
and the widget list to the current version. Screenshots are pinned per published version on
pub.dev, so this needed a release rather than just an edit to `main`.

## 2.13.0 — R9: full component-suite audit

Audited all 89 web custom elements (`neptune_web_ui`, the canonical recipe
source) against the 149 Flutter classes for genuine capability gaps — not a
naming diff, an actual missing thing a consumer would hit. Result: **one**
real gap. Everything else either has a dedicated Flutter widget, is covered
by a Material widget the theme already brands (`Divider`, `FloatingActionButton`,
`IconButton`, `NavigationBar` all read the Odyssey `ColorScheme` with zero
wrapper needed), or is a deliberate idiom difference already established
throughout this library (data-driven widgets — `NeptuneAccordion`,
`NeptuneTabs`, `NeptuneStepper` — take a `List<...>` of records rather than
exposing discrete child widgets per item).

- **`NeptuneAppBar` gained `variant`** (`small`/`center`/`medium`/`large`,
  matching web's `<npt-top-app-bar>`): `medium`/`large` reserve the 56dp row
  for leading/actions only and drop a bigger headline (28px / 45px) below it
  — the M3 collapsing-header pattern the Flutter widget was missing
  entirely. Ported with one accessibility improvement over the web source:
  the title stays in the semantics tree via an explicit `Semantics(header:
  true)` wrapper in every variant, rather than the web version's pattern of
  hiding the inline title via `visibility:hidden` (which removes it from the
  accessibility tree) and marking the stacked headline `aria-hidden` (same
  problem) — as shipped, the web component has no accessible title in
  medium/large.

flutter analyze clean · 109 tests pass · CI no-literals gate green.

## 2.12.0 — R6: design evolution

**Density, dark-mode elevation, per-brand motion, feedback tokens, Arabic
numerals, and a new loading/splash widget family.**

- **Dark-mode elevation is a glow, not an invisible shadow.** `NptIdentity`'s
  `elevation1..5` used a fixed dark-shadow recipe that barely registers
  against an already-dark surface; dark mode now lerps toward `primary` with
  more blur and less directional offset, reading as ambient light rather
  than a cast shadow. Light mode is byte-identical to before.
- **Density lever.** `NptDensity` (comfortable/compact, `NeptuneTheme.fromConfig(density:)`)
  scales spacing at density-aware call sites — `NeptuneListTile` and the
  `NeptuneCta` family today; more widgets opt in incrementally.
- **Per-brand signature motion.** `NeptuneCta`'s sheen/nudge cycle length
  used to be a fixed 4800ms/2400ms for every brand; it's now derived from
  the brand's own `motion.slow`/`durationStandard` (Neptune's smooth-fluid
  reproduces the old constants exactly; calmer/snappier brands now visibly
  differ, not just in easing but in tempo).
- **Haptic + sound tokens.** `NptFeedback` (haptics via real
  `HapticFeedback` calls, weighted per brand `contentTone`; `onSoundCue` is
  a plain hook — no bundled audio in this package, see `neptune_sound_kit`)
  fires from `NeptuneCta`, `NeptuneCheckbox`, `NeptuneSwitch`.
- **Arabic-Indic numerals.** `NeptuneNumeralStyle`/`NptNumerals` +
  `NeptuneTheme.formatDigits` — an independent lever from `arabic:` (many
  Gulf/Libyan banking apps run an Arabic UI with Latin digits, or vice
  versa). Wired into `NeptuneBalanceCard`/`NeptuneTransactionRow` today.
- **New loader family** (`neptune_loaders.dart`): `NeptuneSpinner`,
  `NeptuneDotsLoader`, `NeptunePulseLoader`, and `NeptuneHourglassLoader`
  (extracted from `NeptuneStatusMotion` so it's usable standalone).
  `NeptuneStatusMotion` gained `loaderStyle` so any of the four can precede
  the same success/reject morph — one hand-off choreography, four "waiting"
  feelings.
- **`NeptuneSplashScreen`** — the ambient welcome backdrop + a large brand
  mark + a loader, for the cold-start moment before an app has real state.
- **Contrast lift.** Light-mode `tertiary`/`success` fills measured
  3.0–4.4:1 (2.10's audit finding); a small `themes.css` lightness tune
  brings every brand to 4.5–4.6:1, giving body-text headroom above the
  UI-tier floor those pairs are actually held to.

flutter analyze clean · 105 tests pass · CI no-literals gate green.

## 2.11.0

**The colour pipeline is now bidirectional.** `hexToOklch`/`rgb255ToOklch`
invert the existing OKLCH→sRGB path exactly (round-trips a colour through
OKLCH and back to the identical hex) — turn any sampled or picked colour
straight into brandprint seeds. `extractSeedsFromRgba` finds a dominant
primary + a sufficiently-distinct saturated accent from raw decoded pixels
(e.g. a client's logo), the same algorithm as `tools/client-demo`'s Python
extractor, now available to any Dart/Flutter consumer with no Python
dependency.

flutter analyze clean · 83 tests pass · CI no-literals gate green.


## 2.10.0

**`NeptuneDemoShellApp` — a complete branded demo app in ~10 lines.** Hand it
any `BrandprintConfig` (a client's real seeds) and a logo widget; get a
running, navigable, bilingual (EN/AR) app: the Welcome template, then a
5-tab glass-dock shell (Home/Transfer/Cards/Insights/Profile) composed
entirely from the existing screen templates — dashboard, transfer (with the
hourglass→success outcome), cards, an Insights tab built on `NeptuneCompareBars`
+ `NeptuneFxCard` + `NeptuneBudgetRing`, and a Profile tab with dark-mode and
language toggles that re-skin the whole app live.

This formalizes the pattern proven in the first client prototype into a
public, reusable library widget — the foundation for the CLI/desktop
demo-factory tooling. `NeptuneDemoStrings` carries sensible bilingual
defaults for every string; override only what a client wants changed.

Verified end-to-end with a custom (non-reference) brandprint: welcome → every
tab → transfer → confirm → the linked outcome motion → logout, LTR and
RTL-start, zero exceptions.

flutter analyze clean · 74 tests pass · CI no-literals gate green.


## 2.9.0

**The full account-opening onboarding flow (R5)** — modelled on a real
production banking app's onboarding sequence, not a generic wizard. Ten new
template widgets in `lib/src/templates/neptune_onboarding_flow.dart`:

- `NeptuneOtpStepTemplate`, `NeptuneInstructionTemplate` (the reusable
  "how this works" pattern for document/selfie steps).
- `NeptuneDocumentCaptureTemplate` — a document frame drawn with four
  INDEPENDENT corner brackets (not a full rectangle), a colour-coded status
  pill and a shutter that glows once ready.
- `NeptuneSelfieCaptureTemplate` — an oval face guide with colour-coded
  readiness (idle/challenge/aligned) and a large centred countdown numeral.
- `NeptuneOcrReviewTemplate` — read-only OCR fields alongside editable date
  fields, with an optional validation banner.
- `NeptuneOnboardingFormStep` — labelled fields + tappable pickers (branch,
  municipality, job) for the personal/account-details steps.
- `NeptuneAttachmentTile` + `NeptuneDocumentsStep` — dashed-until-attached
  upload tiles (birth certificate, signature).
- `NeptuneTermsTemplate` — scrollable terms with Accept/Decline.
- `NeptuneOnboardingStatusTemplate` — the shared terminal screen: EVERY
  backend outcome (processing, success, manual review, rejected, failed)
  renders through one widget driven by `NeptuneStatusMotion`, plus a
  tap-to-copy detail card and Check-now/Refresh + Leave actions.
- `NeptuneIdentityCorrectionTemplate` — the identity-mismatch recovery screen.

Verified against engine renders of all ten screens (corner-bracket frame,
oval countdown, OCR review, dashed-to-filled attachments, the checkmark
morph) before shipping — not just widget tests.

flutter analyze clean · 72 tests pass · CI no-literals gate green.


## 2.8.0

**State completeness + insights charts (R4b).** Banks judge kits by the
unhappy paths — loading/empty/error is now a first-class contract:

- `NeptuneStateSwitcher` — one wrapper that cross-fades between loading
  (skeleton), error (branded alert + retry), empty (`NeptuneEmptyState`) and
  the ready content, on the brand motion curve.
- `NeptuneShimmer` + `NeptuneSkeletonCard` / `NeptuneSkeletonRow` — a real
  sweeping shimmer (RTL-aware direction) over bones shaped like the actual
  card/row anatomy, not generic grey boxes.
- `NeptuneBarChart` — labelled vertical bars with an optional highlighted
  period and tabular-money caption.
- `NeptuneCompareBars` — paired this-vs-last-period bars per category with a
  computed delta chip (the "vs last month" story from the web Insights tier).

Example gallery gains a States & charts section; SHOTS captures it (fixed
scroll targeting after the previous section grew).

flutter analyze clean · 57 tests pass · CI no-literals gate green.


## 2.7.0

**All nine published templates, composed.** `lib/src/templates/` ships the
full templates.html set as data-parameterised screen widgets (joining
`NeptuneWelcome`): `NeptuneAuthTemplate` (credentials → OTP),
`NeptuneKycTemplate` (capture tiles + tier limit), `NeptuneDashboardTemplate`,
`NeptuneCardsTemplate` (swipeable carousel + controls),
`NeptuneTransferTemplate` (amount → review → hourglass/success outcome),
`NeptuneWalletTemplate` and `NeptuneCorporateTemplate` (responsive side-nav
workspace). Hand them data + callbacks; they wear the active brand — any
brandprint, LTR/RTL, light/dark. The example gallery gains a template browser
and the SHOTS harness captures every template.


## 2.6.1

- Colour canon: brand tables are now GENERATED from themes.css via the repo's
  token codegen (single OKLCH implementation shared with the web). 21 of 296
  role values shift by ±1 LSB — imperceptible — making pinned brands and
  custom-seed generation exactly consistent.
- Fix: `NeptuneSegmented` no longer fails layout (silently blanking the
  subtree) in unbounded-width slots such as `NeptuneListTile.trailing` — it
  shrink-wraps when unbounded, keeps equal-width segments when bounded.
- `NeptuneWelcome` gains `lockup:` for real client logos.
- pub.dev screenshots added.


## 2.6.0

**Templates & motion — the living Odyssey vibes.** The Welcome / Sign-in
template and the animated flourishes from templates.html, ported for real
(engine-rendered screenshots verified per brand), plus a new Odyssey-original
outcome motion:

- `NeptuneStatusMotion` — an animated HOURGLASS (draining sand + flip loop)
  that hands off smoothly to an animated SUCCESS check (stroke-drawn, colour-
  able, defaults to the brand success role) or an animated REJECTED cross
  (stroke-drawn with a decaying shake). The three states are linked through a
  spin-out/spring-in transition on the brand motion curves.
- `NeptuneCta` is now the real premium CTA: a slow SPECULAR SHEEN sweeps the
  pill on the web's 4.8s cycle, the arrow NUDGES (±4dp / 2.4s, mirrors under
  RTL), press scales to 0.98 on the emphasized curve, and the primary
  key-light glow rides underneath. New `tonal:` secondary tone. All motion
  pauses under reduced-motion.
- `NeptuneWelcome` + `NeptuneAmbientBackdrop` + `NeptuneBrandLockup` — the
  full Welcome / Sign-in template: radial brand wash, three soft orbs drifting
  on 15/19/17s loops (static under reduced-motion), the brand lockup with its
  accent dot, and the bold mixed-weight promise (display-w500 + w800 primary).
- Example: "Motion & templates" gallery section + a push-able Welcome route;
  the SHOTS harness now captures pushed routes (boundary moved to
  MaterialApp.builder) and renders the Welcome per brand.


## 2.5.2

Two real layout bugs caught by the full-depth visual sweep (every gallery
viewport × 4 brands × light/dark):

- `NeptuneToolbar` now hands its center slot BOUNDED width (children wrapped in
  `Flexible`). A flex child there (e.g. `NeptuneSearchField`, which contains an
  `Expanded`) previously failed layout and blanked the surrounding subtree.
  Regression-tested with a SearchField in the center slot.
- `NeptuneCreditScoreGauge` honours its `size` under tight constraints (e.g.
  inside `Expanded`) instead of painting a giant arc outside its bounds.

## 2.5.1

Depth polish: `NeptuneCta` now rides elevation-3 with a soft primary key-light
(the web CTA recipe) instead of sitting flat, and `showNeptuneDialog` gets the
deep soft drop (web elevation-5). Verified via the SHOTS harness.

## 2.5.0

**The identity release — Odyssey stops looking like generic Material.** Ports
the web token levers that sit above the M3 colour scheme, so every brand
carries its signature look (verified pixel-by-pixel against the shipped web
templates via engine-rendered screenshots across 4 brands × light/dark × RTL):

- `NptIdentity` theme extension: per-brand glass recipes (`--npt-glass-tint`
  mix ratios + blur), the signature motif lever, elevation tokens
  (`--npt-elevation-1/2/3/5`), the primary key-light glow, and the
  login-shell / dashboard-hero / content-tone levers. Resolves for custom
  brandprint seeds too (keyed off the `glassTint` lever).
- `NeptuneMotifLayer`: the four brand motifs as CustomPainters — Neptune sonar
  tide-rings, Triton coastal arcs, Nereid grid-spark, Proteus shield
  guilloché — ported from the `--npt-motif` CSS gradients.
- `NeptuneGlass`: real backdrop-blur glass with the brand tint and hairline
  seal (card glass + dock pane recipes). `NeptuneCard` with the web's four
  variants (standard / elevated / tonal / glass, `motif:` overlay opt-in).
- `NeptuneEyebrow`: the uppercase, letter-spaced display-face micro-label.
- Widgets now wear the identity: the dock is glass with the raised-active
  circle popping above the bar (sprung on the brand motion curve), card art
  carries the motif + elevation + selection glow, the balance-card hero etches
  the motif over its gradient with the web's display-md amount, onboarding
  heroes get the login-shell motif backdrop, stat cards use the eyebrow.
- Example gallery: fixed phone-frame window on macOS, content scrolls under
  the glass dock, and a `--dart-define=SHOTS=true` harness renders pixel-exact
  gallery screenshots per brand/mode/scroll for visual regression.

## 2.4.0

The "fully fledged" release — ~33 new branded widgets take the package past
Material parity into a complete fintech design system (now ~88 widgets). All
theme-only (no literal colours/radii/fonts), RTL-safe, ≥48dp; 40 widget tests
pass under light/dark/RTL × brands; `flutter analyze` clean.

- Form fields: `NeptuneTextField`, `NeptuneSelect`, `NeptuneStepperInput`,
  `NeptuneDateField`.
- Selection controls: `NeptuneCheckbox`/`NeptuneCheckboxTile`,
  `NeptuneRadioGroup`, `NeptuneSwitch`, `NeptuneSegmented`, `NeptuneSlider`.
- Overlays: `showNeptuneDialog`, `showNeptuneSheet`, `NeptuneMenu`,
  `NeptuneTooltip`.
- Navigation / structure: `NeptuneTabs`, `NeptuneBreadcrumbs`,
  `NeptunePagination`, `NeptuneAccordion`.
- Display: `NeptuneAvatar`/`NeptuneAvatarGroup`, `NeptuneBadge`, `NeptuneTag`,
  `NeptuneProgressBar`, `NeptuneProgressRing`, `NeptuneRating`,
  `NeptuneListTile`, `NeptuneTimeline`.
- Fintech: `NeptuneInsightCard`, `NeptuneFxCard`, `NeptuneBudgetRing`,
  `NeptuneSpendBreakdown`, `NeptuneCreditScoreGauge`.

Mobile-readiness fixes (found by narrow-width testing): `NeptuneAccountTile`
and `NeptuneLimitMeter` trailing values now flex/ellipsize; `NeptuneApprovalItem`
stacks its actions on narrow widths; `NeptuneTabs` no longer requires a bounded
height. The example app gained gallery sections for every new widget.

## 2.3.0

The full solution — real brand typography + the remaining structural widgets.

- **Fonts now render for real.** `NeptuneTheme` integrates `google_fonts`: each
  brand's display / text / num families (Hanken Grotesk, Bricolage Grotesque,
  Space Grotesk, Sora) are loaded and applied to the whole `TextTheme`, and
  `moneyStyle` resolves the brand `num` face with tabular figures.
- **Arabic / RTL faces.** `NptType` now carries the Arabic faces per brand
  (`displayAr` / `textAr` / `numAr` — IBM Plex Sans Arabic, Reem Kufi, Tajawal,
  Readex Pro, Noto Kufi Arabic, matching the web `--npt-font-*-ar` tokens). Pass
  `arabic: true` to `NeptuneTheme.light/dark/fromConfig/fromBrandprint` for an
  RTL build; `moneyStyle` is direction-aware and swaps to the Arabic numeral
  face under RTL, mirroring the web's `[dir="rtl"]` font swap.
- **New widgets:** `NeptuneDataTable` (themed Material `DataTable`, zebra rows,
  numeric/money columns), the responsive shell — `NeptuneAppShell`,
  `NeptuneSideNav` / `NeptuneSideNavItem`, `NeptuneToolbar`, `NeptuneNavRail`
  (Material `NavigationRail`) — plus `NeptuneCardControls`, `NeptuneAddCard`
  (dashed tile), and `NeptuneToast` + `showNeptuneToast` (overlay, no Scaffold
  needed).
- **Example:** a full components-gallery screen showcasing every widget.
- Colour goldens unchanged (byte-identical); `flutter analyze` clean; all
  widget tests pass under light / dark / RTL × 4 brands. COVERAGE.md updated.

## 2.2.0

Widget parity, round 2 — the package now ships ~46 branded widgets (up from 16),
covering the full dashboard / transfer / corporate / wallet surfaces:

- Money inputs: NeptuneAmountInput, NeptuneCurrencyField, NeptuneIbanField,
  NeptuneOtpInput, NeptunePinInput, NeptuneAmountKeypad.
- Money movement: NeptuneStepper, NeptuneTransferReview, NeptuneMethodRow,
  NeptuneBeneficiaryTile, NeptuneSuccess, NeptuneReceipt.
- Data-viz (CustomPainter): NeptuneSparkline, NeptuneDonut, NeptuneLimitMeter,
  NeptuneTrend.
- Corporate: NeptuneApprovalItem, NeptuneBatchCard, NeptuneAuditRow,
  NeptuneUserRow, NeptunePermissionToggle, NeptuneWorkflowStatus.
- Wallet/pay: NeptuneMerchantRow, NeptuneVoucherCard, NeptuneQrPay,
  NeptuneTopupRow, NeptuneTierBadge.
- Feedback/shell: NeptuneAlert, NeptuneBanner, NeptuneEmptyState,
  NeptuneSkeleton, NeptunePageHeader, NeptuneSearchField.

All theme-only (no literals), RTL-safe, ≥48dp; 36 widget tests pass under
light/dark/RTL × 4 brands; flutter analyze clean. COVERAGE.md updated.

## 2.1.0

Widget parity pass — the package now ships **16 branded widgets** (up from 4),
matching the web components shown in the docs templates. New:

- `NeptuneButton` (filled / tonal / outlined / text) + `NeptuneCta` (animated
  pill CTA), `NeptuneStatCard`, `NeptuneCardArt` (gradient card + `selected`
  ring), `NeptuneQuickActions` / `NeptuneQuickAction`, `NeptuneDock` /
  `NeptuneDockItem` (floating nav, raised active indicator), `NeptuneAppBar`,
  `NeptuneOnboarding`, `NeptuneSection`, `NeptuneChip`, `NeptuneStatusChip`.
- A real **example app** (`example/`) — a themed dashboard + onboarding screen
  built only from the widget set.
- Honest **COVERAGE.md** mapping every web component → implemented / Material
  fallback / TODO (nothing silently dropped).
- All widgets theme-only (no literals), RTL-safe, ≥48dp targets;
  `test/widgets_test.dart` builds them under light/dark/RTL × 4 brands.
  `flutter analyze` clean.

## 2.0.0

Aligns the Flutter package with the Neptune Odyssey 2.x line (vendor-neutral, white-label).

- Reference brands are the four neutral demo skins — `neptune` / `triton` / `nereid` /
  `proteus` (no real-institution identity).
- Brandprint strings remain byte-identical to the JS/TS reference and stable across
  versions: a saved `NO1-…` resolves to the same theme on Flutter, Web, React, Vue,
  Svelte and React Native (golden-tested).
- `NeptuneTheme.light` / `.dark` / `.fromBrandprint` / `.fromConfig`; `ThemeExtension`s
  `NptColors` / `NptShape` / `NptType` / `NptMotion`; theme-only widgets (balance card,
  transaction row, account tile, primary button). RTL-safe, ≥48dp targets, no literals.
- 31 golden tests; `flutter analyze` clean.

## 1.0.0

First stable release of the Neptune Odyssey Flutter package by Neptune.Fintech.

- Const M3 `ColorScheme`s for the four reference brands × light/dark, byte-identical
  to the cross-platform pinned palettes (`build/tokens.resolved.json`).
- `ThemeExtension`s: `NptColors` (incl. success roles), `NptShape`, `NptType`, `NptMotion`.
- `NeptuneTheme.light` / `.dark` / `.fromBrandprint` / `.fromConfig` → full
  `ThemeData(useMaterial3: true)`; money uses `FontFeature.tabularFigures()`.
- Brandprint codec (byte-identical to the JS reference, idempotent, checksum-validated)
  and the shared OKLCH→sRGB converter for custom seeds.
- Theme-only widgets (balance card, transaction row, account tile, primary button);
  `EdgeInsetsDirectional` + ≥48dp targets; no literal colours/radii/fonts.
- 31 golden tests; `flutter analyze` clean.
