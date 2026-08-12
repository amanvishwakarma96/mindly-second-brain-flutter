import 'package:flutter/material.dart';
import 'package:mindly/app/app_routes.dart';

class MobilePrimaryNavigation extends StatelessWidget {
  const MobilePrimaryNavigation({super.key, required this.selectedIndex});

  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      key: const ValueKey<String>('mobile-primary-navigation'),
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) => _select(context, index),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
        NavigationDestination(
          icon: Icon(Icons.edit_note_rounded),
          label: 'Capture',
        ),
        NavigationDestination(
          icon: Icon(Icons.auto_stories_rounded),
          label: 'Memory',
        ),
        NavigationDestination(
          icon: Icon(Icons.auto_awesome_rounded),
          label: 'Insights',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_rounded),
          label: 'Settings',
        ),
      ],
    );
  }

  void _select(BuildContext context, int index) {
    if (index == selectedIndex) {
      return;
    }

    final navigator = Navigator.of(context);
    if (index == 0) {
      navigator.popUntil((route) => route.isFirst);
      return;
    }

    final route = switch (index) {
      1 => AppRoutes.textCapture,
      2 => AppRoutes.memory,
      3 => AppRoutes.insights,
      4 => AppRoutes.settings,
      _ => null,
    };
    if (route == null) {
      return;
    }

    if (index == 1) {
      navigator.pushNamed(route);
    } else {
      navigator.pushReplacementNamed(route);
    }
  }
}
