import 'package:blinkit_clone/sub_screens/category_sidebar.dart';
import 'package:blinkit_clone/sub_screens/category_product_list.dart';
import 'package:blinkit_clone/sub_screens/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../providers/product_provider.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

class GroceryScreen extends StatefulWidget {
  final Category? selectedCategory;
  final String? superCategoryName;

  const GroceryScreen({
    super.key,
    this.selectedCategory,
    this.superCategoryName,
  });

  @override
  State<GroceryScreen> createState() => _GroceryScreenState();
}

class _GroceryScreenState extends State<GroceryScreen> {
  String? selectedSuperCategory;
  String? selectedSubCategory;
  String? selectedSubSubCategory;

  String _selectedSort = 'default';
  bool _filterRating = false;
  bool _filterTime = false;
  bool _filterOffers = false;
  String _selectedVegFilter = 'all'; // 'all', 'veg', 'non_veg'

  @override
  void initState() {
    super.initState();
    if (widget.selectedCategory != null && widget.superCategoryName != null) {
      selectedSuperCategory = widget.superCategoryName;
      selectedSubCategory = widget.selectedCategory!.name;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().fetchCategories().then((_) {
        if (!mounted) return;
        final catProv = context.read<CategoryProvider>();
        if (selectedSuperCategory == null && catProv.categories.isNotEmpty) {
          final firstSuper = catProv.categories.first.name;
          setState(() {
            selectedSuperCategory = firstSuper;
          });
          context.read<ProductProvider>().fetchProductsBySuperCategory(firstSuper);
        }
      });

      if (widget.selectedCategory != null) {
        context.read<ProductProvider>().fetchProductsBySubCategory(
          widget.selectedCategory!.name,
        );
      } else {
        context.read<ProductProvider>().fetchProducts();
      }
    });
  }

  void _onCategorySelected(String superCategory, String? subCategory, String? subSubCategory) {
    setState(() {
      selectedSuperCategory = superCategory;
      selectedSubCategory = subCategory;
      selectedSubSubCategory = subSubCategory;
    });

    if (subSubCategory != null) {
      context.read<ProductProvider>().fetchProductsBySubSubCategory(subCategory!, subSubCategory);
    } else if (subCategory != null) {
      context.read<ProductProvider>().fetchProductsBySubCategory(subCategory);
    } else {
      context.read<ProductProvider>().fetchProductsBySuperCategory(
        superCategory,
      );
    }
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Sort by",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Default", style: TextStyle(fontWeight: FontWeight.w500)),
                    trailing: _selectedSort == 'default'
                        ? const Icon(Icons.check_circle, color: Color(0xFFE23744))
                        : null,
                    onTap: () {
                      setState(() => _selectedSort = 'default');
                      setModalState(() {});
                      Navigator.pop(ctx);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Price: Low to High", style: TextStyle(fontWeight: FontWeight.w500)),
                    trailing: _selectedSort == 'low_to_high'
                        ? const Icon(Icons.check_circle, color: Color(0xFFE23744))
                        : null,
                    onTap: () {
                      setState(() => _selectedSort = 'low_to_high');
                      setModalState(() {});
                      Navigator.pop(ctx);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Price: High to Low", style: TextStyle(fontWeight: FontWeight.w500)),
                    trailing: _selectedSort == 'high_to_low'
                        ? const Icon(Icons.check_circle, color: Color(0xFFE23744))
                        : null,
                    onTap: () {
                      setState(() => _selectedSort = 'high_to_low');
                      setModalState(() {});
                      Navigator.pop(ctx);
                    },
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  Widget _buildFilterChip(
    String label, {
    bool hasDropdown = false,
    bool hasTagIcon = false,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(
            color: isActive ? const Color(0xFFE23744) : Colors.grey.shade300,
            width: isActive ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
          color: isActive ? const Color(0xFFFFEBEB) : Colors.white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasTagIcon) ...[
              Icon(
                Icons.local_offer_outlined,
                size: 13,
                color: isActive ? const Color(0xFFE23744) : Colors.black54,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? const Color(0xFFE23744) : Colors.black87,
              ),
            ),
            if (hasDropdown) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down,
                size: 13,
                color: isActive ? const Color(0xFFE23744) : Colors.black54,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersRow() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            _buildFilterChip(
              _selectedSort == 'default'
                  ? "Sort"
                  : (_selectedSort == 'low_to_high'
                      ? "Sort: Low to High"
                      : "Sort: High to Low"),
              hasDropdown: true,
              isActive: _selectedSort != 'default',
              onTap: _showSortBottomSheet,
            ),
            _buildFilterChip(
              "All",
              isActive: _selectedVegFilter == 'all',
              onTap: () {
                setState(() {
                  _selectedVegFilter = 'all';
                });
              },
            ),
            _buildFilterChip(
              "Veg 🟢",
              isActive: _selectedVegFilter == 'veg',
              onTap: () {
                setState(() {
                  _selectedVegFilter = 'veg';
                });
              },
            ),
            _buildFilterChip(
              "Non-Veg 🔴",
              isActive: _selectedVegFilter == 'non_veg',
              onTap: () {
                setState(() {
                  _selectedVegFilter = 'non_veg';
                });
              },
            ),
            _buildFilterChip(
              "Rating 4.0+",
              isActive: _filterRating,
              onTap: () {
                setState(() {
                  _filterRating = !_filterRating;
                });
              },
            ),
            _buildFilterChip(
              "20-30 min",
              isActive: _filterTime,
              onTap: () {
                setState(() {
                  _filterTime = !_filterTime;
                });
              },
            ),
            _buildFilterChip(
              "Offers",
              hasTagIcon: true,
              isActive: _filterOffers,
              onTap: () {
                setState(() {
                  _filterOffers = !_filterOffers;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryEmoji(String subCatName) {
    switch (subCatName.toLowerCase()) {
      case 'biryani':
        return '🍲';
      case 'burgers':
        return '🍔';
      case 'pizzas':
        return '🍕';
      case 'cakes':
        return '🍰';
      case 'chinese':
        return '🍜';
      case 'rolls':
        return '🌯';
      default:
        return '🍛';
    }
  }

  Widget _buildHorizontalSubcategoryChips(List<Category> subCats) {
    final allSelected = selectedSubCategory == null;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          // "All" chip
          GestureDetector(
            onTap: () {
              setState(() {
                selectedSubCategory = null;
              });
              if (selectedSuperCategory != null) {
                context.read<ProductProvider>().fetchProductsBySuperCategory(selectedSuperCategory!);
              }
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: allSelected ? const Color(0xFFE23744) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: allSelected ? null : Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Text(
                    '🍴',
                    style: TextStyle(
                      fontSize: 14,
                      color: allSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'All',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: allSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Subcategory chips
          ...subCats.map((subCat) {
            final isSelected = selectedSubCategory == subCat.name;
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedSubCategory = subCat.name;
                });
                context.read<ProductProvider>().fetchProductsBySubCategory(subCat.name);
              },
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFE23744) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected ? null : Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Text(
                      _getCategoryEmoji(subCat.name),
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      subCat.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCustomHeader() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 8,
        left: 16,
        right: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Custom Circle Back Button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Title & Subtitle column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      selectedSuperCategory ?? 'What are you craving?',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Find the best food & restaurants',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Custom Search Button
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SearchScreen()),
                  );
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF0F0),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.search,
                    color: Color(0xFFE23744),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            color: Colors.grey.shade100,
            height: 1,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Consumer2<CategoryProvider, ProductProvider>(
        builder: (context, categoryProvider, productProvider, child) {
          if (categoryProvider.isLoading &&
              categoryProvider.categories.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFE23744)));
          }

          // Apply filters
          List<ProductModel> filtered = productProvider.categoryProducts.toList();

          if (_selectedVegFilter == 'veg') {
            filtered = filtered.where((p) => p.isVeg).toList();
          } else if (_selectedVegFilter == 'non_veg') {
            filtered = filtered.where((p) => !p.isVeg).toList();
          }

          if (_filterRating) {
            filtered = filtered.where((p) => p.rating >= 4.0).toList();
          }

          if (_filterTime) {
            filtered = filtered.where((p) => p.deliveryTime >= 20 && p.deliveryTime <= 30).toList();
          }

          if (_filterOffers) {
            filtered = filtered.where((p) => p.discountPercent > 0).toList();
          }

          if (_selectedSort == 'low_to_high') {
            filtered.sort((a, b) {
              final aPrice = a.price * (1 - a.discountPercent / 100);
              final bPrice = b.price * (1 - b.discountPercent / 100);
              return aPrice.compareTo(bPrice);
            });
          } else if (_selectedSort == 'high_to_low') {
            filtered.sort((a, b) {
              final aPrice = a.price * (1 - a.discountPercent / 100);
              final bPrice = b.price * (1 - b.discountPercent / 100);
              return bPrice.compareTo(aPrice);
            });
          }

          final activeSupCat = categoryProvider.categories.firstWhere(
            (c) => c.name == selectedSuperCategory,
            orElse: () => categoryProvider.categories.isNotEmpty
                ? categoryProvider.categories.first
                : SupCatModel(name: '', categories: []),
          );
          final subCats = activeSupCat.categories;

          return Column(
            children: [
              _buildCustomHeader(),
              _buildHorizontalSubcategoryChips(subCats),
              Expanded(
                child: Row(
                  children: [
                    CategorySidebar(
                      categories: categoryProvider.categories,
                      selectedSuperCategory: selectedSuperCategory,
                      selectedSubCategory: selectedSubCategory,
                      selectedSubSubCategory: selectedSubSubCategory,
                      onCategorySelected: _onCategorySelected,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          _buildFiltersRow(),
                          Expanded(
                            child: CategoryProductList(
                              products: filtered,
                              isLoading: productProvider.isLoading,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}




