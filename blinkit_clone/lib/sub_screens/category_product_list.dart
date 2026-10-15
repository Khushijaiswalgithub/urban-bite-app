import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../widgets/cart_conflict_dialog.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';

class CategoryProductList extends StatelessWidget {
  final List<ProductModel> products;
  final bool isLoading;

  const CategoryProductList({
    super.key,
    required this.products,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFE23744)));
    }

    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No items found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Try switching categories',
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: products.length,
      separatorBuilder: (context, index) => Divider(color: Colors.grey[100], height: 24),
      itemBuilder: (context, index) {
        final product = products[index];
        final discountedPrice = product.price * (1 - product.discountPercent / 100);
        final double rating = product.rating;
        final int deliveryTime = product.deliveryTime;

        void showCartSheet() {
          final scaffold = Scaffold.of(context);
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          scaffold.showBottomSheet((ctx) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8),
                ],
              ),
              child: Consumer<CartProvider>(
                builder: (context, cart, _) {
                  return Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${cart.itemCount} item${cart.itemCount == 1 ? '' : 's'} in cart',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₹${cart.totalAmount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(ctx);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CartScreen(),
                                ),
                              );
                            },
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.shopping_bag_outlined,
                                    color: Colors.black87,
                                    size: 24,
                                  ),
                                ),
                                if (cart.itemCount > 0)
                                  Positioned(
                                    right: -6,
                                    top: -6,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.15),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        '${cart.itemCount}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CartScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE23744),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            child: const Text(
                              'View Cart',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            );
          }, backgroundColor: Colors.transparent);
        }

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailScreen(product: product),
              ),
            );
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image on the left
              Stack(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[50],
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: product.images.isNotEmpty
                          ? (product.images.first.startsWith('http')
                              ? CachedNetworkImage(
                                  imageUrl: product.images.first,
                                  width: 90,
                                  height: 90,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: Colors.grey[50],
                                    child: const Center(
                                      child: SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFE23744)),
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    color: Colors.grey[100],
                                    child: const Icon(Icons.restaurant, color: Colors.grey, size: 28),
                                  ),
                                )
                              : Image.asset(
                                  product.images.first,
                                  width: 90,
                                  height: 90,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    color: Colors.grey[100],
                                    child: const Icon(Icons.restaurant, color: Colors.grey, size: 28),
                                  ),
                                ))
                          : Container(
                              color: Colors.grey[100],
                              child: const Icon(Icons.restaurant, color: Colors.grey, size: 28),
                            ),
                    ),
                  ),
                  // Heart/Wishlist Button Overlay
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Consumer<WishlistProvider>(
                      builder: (context, wishlist, _) {
                        final isFav = wishlist.isFavorite(product.id ?? '');
                        return GestureDetector(
                          onTap: () {
                            wishlist.toggleFavorite(product.id ?? '');
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav ? Colors.red : Colors.white,
                              size: 14,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Time Badge Overlay at bottom
                  Positioned(
                    bottom: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 2,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Text(
                        '$deliveryTime min',
                        style: const TextStyle(
                          color: Color(0xFF2E7D32),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              // Product details column on the right
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Rating row
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 14),
                        const SizedBox(width: 2),
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '• ${product.subCategory ?? 'Food'}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Delivery Details Row
                    Text(
                      '$deliveryTime min • ₹${(product.discountPercent > 0 ? discountedPrice : product.price).toStringAsFixed(0)} for one',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Add Button / Cart Adjuster aligned to the bottom right
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        height: 32,
                        width: 80,
                        alignment: Alignment.center,
                        child: Consumer<CartProvider>(
                          builder: (context, cart, _) {
                            final existing = cart.items.indexWhere(
                              (i) => i.productId == product.id && i.quantity == product.quantity,
                            );
                            if (existing < 0) {
                              return GestureDetector(
                                onTap: () {
                                  try {
                                    cart.addItem(product);
                                    showCartSheet();
                                  } on RestaurantConflictException catch (e) {
                                    handleCartConflict(
                                      context: context,
                                      exception: e,
                                      product: product,
                                      onSuccess: () {
                                        showCartSheet();
                                      },
                                    );
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: const Color(0xFFE23744), width: 1.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Text(
                                        'Add ',
                                        style: TextStyle(
                                          color: Color(0xFFE23744),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Icon(Icons.add, size: 12, color: Color(0xFFE23744)),
                                    ],
                                  ),
                                ),
                              );
                            }

                            final count = cart.items[existing].count;
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: const Color(0xFFE23744), width: 1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () => cart.updateQuantity(
                                      product.id ?? '',
                                      product.quantity,
                                      count - 1,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFE23744),
                                        borderRadius: BorderRadius.horizontal(left: Radius.circular(7)),
                                      ),
                                      child: const Icon(Icons.remove, color: Colors.white, size: 12),
                                    ),
                                  ),
                                  Text(
                                    '$count',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => cart.updateQuantity(
                                      product.id ?? '',
                                      product.quantity,
                                      count + 1,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF4CAF50),
                                        borderRadius: BorderRadius.horizontal(right: Radius.circular(7)),
                                      ),
                                      child: const Icon(Icons.add, color: Colors.white, size: 12),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}




