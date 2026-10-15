import 'package:flutter/material.dart';
import '../models/category_model.dart';

class CategorySidebar extends StatefulWidget {
  final List<SupCatModel> categories;
  final String? selectedSuperCategory;
  final String? selectedSubCategory;
  final String? selectedSubSubCategory;
  final Function(String, String?, String?) onCategorySelected;

  const CategorySidebar({
    super.key,
    required this.categories,
    required this.selectedSuperCategory,
    required this.selectedSubCategory,
    required this.selectedSubSubCategory,
    required this.onCategorySelected,
  });

  @override
  State<CategorySidebar> createState() => _CategorySidebarState();
}

class _CategorySidebarState extends State<CategorySidebar> {
  String? _expandedSubCategory;

  @override
  void initState() {
    super.initState();
    _expandedSubCategory = widget.selectedSubCategory;
  }

  @override
  void didUpdateWidget(covariant CategorySidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedSubCategory != oldWidget.selectedSubCategory &&
        widget.selectedSubCategory != _expandedSubCategory) {
      _expandedSubCategory = widget.selectedSubCategory;
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayCategories = widget.selectedSuperCategory != null
        ? widget.categories.where((cat) => cat.name == widget.selectedSuperCategory).toList()
        : widget.categories;
    return Container(
      width: 100,
      color: const Color(0xFFF7F7F7),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: displayCategories.length,
        itemBuilder: (context, index) {
          final superCategory = displayCategories[index];
          final isSelected = superCategory.name == widget.selectedSuperCategory;

          return Column(
            children: [
              // Supercategory card
              GestureDetector(
                onTap: () => widget.onCategorySelected(superCategory.name, null, null),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(color: const Color(0xFFE23744), width: 1.5)
                        : null,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          color: isSelected ? const Color(0xFFFFEBEB) : Colors.grey[200],
                        ),
                        child: Icon(
                          _getCategoryIcon(superCategory.name),
                          color: isSelected ? const Color(0xFFE23744) : Colors.grey[600],
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        superCategory.name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? const Color(0xFFE23744) : Colors.grey[800],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              // Subcategories list under selected supercategory
              if (isSelected && superCategory.categories.isNotEmpty)
                ...superCategory.categories.map((subCat) {
                  final isSubSelected = subCat.name == widget.selectedSubCategory;
                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if (_expandedSubCategory == subCat.name) {
                              _expandedSubCategory = null;
                            } else {
                              _expandedSubCategory = subCat.name;
                            }
                          });
                          widget.onCategorySelected(superCategory.name, subCat.name, null);
                        },
                        child: Row(
                          children: [
                            // Left edge red indicator for active subcategory
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 3,
                              height: 36,
                              decoration: BoxDecoration(
                                color: isSubSelected ? const Color(0xFFE23744) : Colors.transparent,
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(3),
                                  bottomRight: Radius.circular(3),
                                ),
                              ),
                            ),
                            Expanded(
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                                decoration: BoxDecoration(
                                  color: isSubSelected ? Colors.white : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: isSubSelected
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.03),
                                            blurRadius: 2,
                                            offset: const Offset(0, 1),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        color: Colors.white,
                                        child: _buildSubcategoryImage(subCat.image),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      subCat.name,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: isSubSelected ? FontWeight.bold : FontWeight.w500,
                                        color: isSubSelected ? const Color(0xFFE23744) : Colors.grey[700],
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (subCat.subCategories != null && subCat.subCategories!.isNotEmpty)
                                      Icon(
                                        _expandedSubCategory == subCat.name
                                            ? Icons.keyboard_arrow_up
                                            : Icons.keyboard_arrow_down,
                                        size: 16,
                                        color: isSubSelected ? const Color(0xFFE23744) : Colors.grey[600],
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_expandedSubCategory == subCat.name && subCat.subCategories != null && subCat.subCategories!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 8, top: 4, bottom: 8, right: 8),
                          child: Column(
                            children: subCat.subCategories!.map((subSubCat) {
                              final isSubSubSelected = subSubCat.name == widget.selectedSubSubCategory;
                              return GestureDetector(
                                onTap: () => widget.onCategorySelected(superCategory.name, subCat.name, subSubCat.name),
                                child: Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(bottom: 6),
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                                  decoration: BoxDecoration(
                                    color: isSubSubSelected ? Colors.white : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    border: isSubSubSelected
                                        ? Border.all(color: const Color(0xFFE23744), width: 1.2)
                                        : Border.all(color: Colors.grey.shade200, width: 0.8),
                                    boxShadow: isSubSubSelected
                                        ? [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.04),
                                              blurRadius: 3,
                                              offset: const Offset(0, 1),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Text(
                                    subSubCat.name,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 8.5,
                                      fontWeight: isSubSubSelected ? FontWeight.bold : FontWeight.w500,
                                      color: isSubSubSelected ? const Color(0xFFE23744) : Colors.grey[700],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  );
                }).toList(),
              const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'fruits':
        return Icons.apple;
      case 'vegetables':
        return Icons.eco;
      case 'dairy':
        return Icons.local_drink;
      case 'meat':
        return Icons.category;
      case 'bakery':
        return Icons.cake;
      case 'snacks':
        return Icons.fastfood;
      case 'beverages':
        return Icons.local_cafe;
      default:
        return Icons.restaurant;
    }
  }

  Widget _buildSubcategoryImage(String imagePath) {
    // treat as network if it looks like a url, otherwise asset
    final isNetwork =
        imagePath.startsWith('http://') || imagePath.startsWith('https://');
    if (isNetwork) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.image_not_supported, size: 16, color: Colors.grey),
      );
    }

    // asset fallback, with guard for empty path
    if (imagePath.isEmpty) {
      return const Icon(Icons.image, size: 16, color: Colors.grey);
    }

    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.image_not_supported, size: 16, color: Colors.grey),
    );
  }
}




