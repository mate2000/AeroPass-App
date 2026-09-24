import 'package:flutter/material.dart';

import '../core/design/app_colors.dart';
import '../l10n/generated/app_localizations.dart';

/// 015 FR-020: while the deployed biometric provider approves every image
/// (R-01), every screen carries this ribbon. It cannot be dismissed, it is
/// in every screenshot, and screen readers read it.
///
/// It takes the status-bar area plus one short row. The top padding is then
/// removed from the page below, so each screen's own `SafeArea` does not pad
/// twice. It is installed in `MaterialApp.builder`, so it wraps every route.
class DemoRibbon extends StatelessWidget {
  const DemoRibbon({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final media = MediaQuery.of(context);
    // Laid out bottom-up, so the ribbon (second) sits on top but is painted
    // after the page. A route's BlockSemantics drops the semantics of
    // everything painted before it, which would silence the ribbon for
    // screen readers.
    return Column(
      verticalDirection: VerticalDirection.up,
      children: [
        Expanded(
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: child,
          ),
        ),
        Semantics(
          container: true,
          label: l10n.demoRibbonSemantics,
          excludeSemantics: true,
          child: Container(
            key: const Key('demo-ribbon'),
            width: double.infinity,
            color: AppColors.demoRibbonBackground,
            padding: EdgeInsets.only(top: media.padding.top, bottom: 2),
            alignment: Alignment.center,
            child: Text(
              l10n.demoRibbonLabel,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.demoRibbonForeground,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
