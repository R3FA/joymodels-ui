import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:joymodels_mobile/core/di/di.dart';
import 'package:joymodels_mobile/data/core/exceptions/forbidden_exception.dart';
import 'package:joymodels_mobile/data/core/exceptions/network_exception.dart';
import 'package:joymodels_mobile/data/core/exceptions/session_expired_exception.dart';
import 'package:joymodels_mobile/data/model/models/response_types/model_response_api_model.dart';
import 'package:joymodels_mobile/data/model/pagination/response_types/pagination_response_api_model.dart';
import 'package:joymodels_mobile/data/model/shopping_cart/request_types/shopping_cart_search_request_api_model.dart';
import 'package:joymodels_mobile/data/model/shopping_cart/response_types/shopping_cart_item_response_api_model.dart';
import 'package:joymodels_mobile/data/repositories/order_repository.dart';
import 'package:joymodels_mobile/data/repositories/shopping_cart_repository.dart';
import 'package:joymodels_mobile/ui/core/mixins/pagination_mixin.dart';
import 'package:joymodels_mobile/ui/core/view_model/regex_view_model.dart';
import 'package:joymodels_mobile/ui/model_page/view_model/model_page_view_model.dart';
import 'package:joymodels_mobile/ui/model_page/widgets/model_page_screen.dart';
import 'package:provider/provider.dart';

class ShoppingCartPageViewModel extends ChangeNotifier
    with PaginationMixin<ShoppingCartItemResponseApiModel> {
  final shoppingCartRepository = sl<ShoppingCartRepository>();
  final orderRepository = sl<OrderRepository>();

  bool isLoading = false;
  bool isCheckoutLoading = false;
  String? errorMessage;
  String? checkoutSuccessMessage;
  VoidCallback? onSessionExpired;
  VoidCallback? onForbidden;
  VoidCallback? onCheckoutSuccess;

  PaginationResponseApiModel<ShoppingCartItemResponseApiModel>? _paginationData;

  @override
  PaginationResponseApiModel<ShoppingCartItemResponseApiModel>?
  get paginationData => _paginationData;

  @override
  bool get isLoadingPage => isLoading;

  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  String? searchErrorMessage;

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
    final newQuery = searchController.text.trim();
    if (newQuery == searchQuery) return;

    if (newQuery.isNotEmpty) {
      final validationError = RegexValidationViewModel.validateText(newQuery);
      if (validationError != null) {
        searchErrorMessage = validationError;
        notifyListeners();
        return;
      }
    }

    searchErrorMessage = null;
    searchQuery = newQuery;
    loadPage(1);
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
    } on ForbiddenException {
      isLoading = false;
      notifyListeners();
      onForbidden?.call();
    } on NetworkException {
      errorMessage = NetworkException().toString();
      isLoading = false;
      notifyListeners();
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
    } on ForbiddenException {
      notifyListeners();
      onForbidden?.call();
      return false;
    } on NetworkException {
      errorMessage = NetworkException().toString();
      notifyListeners();
      return false;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> checkout() async {
    if (items.isEmpty) return false;

    errorMessage = null;
    checkoutSuccessMessage = null;
    isCheckoutLoading = true;
    notifyListeners();

    try {
      final checkoutResponse = await orderRepository.checkout();

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: checkoutResponse.clientSecret,
          customerEphemeralKeySecret: checkoutResponse.ephemeralKey,
          customerId: checkoutResponse.customerId,
          merchantDisplayName: 'JoyModels',
          style: ThemeMode.dark,
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      final confirmResponse = await orderRepository.confirm(
        checkoutResponse.paymentIntentId,
      );

      isCheckoutLoading = false;

      if (confirmResponse.success) {
        checkoutSuccessMessage =
            'Payment successful! Models added to your library.';
        notifyListeners();
        await loadPage(1);
        onCheckoutSuccess?.call();
        return true;
      } else {
        errorMessage = confirmResponse.message;
        notifyListeners();
        return false;
      }
    } on StripeException catch (e) {
      isCheckoutLoading = false;
      if (e.error.code == FailureCode.Canceled) {
        notifyListeners();
        return false;
      }
      errorMessage = e.error.localizedMessage ?? 'Payment failed';
      notifyListeners();
      return false;
    } on SessionExpiredException {
      isCheckoutLoading = false;
      errorMessage = SessionExpiredException().toString();
      notifyListeners();
      onSessionExpired?.call();
      return false;
    } on ForbiddenException {
      isCheckoutLoading = false;
      notifyListeners();
      onForbidden?.call();
      return false;
    } on NetworkException {
      errorMessage = NetworkException().toString();
      isCheckoutLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      isCheckoutLoading = false;
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearSearch() {
    searchController.clear();
    searchQuery = '';
    searchErrorMessage = null;
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
    onForbidden = null;
    onCheckoutSuccess = null;
    super.dispose();
  }
}
