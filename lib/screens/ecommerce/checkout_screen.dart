import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:khalti_checkout_flutter/khalti_checkout_flutter.dart';
import '../../providers/ecommerce/cart_provider.dart';
import '../../services/ecommerce/payment_service.dart';
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
  final PaymentService _paymentService = PaymentService();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _startCheckout() async {
    if (_nameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all shipping details')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Initiate checkout — validates cart + stock, stores shipping details,
      // creates Khalti payment. Order is NOT created yet.
      final result = await _paymentService.initiateCheckout(
        shippingName: _nameController.text.trim(),
        shippingPhone: _phoneController.text.trim(),
        shippingAddress: _addressController.text.trim(),
      );

      final pidx = result['pidx'] as String;

      if (!mounted) return;

      final payConfig = KhaltiPayConfig(
        publicKey: 'c022678dc644484daebba89b688110ec',
        pidx: pidx,
        environment: Environment.test,
      );

      final khalti = await Khalti.init(
        enableDebugging: true,
        payConfig: payConfig,
        onPaymentResult: (paymentResult, khalti) async {
          log('Payment result: $paymentResult');

          // Verify with backend — order is created atomically here
          final verified = await _verifyCheckout(pidx, khalti);
          if (verified == null || verified['status'] != 'completed') {
            // Retry once after 2 seconds
            await Future.delayed(const Duration(seconds: 2));
            final retried = await _verifyCheckout(pidx, khalti);
            if (retried == null || retried['status'] != 'completed') {
              khalti.close(context);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Payment verification failed. Your cart is still intact — please try again.',
                    ),
                  ),
                );
              }
            }
          }
        },
        onMessage:
            (
              khalti, {
              description,
              statusCode,
              event,
              needsPaymentConfirmation,
            }) async {
              log('Khalti message: $description');

              if (needsPaymentConfirmation == true) {
                final result = await _verifyCheckout(pidx, khalti);
                if (result == null || result['status'] != 'completed') {
                  // Verification failed — nothing was created, cart is intact
                  khalti.close(context);
                }
              } else {
                // User closed Khalti without paying — nothing to clean up
                khalti.close(context);
              }
            },
        onReturn: () {
          log('Returned to app from Khalti');
        },
      );

      if (mounted) {
        khalti.open(context);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Checkout failed: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Verifies payment with backend.
  // On success: order is created, cart is cleared, Khalti is closed, navigates to order detail.
  // On failure: returns result (or null on error) so caller can handle messaging.
  Future<Map<String, dynamic>?> _verifyCheckout(
    String pidx,
    Khalti khalti,
  ) async {
    try {
      final result = await _paymentService.verifyCheckout(pidx: pidx);

      if (result['status'] == 'completed') {
        khalti.close(context);
        if (!mounted) return result;

        // Refresh local cart state since backend cleared it atomically
        await context.read<CartProvider>().fetchCart();

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) =>
                OrderDetailScreen(orderId: result['orderId'] as String),
          ),
          (route) => route.settings.name == '/shop' || route.isFirst,
        );
      }

      return result;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final total = cartProvider.total;

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

                  ...cartProvider.items.map((cartItem) {
                    final subtotal = cartItem.product.price * cartItem.quantity;
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
                        'Rs. ${total.toStringAsFixed(0)}',
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

      bottomNavigationBar: BottomBar(
        child: PrimaryButton(
          text: 'Pay Rs. ${total.toStringAsFixed(0)} with Khalti',
          isLoading: _isLoading,
          onTap: _startCheckout,
        ),
      ),
    );
  }
}
