import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ecommerce/order_provider.dart';
import '../../models/ecommerce/order_model.dart';
import '../../widgets/common.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((duration) {
      context.read<OrderProvider>().fetchOrderById(widget.orderId);
    });
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return const Color(0xFFF57C00);
      case OrderStatus.confirmed:
        return kPrimary;
      case OrderStatus.shipped:
        return kGreen;
      case OrderStatus.delivered:
        return const Color(0xFF2E7D32);
      case OrderStatus.cancelled:
        return kRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final order = orderProvider.selectedOrder;

    if (orderProvider.isLoading || order == null) {
      return const Scaffold(
        backgroundColor: kBackground,
        body: Center(child: CircularProgressIndicator(color: kPrimary)),
      );
    }

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppTopBar(
        title:
            'Order #${order.id.substring(order.id.length - 6).toUpperCase()}',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status and date card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kWhite,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Status',
                        style: TextStyle(fontSize: 12, color: kTextGrey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.status.name[0].toUpperCase() +
                            order.status.name.substring(1),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _statusColor(order.status),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Date',
                        style: TextStyle(fontSize: 12, color: kTextGrey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(order.createdAt),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: kTextDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Order items card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kWhite,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionLabel('Items'),
                  const SizedBox(height: 12),

                  ...order.items.map((item) {
                    final hasImage =
                        item.product != null &&
                        item.product!.imageUrls.isNotEmpty;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          // Product image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: hasImage
                                ? Image.network(
                                    item.product!.imageUrls[0],
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return _buildImagePlaceholder();
                                    },
                                  )
                                : _buildImagePlaceholder(),
                          ),

                          const SizedBox(width: 12),

                          // Product name and quantity
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.product?.name ?? 'Product',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: kTextDark,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '× ${item.quantity}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: kTextGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Price at time of order
                          Text(
                            'Rs. ${(item.priceAtTime * item.quantity).toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: kTextDark,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Price summary card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kWhite,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionLabel('Price Summary'),
                  const SizedBox(height: 12),

                  ...order.items.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${item.product?.name ?? 'Product'} × ${item.quantity}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: kTextGrey,
                              ),
                            ),
                          ),
                          Text(
                            'Rs. ${(item.priceAtTime * item.quantity).toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: kTextDark,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const Divider(color: kDivider),
                  const SizedBox(height: 8),

                  // Total
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
                        'Rs. ${order.totalAmount.toStringAsFixed(0)}',
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

            const SizedBox(height: 12),

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

                  _buildInfoRow('Name', order.shippingName),
                  const SizedBox(height: 8),
                  _buildInfoRow('Phone', order.shippingPhone),
                  const SizedBox(height: 8),
                  _buildInfoRow('Address', order.shippingAddress),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: kTextGrey),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: kTextDark,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 50,
      height: 50,
      color: kBackground,
      child: const Icon(Icons.inventory_2_outlined, color: kTextHint, size: 22),
    );
  }
}
