import 'package:flutter/material.dart';
import 'package:joymodels_mobile/ui/home_page/view_model/home_page_view_model.dart';
import 'package:provider/provider.dart';

class NavigationBarWidget extends StatelessWidget {
  const NavigationBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomePageScreenViewModel>();

    const double iconSize = 32;
    const double navBarHeight = 70;

    return NavigationBar(
      height: navBarHeight,
      selectedIndex: viewModel.selectedNavBarItem,
      onDestinationSelected: viewModel.onNavigationBarItemTapped,
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
          icon: Icon(Icons.person, size: iconSize),
          label: 'Profile',
        ),
      ],
    );
  }
}
