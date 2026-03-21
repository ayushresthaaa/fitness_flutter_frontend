import '../../models/ecommerce/product_model.dart';
import '../../services/ecommerce/product_service.dart';
import '../base/base_provider.dart';

class ProductProvider extends BaseProvider {
  final ProductService _service = ProductService();

  List<Product> _products = [];
  List<Product> _featuredProducts = [];
  List<ProductCategory> _categories = [];
  Product? _selectedProduct;

  int _currentPage = 1;
  int _totalPages = 1;
  int _total = 0;

  String _searchQuery = '';
  String? _selectedCategoryId;

  // Getters
  List<Product> get products => _products;
  List<Product> get featuredProducts => _featuredProducts;
  List<ProductCategory> get categories => _categories;
  Product? get selectedProduct => _selectedProduct;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get total => _total;
  String get searchQuery => _searchQuery;
  String? get selectedCategoryId => _selectedCategoryId;

  // Fetch products for a specific page with current filters applied
  Future<void> fetchProducts({int page = 1}) async {
    final result = await execute(
      () => _service.getProducts(
        page: page,
        limit: 10,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        categoryId: _selectedCategoryId,
      ),
    );

    if (result != null) {
      _products = result['products'];
      final pagination = result['pagination'];
      _currentPage = pagination['page'];
      _totalPages = pagination['totalPages'];
      _total = pagination['total'];
      notifyListeners();
    }
  }

  // Go to a specific page
  Future<void> goToPage(int page) async {
    if (page < 1 || page > _totalPages) return;
    await fetchProducts(page: page);
  }

  // Update search query and reset to page 1
  Future<void> setSearch(String query) async {
    _searchQuery = query;
    await fetchProducts(page: 1);
  }

  // Update selected category and reset to page 1
  Future<void> setCategory(String? categoryId) async {
    _selectedCategoryId = categoryId;
    await fetchProducts(page: 1);
  }

  // Just reset state without fetching — used when leaving the screen
  void clearFilters() {
    _searchQuery = '';
    _selectedCategoryId = null;
    _currentPage = 1;
    _totalPages = 1;
    _total = 0;
    _products = [];
    notifyListeners();
  }

  // Reset filters and fetch fresh — used when opening the screen
  Future<void> resetAndFetch() async {
    _searchQuery = '';
    _selectedCategoryId = null;
    await fetchProducts(page: 1);
  }

  // Fetch featured products for home screen
  Future<void> fetchFeaturedProducts() async {
    final result = await execute(() => _service.getFeaturedProducts());
    if (result != null) {
      _featuredProducts = result;
      notifyListeners();
    }
  }

  // Fetch single product by id
  Future<void> fetchProductById(String id) async {
    final result = await execute(() => _service.getProductById(id));
    if (result != null) {
      _selectedProduct = result;
      notifyListeners();
    }
  }

  // Fetch categories for filter chips
  Future<void> fetchCategories() async {
    final result = await execute(() => _service.getCategories());
    if (result != null) {
      _categories = result;
      notifyListeners();
    }
  }

  void clearSelectedProduct() {
    _selectedProduct = null;
    notifyListeners();
  }

  void reset() {
    _products = [];
    _featuredProducts = [];
    _categories = [];
    _selectedProduct = null;
    _currentPage = 1;
    _totalPages = 1;
    _total = 0;
    _searchQuery = '';
    _selectedCategoryId = null;
    clearError();
    notifyListeners();
  }
}
