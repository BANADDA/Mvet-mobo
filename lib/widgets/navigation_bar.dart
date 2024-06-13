import 'package:flutter/material.dart';

class NavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;
  final List<NavigationDestination> destinations;
  final Color indicatorColor;

  const NavigationBar({
    Key? key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    required this.indicatorColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onDestinationSelected,
      selectedItemColor: indicatorColor,
      items: destinations
          .map((destination) => BottomNavigationBarItem(
                icon: destination.icon,
                label: destination.label,
              ))
          .toList(),
    );
  }
}

class NavigationDestination {
  final Widget icon;
  final String label;

  const NavigationDestination({
    required this.icon,
    required this.label,
  });
}
