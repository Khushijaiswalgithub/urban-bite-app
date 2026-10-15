import 'package:blinkit_clone/providers/cart_provider.dart';
import 'package:blinkit_clone/providers/wishlist_provider.dart';
import 'package:blinkit_clone/sub_screens/cart_screen.dart';
import 'package:blinkit_clone/widgets/cart_conflict_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../models/product_model.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int currentImageIndex = 0;
  ProductVariant? _selectedVariant;

  @override
  void initState() {
    super.initState();
    if (widget.product.variants.isNotEmpty) {
      _selectedVariant = widget.product.variants[0];
    }
  }

  ProductVariant get _activeVariant {
    if (_selectedVariant != null) {
      return _selectedVariant!;
    }
    return ProductVariant(
      quantity: widget.product.quantity,
      price: widget.product.price,
      discountPercent: widget.product.discountPercent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeVar = _activeVariant;
    final discountedPrice =
        activeVar.price * (1 - activeVar.discountPercent / 100);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 56,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 8, bottom: 8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
            ),
          ),
        ),
        title: Text(
          widget.product.name,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.shopping_cart_outlined,
                      color: Colors.black87,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CartScreen(),
                        ),
                      );
                    },
                  ),
                  if (cart.itemCount > 0)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE23744), // Zomato red
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Center(
                          child: Text(
                            '${cart.itemCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Product Image Card
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    Container(
                      height: 280,
                      width: double.infinity,
                      color: const Color(0xFFFDFDFD),
                      child: Builder(
                        builder: (context) {
                          List<Map<String, String>> mediaItems = [];
                          if (widget.product.video != null && widget.product.video!.isNotEmpty) {
                            mediaItems.add({'type': 'video', 'url': widget.product.video!});
                          }
                          if (widget.product.images.isNotEmpty) {
                            for (var img in widget.product.images) {
                              mediaItems.add({'type': 'image', 'url': img});
                            }
                          } else if (mediaItems.isEmpty) {
                            mediaItems.add({'type': 'image', 'url': ''});
                          }

                          return PageView.builder(
                            itemCount: mediaItems.length,
                            onPageChanged: (index) {
                              setState(() {
                                currentImageIndex = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              final item = mediaItems[index];
                              final url = item['url'] ?? '';

                              if (item['type'] == 'video') {
                                return ProductVideoPlayer(url: url);
                              } else {
                                if (url.startsWith('http')) {
                                  return CachedNetworkImage(
                                    imageUrl: url,
                                    fit: BoxFit.contain,
                                    placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator(color: Color(0xFFE23744)),
                                    ),
                                    errorWidget: (context, url, error) => const Icon(
                                      Icons.restaurant,
                                      size: 80,
                                      color: Colors.grey,
                                    ),
                                  );
                                } else {
                                  return Image.asset(
                                    url.isNotEmpty ? url : 'assets/images/placeholder.png',
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.restaurant,
                                      size: 80,
                                      color: Colors.grey,
                                    ),
                                  );
                                }
                              }
                            },
                          );
                        }
                      ),
                    ),
                    // Favourite overlay
                    Positioned(
                      left: 12,
                      top: 12,
                      child: Consumer<WishlistProvider>(
                        builder: (context, wishlist, _) {
                          final isFav = wishlist.isFavorite(widget.product.id ?? '');
                          return GestureDetector(
                            onTap: () {
                              wishlist.toggleFavorite(widget.product.id ?? '');
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isFav ? Icons.favorite : Icons.favorite_border,
                                    color: const Color(0xFFE23744),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isFav ? "Saved" : "Favourite",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // Pagination indicator
                    if (widget.product.images.isNotEmpty)
                      Positioned(
                        right: 12,
                        bottom: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Builder(
                            builder: (context) {
                              int mediaCount = widget.product.images.length;
                              if (widget.product.video != null && widget.product.video!.isNotEmpty) {
                                mediaCount += 1;
                              }
                              return Text(
                                '${currentImageIndex + 1}/$mediaCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 2. Product Name & Share Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: widget.product.isVeg ? Colors.green.shade50 : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: widget.product.isVeg ? Colors.green.shade200 : Colors.red.shade200,
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.circle,
                                color: widget.product.isVeg ? Colors.green : Colors.red,
                                size: 10,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.product.isVeg ? 'VEGETARIAN' : 'NON-VEGETARIAN',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: widget.product.isVeg ? Colors.green.shade800 : Colors.red.shade800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                   GestureDetector(
                    onTap: () {
                      final shareText = 'Check out ${widget.product.name} (${activeVar.quantity}) on The urban bite! Price: ₹${(activeVar.discountPercent > 0 ? discountedPrice : activeVar.price).toStringAsFixed(0)} - https://theurbanbite.com/product/${widget.product.id}';
                      Clipboard.setData(ClipboardData(text: shareText));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Product details copied to clipboard!'),
                          backgroundColor: Color(0xFFE23744),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[200]!),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.share_outlined, size: 16, color: Colors.black87),
                          SizedBox(width: 4),
                          Text(
                            "Share",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 3. Weight/Variant Selector
              GestureDetector(
                onTap: widget.product.variants.length <= 1
                    ? null
                    : () => _showVariantSelector(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: widget.product.variants.length <= 1
                          ? Colors.grey[200]!
                          : const Color(0xFFE23744).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.scale_outlined, size: 16, color: Color(0xFFE23744)),
                      const SizedBox(width: 6),
                      Text(
                        activeVar.quantity,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      if (widget.product.variants.length > 1) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.keyboard_arrow_down, size: 16, color: Color(0xFFE23744)),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 4. Pricing Row
              Row(
                children: [
                  if (activeVar.discountPercent > 0) ...[
                    Text(
                      '₹${activeVar.price.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[500],
                        decoration: TextDecoration.lineThrough,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    '₹${(activeVar.discountPercent > 0 ? discountedPrice : activeVar.price).toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 24,
                      color: Color(0xFFE23744), // Zomato red
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (activeVar.discountPercent > 0) ...[
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEB), // Soft pink
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${activeVar.discountPercent.toStringAsFixed(0)}% OFF',
                        style: const TextStyle(
                          color: Color(0xFFE23744), // Zomato red
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 24),

              // 5. About this product Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title with red bar underline
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "About this product",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 40,
                        height: 3,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE23744),
                          borderRadius: BorderRadius.circular(1.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Product Name/Store Info list item
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFEBEB),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.restaurant_menu_outlined,
                          color: Color(0xFFE23744),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.product.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Description list item
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFEBEB),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.description_outlined,
                          color: Color(0xFFE23744),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Description",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              (widget.product.description != null && widget.product.description!.isNotEmpty)
                                  ? widget.product.description!
                                  : "Warm, rich chocolate cake with a molten chocolate center that flows out upon cutting.",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 6. Policy Cards Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Details Card
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[200]!),
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.shield_outlined, color: Color(0xFFE23744), size: 18),
                              SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  "Product Details",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEBEB),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              (widget.product.productDetail != null && widget.product.productDetail!.isNotEmpty)
                                  ? widget.product.productDetail!
                                  : "Contains chocolate, cream, egg, cocoa powder.",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[800],
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Return Policy Card
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[200]!),
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.autorenew_outlined, color: Color(0xFFE23744), size: 18),
                              SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  "Return Policy",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEBEB),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              (widget.product.returnPolicy != null && widget.product.returnPolicy!.isNotEmpty)
                                  ? widget.product.returnPolicy!
                                  : "Non-returnable item.",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[800],
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: 12 + MediaQuery.of(context).padding.bottom,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Consumer<CartProvider>(
          builder: (context, cart, child) {
              final productId = widget.product.id ?? '';
              final existingIndex = cart.items.indexWhere(
                (i) => i.productId == productId && i.quantity == activeVar.quantity,
              );
              final int currentCount = existingIndex >= 0
                  ? cart.items[existingIndex].count
                  : 0;

              return Row(
                children: [
                  // Cart Icon button on left
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CartScreen(),
                        ),
                      );
                    },
                    child: Container(
                      width: 50,
                      color: Colors.transparent,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              const Icon(
                                Icons.shopping_cart_outlined,
                                color: Colors.black87,
                                size: 28,
                              ),
                              if (cart.itemCount > 0)
                                Positioned(
                                  right: -6,
                                  top: -6,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFE23744), // Zomato red
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 16,
                                      minHeight: 16,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${cart.itemCount}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Cart",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Middle Quantity Adjuster
                  Expanded(
                    flex: 4,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        border: Border.all(color: Colors.grey[200]!),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Minus button
                          GestureDetector(
                            onTap: () {
                              if (currentCount > 0) {
                                final newCount = currentCount - 1;
                                Provider.of<CartProvider>(
                                  context,
                                  listen: false,
                                ).updateQuantity(productId, activeVar.quantity, newCount);
                              }
                            },
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFEBEB), // soft pink
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.remove,
                                  color: Color(0xFFE23744), // Zomato red
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                          Text(
                            '$currentCount',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          // Plus button
                          GestureDetector(
                            onTap: () {
                              final cartProv = Provider.of<CartProvider>(
                                context,
                                listen: false,
                              );
                              if (currentCount == 0) {
                                try {
                                  final productCopy = widget.product.copyWith(
                                    price: activeVar.price,
                                    discountPercent: activeVar.discountPercent,
                                    quantity: activeVar.quantity,
                                  );
                                  cartProv.addItem(productCopy);
                                } on RestaurantConflictException catch (e) {
                                  handleCartConflict(
                                    context: context,
                                    exception: e,
                                    product: widget.product.copyWith(
                                      price: activeVar.price,
                                      discountPercent: activeVar.discountPercent,
                                      quantity: activeVar.quantity,
                                    ),
                                    onSuccess: () {},
                                  );
                                }
                              } else {
                                cartProv.updateQuantity(productId, activeVar.quantity, currentCount + 1);
                              }
                            },
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: const BoxDecoration(
                                color: Color(0xFF2CB742), // Green
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Right Add to Cart Button
                  Expanded(
                    flex: 5,
                    child: GestureDetector(
                      onTap: () {
                        final cartProv = Provider.of<CartProvider>(
                          context,
                          listen: false,
                        );
                        if (currentCount == 0) {
                          try {
                            final productCopy = widget.product.copyWith(
                              price: activeVar.price,
                              discountPercent: activeVar.discountPercent,
                              quantity: activeVar.quantity,
                            );
                            cartProv.addItem(productCopy);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${widget.product.name} (${activeVar.quantity}) added to cart!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } on RestaurantConflictException catch (e) {
                            handleCartConflict(
                              context: context,
                              exception: e,
                              product: widget.product.copyWith(
                                price: activeVar.price,
                                discountPercent: activeVar.discountPercent,
                                quantity: activeVar.quantity,
                              ),
                              onSuccess: () {},
                            );
                          }
                        } else {
                          // Go to cart screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CartScreen(),
                            ),
                          );
                        }
                      },
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE23744), // Zomato red
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              currentCount == 0 ? "Add to Cart" : "Go to Cart",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '₹${(activeVar.discountPercent > 0 ? discountedPrice : activeVar.price).toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
  }

  void _showVariantSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Unit',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: widget.product.variants.length,
                  separatorBuilder: (_, __) => Divider(color: Colors.grey[100]),
                  itemBuilder: (context, idx) {
                    final variant = widget.product.variants[idx];
                    final isSelected = _selectedVariant == variant;
                    final vDiscountedPrice = variant.price * (1 - variant.discountPercent / 100);

                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedVariant = variant;
                        });
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFFFF2F2) : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: isSelected
                              ? Border.all(color: const Color(0xFFE23744), width: 1)
                              : Border.all(color: Colors.transparent),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                variant.quantity,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? const Color(0xFFE23744) : Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (variant.discountPercent > 0) ...[
                                  Text(
                                    '₹${variant.price.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[400],
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Text(
                                  '₹${(variant.discountPercent > 0 ? vDiscountedPrice : variant.price).toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? const Color(0xFFE23744) : Colors.black87,
                                  ),
                                ),
                                if (variant.discountPercent > 0) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFEBEB),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '${variant.discountPercent.toStringAsFixed(0)}% OFF',
                                      style: const TextStyle(
                                        color: Color(0xFFE23744),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                                if (isSelected) ...[
                                  const SizedBox(width: 12),
                                  const Icon(
                                    Icons.check_circle,
                                    color: Color(0xFFE23744),
                                    size: 20,
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ProductVideoPlayer extends StatefulWidget {
  final String url;
  const ProductVideoPlayer({Key? key, required this.url}) : super(key: key);

  @override
  State<ProductVideoPlayer> createState() => _ProductVideoPlayerState();
}

class _ProductVideoPlayerState extends State<ProductVideoPlayer> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.url));
      await _videoPlayerController.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: false,
        looping: false,
        showControls: true,
        placeholder: const Center(
          child: CircularProgressIndicator(color: Color(0xFFE23744)),
        ),
      );
      setState(() {});
    } catch (e) {
      setState(() {
        _isError = true;
      });
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isError) {
      return const Center(
        child: Icon(Icons.error_outline, size: 40, color: Colors.grey),
      );
    }
    return _chewieController != null && _chewieController!.videoPlayerController.value.isInitialized
        ? Chewie(controller: _chewieController!)
        : const Center(
            child: CircularProgressIndicator(color: Color(0xFFE23744)),
          );
  }
}





