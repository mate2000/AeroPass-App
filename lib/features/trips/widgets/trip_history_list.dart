import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../../core/design/app_colors.dart';
import '../../../domain/entities/trip.dart';
import '../../../l10n/generated/app_localizations.dart';

/// "VIAJES RECIENTES" (012-mis-viajes FR-012, FR-020). Plain rows: nothing
/// here is tappable, and nothing suggests it is. The 90-day limit is
/// stated.
class TripHistoryList extends StatelessWidget {
  const TripHistoryList({required this.trips, super.key});

  final List<Trip> trips;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final date = DateFormat('d MMM y', 'es');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE3E7EC)),
          ),
          child: Column(
            children: [
              for (final (index, trip) in trips.indexed) ...[
                if (index > 0) const Divider(height: 1, indent: 16),
                MergeSemantics(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        const ExcludeSemantics(
                          child: Icon(
                            Icons.flight_outlined,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Semantics(
                                label:
                                    '${trip.origin.city} → '
                                    '${trip.destination.city}',
                                excludeSemantics: true,
                                child: Text(
                                  '${trip.origin.code} → '
                                  '${trip.destination.code}',
                                  style: textTheme.titleSmall?.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Text(
                                l10n.tripsHistoryRow(
                                  trip.flightNumber,
                                  date.format(trip.departureLocal),
                                ),
                                style: textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.tripsHistoryRetention,
          style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
