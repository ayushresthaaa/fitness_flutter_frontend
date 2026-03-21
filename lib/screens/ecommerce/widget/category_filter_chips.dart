import 'package:flutter/material.dart';
import '../../../models/ecommerce/product_model.dart';
import '../../../widgets/common.dart';

class CategoryFilterChips extends StatelessWidget {
  final List<ProductCategory> categories;
  final String? selectedCategoryId;
  final void Function(String? categoryId) onCategorySelected;

  const CategoryFilterChips({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // "All" chip — always shown first, clears the category filter
          _buildChip(
            label: 'All',
            isSelected: selectedCategoryId == null,
            onTap: () {
              onCategorySelected(null);
            },
          ),

          const SizedBox(width: 8),

          // One chip per category
          ...categories.map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildChip(
                label: category.name,
                isSelected: selectedCategoryId == category.id,
                onTap: () {
                  onCategorySelected(category.id);
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? kPrimary : kWhite,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? kWhite : kTextGrey,
          ),
        ),
      ),
    );
  }
}
