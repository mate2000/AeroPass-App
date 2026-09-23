import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../app/router.dart';
import '../../core/design/app_colors.dart';
import '../../core/happy_path_flags.dart';
import '../../domain/entities/pass.dart';
import '../../l10n/generated/app_localizations.dart';
import '../trips/trip_time_format.dart';
import 'pass_viewmodel.dart';
import 'widgets/journey_stepper.dart';
import 'widgets/qr_code_painter.dart';
import 'widgets/rotation_ring.dart';

/// Screen 14, "QR Pase" (014-qr-pase). Composition only (Principle VIII).
///
/// A code is drawn only in [PassShowing]. Every other state shows its reason
/// and a way forward, and the conventional checkpoint is always stated
/// (FR-013). "Simular expirado" exists only behind the release-refused
/// `DEV_PASS_CONTROLS` flag (FR-019).
class PassView extends StatefulWidget {
  const PassView({required this.viewModel, super.key});

  final PassViewModel viewModel;

  @override
  State<PassView> createState() => _PassViewState();
}

class _PassViewState extends State<PassView> {
  static final _time = DateFormat('H:mm');
  int _announcedRotations = 0;

  PassViewModel get _viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onChanged);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onChanged);
    super.dispose();
  }

  /// "Código actualizado" once per rotation, not every second.
  void _onChanged() {
    if (!mounted || _viewModel.rotations == _announcedRotations) return;
    _announcedRotations = _viewModel.rotations;
    SemanticsService.sendAnnouncement(
      View.of(context),
      AppLocalizations.of(context).passCodeUpdated,
      TextDirection.ltr,
    );
  }

  void _openHelp() {
    _viewModel.onHelpOpened();
    context.push(AppRoutes.help);
  }

  String _tripLine(AppLocalizations l10n) {
    final trip = _viewModel.trip;
    final departure = _viewModel.departure;
    if (trip == null || departure == null) return '';
    final time = _time.format(departure.local);
    final when = switch (departure.day) {
      TripDay.today => l10n.tripsToday(time),
      TripDay.tomorrow => l10n.tripsTomorrow(time),
      TripDay.other => l10n.tripsOnDate(
        DateFormat('d MMM', 'es').format(departure.local),
        time,
      ),
    };
    return l10n.passTripLine(
      trip.flightNumber,
      trip.origin.code,
      trip.destination.code,
      when,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            final state = _viewModel.state;
            final trip = _viewModel.trip;
            final pass = state is PassShowing ? state.pass : null;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    children: [
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.navy,
                        ),
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.chevron_left),
                        label: Text(l10n.passBack),
                      ),
                      const Spacer(),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.navy,
                        ),
                        onPressed: _openHelp,
                        child: Text(l10n.passHelp),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_viewModel.holderName != null)
                              Text(
                                _viewModel.holderName!,
                                style: textTheme.titleLarge?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            if (trip != null)
                              Text(
                                _tripLine(l10n),
                                style: textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (trip?.seat != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE6F7F5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            l10n.passSeat(trip!.seat!),
                            style: textTheme.labelMedium?.copyWith(
                              color: const Color(0xFF0E6B60),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  child: JourneyStepper(
                    validated: switch (state) {
                      PassShowing(:final pass) => pass.validated,
                      PassBoardedView() => Checkpoint.values.toSet(),
                      _ => const {},
                    },
                    current: pass?.nextCheckpoint,
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                    child: switch (state) {
                      PassLoading() => const Padding(
                        padding: EdgeInsets.all(48),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      PassShowing(:final pass, :final code) => _Showing(
                        viewModel: _viewModel,
                        pass: pass,
                        payload: code.payload,
                      ),
                      PassBoardedView() => const _Boarded(),
                      PassUnavailable(:final reason) => _Unavailable(
                        reason: reason,
                        viewModel: _viewModel,
                      ),
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F5F7),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (pass != null)
                          Text(
                            pass.nextCheckpoint == Checkpoint.security
                                ? l10n.passFooterSecurity
                                : l10n.passFooterBoarding,
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        if (pass != null) const SizedBox(height: 4),
                        Text(
                          l10n.passCheckpointLine,
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Showing extends StatelessWidget {
  const _Showing({
    required this.viewModel,
    required this.pass,
    required this.payload,
  });

  final PassViewModel viewModel;
  final Pass pass;
  final String payload;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final seconds = viewModel.secondsLeft;
    final countdown =
        '${(seconds ~/ 60).toString().padLeft(2, '0')}:'
        '${(seconds % 60).toString().padLeft(2, '0')}';
    return Column(
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: RotationRing(
            fractionLeft: viewModel.windowFractionLeft,
            child: QrCodeView(
              payload: payload,
              semanticLabel: l10n.passCodeSemantics,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.passRefreshesIn(countdown),
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: AppColors.textSecondary),
        ),
        // FR-019: absent from any build without the release-refused flag.
        if (HappyPathFlags.devPassControls && viewModel.canDevExpire)
          TextButton(
            onPressed: viewModel.devExpire,
            child: Text(l10n.passDevExpire),
          ),
      ],
    );
  }
}

class _Boarded extends StatelessWidget {
  const _Boarded();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        const SizedBox(height: 24),
        const ExcludeSemantics(
          child: Icon(
            Icons.flight_takeoff,
            size: 56,
            color: AppColors.turquoise,
          ),
        ),
        const SizedBox(height: 16),
        Semantics(
          header: true,
          child: Text(
            l10n.passBoardedTitle,
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.passBoardedBody,
          style: textTheme.titleMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _Unavailable extends StatelessWidget {
  const _Unavailable({required this.reason, required this.viewModel});

  final PassUnavailableReason reason;
  final PassViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final (title, body) = switch (reason) {
      PassUnavailableReason.expired => (l10n.passExpiredTitle, null),
      PassUnavailableReason.revoked => (l10n.passRevokedTitle, null),
      PassUnavailableReason.flightCancelled => (
        l10n.passFlightCancelledTitle,
        null,
      ),
      PassUnavailableReason.flightChanged => (
        l10n.passFlightChangedTitle,
        null,
      ),
      PassUnavailableReason.untrustedClock => (
        l10n.passClockTitle,
        l10n.passClockBody,
      ),
      PassUnavailableReason.compromisedDevice => (
        l10n.passCompromisedTitle,
        null,
      ),
      PassUnavailableReason.issuanceFailed => (
        l10n.passIssuanceFailedTitle,
        null,
      ),
      PassUnavailableReason.offlineWithoutPass => (l10n.passOfflineTitle, null),
    };
    final (String label, VoidCallback onPressed) = switch (reason) {
      PassUnavailableReason.expired => (
        l10n.passRequestNew,
        viewModel.requestNewPass,
      ),
      PassUnavailableReason.revoked ||
      PassUnavailableReason.flightCancelled ||
      PassUnavailableReason.flightChanged => (
        l10n.passBackToTrips,
        () => context.go(AppRoutes.trips),
      ),
      PassUnavailableReason.compromisedDevice => (
        l10n.passTalkToAgent,
        () => context.push(AppRoutes.agentEscalation),
      ),
      PassUnavailableReason.untrustedClock ||
      PassUnavailableReason.issuanceFailed ||
      PassUnavailableReason.offlineWithoutPass => (
        l10n.passRetry,
        viewModel.retry,
      ),
    };
    return Column(
      children: [
        const SizedBox(height: 24),
        const ExcludeSemantics(
          child: Icon(Icons.qr_code_2, size: 56, color: AppColors.slate),
        ),
        const SizedBox(height: 16),
        Semantics(
          header: true,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: textTheme.titleLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (body != null) ...[
          const SizedBox(height: 8),
          Text(
            body,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
        const SizedBox(height: 20),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.navy,
            minimumSize: const Size.fromHeight(52),
          ),
          onPressed: onPressed,
          child: Text(label),
        ),
      ],
    );
  }
}
