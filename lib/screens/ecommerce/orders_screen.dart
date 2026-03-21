import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ecommerce/order_provider.dart';
import '../../models/ecommerce/order_model.dart';
import '../../widgets/common.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';

  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((duration) {
      context.read<OrderProvider>().fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppTopBar(title: 'My Orders'),
      body: orderProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: kPrimary))
          : orderProvider.orders.isEmpty
              ? const EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'No orders yet',
                  subtitle: 'Your orders will appear here',
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: orderProvider.orders.length,
                        separatorBuilder: (context, index) {
                          return const SizedBox(height: 12);
                        },
                        itemBuilder: (context, index) {
                          final order = orderProvider.orders[index];
                          return _OrderCard(
                            order: order,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OrderDetailScreen(
                                    orderId: order.id,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),

                    // Pagination row
                    if (orderProvider.totalPages > 1)
                      _buildPaginationRow(orderProvider),
                  ],
                ),
    );
  }

  Widget _buildPaginationRow(OrderProvider orderProvider) {
    return Container(
      color: kWhite,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous button
          IconButton(
            onPressed: orderProvider.currentPage > 1
                ? () {
                    orderProvider.goToPage(orderProvider.currentPage - 1);
                  }
                : null,
            icon: const Icon(Icons.chevron_left_rounded),
            color: kPrimary,
            disabledColor: kTextHint,
          ),

          // Page number buttons
          ...List.generate(orderProvider.totalPages, (index) {
            final pageNumber = index + 1;
            final isCurrentPage = pageNumber == orderProvider.currentPage;

            return GestureDetector(
              onTap: () {
                orderProvider.goToPage(pageNumber);
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
            onPressed: orderProvider.currentPage < orderProvider.totalPages
                ? () {
                    orderProvider.goToPage(orderProvider.currentPage + 1);
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

// A single order card
class _OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;

  const _OrderCard({required this.order, required this.onTap});

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order id
                  Text(
                    'Order #${order.id.substring(order.id.length - 6).toUpperCase()}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: kTextDark,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Item count + date
                  Text(
                    '${order.items.length} ${order.items.length == 1 ? 'item' : 'items'} · ${_formatDate(order.createdAt)}',
                    style: const TextStyle(fontSize: 12, color: kTextGrey),
                  ),

                  const SizedBox(height: 6),

                  // Total
                  Text(
                    'Rs. ${order.totalAmount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: kPrimary,
                    ),
                  ),
                ],
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Status
                Text(
                  order.status.name[0].toUpperCase() +
                      order.status.name.substring(1),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _statusColor(order.status),
                  ),
                ),

                const SizedBox(height: 8),

                const Icon(
                  Icons.chevron_right_rounded,
                  color: kTextHint,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}