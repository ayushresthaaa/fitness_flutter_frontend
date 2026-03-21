import 'package:flutter/material.dart';
import '../../../models/ecommerce/product_model.dart';
import '../../../widgets/common.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasImage = product.imageUrls.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: hasImage
                  ? Image.network(
                      product.imageUrls[0],
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholder();
                      },
                    )
                  : _buildPlaceholder(),
            ),

            // Product info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category name
                  Text(
                    product.category?.name ?? '',
                    style: const TextStyle(fontSize: 11, color: kTextGrey),
                  ),

                  const SizedBox(height: 3),

                  // Product name
                  Text(
                    product.name,
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
                    'Rs. ${product.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: kPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Shown when image is missing or fails to load
  Widget _buildPlaceholder() {
    return Container(
      height: 140,
      width: double.infinity,
      color: kBackground,
      child: const Icon(Icons.inventory_2_outlined, color: kTextHint, size: 40),
    );
  }
}
