import '../../models/ecommerce/order_model.dart';
import '../../services/ecommerce/order_service.dart';
import '../base/base_provider.dart';

class OrderProvider extends BaseProvider {
  final OrderService _service = OrderService();

  List<Order> _orders = [];
  Order? _selectedOrder;

  int _currentPage = 1;
  int _totalPages = 1;

  // Getters
  List<Order> get orders => _orders;
  Order? get selectedOrder => _selectedOrder;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;

  // Place a new order from the current cart
  Future<Order?> placeOrder({
    required String shippingName,
    required String shippingPhone,
    required String shippingAddress,
  }) async {
    final result = await execute(
      () => _service.placeOrder(
        shippingName: shippingName,
        shippingPhone: shippingPhone,
        shippingAddress: shippingAddress,
      ),
    );

    if (result != null) {
      _orders.insert(0, result);
      _selectedOrder = result;
      notifyListeners();
    }

    return result;
  }

  // Fetch order history for a specific page
  Future<void> fetchOrders({int page = 1}) async {
    final result = await execute(
      () => _service.getOrders(page: page, limit: 10),
    );

    if (result != null) {
      _orders = result['orders'];
      final pagination = result['pagination'];
      _currentPage = pagination['page'];
      _totalPages = pagination['totalPages'];
      notifyListeners();
    }
  }

  // Go to a specific page — called by pagination buttons
  Future<void> goToPage(int page) async {
    if (page < 1 || page > _totalPages) return;
    await fetchOrders(page: page);
  }

  // Fetch single order detail
  Future<void> fetchOrderById(String id) async {
    final result = await execute(() => _service.getOrderById(id));

    if (result != null) {
      _selectedOrder = result;
      notifyListeners();
    }
  }

  void clearSelectedOrder() {
    _selectedOrder = null;
    notifyListeners();
  }

  void reset() {
    _orders = [];
    _selectedOrder = null;
    _currentPage = 1;
    _totalPages = 1;
    clearError();
    notifyListeners();
  }
}
