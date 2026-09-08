// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Branded navigation & structure: tabs, breadcrumbs, pagination and an
// accordion. Colour, shape and type are read from the active theme only — no
// literals. Every interactive target is comfortably tappable. RTL-safe via
// EdgeInsetsDirectional / AlignmentDirectional and direction-aware chevrons.

import 'package:flutter/material.dart';

import '../theme/extensions.dart';

/// How a [NeptuneTabs] strip claims horizontal space.
enum NeptuneTabsWidth {
  /// Each tab is as wide as its own label, the strip sits at the start edge,
  /// and it scrolls horizontally once the labels outrun the width. The default,
  /// and the right choice for a long or open-ended set of tabs.
  hug,

  /// The tabs divide the available width equally and the strip — divider
  /// included — spans it end to end. For a short, fixed set (two or three)
  /// where a start-hugging strip leaves the rest of the width empty.
  ///
  /// There is no horizontal scroll in this mode, so labels that do not fit
  /// their share ellipsize. In a slot that does NOT bound the width the strip
  /// falls back to [hug] rather than blanking (rulebook §4).
  fill,
}

/// A horizontal strip of tab labels with an animated pill/underline indicator
/// beneath the active one (web `<npt-tabs>`). The active label is
/// primary-coloured; inactive labels use [ColorScheme.onSurfaceVariant]. Each
/// tab is at least 48dp tall. [width] decides whether the tabs hug their labels
/// and scroll ([NeptuneTabsWidth.hug], the default) or share the available
/// width ([NeptuneTabsWidth.fill]). Theme-only, RTL-safe.
class NeptuneTabs extends StatelessWidget {
  /// The ordered tab labels.
  final List<String> tabs;

  /// Index of the currently-selected tab.
  final int index;

  /// Called with the tapped tab's index. When null the tabs are non-interactive.
  final ValueChanged<int>? onChanged;

  /// How the strip claims horizontal space. Defaults to
  /// [NeptuneTabsWidth.hug] — the scrolling, start-aligned strip.
  final NeptuneTabsWidth width;

  const NeptuneTabs({
    super.key,
    required this.tabs,
    required this.index,
    this.onChanged,
    this.width = NeptuneTabsWidth.hug,
  });

  @override
  Widget build(BuildContext context) {
    if (width == NeptuneTabsWidth.hug) {
      // A horizontal scroll view hands its child an UNBOUNDED width, which is
      // exactly why a `fill` strip cannot be had by wrapping this one from the
      // outside: no SizedBox, Expanded or stretch ever reaches the row inside.
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: _strip(context, stretch: false),
      );
    }
    // Equal-width tabs when the parent bounds our width; the hugging strip in
    // unbounded slots — flex children in unbounded width silently blank the
    // subtree (rulebook §4, same self-adaptation as NeptuneSegmented).
    return LayoutBuilder(
      builder: (context, constraints) => constraints.hasBoundedWidth
          ? _strip(context, stretch: true)
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: _strip(context, stretch: false),
            ),
    );
  }

  Widget _strip(BuildContext context, {required bool stretch}) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final text = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: BorderDirectional(
          bottom: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      child: Row(
        mainAxisSize: stretch ? MainAxisSize.max : MainAxisSize.min,
        children: [
          for (var i = 0; i < tabs.length; i++)
            if (stretch)
              Expanded(
                child: _Tab(
                  label: tabs[i],
                  selected: i == index,
                  onTap: onChanged == null ? null : () => onChanged!(i),
                  scheme: scheme,
                  shape: shape,
                  text: text,
                ),
              )
            else
              _Tab(
                label: tabs[i],
                selected: i == index,
                onTap: onChanged == null ? null : () => onChanged!(i),
                scheme: scheme,
                shape: shape,
                text: text,
              ),
        ],
      ),
    );
  }
}

/// A single tab label + its underline indicator. The indicator animates between
/// the inactive (transparent) and active (primary) states.
class _Tab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final ColorScheme scheme;
  final NptShape shape;
  final TextTheme text;

  const _Tab({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.scheme,
    required this.shape,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final fg = selected ? scheme.primary : scheme.onSurfaceVariant;

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Align(
                  alignment: AlignmentDirectional.center,
                  child: Text(
                    label,
                    style: text.titleSmall?.copyWith(color: fg),
                    textAlign: TextAlign.center,
                    // No-op while the width is unbounded (hug); the ellipsis is
                    // what a fill tab does with a label wider than its share.
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                height: 3,
                margin: const EdgeInsetsDirectional.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: selected
                      ? scheme.primary
                      : scheme.primary.withValues(alpha: 0),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(shape.full),
                    topRight: Radius.circular(shape.full),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One node in a [NeptuneBreadcrumbs] trail. A null [onTap] renders the crumb as
/// plain (non-interactive) text — typically the current/last crumb.
class NeptuneCrumb {
  /// The crumb's visible label.
  final String label;

  /// Tap handler. When null the crumb is non-interactive.
  final VoidCallback? onTap;

  const NeptuneCrumb(this.label, {this.onTap});
}

/// A breadcrumb trail (web `<npt-breadcrumbs>`): crumbs separated by a
/// direction-aware chevron. Earlier crumbs are primary-coloured and tappable;
/// the last crumb is the current page in [ColorScheme.onSurface]. Wraps onto a
/// new line when it overflows. Theme-only, RTL-safe.
class NeptuneBreadcrumbs extends StatelessWidget {
  /// The ordered trail, root first and current page last.
  final List<NeptuneCrumb> crumbs;

  const NeptuneBreadcrumbs({super.key, required this.crumbs});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final text = Theme.of(context).textTheme;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final chevron =
        isRtl ? Icons.chevron_left_rounded : Icons.chevron_right_rounded;

    final children = <Widget>[];
    for (var i = 0; i < crumbs.length; i++) {
      final crumb = crumbs[i];
      final isLast = i == crumbs.length - 1;
      final interactive = crumb.onTap != null && !isLast;

      final label = Text(
        crumb.label,
        style: text.labelLarge?.copyWith(
          color: isLast ? scheme.onSurface : scheme.primary,
        ),
      );

      children.add(
        interactive
            ? Material(
                type: MaterialType.transparency,
                borderRadius: shape.rXs,
                child: InkWell(
                  onTap: crumb.onTap,
                  borderRadius: shape.rXs,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    child: label,
                  ),
                ),
              )
            : Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 6,
                  vertical: 4,
                ),
                child: label,
              ),
      );

      if (!isLast) {
        children.add(
          Icon(chevron, size: 18, color: scheme.onSurfaceVariant),
        );
      }
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
    );
  }
}

/// A windowed pager (web `<npt-pagination>`): a previous chevron, a run of
/// page-number pills centred on the current [page], and a next chevron. The
/// active pill is a filled [ColorScheme.primary]; the rest are tonal
/// surface-containers. Prev is disabled on the first page and next on the last.
/// Targets are at least 40dp. Theme-only, RTL-safe.
class NeptunePagination extends StatelessWidget {
  /// The current zero-based page index.
  final int page;

  /// The total number of pages.
  final int pageCount;

  /// Called with the requested page index. When null the pager is read-only.
  final ValueChanged<int>? onChanged;

  /// How many number pills to show in the window.
  static const int _window = 5;

  const NeptunePagination({
    super.key,
    required this.page,
    required this.pageCount,
    this.onChanged,
  });

  /// The inclusive run of page indices visible in the window, clamped to range.
  List<int> _visiblePages() {
    if (pageCount <= 0) return const [];
    const half = _window ~/ 2;
    var start = page - half;
    var end = page + half;
    if (start < 0) {
      end -= start;
      start = 0;
    }
    if (end > pageCount - 1) {
      start -= end - (pageCount - 1);
      end = pageCount - 1;
    }
    if (start < 0) start = 0;
    return [for (var i = start; i <= end; i++) i];
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final canPrev = page > 0;
    final canNext = page < pageCount - 1;

    void go(int p) {
      if (onChanged != null && p >= 0 && p < pageCount && p != page) {
        onChanged!(p);
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ArrowButton(
          icon:
              isRtl ? Icons.chevron_right_rounded : Icons.chevron_left_rounded,
          onTap: canPrev && onChanged != null ? () => go(page - 1) : null,
          scheme: scheme,
        ),
        const SizedBox(width: 8),
        for (final p in _visiblePages()) ...[
          _PagePill(
            page: p,
            active: p == page,
            onTap: onChanged != null ? () => go(p) : null,
            scheme: scheme,
          ),
          const SizedBox(width: 8),
        ],
        _ArrowButton(
          icon:
              isRtl ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
          onTap: canNext && onChanged != null ? () => go(page + 1) : null,
          scheme: scheme,
        ),
      ],
    );
  }
}

/// A 40dp circular prev/next control. A null [onTap] renders the disabled
/// (dimmed) state.
class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final ColorScheme scheme;

  const _ArrowButton({
    required this.icon,
    required this.onTap,
    required this.scheme,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final fg =
        enabled ? scheme.onSurface : scheme.onSurfaceVariant.withValues(alpha: 0.38);

    return Material(
      color: scheme.surfaceContainerHigh,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 20, color: fg),
        ),
      ),
    );
  }
}

/// A single page-number pill. The active page is a filled [ColorScheme.primary];
/// inactive pages are tonal surface-containers. At least 40dp square.
class _PagePill extends StatelessWidget {
  final int page;
  final bool active;
  final VoidCallback? onTap;
  final ColorScheme scheme;

  const _PagePill({
    required this.page,
    required this.active,
    required this.onTap,
    required this.scheme,
  });

  @override
  Widget build(BuildContext context) {
    final shape = Theme.of(context).extension<NptShape>()!;
    final text = Theme.of(context).textTheme;
    final bg = active ? scheme.primary : scheme.surfaceContainerHigh;
    final fg = active ? scheme.onPrimary : scheme.onSurfaceVariant;

    return Material(
      color: bg,
      borderRadius: shape.rSm,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        customBorder: RoundedRectangleBorder(borderRadius: shape.rSm),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 8),
            child: Center(
              widthFactor: 1,
              child: Text(
                '${page + 1}',
                style: text.labelLarge?.copyWith(color: fg),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One collapsible panel in a [NeptuneAccordion].
class NeptuneAccordionPanel {
  /// The header title.
  final String title;

  /// The body revealed when the panel is expanded.
  final Widget child;

  /// Whether the panel starts expanded.
  final bool initiallyExpanded;

  const NeptuneAccordionPanel({
    required this.title,
    required this.child,
    this.initiallyExpanded = false,
  });
}

/// A stack of collapsible panels (web `<npt-accordion>`): each panel has a
/// tappable header (title + an animated chevron) over an animated body. The
/// surface is a rounded surface-container-low with outline-variant dividers
/// between panels. When [allowMultiple] is false, opening a panel collapses the
/// others. Expansion state is managed internally. Theme-only, RTL-safe.
class NeptuneAccordion extends StatefulWidget {
  /// The panels, top to bottom.
  final List<NeptuneAccordionPanel> panels;

  /// When true, more than one panel may be open at once.
  final bool allowMultiple;

  const NeptuneAccordion({
    super.key,
    required this.panels,
    this.allowMultiple = false,
  });

  @override
  State<NeptuneAccordion> createState() => _NeptuneAccordionState();
}

class _NeptuneAccordionState extends State<NeptuneAccordion> {
  late final Set<int> _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = {
      for (var i = 0; i < widget.panels.length; i++)
        if (widget.panels[i].initiallyExpanded) i,
    };
  }

  void _toggle(int i) {
    setState(() {
      if (_expanded.contains(i)) {
        _expanded.remove(i);
      } else {
        if (!widget.allowMultiple) _expanded.clear();
        _expanded.add(i);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: shape.rLg,
        border: Border.fromBorderSide(BorderSide(color: scheme.outlineVariant)),
      ),
      child: ClipRRect(
        borderRadius: shape.rLg,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < widget.panels.length; i++) ...[
              if (i > 0)
                Divider(height: 1, thickness: 1, color: scheme.outlineVariant),
              _AccordionTile(
                panel: widget.panels[i],
                expanded: _expanded.contains(i),
                onTap: () => _toggle(i),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A single accordion header + animated body.
class _AccordionTile extends StatelessWidget {
  final NeptuneAccordionPanel panel;
  final bool expanded;
  final VoidCallback onTap;

  const _AccordionTile({
    required this.panel,
    required this.expanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        panel.title,
                        style: text.titleSmall?.copyWith(
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      turns: expanded ? 0.5 : 0,
                      child: Icon(
                        Icons.expand_more_rounded,
                        size: 22,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
          sizeCurve: Curves.easeOut,
          firstCurve: Curves.easeOut,
          secondCurve: Curves.easeOut,
          crossFadeState:
              expanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          firstChild: Container(
            width: double.infinity,
            padding: const EdgeInsetsDirectional.only(
              start: 16,
              end: 16,
              bottom: 16,
            ),
            child: DefaultTextStyle.merge(
              style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
              child: panel.child,
            ),
          ),
          secondChild: const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}
