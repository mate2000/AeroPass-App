import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/design/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';
import 'trip_time_format.dart';
import 'trips_home_viewmodel.dart';
import 'widgets/credential_strip.dart';
import 'widgets/next_trip_card.dart';
import 'widgets/trip_history_list.dart';

/// Screen 12, "Mis viajes" (012-mis-viajes). Composition only
/// (Principle VIII). The tab bar belongs to the shell around it.
class TripsHomeView extends StatefulWidget {
  const TripsHomeView({required this.viewModel, super.key});

  final TripsHomeViewModel viewModel;

  @override
  State<TripsHomeView> createState() => _TripsHomeViewState();
}

class _TripsHomeViewState extends State<TripsHomeView> {
  final _scrollController = ScrollController();
  final _historyKey = GlobalKey();

  TripsHomeViewModel get _viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onChanged);
    _scrollController.addListener(_checkHistoryVisible);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onChanged);
    _scrollController.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkHistoryVisible());
    final target = _viewModel.pendingNavigation;
    if (target == null) return;
    if (!(ModalRoute.of(context)?.isCurrent ?? true)) return;
    _viewModel.consumeNavigation();
    switch (target) {
      case TripsHomeTarget.startTrip:
        context
            .push(AppRoutes.tripVerification)
            .then((_) => _viewModel.onReturned());
      case TripsHomeTarget.viewPass:
        context.push(AppRoutes.pass).then((_) => _viewModel.onReturned());
      case TripsHomeTarget.welcome:
        context.go(AppRoutes.welcome);
    }
  }

  /// FR-016: "history opened" is the section first scrolling into view.
  void _checkHistoryVisible() {
    if (!mounted) return;
    final box = _historyKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return;
    final top = box.localToGlobal(Offset.zero).dy;
    if (top < MediaQuery.sizeOf(context).height) _viewModel.onHistoryVisible();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return ColoredBox(
      color: const Color(0xFFF3F5F7),
      child: SafeArea(
        bottom: false,
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            final summary = _viewModel.summary;
            final trip = _viewModel.nextTrip;
            final departure = _viewModel.nextDeparture;
            final history = _viewModel.history;
            final greeting = switch (_viewModel.greeting) {
              Greeting.morning => l10n.tripsGreetingMorning,
              Greeting.afternoon => l10n.tripsGreetingAfternoon,
              Greeting.evening => l10n.tripsGreetingEvening,
            };
            return ListView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              greeting,
                              style: textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            if (_viewModel.firstName != null)
                              Text(
                                _viewModel.firstName!,
                                style: textTheme.headlineSmall?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    ExcludeSemantics(
                      child: InitialsAvatar(
                        initials: CredentialStrip.initialsOf(
                          summary?.holderName,
                        ),
                        size: 44,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                CredentialStrip(summary: summary),
                const SizedBox(height: 24),
                if (!_viewModel.loaded && trip == null)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (trip != null && departure != null) ...[
                  _SectionHeading(l10n.tripsNextHeading),
                  NextTripCard(
                    trip: trip,
                    departure: departure,
                    action: _viewModel.action,
                    stale: _viewModel.tripsStale,
                    minutesSinceFetched: _viewModel.minutesSinceTripsFetched,
                    onStart: _viewModel.startTrip,
                    onViewPass: _viewModel.viewPass,
                  ),
                ] else if (_viewModel.tripsUnavailable)
                  _UnavailableTrips(onRetry: _viewModel.retryTrips)
                else
                  const _EmptyTrips(),
                if (history.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  KeyedSubtree(
                    key: _historyKey,
                    child: _SectionHeading(l10n.tripsHistoryHeading),
                  ),
                  TripHistoryList(trips: history),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Semantics(
      header: true,
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    ),
  );
}

/// FR-011: how a trip appears, with nothing for the passenger to do.
class _EmptyTrips extends StatelessWidget {
  const _EmptyTrips();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const ExcludeSemantics(
            child: Icon(Icons.flight_takeoff, size: 40, color: AppColors.navy),
          ),
          const SizedBox(height: 12),
          Semantics(
            header: true,
            child: Text(
              l10n.tripsEmptyTitle,
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.tripsEmptyBody,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// FR-013: no trips read yet this session, and the read failed.
class _UnavailableTrips extends StatelessWidget {
  const _UnavailableTrips({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            l10n.tripsUnavailableTitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: onRetry, child: Text(l10n.tripsRetry)),
        ],
      ),
    );
  }
}
