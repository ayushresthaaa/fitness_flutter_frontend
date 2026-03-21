import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ecommerce/cart_provider.dart';
import '../../models/ecommerce/cart_model.dart';
import '../../widgets/common.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  static const routeName = '/cart';

  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((duration) {
      context.read<CartProvider>().fetchCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppTopBar(title: 'Cart'),
      body: cartProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: kPrimary))
          : cartProvider.items.isEmpty
              ? const EmptyState(
                  icon: Icons.shopping_cart_outlined,
                  title: 'Your cart is empty',
                  subtitle: 'Add products to get started',
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartProvider.items.length,
                  separatorBuilder: (context, index) {
                    return const SizedBox(height: 12);
                  },
                  itemBuilder: (context, index) {
                    final cartItem = cartProvider.items[index];
                    return _CartItemRow(cartItem: cartItem);
                  },
                ),

      // Bottom bar with total and checkout button
      bottomNavigationBar: cartProvider.items.isEmpty
          ? null
          : BottomBar(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Total row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: kTextDark,
                        ),
                      ),
                      Text(
                        'Rs. ${cartProvider.total.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: kPrimary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Checkout button
                  PrimaryButton(
                    text: 'Proceed to Checkout',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CheckoutScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}

// A single cart item row
class _CartItemRow extends StatelessWidget {
  final CartItem cartItem;

  const _CartItemRow({required this.cartItem});

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.read<CartProvider>();
    final hasImage = cartItem.product.imageUrls.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Product image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: hasImage
                ? Image.network(
                    cartItem.product.imageUrls[0],
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildImagePlaceholder();
                    },
                  )
                : _buildImagePlaceholder(),
          ),

          const SizedBox(width: 12),

          // Product info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category
                Text(
                  cartItem.product.category?.name ?? '',
                  style: const TextStyle(fontSize: 11, color: kTextGrey),
                ),

                const SizedBox(height: 3),

                // Product name
                Text(
                  cartItem.product.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: kTextDark,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 6),

                // Price
                Text(
                  'Rs. ${cartItem.product.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: kPrimary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Quantity controls and remove button
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Remove button
              GestureDetector(
                onTap: () {
                  cartProvider.removeItem(cartItem.id);
                },
                child: const Icon(
                  Icons.delete_outline,
                  color: kRed,
                  size: 20,
                ),
              ),

              const SizedBox(height: 10),

              // Quantity controls
              Row(
                children: [
                  // Decrease quantity
                  GestureDetector(
                    onTap: cartItem.quantity > 1
                        ? () {
                            cartProvider.updateQuantity(
                              itemId: cartItem.id,
                              quantity: cartItem.quantity - 1,
                            );
                          }
                        : null,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: kBackground,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.remove,
                        size: 16,
                        color: cartItem.quantity > 1 ? kTextDark : kTextHint,
                      ),
                    ),
                  ),

                  // Quantity count
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      '${cartItem.quantity}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: kTextDark,
                      ),
                    ),
                  ),

                  // Increase quantity
                  GestureDetector(
                    onTap: cartItem.quantity < cartItem.product.stock
                        ? () {
                            cartProvider.updateQuantity(
                              itemId: cartItem.id,
                              quantity: cartItem.quantity + 1,
                            );
                          }
                        : null,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: kBackground,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.add,
                        size: 16,
                        color: cartItem.quantity < cartItem.product.stock
                            ? kTextDark
                            : kTextHint,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Placeholder shown when image is missing or fails to load
  Widget _buildImagePlaceholder() {
    return Container(
      width: 70,
      height: 70,
      color: kBackground,
      child: const Icon(
        Icons.inventory_2_outlined,
        color: kTextHint,
        size: 28,
      ),
    );
  }
}