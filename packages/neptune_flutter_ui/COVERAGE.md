# Flutter coverage vs the web component set

Neptune Odyssey ships **89 web components**. The Flutter package gives you:

1. **Tab width control (2.22.0).** `NeptuneTabs.width` takes
   `NeptuneTabsWidth.hug` (default — labels hug their own width at the start
   edge, strip scrolls) or `.fill` (tabs divide the available width, divider
   spans it end to end, over-long labels ellipsize). Hosts could not do this
   from the outside: the hugging strip's horizontal `SingleChildScrollView`
   hands its row an unbounded width, so no external constraint reaches the
   tabs. Honest scope: Flutter only — the web `<npt-tabs>` has no equivalent
   attribute yet, so this is a Flutter-ahead capability, not parity.
1. **Host icon sets + a host FAB (2.15.0).** White-label chrome no longer means
   Material glyphs: `NeptuneDockItem`, `NeptuneQuickAction` and
   `NeptuneAccountTile` each take an optional `iconWidget` next to `icon`, so a
   bank ships its own designed marks (SVG, `ImageIcon`, lettermark) and they
   inherit the exact active/inactive tint the glyph would have had — via
   `IconTheme` + `DefaultTextStyle`, never a forced colour filter, so
   multi-colour marks survive; a monochrome mark should inherit `currentColor`.
   `NeptuneDock.centerGap`/`centerGapWidth` reserve inert space mid-row so an
   app with a centre floating action button can adopt the dock (the host owns
   the button; the glass pane and raised-active spring are untouched). Honest
   scope: only these three widgets carry the slot so far — the rest of the
   icon-bearing set (`NeptuneListTile`, `NeptuneMethodRow`,
   `NeptuneSideNavItem`, `NeptuneNavRailItem`, `NeptuneTopupRow`,
   `NeptuneMerchantRow` …) is still `IconData`-only and extends the same way
   when a client needs it.
1. **Unlock ritual (2.14.0).** `NeptuneUnlockReveal` — the "swipe up to open"
   returning-user lock screen: a primary canvas with a pill-shaped cutout
   revealing the brand gradient + motif behind it; drag up to unlock (spring
   back below the ~60% threshold), tap-to-unlock as the accessible
   activation, cross-fade under reduced motion. Odyssey-original, beyond the
   web set.
1. **Full-suite audit (2.13.0 / R9).** All 89 web custom elements checked
   against Flutter for genuine capability gaps (not naming diffs) — one
   found and fixed: `NeptuneAppBar` gained the M3 `medium`/`large`
   collapsing-header variants `<npt-top-app-bar>` has. Everything else is
   either a dedicated widget, covered by a Material widget the theme already
   brands (`Divider`, FAB, `IconButton`, `NavigationBar`), or an established
   data-driven idiom (`NeptuneAccordion`/`NeptuneTabs`/`NeptuneStepper` take
   a `List<...>` rather than discrete per-item child widgets).
1. **Design evolution (2.12.0 / R6).** Density + Arabic-numeral levers,
   dark-mode elevation as a glow rather than an invisible shadow, per-brand
   signature CTA motion timing, haptic/sound feedback tokens (`NptFeedback`;
   sound wiring lives in the optional `neptune_sound_kit` package), and a new
   standalone loader family (`NeptuneSpinner`/`NeptuneDotsLoader`/`NeptunePulseLoader`/`NeptuneHourglassLoader`)
   + `NeptuneSplashScreen`, all feeding the same `NeptuneStatusMotion` hand-off.
1. **Theme parity — guaranteed.** `NeptuneTheme.light/dark(brand)` (or `.fromBrandprint`) returns a full Material 3 `ThemeData`, so **every Material widget** is already on-brand — resolved byte-identically from the same brandprint (golden-tested). You're never blocked.
2. **Real brand typography.** The theme loads each brand's display / text / num faces via `google_fonts` and applies them across the whole `TextTheme`; `NeptuneTheme.moneyStyle` renders amounts in the brand `num` face with tabular figures. Pass `arabic: true` (or run under RTL) and the Arabic faces (IBM Plex Sans Arabic, Reem Kufi, Tajawal, Readex Pro, Noto Kufi Arabic) take over, mirroring the web `--npt-font-*-ar` tokens; `moneyStyle` swaps to the Arabic numeral face under RTL.
3. **~88 branded widgets** — past Material parity into a complete fintech design system. All theme-only (no literals), RTL-safe (`EdgeInsetsDirectional`), ≥48dp targets, covered by `test/widgets_test.dart` (build under light/dark/RTL × 4 brands; 40 tests).
4. **NeptuneDemoShellApp (2.10.0).** A complete branded demo app (Welcome + 5-tab dock shell) from any `BrandprintConfig` + logo in ~10 lines, composed entirely from the existing templates — the foundation for client-demo tooling.
5. **Onboarding flow (2.9.0).** Ten template widgets covering the full account-opening sequence — OTP, instructions, document capture (corner-bracket frame), selfie capture (oval + countdown), OCR review, personal/account-detail form steps, document attachments, terms, the shared terminal status screen (`NeptuneOnboardingStatusTemplate`, built on `NeptuneStatusMotion`), and identity-correction recovery. Modelled on a real production onboarding sequence.
6. **State completeness + charts (2.8.0).** `NeptuneStateSwitcher` makes loading/empty/error a first-class, cross-fading contract; `NeptuneShimmer`/`NeptuneSkeletonCard`/`NeptuneSkeletonRow` give real anatomy-shaped placeholders; `NeptuneBarChart`/`NeptuneCompareBars` round out Insights with labelled bars and this-vs-last-period comparison.
7. **Screen templates (2.7.0).** All nine templates.html screens ship as composed, data-parameterised widgets in `lib/src/templates/` — auth/OTP, KYC, retail dashboard, cards (carousel + controls), transfer flow (with the hourglass→outcome motion), wallet home, corporate approvals — plus `NeptuneWelcome`. See the example template browser.
8. **Templates & motion (2.6.0).** The Welcome / Sign-in template ships for real: `NeptuneWelcome` (+ `NeptuneAmbientBackdrop`, `NeptuneBrandLockup`) with the ambient orb backdrop, and `NeptuneCta` is the true animated CTA (specular sheen sweep, nudging arrow, press-scale, key-light — reduced-motion safe). `NeptuneStatusMotion` adds the Odyssey-original hourglass → animated success-check / rejected-cross outcome flow with linked transitions.
9. **The Odyssey identity layer (2.5.0).** `NptIdentity` carries the web's above-M3 levers: per-brand **glass** (tint ratios + blur → `NeptuneGlass`), the **signature motif** (`NeptuneMotifLayer`: sonar tide-rings / coastal arcs / grid-spark / shield guilloché), **elevation + glow tokens**, and the login-shell/dashboard-hero/content-tone names. The dock is real glass with the raised-active indicator, card art and hero balance cards carry the motif over the brand gradient, and `NeptuneEyebrow` gives the tracked-uppercase micro-label. This is what makes the Flutter widgets read as *Odyssey*, not generic Material — same recipes as `themes.css`, resolved per brandprint (custom seeds included).

Honest status — nothing silently dropped.

## ✅ Implemented branded widgets
| Group | Flutter widgets | Web |
|---|---|---|
| Cards / finance | `NeptuneBalanceCard`, `NeptuneStatCard`, `NeptuneTransactionRow`, `NeptuneAccountTile` (+`iconWidget`), `NeptuneCardArt` (+`selected`) | `npt-balance-card`, `npt-stat-card`, `npt-transaction-row`, `npt-card-row`, `npt-card-art` |
| Actions | `NeptuneButton` (filled/tonal/outlined/text), `NeptunePrimaryButton`, `NeptuneCta`, `NeptuneQuickActions`/`NeptuneQuickAction` (+`iconWidget`) | `npt-button`, `npt-cta`, `npt-quick-actions` |
| Navigation / shell | `NeptuneDock` (+`centerGap`)/`NeptuneDockItem` (+`iconWidget`), `NeptuneAppBar`, `NeptunePageHeader`, `NeptuneSection`, `NeptuneSearchField`, `NeptuneAppShell`, `NeptuneSideNav`/`NeptuneSideNavItem`, `NeptuneToolbar`, `NeptuneNavRail`/`NeptuneNavRailItem` | `npt-dock`, `npt-app-bar`, `npt-page-header`, `npt-section`, `npt-search-field`, `npt-app-shell`, `npt-side-nav`, `npt-side-nav-item`, `npt-toolbar`, `npt-nav-rail` |
| Card management | `NeptuneCardControls`, `NeptuneAddCard` | `npt-card-controls`, `npt-add-card` |
| Data | `NeptuneDataTable`/`NeptuneColumn` | `npt-data-table` |
| Onboarding | `NeptuneOnboarding` | `npt-onboarding` |
| Money inputs | `NeptuneAmountInput`, `NeptuneCurrencyField`, `NeptuneIbanField`, `NeptuneOtpInput`, `NeptunePinInput`, `NeptuneAmountKeypad` | `npt-amount-input`, `npt-currency-field`, `npt-iban-field`, `npt-otp-input`, `npt-pin-input`, `npt-amount-keypad` |
| Money movement | `NeptuneStepper`, `NeptuneTransferReview`, `NeptuneMethodRow`, `NeptuneBeneficiaryTile`, `NeptuneSuccess`, `NeptuneReceipt` | `npt-stepper`, `npt-transfer-review`, `npt-method-row`, `npt-beneficiary-tile`, `npt-success`, `npt-receipt` |
| Data-viz | `NeptuneSparkline`, `NeptuneDonut`, `NeptuneLimitMeter`, `NeptuneTrend` | `npt-sparkline`, `npt-donut`, `npt-limit-meter`, `npt-trend` |
| Corporate | `NeptuneApprovalItem`, `NeptuneBatchCard`, `NeptuneAuditRow`, `NeptuneUserRow`, `NeptunePermissionToggle`, `NeptuneWorkflowStatus` | `npt-approval-item`, `npt-batch-card`, `npt-audit-row`, `npt-user-row`, `npt-permission-toggle`, `npt-workflow-status` |
| Wallet / pay | `NeptuneMerchantRow`, `NeptuneVoucherCard`, `NeptuneQrPay`, `NeptuneTopupRow`, `NeptuneTierBadge` | `npt-merchant-row`, `npt-voucher-card`, `npt-qr-pay`, `npt-topup-row`, `npt-tier-badge` |
| Feedback | `NeptuneChip`, `NeptuneStatusChip`, `NeptuneAlert`, `NeptuneBanner`, `NeptuneEmptyState`, `NeptuneSkeleton`, `NeptuneToast` + `showNeptuneToast` | `npt-chip`, `npt-status-chip`, `npt-alert`, `npt-banner`, `npt-empty-state`, `npt-skeleton`, `npt-snackbar`/`npt-toast` |
| Form fields | `NeptuneTextField`, `NeptuneSelect`/`NeptuneSelectOption`, `NeptuneStepperInput`, `NeptuneDateField` | `npt-text-field`, `npt-select`, `npt-stepper`, `npt-date-field` |
| Selection controls | `NeptuneCheckbox`/`NeptuneCheckboxTile`, `NeptuneRadioGroup`/`NeptuneRadioOption`, `NeptuneSwitch`, `NeptuneSegmented`/`NeptuneSegment`, `NeptuneSlider` | `npt-checkbox`, `npt-radio`, `npt-switch`, `npt-segmented-button`, `npt-slider` |
| Overlays | `showNeptuneDialog`/`NeptuneDialogAction`, `showNeptuneSheet`, `NeptuneMenu`/`NeptuneMenuItem`, `NeptuneTooltip` | `npt-dialog`, `npt-bottom-sheet`, `npt-menu`, `npt-tooltip` |
| Navigation / structure | `NeptuneTabs`, `NeptuneBreadcrumbs`/`NeptuneCrumb`, `NeptunePagination`, `NeptuneAccordion`/`NeptuneAccordionPanel` | `npt-tabs`, `npt-breadcrumbs`, `npt-pagination`, `npt-accordion` |
| Display | `NeptuneAvatar`/`NeptuneAvatarGroup`, `NeptuneBadge`, `NeptuneTag`, `NeptuneProgressBar`, `NeptuneProgressRing`, `NeptuneRating`, `NeptuneListTile`, `NeptuneTimeline`/`NeptuneTimelineEntry` | `npt-avatar`, `npt-badge`, `npt-tag`, `npt-progress`, `npt-rating`, `npt-list`, `npt-timeline` |
| Fintech (premium) | `NeptuneInsightCard`, `NeptuneFxCard`, `NeptuneBudgetRing`, `NeptuneSpendBreakdown`/`NeptuneSpendSlice`, `NeptuneCreditScoreGauge` | beyond the web set — Flutter-first |
| Auth / unlock | `NeptuneUnlockReveal` (swipe-up unlock ritual) | beyond the web set — Flutter-first |

See `example/lib/main.dart` for a live components gallery (every widget, with brand / dark / RTL toggles) plus the onboarding hero.

## ≈ Use a themed Material widget (no wrapper needed)
A few primitives are still best served straight from themed Material: `npt-divider`→`Divider`, `npt-nav-bar`→`NavigationBar` (or `NeptuneDock`), `npt-icon-button/fab`→`IconButton`/`FloatingActionButton`, `npt-card`→`Card`, `npt-snackbar`→`SnackBar` (or `showNeptuneToast`). Everything else now has a branded wrapper.

## ⬜ Remaining TODO (niche)
Live hardware-backed flows only: `npt-merchant`/QR **live camera scanning** (the static `NeptuneQrPay` presentation widget ships; live capture is app-level via a camera plugin). Everything structural is now implemented.

© 2026 Neptune.Fintech (neptune.ly).
