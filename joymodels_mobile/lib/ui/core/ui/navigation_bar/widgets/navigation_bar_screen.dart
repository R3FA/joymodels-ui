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

    return NavigationBar(
      height: navBarHeight,
      selectedIndex: viewModel.selectedNavBarItem,
      onDestinationSelected: (index) =>
          viewModel.onNavigationBarItemTapped(context, index),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home, size: iconSize),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.group, size: iconSize),
          label: 'Community',
        ),
        NavigationDestination(
          icon: Icon(Icons.add_box, size: iconSize),
          label: 'Add',
        ),
        NavigationDestination(
          icon: Icon(Icons.shopping_cart, size: iconSize),
          label: 'Cart',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings, size: iconSize),
          label: 'Settings',
        ),
      ],
    );
  }
}
