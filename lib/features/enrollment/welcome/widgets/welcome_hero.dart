import 'package:flutter/material.dart';

import '../../../../core/design/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// The navy header: the AeroPass wordmark and a decorative
/// security-checkpoint illustration. Purely presentational — every fact it
/// suggests is also stated in text elsewhere on the screen (FR-014), so its
/// contents are excluded from the semantics tree.
class WelcomeHero extends StatelessWidget {
  const WelcomeHero({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ExcludeSemantics(
      child: Container(
        color: AppColors.navy,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LogoMark(appName: l10n.appTitle),
            const SizedBox(height: 16),
            const _CheckpointIllustration(),
          ],
        ),
      ),
    );
  }
}

class _LogoMark extends StatelessWidget {
  const _LogoMark({required this.appName});

  final String appName;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.teal,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.arrow_upward_rounded,
            color: Colors.white,
            size: 16,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          appName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}

/// A simplified approximation of the mockup's security-gate illustration
/// (a passenger walking through a checkpoint, flanked by turnstile posts).
/// Built from basic shapes rather than a traced vector, pending a real
/// exported illustration asset.
class _CheckpointIllustration extends StatelessWidget {
  const _CheckpointIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const _TurnstilePost(),
          const SizedBox(width: 28),
          _GateFrame(),
          const SizedBox(width: 28),
          const _TurnstilePost(),
        ],
      ),
    );
  }
}

class _TurnstilePost extends StatelessWidget {
  const _TurnstilePost();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (_) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: AppColors.teal,
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }
}

class _GateFrame extends StatelessWidget {
  const _GateFrame();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 130,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.teal, width: 3),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(48)),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, color: AppColors.teal, size: 22),
          SizedBox(height: 8),
          Icon(Icons.person, color: Colors.white, size: 44),
        ],
      ),
    );
  }
}
