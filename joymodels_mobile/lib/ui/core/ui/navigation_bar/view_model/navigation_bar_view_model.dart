import 'package:flutter/material.dart';
import 'package:joymodels_mobile/ui/home_page/widgets/home_page_screen.dart';
import 'package:joymodels_mobile/ui/model_create_page/widgets/model_create_page_screen.dart';
import 'package:joymodels_mobile/ui/shopping_cart_page/view_model/shopping_cart_page_view_model.dart';
import 'package:joymodels_mobile/ui/shopping_cart_page/widgets/shopping_cart_page_screen.dart';
import 'package:provider/provider.dart';

enum NavBarItem { home, community, add, cart, settings }

class NavigationBarViewModel with ChangeNotifier {
  int selectedNavBarItem = 0;

  void _navigateToHome(BuildContext context) {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => HomePageScreen()));
  }

  void _navigateToCommunity(BuildContext context) {
    // TODO: Implementiraj
  }

  void _navigateToAddModel(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => ModelCreatePageScreen()),
    );
  }

  void _navigateToCart(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => ShoppingCartPageViewModel(),
          child: const ShoppingCartPageScreen(),
        ),
      ),
    );
  }

  void _navigateToSettings(BuildContext context) {
    // TODO: Implementiraj
  }

  void onNavigationBarItemTapped(BuildContext context, int index) {
    final navBarItem = NavBarItem.values[index];

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
      case NavBarItem.settings:
        _navigateToSettings(context);
        break;
    }

    selectedNavBarItem = index;
    notifyListeners();
  }
}
