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
      if (!viewModel.isAdminOrRoot)
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
    if (viewModel.isAdminOrRoot) {
      if (adjustedIndex == 3) {
        adjustedIndex = 2;
      } else if (adjustedIndex == 4) {
        adjustedIndex = 3;
      }
    } else {
      if (adjustedIndex == 2) {
        adjustedIndex = 2;
      } else if (adjustedIndex >= 3) {
        adjustedIndex = adjustedIndex - 1;
      }
    }
    adjustedIndex = adjustedIndex.clamp(0, destinations.length - 1);

    return NavigationBar(
      height: navBarHeight,
      selectedIndex: adjustedIndex,
      onDestinationSelected: (index) {
        int actualIndex = index;
        if (viewModel.isAdminOrRoot) {
          if (index >= 3) {
            actualIndex = index + 1;
          }
        } else {
          if (index >= 2) {
            actualIndex = index + 1;
          }
        }
        viewModel.onNavigationBarItemTapped(context, actualIndex);
      },
      destinations: destinations,
    );
  }
}
