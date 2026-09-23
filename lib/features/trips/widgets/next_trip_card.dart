import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../../core/design/app_colors.dart';
import '../../../domain/entities/trip.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../trip_time_format.dart';
import '../trips_home_viewmodel.dart';

/// "PRÓXIMO VIAJE" (012-mis-viajes FR-004–FR-009, FR-014, FR-015).
///
/// Everything on it comes from the trip source: route, flight, departure in
/// the airport's clock, status, and gate and seat only when the airline has
/// a live integration. The action slot shows "Iniciar viaje" or the stated
/// reason it is not offered. The route is read as one sentence with city
/// names, never spelled-out codes.
class NextTripCard extends StatelessWidget {
  const NextTripCard({
    required this.trip,
    required this.departure,
    required this.action,
    required this.stale,
    required this.minutesSinceFetched,
    required this.onStart,
    required this.onViewPass,
    super.key,
  });

  final Trip trip;
  final DepartureDescription departure;
  final TripAction action;
  final bool stale;
  final int minutesSinceFetched;
  final VoidCallback onStart;
  final VoidCallback onViewPass;

  static final _time = DateFormat('H:mm');

  static String whenLabel(
    AppLocalizations l10n,
    DepartureDescription departure,
    String city,
  ) {
    final time = _time.format(departure.local);
    final when = switch (departure.day) {
      TripDay.today => l10n.tripsToday(time),
      TripDay.tomorrow => l10n.tripsTomorrow(time),
      TripDay.other => l10n.tripsOnDate(
        DateFormat('d MMM', 'es').format(departure.local),
        time,
      ),
    };
    return departure.deviceZoneDiffers
        ? '$when ${l10n.tripsLocalTimeOf(city)}'
        : when;
  }

  /// The stated reason. The window's opening is given in the departure
  /// airport's clock, like every other time on the card (FR-014).
  static String reasonLabel(
    AppLocalizations l10n,
    TripActionUnavailable a,
    Duration airportOffset,
  ) => switch (a.reason) {
    TripActionReason.unconfirmed => l10n.tripsReasonUnconfirmed,
    TripActionReason.expired => l10n.tripsReasonExpired,
    TripActionReason.revoked => l10n.tripsReasonRevoked,
    TripActionReason.suspended => l10n.tripsReasonSuspended,
    TripActionReason.cancelled => l10n.tripsStatusCancelled,
    TripActionReason.departed => l10n.tripsReasonDeparted,
    TripActionReason.notYetOpen => l10n.tripsReasonAvailableFrom(
      DateFormat(
        "d 'de' MMMM",
        'es',
      ).format(a.availableFrom!.toUtc().add(airportOffset)),
      _time.format(a.availableFrom!.toUtc().add(airportOffset)),
    ),
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final when = whenLabel(l10n, departure, trip.origin.city);

    final details = trip.live
        ? [
            if (trip.gate != null) l10n.tripsGate(trip.gate!),
            if (trip.seat != null) l10n.tripsSeat(trip.seat!),
          ]
        : <String>[];
    final detailLine = trip.live
        ? details.join(' · ')
        : l10n.tripsDetailsUnavailable;

    final statusChip = switch (trip.status) {
      TripStatus.delayed => l10n.tripsStatusDelayed,
      TripStatus.cancelled => l10n.tripsStatusCancelled,
      TripStatus.unknown => l10n.tripsStatusUnknown,
      TripStatus.onTime || TripStatus.departed => null,
    };

    final routeSemantics = [
      l10n.tripsRouteSemantics(
        trip.origin.city,
        trip.destination.city,
        trip.flightNumber,
        when,
      ),
      if (detailLine.isNotEmpty) detailLine,
      ?statusChip,
      if (trip.connectsTo != null) l10n.tripsConnectsTo(trip.connectsTo!.city),
      if (stale) l10n.tripsUpdatedAgo(minutesSinceFetched),
    ].join('. ');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE3E7EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            container: true,
            label: routeSemantics,
            excludeSemantics: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (statusChip != null || stale)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (statusChip != null) _Chip(label: statusChip),
                        if (stale)
                          Text(
                            l10n.tripsUpdatedAgo(minutesSinceFetched),
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                Row(
                  children: [
                    _Airport(airport: trip.origin, alignEnd: false),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            trip.flightNumber,
                            style: textTheme.labelSmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward,
                            size: 18,
                            color: AppColors.navy,
                          ),
                          Text(
                            when,
                            textAlign: TextAlign.center,
                            style: textTheme.labelMedium?.copyWith(
                              color: AppColors.turquoise,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _Airport(airport: trip.destination, alignEnd: true),
                  ],
                ),
                if (trip.connectsTo != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    l10n.tripsConnectsTo(trip.connectsTo!.city),
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 24),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              if (detailLine.isNotEmpty)
                ExcludeSemantics(
                  child: Text(
                    detailLine,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              switch (action) {
                TripActionViewPass() => FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    minimumSize: const Size(48, 48),
                  ),
                  onPressed: onViewPass,
                  child: Text(l10n.tripsViewPass),
                ),
                TripActionStart() => FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    minimumSize: const Size(48, 48),
                  ),
                  onPressed: onStart,
                  child: Text(l10n.tripsStart),
                ),
                final TripActionUnavailable unavailable => Text(
                  reasonLabel(l10n, unavailable, trip.departureOffset),
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              },
            ],
          ),
        ],
      ),
    );
  }
}

class _Airport extends StatelessWidget {
  const _Airport({required this.airport, required this.alignEnd});

  final Airport airport;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          airport.code,
          style: textTheme.headlineSmall?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          airport.city,
          style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: const Color(0xFFE4E8EE),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      label,
      style: Theme.of(context).textTheme.labelSmall
          ?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
    ),
  );
}
