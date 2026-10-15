import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../providers/user_provider.dart';
import 'orderconfirmation_screen.dart';
import '../models/cart_item.dart';
import '../models/user_model.dart';

// Custom Dashed Divider to match the Zomato ticket layout
class DashedDivider extends StatelessWidget {
  final double height;
  final Color color;
  final double dashWidth;
  final double dashSpace;

  const DashedDivider({
    super.key,
    this.height = 1.2,
    this.color = const Color(0xFFFFC0C0),
    this.dashWidth = 6,
    this.dashSpace = 4,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: height,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
        );
      },
    );
  }
}

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isBillExpanded = true;
  String _paymentMethod = 'COD';
  List<Map<String, double>> _deliveryRules = [];

  static const double _fallbackCharge = 40.0;
  static const double _fallbackFreeThreshold = 500.0;

  @override
  void initState() {
    super.initState();
    _loadDeliveryRules();
  }

  Future<void> _loadDeliveryRules() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('delivery_rules')
          .get();
      final List<Map<String, double>> parsed = [];
      for (final doc in snap.docs) {
        final data = doc.data();
        final charge = (data['charge'] is num)
            ? (data['charge'] as num).toDouble()
            : null;
        final min = (data['min'] is num)
            ? (data['min'] as num).toDouble()
            : null;
        final max = (data['max'] is num)
            ? (data['max'] as num).toDouble()
            : null;
        if (charge != null && min != null && max != null) {
          parsed.add({'min': min, 'max': max, 'charge': charge});
        }
      }

      parsed.sort((a, b) => a['min']!.compareTo(b['min']!));

      setState(() {
        _deliveryRules = parsed;
      });
    } catch (e) {
      setState(() {
        _deliveryRules = [];
      });
    }
  }

  double _computeDeliveryCharge(double orderAmount) {
    if (_deliveryRules.isEmpty) {
      return orderAmount < _fallbackFreeThreshold ? _fallbackCharge : 0.0;
    }

    for (final rule in _deliveryRules) {
      final min = rule['min']!;
      final max = rule['max']!;
      final charge = rule['charge']!;
      if (orderAmount >= min && orderAmount <= max) return charge;
    }

    final highestMax = _deliveryRules
        .map((r) => r['max']!)
        .reduce((a, b) => max(a, b));
    if (orderAmount > highestMax) return 0.0;

    return _deliveryRules.first['charge']!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFBF9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leadingWidth: Navigator.canPop(context) ? 56 : 16,
        leading: Navigator.canPop(context)
            ? Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 8, bottom: 8),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF2F2),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFFE23744), size: 20),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                  ),
                ),
              )
            : const SizedBox.shrink(),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'My Cart',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Review your items and place your order',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.shopping_cart_outlined,
                      color: Colors.black87,
                      size: 28,
                    ),
                    if (cart.itemCount > 0)
                      Positioned(
                        right: 0,
                        top: 10,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Color(0xFFE23744),
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
              );
            },
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFF2F2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shopping_cart_outlined,
                      size: 64,
                      color: Color(0xFFE23744),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Your cart is empty',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add items to your cart to order them!',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          final double deliveryCharge = _computeDeliveryCharge(cart.totalAmount);
          final double toPay = cart.totalAmount + deliveryCharge;
          final double originalToPay = cart.originalTotalAmount + deliveryCharge;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    ...cart.items.map((item) => _buildCartItem(context, item, cart)),
                    const SizedBox(height: 8),
                    _buildBillSummaryCard(context, cart, deliveryCharge, toPay, originalToPay),
                    const SizedBox(height: 16),
                    if (cart.totalSavings > 0) ...[
                      _buildSavingsBanner(cart),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
              _buildBottomCheckoutBar(context, cart, deliveryCharge, toPay),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItem(
    BuildContext context,
    CartItem item,
    CartProvider cart,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFECEC), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE23744).withOpacity(0.01),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Product Image
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[50],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: item.image.startsWith('http')
                  ? CachedNetworkImage(
                      imageUrl: item.image,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator(color: Color(0xFFE23744), strokeWidth: 2)),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.image_not_supported, color: Colors.grey),
                    )
                  : Image.asset(
                      item.image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.image_not_supported, color: Colors.grey),
                    ),
            ),
          ),

          const SizedBox(width: 12),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title & Remove Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => cart.removeItem(item.productId, item.quantity),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFF2F2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Color(0xFFE23744),
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 2),

                // Subtitle (Weight/Qty)
                Text(
                  item.quantity,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 10),

                // Controls & Price Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Quantity Controls
                    Row(
                      children: [
                        // Minus button
                        GestureDetector(
                          onTap: () => cart.updateQuantity(
                            item.productId,
                            item.quantity,
                            item.count - 1,
                          ),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFF2F2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.remove,
                              color: Color(0xFFE23744),
                              size: 14,
                            ),
                          ),
                        ),

                        // Count
                        SizedBox(
                          width: 28,
                          child: Center(
                            child: Text(
                              '${item.count}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),

                        // Plus button
                        GestureDetector(
                          onTap: () => cart.updateQuantity(
                            item.productId,
                            item.quantity,
                            item.count + 1,
                          ),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE8F5E9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Color(0xFF4CAF50),
                              size: 14,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Prices
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (item.discountPercent > 0)
                          Text(
                            '₹${item.originalTotalPrice.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[400],
                              decoration: TextDecoration.lineThrough,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        Text(
                          '₹${item.totalPrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE23744),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillSummaryCard(
    BuildContext context,
    CartProvider cart,
    double deliveryCharge,
    double toPay,
    double originalToPay,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFECEC), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(
                      Icons.receipt_long_outlined,
                      color: Color(0xFFE23744),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Bill Summary',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => setState(() => _isBillExpanded = !_isBillExpanded),
                  child: Icon(
                    _isBillExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                const Divider(height: 1, color: Color(0xFFFFECEC)),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildBillRow(
                        'Order Total (Excl. Taxes)',
                        '₹${cart.originalTotalAmount.toStringAsFixed(0)}',
                        '₹${cart.totalAmount.toStringAsFixed(0)}',
                        showOriginal: cart.totalSavings > 0,
                      ),
                      const SizedBox(height: 12),
                      _buildBillRow('Taxes & Charges', '', '₹0.00'),
                      const SizedBox(height: 12),
                      _buildBillRow(
                        'Delivery Charges',
                        '',
                        deliveryCharge > 0
                            ? '₹${deliveryCharge.toStringAsFixed(0)}'
                            : 'Free',
                        isGreen: deliveryCharge == 0,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: DashedDivider(),
                      ),
                      _buildBillRow(
                        'To Pay (Incl. Taxes)',
                        '₹${originalToPay.toStringAsFixed(0)}',
                        '₹${toPay.toStringAsFixed(0)}',
                        showOriginal: cart.totalSavings > 0,
                        isBold: true,
                        isRed: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            crossFadeState: _isBillExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  Widget _buildBillRow(
    String label,
    String originalPrice,
    String finalPrice, {
    bool showOriginal = false,
    bool isGreen = false,
    bool isBold = false,
    bool isRed = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: isBold ? Colors.black87 : Colors.grey[700],
          ),
        ),
        Row(
          children: [
            if (showOriginal && originalPrice.isNotEmpty) ...[
              Text(
                originalPrice,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[400],
                  decoration: TextDecoration.lineThrough,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              finalPrice,
              style: TextStyle(
                fontSize: isBold ? 16 : 14,
                fontWeight: FontWeight.bold,
                color: isRed
                    ? const Color(0xFFE23744)
                    : isGreen
                        ? const Color(0xFF2E7D32)
                        : Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSavingsBanner(CartProvider cart) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC8E6C9), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Color(0xFFC8E6C9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_offer,
              color: Color(0xFF2E7D32),
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'You saved on this order!',
              style: TextStyle(
                color: Color(0xFF2E7D32),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            '₹${cart.totalSavings.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Color(0xFF2E7D32),
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCheckoutBar(
    BuildContext context,
    CartProvider cart,
    double deliveryCharge,
    double toPay,
  ) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: 12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Shopping bag icon inside container
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF2F2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  color: Color(0xFFE23744),
                  size: 24,
                ),
              ),
              if (cart.itemCount > 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE23744),
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
          const SizedBox(width: 12),

          // Total label and amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '₹${toPay.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Checkout Button
          ElevatedButton(
            onPressed: () => _showConfirmOrderSheet(context, cart, deliveryCharge, toPay),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE23744),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Checkout',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmOrderSheet(
    BuildContext context,
    CartProvider cart,
    double deliveryCharge,
    double toPay,
  ) {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    int? selectedAddressIndex;

    int getActiveAddressIndex(UserModel? u) {
      if (u == null || u.addresses.isEmpty) return 0;
      for (int i = 0; i < u.addresses.length; i++) {
        if (u.addresses[i].isActive) return i;
      }
      return 0;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.6,
              minChildSize: 0.3,
              maxChildSize: 0.95,
              builder: (_, controller) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      children: [
                        // Drag Indicator
                        Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const Text(
                          'Confirm your order',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Scrollable order details
                        Expanded(
                          child: ListView(
                            controller: controller,
                            children: [
                              // Items Summary Block
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade100),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Items',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ...cart.items.map(
                                      (it) => Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 6),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(8),
                                                color: Colors.white,
                                              ),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: it.image.startsWith('http')
                                                    ? CachedNetworkImage(
                                                        imageUrl: it.image,
                                                        fit: BoxFit.cover,
                                                        placeholder: (_, __) => const Center(
                                                          child: SizedBox(
                                                            width: 14,
                                                            height: 14,
                                                            child: CircularProgressIndicator(strokeWidth: 2),
                                                          ),
                                                        ),
                                                        errorWidget: (_, __, ___) =>
                                                            const Icon(Icons.image_not_supported, size: 18, color: Colors.grey),
                                                      )
                                                    : Image.asset(
                                                        it.image,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (_, __, ___) =>
                                                            const Icon(Icons.image_not_supported, size: 18, color: Colors.grey),
                                                      ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    it.name,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 13,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                  Text(
                                                    it.quantity,
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'x${it.count}  ₹${it.totalPrice.toStringAsFixed(0)}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const Divider(),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Subtotal',
                                          style: TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                        Text(
                                          '₹${cart.totalAmount.toStringAsFixed(0)}',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Payment Selection Block
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade100),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Payment',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    GestureDetector(
                                      onTap: () {
                                        setModalState(() {
                                          _paymentMethod = 'COD';
                                        });
                                      },
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: _paymentMethod == 'COD'
                                              ? const Color(0xFFE23744).withOpacity(0.08)
                                              : Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: _paymentMethod == 'COD'
                                                ? const Color(0xFFE23744).withOpacity(0.4)
                                                : Colors.grey.shade200,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: _paymentMethod == 'COD'
                                                    ? const Color(0xFFE23744).withOpacity(0.15)
                                                    : Colors.grey[100],
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.payments,
                                                color: _paymentMethod == 'COD'
                                                    ? const Color(0xFFE23744)
                                                    : Colors.grey[600],
                                                size: 18,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Cash on Delivery',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 14,
                                                      color: _paymentMethod == 'COD'
                                                          ? const Color(0xFFE23744)
                                                          : Colors.black87,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Pay with cash when the order is delivered',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.grey[500],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Icon(
                                              _paymentMethod == 'COD'
                                                  ? Icons.check_circle
                                                  : Icons.circle_outlined,
                                              color: _paymentMethod == 'COD'
                                                  ? const Color(0xFFE23744)
                                                  : Colors.grey,
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Online payments are currently disabled. Cash on Delivery is available.',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Delivery Address Block
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade100),
                                ),
                                child: Consumer<UserProvider>(
                                  builder: (context, userProvider, child) {
                                    final u = userProvider.user;
                                    final hasAddresses = u != null && u.addresses.isNotEmpty;
                                    final indexToShow = selectedAddressIndex ?? getActiveAddressIndex(u);
                                    AddressModel? selectedAddress;
                                    if (hasAddresses && indexToShow >= 0 && indexToShow < u.addresses.length) {
                                      selectedAddress = u.addresses[indexToShow];
                                    }

                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Delivery Address',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            if (hasAddresses)
                                              GestureDetector(
                                                onTap: () {
                                                  _showAddressSelectorBottomSheet(
                                                    context,
                                                    userProvider,
                                                    indexToShow,
                                                    (newIndex) {
                                                      setModalState(() {
                                                        selectedAddressIndex = newIndex;
                                                      });
                                                    },
                                                  );
                                                },
                                                child: const Text(
                                                  'CHANGE',
                                                  style: TextStyle(
                                                    color: Color(0xFFE23744),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              )
                                            else
                                              GestureDetector(
                                                onTap: () {
                                                  _showAddAddressDialog(
                                                    context,
                                                    userProvider,
                                                    () {
                                                      setModalState(() {
                                                        selectedAddressIndex = 0;
                                                      });
                                                    },
                                                  );
                                                },
                                                child: const Text(
                                                  'ADD',
                                                  style: TextStyle(
                                                    color: Color(0xFFE23744),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        if (selectedAddress != null)
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Icon(
                                                Icons.location_on,
                                                color: Color(0xFFE23744),
                                                size: 18,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  '${selectedAddress.house}, ${selectedAddress.area}, ${selectedAddress.city}, ${selectedAddress.state} - ${selectedAddress.pincode}',
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    height: 1.4,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        else
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'No saved addresses found.',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              SizedBox(
                                                width: double.infinity,
                                                child: OutlinedButton.icon(
                                                  onPressed: () {
                                                    _showAddAddressDialog(
                                                      context,
                                                      userProvider,
                                                      () {
                                                        setModalState(() {
                                                          selectedAddressIndex = 0;
                                                        });
                                                      },
                                                    );
                                                  },
                                                  style: OutlinedButton.styleFrom(
                                                    side: const BorderSide(color: Color(0xFFE23744)),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                  ),
                                                  icon: const Icon(
                                                    Icons.add,
                                                    color: Color(0xFFE23744),
                                                    size: 16,
                                                  ),
                                                  label: const Text(
                                                    'Add Delivery Address',
                                                    style: TextStyle(
                                                      color: Color(0xFFE23744),
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),

                        // Action Buttons Bar
                        Padding(
                          padding: EdgeInsets.only(
                            top: 8.0,
                            bottom: 12.0 + MediaQuery.of(context).padding.bottom,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    side: BorderSide(color: Colors.grey.shade300),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                  ),
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    final userProvider = Provider.of<UserProvider>(context, listen: false);
                                    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
                                    final cartProvider = Provider.of<CartProvider>(context, listen: false);

                                    final currentUser = userProvider.getCurrentUser();
                                    if (currentUser == null) {
                                      messenger.showSnackBar(
                                        const SnackBar(
                                          content: Text('Please sign in to place an order'),
                                          backgroundColor: Color(0xFFE23744),
                                        ),
                                      );
                                      return;
                                    }

                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (_) => const Center(
                                        child: CircularProgressIndicator(color: Color(0xFFE23744)),
                                      ),
                                    );

                                    try {
                                      await userProvider.initialize();
                                      final userData = userProvider.user;
                                      Map<String, dynamic>? deliveryAddress;

                                      if (userData != null && userData.addresses.isNotEmpty) {
                                        final index = selectedAddressIndex ?? getActiveAddressIndex(userData);
                                        if (index >= 0 && index < userData.addresses.length) {
                                          deliveryAddress = userData.addresses[index].toMap();
                                        } else {
                                          deliveryAddress = userData.addresses.first.toMap();
                                        }
                                      } else {
                                        try {
                                          final doc = await FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(currentUser.uid)
                                              .get();
                                          if (doc.exists) {
                                            final data = doc.data();
                                            final addrs = (data?['addresses'] as List<dynamic>?) ?? [];
                                            if (addrs.isNotEmpty) {
                                              deliveryAddress = Map<String, dynamic>.from(addrs.first as Map);
                                            }
                                          }
                                        } catch (_) {}
                                      }

                                      if (deliveryAddress == null) {
                                        navigator.pop(); // Pop loader dialog
                                        messenger.showSnackBar(
                                          const SnackBar(
                                            content: Text('Please add a delivery address first'),
                                            backgroundColor: Color(0xFFE23744),
                                          ),
                                        );
                                        return;
                                      }

                                      await orderProvider.placeOrder(
                                        userId: currentUser.uid,
                                        items: cartProvider.items,
                                        totalAmount: cartProvider.totalAmount + deliveryCharge,
                                        originalAmount: cartProvider.originalTotalAmount + deliveryCharge,
                                        deliveryAddress: deliveryAddress,
                                      );

                                      cartProvider.clearCart();
                                      navigator.pop(); // Pop loader dialog
                                      navigator.pop(); // Pop sheet modal

                                      navigator.pushReplacement(
                                        PageRouteBuilder(
                                          transitionDuration: const Duration(milliseconds: 700),
                                          reverseTransitionDuration: const Duration(milliseconds: 400),
                                          pageBuilder: (context, a1, a2) => const OrderConfirmationScreen(),
                                          transitionsBuilder: (context, anim, secAnim, child) {
                                            final scale = Tween<double>(begin: 0.8, end: 1.0).animate(
                                              CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
                                            );
                                            final fade = Tween<double>(begin: 0.0, end: 1.0).animate(
                                              CurvedAnimation(parent: anim, curve: Curves.easeIn),
                                            );
                                            return FadeTransition(
                                              opacity: fade,
                                              child: ScaleTransition(scale: scale, child: child),
                                            );
                                          },
                                        ),
                                      );
                                    } catch (e) {
                                      navigator.pop(); // Pop loader dialog
                                      messenger.showSnackBar(
                                        SnackBar(
                                          content: Text('Failed to place order: $e'),
                                          backgroundColor: const Color(0xFFE23744),
                                        ),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFE23744),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'Confirm',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showAddressSelectorBottomSheet(
    BuildContext context,
    UserProvider userProvider,
    int? selectedIndex,
    Function(int) onSelected,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx2, setStateSheet) {
            final u = userProvider.user;
            final addresses = u?.addresses ?? [];

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Select Delivery Address',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showAddAddressDialog(context, userProvider, () {
                            onSelected(0);
                          });
                        },
                        icon: const Icon(Icons.add, size: 16, color: Color(0xFFE23744)),
                        label: const Text(
                          'Add New',
                          style: TextStyle(
                            color: Color(0xFFE23744),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  if (addresses.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'No saved addresses',
                          style: TextStyle(color: Colors.grey[500], fontSize: 14),
                        ),
                      ),
                    )
                  else
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: addresses.length,
                        itemBuilder: (context, index) {
                          final addr = addresses[index];
                          final isSelected = selectedIndex == index;

                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFFFF0F0)
                                  : Colors.grey[50],
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFFE23744)
                                    : Colors.grey.shade200,
                                width: isSelected ? 1.5 : 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              onTap: () {
                                onSelected(index);
                                Navigator.pop(ctx);
                              },
                              leading: Icon(
                                Icons.location_on,
                                color: isSelected ? const Color(0xFFE23744) : Colors.grey,
                              ),
                              title: Text(
                                addr.house,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Text(
                                '${addr.area}, ${addr.city}, ${addr.state} - ${addr.pincode}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              trailing: Icon(
                                isSelected
                                    ? Icons.check_circle
                                    : Icons.circle_outlined,
                                color: isSelected
                                    ? const Color(0xFFE23744)
                                    : Colors.grey,
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
      },
    );
  }

  void _showAddAddressDialog(
    BuildContext context,
    UserProvider userProvider,
    VoidCallback onAddressAdded,
  ) {
    final formKey = GlobalKey<FormState>();
    final houseController = TextEditingController();
    final areaController = TextEditingController();
    final cityController = TextEditingController();
    final stateController = TextEditingController();
    final pincodeController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.add_location_alt, color: Color(0xFFE23744)),
            SizedBox(width: 8),
            Text(
              'Add New Address',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: houseController,
                  decoration: InputDecoration(
                    labelText: 'House/Building/Apartment *',
                    hintText: 'e.g., 123 Main Street',
                    prefixIcon: const Icon(Icons.home, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE23744)),
                    ),
                  ),
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? 'Required' : null,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: areaController,
                  decoration: InputDecoration(
                    labelText: 'Area/Locality *',
                    hintText: 'e.g., Sector 15',
                    prefixIcon: const Icon(Icons.location_city, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE23744)),
                    ),
                  ),
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? 'Required' : null,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: cityController,
                  decoration: InputDecoration(
                    labelText: 'City *',
                    hintText: 'e.g., Gorakhpur',
                    prefixIcon: const Icon(Icons.location_city, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE23744)),
                    ),
                  ),
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? 'Required' : null,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: stateController,
                  decoration: InputDecoration(
                    labelText: 'State *',
                    hintText: 'e.g., Uttar Pradesh',
                    prefixIcon: const Icon(Icons.map, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE23744)),
                    ),
                  ),
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? 'Required' : null,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: pincodeController,
                  decoration: InputDecoration(
                    labelText: 'Pincode *',
                    hintText: 'e.g., 273001',
                    prefixIcon: const Icon(Icons.pin_drop, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE23744)),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Required';
                    if (!RegExp(r'^\d{6}$').hasMatch(value.trim())) {
                      return 'Enter a valid 6-digit pincode';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final newAddress = AddressModel(
                  house: houseController.text.trim(),
                  area: areaController.text.trim(),
                  city: cityController.text.trim(),
                  state: stateController.text.trim(),
                  pincode: pincodeController.text.trim(),
                  isActive: true,
                );

                try {
                  await userProvider.addAddress(newAddress);
                  onAddressAdded();
                  if (context.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Address added successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to add address: $e'),
                        backgroundColor: const Color(0xFFE23744),
                      ),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE23744),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Add Address'),
          ),
        ],
      ),
    );
  }
}






