import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ecommerce/product_provider.dart';
import '../../widgets/common.dart';
import 'product_detail_screen.dart';
import 'widget/product_card.dart';
import 'widget/category_filter_chips.dart';

class ProductListScreen extends StatefulWidget {
  static const routeName = '/shop';

  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((duration) {
      final productProvider = context.read<ProductProvider>();
      productProvider.resetAndFetch();
      productProvider.fetchCategories();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    context.read<ProductProvider>().clearFilters();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppTopBar(title: 'Shop'),
      body: Column(
        children: [
          const SizedBox(height: 12),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: kWhite,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(fontSize: 14, color: kTextDark),
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  hintStyle: const TextStyle(fontSize: 14, color: kTextGrey),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: kTextGrey,
                    size: 20,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: kTextGrey,
                            size: 20,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            context.read<ProductProvider>().setSearch('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                onSubmitted: (value) {
                  context.read<ProductProvider>().setSearch(value);
                },
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Category filter chips
          CategoryFilterChips(
            categories: productProvider.categories,
            selectedCategoryId: productProvider.selectedCategoryId,
            onCategorySelected: (categoryId) {
              context.read<ProductProvider>().setCategory(categoryId);
            },
          ),

          const SizedBox(height: 12),

          // Product grid or empty state
          Expanded(
            child: productProvider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: kPrimary),
                  )
                : productProvider.products.isEmpty
                ? const EmptyState(
                    icon: Icons.inventory_2_outlined,
                    title: 'No products found',
                    subtitle: 'Try a different search or category',
                  )
                : Column(
                    children: [
                      // Product grid
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.72,
                              ),
                          itemCount: productProvider.products.length,
                          itemBuilder: (context, index) {
                            final product = productProvider.products[index];
                            return ProductCard(
                              product: product,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetailScreen(
                                      productId: product.id,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),

                      // Pagination row — only shown when there are multiple pages
                      if (productProvider.totalPages > 1)
                        _buildPaginationRow(productProvider),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // Pagination row with previous, page numbers and next buttons
  Widget _buildPaginationRow(ProductProvider productProvider) {
    return Container(
      color: kWhite,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous button
          IconButton(
            onPressed: productProvider.currentPage > 1
                ? () {
                    productProvider.goToPage(productProvider.currentPage - 1);
                  }
                : null,
            icon: const Icon(Icons.chevron_left_rounded),
            color: kPrimary,
            disabledColor: kTextHint,
          ),

          // Page number buttons
          ...List.generate(productProvider.totalPages, (index) {
            final pageNumber = index + 1;
            final isCurrentPage = pageNumber == productProvider.currentPage;

            return GestureDetector(
              onTap: () {
                productProvider.goToPage(pageNumber);
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isCurrentPage ? kPrimary : kWhite,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isCurrentPage ? kPrimary : kDivider,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$pageNumber',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isCurrentPage ? kWhite : kTextGrey,
                    ),
                  ),
                ),
              ),
            );
          }),

          // Next button
          IconButton(
            onPressed: productProvider.currentPage < productProvider.totalPages
                ? () {
                    productProvider.goToPage(productProvider.currentPage + 1);
                  }
                : null,
            icon: const Icon(Icons.chevron_right_rounded),
            color: kPrimary,
            disabledColor: kTextHint,
          ),
        ],
      ),
    );
  }
}
