import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:khalti_checkout_flutter/khalti_checkout_flutter.dart';
import '../../providers/ecommerce/cart_provider.dart';
import '../../providers/ecommerce/order_provider.dart';
import '../../models/ecommerce/order_model.dart';
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

  // Once order is placed we store it here and show the Khalti button
  Order? _placedOrder;
  bool _isInitiatingPayment = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }


  Future<void> _placeOrder() async {
    if (_nameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all shipping details')),
      );
      return;
    }

    final orderProvider = context.read<OrderProvider>();

    final order = await orderProvider.placeOrder(
      shippingName: _nameController.text.trim(),
      shippingPhone: _phoneController.text.trim(),
      shippingAddress: _addressController.text.trim(),
    );

    if (order != null && mounted) {

      await context.read<CartProvider>().clearCart();
      setState(() {
        _placedOrder = order;
      });
    }
  }

  Future<void> _initiateKhaltiPayment() async {
    if (_placedOrder == null) return;

    setState(() {
      _isInitiatingPayment = true;
    });

    try {

      final result = await _paymentService.initiatePayment(
        orderId: _placedOrder!.id,
      );

      final pidx = result['pidx'];

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

          // Payment done 
          await _verifyPayment(pidx, khalti);
        },
        onMessage: (
          khalti, {
          description,
          statusCode,
          event,
          needsPaymentConfirmation,
        }) async {
          log('Khalti message: $description');

          // If payment confirmation is needed, verify with backend
          if (needsPaymentConfirmation == true) {
            await _verifyPayment(pidx, khalti);
          } else {
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
          SnackBar(content: Text('Failed to initiate payment: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isInitiatingPayment = false;
        });
      }
    }
  }

  //Verify payment with our backend after Khalti confirms
  Future<void> _verifyPayment(String pidx, Khalti khalti) async {
    try {
      final result = await _paymentService.verifyPayment(pidx: pidx);
      khalti.close(context);

      if (!mounted) return;

      if (result['status'] == 'completed') {
        // Payment successful
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) =>
                OrderDetailScreen(orderId: _placedOrder!.id),
          ),
          (route) => route.settings.name == '/shop' || route.isFirst,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment failed. Please try again.')),
        );
      }
    } catch (error) {
      khalti.close(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment verification failed: $error')),
        );
      }
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
            if (_placedOrder == null)
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

            // Order placed confirmation
            if (_placedOrder != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: kGreen, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Order #${_placedOrder!.id.substring(_placedOrder!.id.length - 6).toUpperCase()} placed. Complete payment to confirm.',
                        style: const TextStyle(
                          fontSize: 13,
                          color: kTextDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 100),
          ],
        ),
      ),

      // Bottom bar — shows Place Order or Pay with Khalti depending on state
      bottomNavigationBar: BottomBar(
        child: _placedOrder == null
            ? PrimaryButton(
                text: 'Place Order',
                isLoading: orderProvider.isLoading,
                onTap: _placeOrder,
              )
            : PrimaryButton(
                text: 'Pay with Khalti',
                isLoading: _isInitiatingPayment,
                onTap: _initiateKhaltiPayment,
              ),
      ),
    );
  }
}