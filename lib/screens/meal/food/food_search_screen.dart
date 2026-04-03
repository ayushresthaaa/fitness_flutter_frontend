// lib/screens/meal/food_search_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../widgets/common.dart';
import '../../../providers/meal/food_provider.dart';
import '../../../models/meal/food_model.dart';
import 'widgets/food_search_tile.dart';
import 'widgets/quantity_bottom_sheet.dart';

class FoodSearchScreen extends StatefulWidget {
  // slotId tells the backend which meal slot (breakfast/lunch etc.) to log into
  final String slotId;
  final String slotName;

  const FoodSearchScreen({
    super.key,
    required this.slotId,
    required this.slotName,
  });

  @override
  State<FoodSearchScreen> createState() => FoodSearchScreenState();
}

class FoodSearchScreenState extends State<FoodSearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  // null = no category filter active
  String? _selectedCategory;

  // whether we are filtering to nepali foods only
  bool _showNepaliOnly = false;

  // whether user has typed anything — controls whether to show recent or results
  bool _hasSearched = false;

  final List<Map<String, String>> _categories = const [
    {'key': 'protein', 'label': 'Protein'},
    {'key': 'grain', 'label': 'Grain'},
    {'key': 'dairy', 'label': 'Dairy'},
    {'key': 'fruit', 'label': 'Fruit'},
    {'key': 'vegetable', 'label': 'Vegetable'},
    {'key': 'legume', 'label': 'Legume'},
    {'key': 'nepali', 'label': 'Nepali'},
    {'key': 'snack', 'label': 'Snack'},
    {'key': 'beverage', 'label': 'Beverage'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // always load recent foods so they show up before any search
      context.read<FoodProvider>().loadRecentFoods();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    context.read<FoodProvider>().clearSearch();
    super.dispose();
  }

  // runs a search with current query + filters
  void _runSearch() {
    final query = _searchController.text.trim();

    setState(() {
      _hasSearched =
          query.isNotEmpty || _selectedCategory != null || _showNepaliOnly;
    });

    context.read<FoodProvider>().searchFoods(
      search: query.isEmpty ? null : query,
      category: _selectedCategory,
      isNepali: _showNepaliOnly ? true : null,
    );
  }

  void _onSearchChanged(String value) {
    setState(() {}); // rebuild to show/hide clear button
    _runSearch();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _hasSearched = false;
      _selectedCategory = null;
      _showNepaliOnly = false;
    });
    context.read<FoodProvider>().clearSearch();
  }

  void _onCategoryTapped(String categoryKey) {
    setState(() {
      if (_selectedCategory == categoryKey) {
        // deselect
        _selectedCategory = null;
        if (categoryKey == 'nepali') _showNepaliOnly = false;
      } else {
        _selectedCategory = categoryKey;
        if (categoryKey == 'nepali') _showNepaliOnly = true;
      }
    });
    _runSearch();
  }

  void _onNepaliToggled(bool value) {
    setState(() {
      _showNepaliOnly = value;
      if (value) {
        _selectedCategory = 'nepali';
      } else {
        if (_selectedCategory == 'nepali') _selectedCategory = null;
      }
    });
    _runSearch();
  }

  // opens the quantity sheet; pops back to meal planner on success
  Future<void> _openQuantitySheet(Food food) async {
    final logged = await QuantityBottomSheet.show(
      context,
      food: food,
      slotId: widget.slotId,
    );

    if (logged && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final foodProvider = context.watch<FoodProvider>();

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppTopBar(title: 'Add to ${widget.slotName}'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // white top section: search bar + category chips + nepali toggle
          Container(
            color: kWhite,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // search bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: kBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      style: const TextStyle(fontSize: 14, color: kTextDark),
                      decoration: InputDecoration(
                        hintText: 'Search foods...',
                        hintStyle: const TextStyle(
                          fontSize: 14,
                          color: kTextGrey,
                        ),
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
                                  size: 18,
                                ),
                                onPressed: _clearSearch,
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 13,
                        ),
                      ),
                      onChanged: _onSearchChanged,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // horizontal category filter chips
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      final isSelected = _selectedCategory == cat['key'];
                      return GestureDetector(
                        onTap: () => _onCategoryTapped(cat['key']!),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? kPrimary : kBackground,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? kPrimary : kDivider,
                            ),
                          ),
                          child: Text(
                            cat['label']!,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isSelected ? kWhite : kTextGrey,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 10),

                // nepali foods toggle
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.restaurant_outlined,
                        size: 16,
                        color: kTextGrey,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Nepali foods only',
                        style: TextStyle(fontSize: 13, color: kTextGrey),
                      ),
                      const Spacer(),
                      Switch(
                        value: _showNepaliOnly,
                        onChanged: _onNepaliToggled,
                        activeColor: kPrimary,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // body — recent foods or search results
          Expanded(child: _buildBody(foodProvider)),
        ],
      ),
    );
  }

  Widget _buildBody(FoodProvider foodProvider) {
    // show spinner while a search is running
    if (foodProvider.isSearching) {
      return const Center(child: CircularProgressIndicator(color: kPrimary));
    }

    // if user hasn't searched yet, show recent foods
    if (!_hasSearched) {
      return _buildRecentSection(foodProvider);
    }

    // search results
    final results = foodProvider.searchResults;
    if (results.isEmpty) {
      return const EmptyState(
        icon: Icons.search_off_outlined,
        title: 'No foods found',
        subtitle: 'Try a different name or category',
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        return FoodSearchTile(
          food: results[index],
          onTap: () => _openQuantitySheet(results[index]),
        );
      },
    );
  }

  Widget _buildRecentSection(FoodProvider foodProvider) {
    final recentFoods = foodProvider.recentFoods;

    if (recentFoods.isEmpty) {
      return const EmptyState(
        icon: Icons.restaurant_menu_outlined,
        title: 'No recent foods',
        subtitle: 'Search above to find and log foods',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 10),
          child: SectionLabel('Recent Foods'),
        ),

        // recent foods as quick-tap chips
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: recentFoods.map((food) {
              return GestureDetector(
                onTap: () => _openQuantitySheet(food),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: kWhite,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: kDivider),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        food.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: kTextDark,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${food.calories.toInt()} kcal',
                        style: const TextStyle(fontSize: 11, color: kTextGrey),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: SectionLabel('All Foods'),
        ),

        // below recent chips, show full list via search with no filters
        Expanded(
          child: FutureBuilder(
            future: _loadAllFoods(),
            builder: (context, snapshot) {
              final results = foodProvider.searchResults;
              if (results.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: kPrimary),
                );
              }
              return ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  return FoodSearchTile(
                    food: results[index],
                    onTap: () => _openQuantitySheet(results[index]),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // loads all foods with no filters so the default list is populated
  Future<void> _loadAllFoods() async {
    final foodProvider = context.read<FoodProvider>();
    if (foodProvider.searchResults.isEmpty) {
      await foodProvider.searchFoods();
    }
  }
}
