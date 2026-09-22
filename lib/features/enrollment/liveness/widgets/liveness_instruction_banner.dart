import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

import '../../../../domain/entities/liveness_phase.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// The dynamic instruction text (UI Reference: "Acércate un poco" —
/// changes as the capture proceeds, FR-004). Every instruction change is
/// also conveyed through a non-visual channel (FR-005, research.md §6):
/// [SemanticsService.sendAnnouncement] (audible via the platform screen
/// reader) and [HapticFeedback.selectionClick] — a passenger looking into
/// the camera is not reading this text.
class LivenessInstructionBanner extends StatefulWidget {
  const LivenessInstructionBanner({required this.instruction, super.key});

  final LivenessInstruction instruction;

  @override
  State<LivenessInstructionBanner> createState() =>
      _LivenessInstructionBannerState();
}

class _LivenessInstructionBannerState
    extends State<LivenessInstructionBanner> {
  bool _announcedInitial = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_announcedInitial) {
      _announcedInitial = true;
      _announce();
    }
  }

  @override
  void didUpdateWidget(covariant LivenessInstructionBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.instruction != widget.instruction) {
      _announce();
    }
  }

  void _announce() {
    final flutterView = View.of(context);
    SemanticsService.sendAnnouncement(
      flutterView,
      _textFor(widget.instruction),
      TextDirection.ltr,
    );
    HapticFeedback.selectionClick();
  }

  String _textFor(LivenessInstruction instruction) {
    final l10n = AppLocalizations.of(context);
    return switch (instruction) {
      LivenessInstructionMoveCloser() => l10n.livenessInstructionMoveCloser,
      LivenessInstructionMoveBack() => l10n.livenessInstructionMoveBack,
      LivenessInstructionCenterFace() => l10n.livenessInstructionCenterFace,
      LivenessInstructionHoldStill() => l10n.livenessInstructionHoldStill,
      LivenessInstructionLookAtCamera() => l10n.livenessInstructionLookAtCamera,
      LivenessInstructionImproveLighting() =>
        l10n.livenessInstructionImproveLighting,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        _textFor(widget.instruction),
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
