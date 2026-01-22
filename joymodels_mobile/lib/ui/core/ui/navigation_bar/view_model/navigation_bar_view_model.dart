import 'package:flutter/material.dart';
import 'package:joymodels_mobile/ui/community_page/widgets/community_page_screen.dart';
import 'package:joymodels_mobile/ui/home_page/widgets/home_page_screen.dart';
import 'package:joymodels_mobile/ui/model_create_page/widgets/model_create_page_screen.dart';
import 'package:joymodels_mobile/ui/shopping_cart_page/view_model/shopping_cart_page_view_model.dart';
import 'package:joymodels_mobile/ui/shopping_cart_page/widgets/shopping_cart_page_screen.dart';
import 'package:provider/provider.dart';

enum NavBarItem { home, community, add, cart, menu }

class NavigationBarViewModel with ChangeNotifier {
  int selectedNavBarItem = 0;

  void _navigateToHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomePageScreen()),
      (route) => false,
    );
  }

  void _navigateToCommunity(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const CommunityPageScreen()),
      (route) => false,
    );
  }

  void _navigateToAddModel(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const ModelCreatePageScreen()),
      (route) => false,
    );
  }

  void _navigateToCart(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => ShoppingCartPageViewModel(),
          child: const ShoppingCartPageScreen(),
        ),
      ),
      (route) => false,
    );
  }

  void _openMenu(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }

  void onNavigationBarItemTapped(BuildContext context, int index) {
    final navBarItem = NavBarItem.values[index];

    if (navBarItem == NavBarItem.menu) {
      _openMenu(context);
      return;
    }

    switch (navBarItem) {
      case NavBarItem.home:
        _navigateToHome(context);
        break;
      case NavBarItem.community:
        _navigateToCommunity(context);
        break;
      case NavBarItem.add:
        _navigateToAddModel(context);
        break;
      case NavBarItem.cart:
        _navigateToCart(context);
        break;
      case NavBarItem.menu:
        break;
    }

    selectedNavBarItem = index;
    notifyListeners();
  }
}
