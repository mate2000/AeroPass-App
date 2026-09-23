import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/design/app_colors.dart';
import '../l10n/generated/app_localizations.dart';
import 'router.dart';

/// The enrolled passenger's three top-level destinations (012-mis-viajes
/// research.md §8): Viajes, Identidad and Perfil. Perfil carries consent
/// withdrawal, two taps from Mis viajes (FR-019).
class HomeShell extends StatelessWidget {
  const HomeShell({required this.location, required this.child, super.key});

  final String location;
  final Widget child;

  static const _destinations = [
    AppRoutes.trips,
    AppRoutes.credentialDetail,
    AppRoutes.profile,
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final selected = _destinations.indexWhere(location.startsWith);
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F7),
      body: child,
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppColors.surface,
        indicatorColor: const Color(0xFFE4E8EE),
        selectedIndex: selected < 0 ? 0 : selected,
        onDestinationSelected: (index) => context.go(_destinations[index]),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.flight_outlined),
            selectedIcon: const Icon(Icons.flight, color: AppColors.navy),
            label: l10n.homeTabTrips,
          ),
          NavigationDestination(
            icon: const Icon(Icons.badge_outlined),
            selectedIcon: const Icon(Icons.badge, color: AppColors.navy),
            label: l10n.homeTabIdentity,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person, color: AppColors.navy),
            label: l10n.homeTabProfile,
          ),
        ],
      ),
    );
  }
}
