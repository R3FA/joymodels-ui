import 'package:flutter/material.dart';
import 'package:joymodels_mobile/ui/core/ui/navigation_bar/view_model/navigation_bar_view_model.dart';
import 'package:provider/provider.dart';

class NavigationBarScreen extends StatelessWidget {
  const NavigationBarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<NavigationBarViewModel>();

    const double iconSize = 32;
    const double navBarHeight = 70;

    final destinations = <NavigationDestination>[
      const NavigationDestination(
        icon: Icon(Icons.home, size: iconSize),
        label: 'Home',
      ),
      const NavigationDestination(
        icon: Icon(Icons.group, size: iconSize),
        label: 'Community',
      ),
      if (viewModel.isAdminOrRoot)
        const NavigationDestination(
          icon: Icon(Icons.add_box, size: iconSize),
          label: 'Add',
        ),
      const NavigationDestination(
        icon: Icon(Icons.shopping_cart, size: iconSize),
        label: 'Cart',
      ),
      const NavigationDestination(
        icon: Icon(Icons.more_horiz, size: iconSize),
        label: 'Menu',
      ),
    ];

    int adjustedIndex = viewModel.selectedNavBarItem;
    if (!viewModel.isAdminOrRoot && adjustedIndex >= 2) {
      adjustedIndex = adjustedIndex > 2 ? adjustedIndex - 1 : adjustedIndex;
    }
    adjustedIndex = adjustedIndex.clamp(0, destinations.length - 1);

    return NavigationBar(
      height: navBarHeight,
      selectedIndex: adjustedIndex,
      onDestinationSelected: (index) {
        int actualIndex = index;
        if (!viewModel.isAdminOrRoot && index >= 2) {
          actualIndex = index + 1;
        }
        viewModel.onNavigationBarItemTapped(context, actualIndex);
      },
      destinations: destinations,
    );
  }
}
