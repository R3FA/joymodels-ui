import 'package:flutter/material.dart';
import 'package:joymodels_mobile/core/di/di.dart';
import 'package:joymodels_mobile/data/core/exceptions/session_expired_exception.dart';
import 'package:joymodels_mobile/data/model/models/response_types/model_response_api_model.dart';
import 'package:joymodels_mobile/data/model/pagination/response_types/pagination_response_api_model.dart';
import 'package:joymodels_mobile/data/model/shopping_cart/request_types/shopping_cart_search_request_api_model.dart';
import 'package:joymodels_mobile/data/model/shopping_cart/response_types/shopping_cart_item_response_api_model.dart';
import 'package:joymodels_mobile/data/repositories/shopping_cart_repository.dart';
import 'package:joymodels_mobile/ui/core/mixins/pagination_mixin.dart';
import 'package:joymodels_mobile/ui/model_page/view_model/model_page_view_model.dart';
import 'package:joymodels_mobile/ui/model_page/widgets/model_page_screen.dart';
import 'package:provider/provider.dart';

class ShoppingCartPageViewModel extends ChangeNotifier
    with PaginationMixin<ShoppingCartItemResponseApiModel> {
  final shoppingCartRepository = sl<ShoppingCartRepository>();

  bool isLoading = false;
  String? errorMessage;
  VoidCallback? onSessionExpired;

  PaginationResponseApiModel<ShoppingCartItemResponseApiModel>? _paginationData;

  @override
  PaginationResponseApiModel<ShoppingCartItemResponseApiModel>?
  get paginationData => _paginationData;

  @override
  bool get isLoadingPage => isLoading;

  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  static const int pageSize = 5;

  double get totalPrice {
    return items.fold(0.0, (sum, item) => sum + item.model.price);
  }

  int get itemCount => items.length;

  Future<void> init() async {
    searchController.addListener(_onSearchChanged);
    await loadPage(1);
  }

  void _onSearchChanged() {
    if (searchController.text != searchQuery) {
      searchQuery = searchController.text;
      loadPage(1);
    }
  }

  @override
  Future<void> loadPage(int pageNumber) async {
    errorMessage = null;
    isLoading = true;
    notifyListeners();

    try {
      final request = ShoppingCartSearchRequestApiModel(
        modelName: searchQuery.isEmpty ? null : searchQuery,
        pageNumber: pageNumber,
        pageSize: pageSize,
      );

      _paginationData = await shoppingCartRepository.search(request);
      isLoading = false;
      notifyListeners();
    } on SessionExpiredException {
      errorMessage = SessionExpiredException().toString();
      isLoading = false;
      notifyListeners();
      onSessionExpired?.call();
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> removeFromShoppingCart(String modelUuid) async {
    errorMessage = null;
    notifyListeners();

    try {
      await shoppingCartRepository.delete(modelUuid);
      await reloadCurrentPage();
      return true;
    } on SessionExpiredException {
      errorMessage = SessionExpiredException().toString();
      notifyListeners();
      onSessionExpired?.call();
      return false;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearSearch() {
    searchController.clear();
    searchQuery = '';
    loadPage(1);
  }

  void onModelTap(BuildContext context, ModelResponseApiModel model) {
    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => ModelPageViewModel(),
            child: ModelPageScreen(loadedModel: model),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    onSessionExpired = null;
    super.dispose();
  }
}
