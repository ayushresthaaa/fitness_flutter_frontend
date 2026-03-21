import '../../models/ecommerce/cart_model.dart';
import '../../services/ecommerce/cart_service.dart';
import '../base/base_provider.dart';
import 'package:dio/dio.dart';

class CartProvider extends BaseProvider {
  final CartService _service = CartService();

  Cart? _cart;

  // Getters
  Cart? get cart => _cart;
  List<CartItem> get items => _cart?.items ?? [];
  double get total => _cart?.total ?? 0;
  int get itemCount => _cart?.itemCount ?? 0;

  // Check if a product is already in the cart
  bool isInCart(String productId) {
    return items.any((item) => item.productId == productId);
  }

  // Get the cart item for a specific product if it exists
  CartItem? getCartItem(String productId) {
    try {
      return items.firstWhere((item) => item.productId == productId);
    } catch (e) {
      return null;
    }
  }

  Future<void> fetchCart() async {
    try {
      final result = await _service.getCart();
      print('fetchCart result: $result');
      print('fetchCart result id: ${result?.id}');
      print('fetchCart items count: ${result?.items.length}');
      _cart = result;
      notifyListeners();
    } catch (e) {
      print('fetchCart error: $e');
      _cart = null;
      notifyListeners();
    }
  }

  Future<void> addToCart({required String productId, int quantity = 1}) async {
    await executeSilent(
      () => _service.addToCart(productId: productId, quantity: quantity),
    );

    if (!hasError) {
      await fetchCart();
    }
  }

  // Update quantity of an existing cart item
  Future<void> updateQuantity({
    required String itemId,
    required int quantity,
  }) async {
    await execute(
      () => _service.updateCartItem(itemId: itemId, quantity: quantity),
    );

    if (!hasError) {
      await fetchCart();
    }
  }

  // Remove a single item from cart
  Future<void> removeItem(String itemId) async {
    await execute(() => _service.removeCartItem(itemId));

    if (!hasError) {
      await fetchCart();
    }
  }

  // Clear entire cart
  Future<void> clearCart() async {
    await execute(() => _service.clearCart());

    if (!hasError) {
      _cart = null;
      notifyListeners();
    }
  }

  void reset() {
    _cart = null;
    clearError();
    notifyListeners();
  }
}
