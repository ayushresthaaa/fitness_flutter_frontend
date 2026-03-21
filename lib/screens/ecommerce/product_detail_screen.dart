import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ecommerce/product_provider.dart';
import '../../providers/ecommerce/cart_provider.dart';
import '../../widgets/common.dart';
import 'cart_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  // Tracks which image is currently shown in the page view
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((duration) {
      context.read<ProductProvider>().fetchProductById(widget.productId);
      context.read<CartProvider>().fetchCart(); // add this
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final cartProvider = context.watch<CartProvider>();
    final product = productProvider.selectedProduct;

    if (productProvider.isLoading || product == null) {
      return const Scaffold(
        backgroundColor: kBackground,
        body: Center(child: CircularProgressIndicator(color: kPrimary)),
      );
    }

    final isInCart = cartProvider.isInCart(product.id);
    final isOutOfStock = product.stock == 0;

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppTopBar(
        title: product.name,
        actions: [
          // Cart icon with item count badge
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartScreen()),
                );
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.shopping_cart_outlined, color: kTextDark),
                  if (cartProvider.itemCount > 0)
                    Positioned(
                      right: -6,
                      top: -6,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: kPrimary,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${cartProvider.itemCount}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: kWhite,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product images page view
            if (product.imageUrls.isNotEmpty)
              Stack(
                children: [
                  SizedBox(
                    height: 280,
                    child: PageView.builder(
                      itemCount: product.imageUrls.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentImageIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Image.network(
                          product.imageUrls[index],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: kBackground,
                              child: const Icon(
                                Icons.inventory_2_outlined,
                                color: kTextHint,
                                size: 60,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  // Dot indicators — only show when more than one image
                  if (product.imageUrls.length > 1)
                    Positioned(
                      bottom: 12,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(product.imageUrls.length, (
                          index,
                        ) {
                          final isActive = index == _currentImageIndex;
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: isActive ? 16 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isActive ? kPrimary : kWhite,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        }),
                      ),
                    ),
                ],
              )
            else
              // Placeholder when no images
              Container(
                height: 280,
                color: kBackground,
                child: const Center(
                  child: Icon(
                    Icons.inventory_2_outlined,
                    color: kTextHint,
                    size: 60,
                  ),
                ),
              ),

            // Product info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category name
                  Text(
                    product.category?.name ?? '',
                    style: const TextStyle(fontSize: 12, color: kTextGrey),
                  ),

                  const SizedBox(height: 6),

                  // Product name
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: kTextDark,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Price and stock status in the same row
                  Row(
                    children: [
                      Text(
                        'Rs. ${product.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: kPrimary,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isOutOfStock
                              ? kRedLight
                              : const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isOutOfStock ? 'Out of Stock' : 'In Stock',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isOutOfStock ? kRed : kGreen,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Description
                  if (product.description != null &&
                      product.description!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Divider(color: kDivider),
                    const SizedBox(height: 16),
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: kTextDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.description!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: kTextGrey,
                        height: 1.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),

      // Add to cart button
      bottomNavigationBar: BottomBar(
        child: PrimaryButton(
          text: isOutOfStock
              ? 'Out of Stock'
              : isInCart
              ? 'Go to Cart'
              : 'Add to Cart',
          isLoading: false,
          onTap: isOutOfStock
              ? null
              : isInCart
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartScreen()),
                  );
                }
              : () async {
                  await context.read<CartProvider>().addToCart(
                    productId: product.id,
                  );
                  if (mounted) {
                    final error = context.read<CartProvider>().error;
                    if (error != null) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(error)));
                      context.read<CartProvider>().clearError();
                    }
                  }
                },
        ),
      ),
    );
  }
}
