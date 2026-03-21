import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ecommerce/cart_provider.dart';
import '../../providers/ecommerce/order_provider.dart';
import '../../widgets/common.dart';
import 'order_detail_screen.dart';

class CheckoutScreen extends StatefulWidget {
  static const routeName = '/checkout';

  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    // Basic validation
    if (_nameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all shipping details')),
      );
      return;
    }

    final orderProvider = context.read<OrderProvider>();
    final cartProvider = context.read<CartProvider>();

    final order = await orderProvider.placeOrder(
      shippingName: _nameController.text.trim(),
      shippingPhone: _phoneController.text.trim(),
      shippingAddress: _addressController.text.trim(),
    );

    if (order != null && mounted) {
      // Clear the cart after successful order
      await cartProvider.clearCart();

      // Navigate to order detail and remove checkout + cart from stack
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => OrderDetailScreen(orderId: order.id),
        ),
        (route) => route.settings.name == '/shop' || route.isFirst,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final orderProvider = context.watch<OrderProvider>();

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppTopBar(title: 'Checkout'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order summary card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kWhite,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionLabel('Order Summary'),
                  const SizedBox(height: 12),

                  // Each cart item
                  ...cartProvider.items.map((cartItem) {
                    final subtotal =
                        cartItem.product.price * cartItem.quantity;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${cartItem.product.name} × ${cartItem.quantity}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: kTextDark,
                              ),
                            ),
                          ),
                          Text(
                            'Rs. ${subtotal.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: kTextDark,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const Divider(color: kDivider),
                  const SizedBox(height: 8),

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
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: kPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Shipping details card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kWhite,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionLabel('Shipping Details'),
                  const SizedBox(height: 12),

                  // Name field
                  const Text(
                    'Full Name',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: kTextDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  AppTextField(
                    controller: _nameController,
                    hint: 'e.g. Aayush Shrestha',
                  ),

                  const SizedBox(height: 12),

                  // Phone field
                  const Text(
                    'Phone Number',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: kTextDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  AppTextField(
                    controller: _phoneController,
                    hint: 'e.g. 9801234567',
                    keyboardType: TextInputType.phone,
                  ),

                  const SizedBox(height: 12),

                  // Address field
                  const Text(
                    'Delivery Address',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: kTextDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  AppTextField(
                    controller: _addressController,
                    hint: 'e.g. Kathmandu, Baneshwor',
                    maxLines: 3,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),

      // Place order button
      bottomNavigationBar: BottomBar(
        child: PrimaryButton(
          text: 'Place Order',
          isLoading: orderProvider.isLoading,
          onTap: _placeOrder,
        ),
      ),
    );
  }
}