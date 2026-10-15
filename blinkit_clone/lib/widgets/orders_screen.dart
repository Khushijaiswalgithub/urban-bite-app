// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../providers/order_provider.dart';
// import '../providers/user_provider.dart';
// import '../models/order_model.dart';

// class OrdersScreen extends StatelessWidget {
//   const OrdersScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final userProvider = Provider.of<UserProvider>(context);
//     final user = userProvider.getCurrentUser();

//     // Provide a Scaffold so Chips and other Material widgets have an ancestor
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('My Orders'),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 0,
//         centerTitle: true,
//       ),
//       body: Builder(
//         builder: (ctx) {
//           if (user == null) {
//             return const Center(child: Text('Please sign in to view orders'));
//           }

//           final orderProvider = Provider.of<OrderProvider>(
//             context,
//             listen: false,
//           );

//           return StreamBuilder<List<OrderModel>>(
//             stream: orderProvider.streamOrdersForUser(user.uid),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               }

//               if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                 return const Center(child: Text('No orders found'));
//               }

//               final orders = snapshot.data!;
//               return ListView.separated(
//                 padding: const EdgeInsets.all(16),
//                 itemCount: orders.length,
//                 separatorBuilder: (_, __) => const SizedBox(height: 12),
//                 itemBuilder: (context, index) {
//                   final o = orders[index];
//                   return _OrderCard(order: o);
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

// class _OrderCard extends StatelessWidget {
//   final OrderModel order;

//   const _OrderCard({required this.order});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.08),
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: Text(
//                   'Order • ${order.id}',
//                   style: const TextStyle(fontWeight: FontWeight.w600),
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//               Text(
//                 order.status.toUpperCase(),
//                 style: TextStyle(
//                   color: order.status == 'placed'
//                       ? Colors.orange
//                       : Colors.green,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Text(
//             '${order.items.length} items • ₹${order.totalAmount.toStringAsFixed(0)}',
//             style: const TextStyle(color: Colors.black54),
//           ),
//           const SizedBox(height: 8),
//           Wrap(
//             spacing: 8,
//             runSpacing: 8,
//             children: order.items
//                 .take(4)
//                 .map((i) => _ItemChip(i.name, i.count))
//                 .toList(),
//           ),
//           const SizedBox(height: 12),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 '${order.createdAt}',
//                 style: const TextStyle(color: Colors.black54, fontSize: 12),
//               ),
//               Text(
//                 '₹${order.savings.toStringAsFixed(0)} saved',
//                 style: const TextStyle(
//                   color: Colors.green,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _ItemChip extends StatelessWidget {
//   final String name;
//   final int count;
//   const _ItemChip(this.name, this.count);

//   @override
//   Widget build(BuildContext context) {
//     return Chip(
//       backgroundColor: Colors.grey[100],
//       label: Text('$name x$count', overflow: TextOverflow.ellipsis),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../providers/user_provider.dart';
import '../models/order_model.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

// Top-level helper to launch phone dialer
Future<void> _dialNumber(BuildContext context, String phone) async {
  if (phone.isEmpty) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Phone number not available')));
    return;
  }

  final uri = Uri(scheme: 'tel', path: phone);
  try {
    if (!await launchUrl(uri)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not launch dialer')));
    }
  } catch (e) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Failed to open dialer')));
  }
}

class _OrdersScreenState extends State<OrdersScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.getCurrentUser();

    final canPop = Navigator.canPop(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFCFBF9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: canPop ? 0 : 16,
        leadingWidth: canPop ? 72 : 0,
        leading: canPop
            ? Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFF0F0),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFFE23744),
                        size: 20,
                      ),
                    ),
                  ),
                ),
              )
            : null,
        toolbarHeight: 80,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                const Text(
                  'My Orders',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => _showSearchDialog(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFF0F0),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.search,
                      color: Colors.black87,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Track, manage and reorder your favourite food',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
            ),
            alignment: Alignment.centerLeft,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: const Color(0xFFE23744),
              labelColor: const Color(0xFFE23744),
              unselectedLabelColor: Colors.grey.shade500,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.label,
              tabs: const [
                Tab(text: 'All Orders'),
                Tab(text: 'Placed'),
                Tab(text: 'Out for Delivery'),
                Tab(text: 'Delivered'),
                Tab(text: 'Cancelled'),
              ],
              onTap: (index) {
                setState(() {
                  _selectedFilter = [
                    'all',
                    'placed',
                    'out_for_delivery',
                    'delivered',
                    'cancelled',
                  ][index];
                });
              },
            ),
          ),
        ),
      ),
      body: user == null ? _buildSignInPrompt() : _buildOrdersList(user.uid),
    );
  }

  Widget _buildSignInPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Sign in to view your orders',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Navigate to sign in
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE23744),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(String userId) {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    return StreamBuilder<List<OrderModel>>(
      stream: orderProvider.streamOrdersForUser(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState();
        }

        final allOrders = snapshot.data!;
        final filteredOrders = _filterOrders(allOrders);

        if (filteredOrders.isEmpty) {
          return _buildEmptyFilterState();
        }

        return RefreshIndicator(
          onRefresh: () async {
            // Force refresh by rebuilding stream
            setState(() {});
          },
          child: Column(
            children: [
              _buildOrdersSummary(allOrders),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredOrders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    return _OrderCard(
                      order: filteredOrders[index],
                      onTap: () =>
                          _showOrderDetails(context, filteredOrders[index]),
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

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFFE23744)),
          SizedBox(height: 16),
          Text('Loading your orders...', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No orders yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'When you place orders, they\'ll appear here',
            style: TextStyle(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE23744),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Start Shopping'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyFilterState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.filter_list_off, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No ${_selectedFilter == 'all' ? '' : _selectedFilter} orders',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersSummary(List<OrderModel> orders) {
    final totalOrders = orders.length;
    final totalSavings = orders.fold<double>(
      0,
      (sum, order) => sum + order.savings,
    );
    final totalSpent = orders.fold<double>(
      0,
      (sum, order) => sum + order.totalAmount,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFD4A35), Color(0xFFFF8E2D)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFD4A35).withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryItem(
              title: 'Total Orders',
              value: totalOrders.toString(),
              icon: Icons.shopping_bag_outlined,
            ),
          ),
          Container(width: 1, height: 32, color: Colors.white.withOpacity(0.3)),
          Expanded(
            child: _SummaryItem(
              title: 'Total Spent',
              value: '₹${totalSpent.toStringAsFixed(0)}',
              icon: Icons.account_balance_wallet_outlined,
            ),
          ),
          Container(width: 1, height: 32, color: Colors.white.withOpacity(0.3)),
          Expanded(
            child: _SummaryItem(
              title: 'Total Saved',
              value: '₹${totalSavings.toStringAsFixed(0)}',
              icon: Icons.savings_outlined,
            ),
          ),
        ],
      ),
    );
  }

  List<OrderModel> _filterOrders(List<OrderModel> orders) {
    if (_selectedFilter == 'all') return orders;
    final sel = _selectedFilter.toLowerCase();
    return orders.where((order) {
      final s = _normalizeStatus(order.status);
      // Accept either underscored or spaced variants
      return s == sel || s.replaceAll(' ', '_') == sel;
    }).toList();
  }

  String _normalizeStatus(String? status) {
    if (status == null) return '';
    return status.toLowerCase().replaceAll(RegExp(r'[_\-]+'), ' ').trim();
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Orders'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Enter order ID or item name',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            // Implement search functionality
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _showOrderDetails(BuildContext context, OrderModel order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _OrderDetailsSheet(order: order),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _SummaryItem({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.white,
          child: Icon(
            icon,
            color: const Color(0xFFFD4A35),
            size: 20,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;

  const _OrderCard({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade100,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderHeader(),
            const SizedBox(height: 12),
            _buildOrderInfo(),
            const SizedBox(height: 12),
            _buildItemsList(),
            if (order.deliveryBoy != null) ...[
              const SizedBox(height: 12),
              _buildDeliveryBoyPreview(context),
            ],
            _buildOtpSection(),
            const SizedBox(height: 14),
            _buildOrderFooter(context),
          ],
        ),
      ),
    );
  }

  Color _getStatusBgColor() {
    switch (_normalizeStatus(order.status)) {
      case 'placed':
        return const Color(0xFFFFF4EC);
      case 'out for delivery':
      case 'out_for_delivery':
        return const Color(0xFFE6F4F1);
      case 'delivered':
        return const Color(0xFFEBF9EB);
      case 'cancelled':
        return const Color(0xFFFFEBEE);
      case 'processing':
        return const Color(0xFFEBF3FF);
      case 'shipped':
        return const Color(0xFFF3EBF9);
      default:
        return Colors.grey.shade100;
    }
  }

  Widget _buildOrderHeader() {
    final statusColor = _getStatusColor();
    final statusBgColor = _getStatusBgColor();
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: statusBgColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_getStatusIcon(), size: 14, color: statusColor),
              const SizedBox(width: 4),
              Text(
                order.status.toUpperCase(),
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Order #${order.id.isNotEmpty && order.id.length >= 8 ? order.id.substring(0, 8) : order.id}...',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.chevron_right,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOtpSection() {
    if (order.otp == null || order.isOtpVerified) {
      return const SizedBox.shrink();
    }

    final otpStr = order.otp!;
    final spacedOtp = otpStr.split('').join(' ');

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD0E2FF)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lock_outline,
            size: 16,
            color: Color(0xFF1E60D5),
          ),
          const SizedBox(width: 8),
          const Text(
            'Delivery OTP',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF1E60D5),
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            spacedOtp,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E60D5),
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfo() {
    final savings = order.savings;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${order.items.length} item${order.items.length > 1 ? 's' : ''}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              '₹${order.totalAmount.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatDateWithTime(order.createdAt),
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
            if (savings > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF9EB),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Saved ₹${savings.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Color(0xFF0F8A5F),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  String _formatDateWithTime(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final day = date.day.toString().padLeft(2, '0');
    final month = months[date.month - 1];
    final year = date.year;

    final period = date.hour >= 12 ? 'PM' : 'AM';
    var hour = date.hour % 12;
    if (hour == 0) hour = 12;
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day $month $year • ${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  Widget _buildItemsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Items:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade100),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            children: List.generate(order.items.length, (index) {
              final item = order.items[index];
              return Padding(
                padding: EdgeInsets.only(
                  top: index == 0 ? 0 : 8.0,
                  bottom: index == order.items.length - 1 ? 0 : 8.0,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: item.image.isNotEmpty
                            ? Image.network(
                                item.image,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => const Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                              )
                            : const Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                                size: 20,
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${item.name} x${item.count}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '₹${item.totalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderFooter(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.access_time,
          size: 14,
          color: Colors.grey.shade500,
        ),
        const SizedBox(width: 4),
        Text(
          _getTimeAgo(order.createdAt),
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 12,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => _showTrackOrderSheet(context, order),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFF0F8A5F),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.gps_fixed,
                  size: 14,
                  color: Color(0xFF0F8A5F),
                ),
                SizedBox(width: 6),
                Text(
                  'Track Order',
                  style: TextStyle(
                    color: Color(0xFF0F8A5F),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showTrackOrderSheet(BuildContext context, OrderModel order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final steps = [
          'placed',
          'processing',
          'shipped',
          'out for delivery',
          'delivered',
          'cancelled',
        ];

        final current = _normalizeStatus(order.status);
        final isCancelled = current.contains('cancel');

        int currentIndex = steps.indexWhere(
          (s) => s == current || s.replaceAll(' ', '_') == current,
        );
        if (currentIndex == -1) {
          // If status not found (shouldn't happen), fall back to cancelled or first
          currentIndex = isCancelled ? steps.indexOf('cancelled') : 0;
        }

        final progress = (currentIndex + 1) / steps.length;
        final progressColor = isCancelled ? Colors.red : Colors.green;

        DateTime stampFor(int i) => order.createdAt.add(Duration(hours: i * 2));

        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (context, sc) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                controller: sc,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Text(
                      'Order Tracking',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Order #${order.id.substring(0, 8)}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      color: progressColor,
                      backgroundColor: progressColor.withOpacity(0.12),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      children: List.generate(steps.length, (i) {
                        final step = steps[i];
                        final done = i <= currentIndex && !isCancelled;
                        // Determine colors/icons per step
                        Color dotColor;
                        IconData dotIcon;
                        Color titleColor = Colors.black;

                        if (isCancelled) {
                          if (step == 'cancelled') {
                            dotColor = Colors.red;
                            dotIcon = Icons.cancel;
                            titleColor = Colors.red;
                          } else {
                            dotColor = Colors.grey[300]!;
                            dotIcon = Icons.radio_button_unchecked;
                            titleColor = Colors.black54;
                          }
                        } else {
                          dotColor = done ? Colors.green : Colors.grey[300]!;
                          dotIcon = done
                              ? Icons.check
                              : Icons.radio_button_unchecked;
                        }

                        return ListTile(
                          leading: CircleAvatar(
                            radius: 14,
                            backgroundColor: dotColor,
                            child: Icon(
                              dotIcon,
                              size: 16,
                              color: dotColor == Colors.grey[300]
                                  ? Colors.grey[600]
                                  : Colors.white,
                            ),
                          ),
                          title: Text(
                            step.replaceAll('_', ' ').toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: titleColor,
                            ),
                          ),
                          subtitle: Text(
                            (isCancelled && step == 'cancelled') ||
                                    (!isCancelled && done)
                                ? '${stampFor(i)}'
                                : 'Pending',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    _buildOtpSection(),
                    const SizedBox(height: 12),
                    if (order.deliveryBoy != null) ...[
                      const Divider(),
                      Text(
                        'Delivery Partner',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (order.deliveryBoy!['photo'] != null &&
                              order.deliveryBoy!['photo'].toString().isNotEmpty)
                            CircleAvatar(
                              radius: 20,
                              backgroundImage: NetworkImage(
                                order.deliveryBoy!['photo'],
                              ),
                            )
                          else
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.grey[200],
                              child: const Icon(Icons.person),
                            ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              order.deliveryBoy!['name'] ?? 'Delivery Partner',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => _dialNumber(
                              context,
                              order.deliveryBoy!['phone']?.toString() ?? '',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE23744),
                            ),
                            child: const Icon(Icons.call),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDeliveryBoyPreview(BuildContext context) {
    final db = order.deliveryBoy!;
    final name = db['name'] ?? 'Delivery Partner';
    final phone = db['phone'] ?? '';
    final photo = db['photo'] ?? '';

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFDFD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          if (photo != null && photo.isNotEmpty)
            CircleAvatar(radius: 20, backgroundImage: NetworkImage(photo))
          else
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey.shade100,
              child: Icon(Icons.person, color: Colors.grey.shade600, size: 20),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                ),
                const SizedBox(height: 2),
                Text(
                  'Delivery Partner',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _dialNumber(context, phone?.toString() ?? ''),
            icon: const Icon(Icons.phone_in_talk, color: Color(0xFFE23744), size: 20),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFFFF0F0),
              padding: const EdgeInsets.all(8),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (_normalizeStatus(order.status)) {
      case 'placed':
        return Colors.orange;
      case 'out for delivery':
      case 'out_for_delivery':
        return Colors.teal;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    switch (_normalizeStatus(order.status)) {
      case 'placed':
        return Icons.shopping_cart;
      case 'out for delivery':
      case 'out_for_delivery':
        return Icons.delivery_dining;
      case 'delivered':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      case 'processing':
        return Icons.hourglass_empty;
      case 'shipped':
        return Icons.local_shipping;
      default:
        return Icons.info;
    }
  }

  String _normalizeStatus(String? status) {
    if (status == null) return '';
    // Normalize to lower-case and replace multiple separators with single space
    return status.toLowerCase().replaceAll(RegExp(r'[_\-]+'), ' ').trim();
  }

  String _formatDate(DateTime date) {
    final months = [
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
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return _formatDate(date);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}

class _OrderDetailsSheet extends StatelessWidget {
  final OrderModel order;

  const _OrderDetailsSheet({required this.order});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Text(
                      'Order Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailSection('Order Information', [
                        _DetailRow('Order ID', order.id),
                        _DetailRow('Status', order.status.toUpperCase()),
                        _DetailRow('Order Date', _formatDate(order.createdAt)),
                        _DetailRow(
                          'Total Amount',
                          '₹${order.totalAmount.toStringAsFixed(0)}',
                        ),
                        _DetailRow(
                          'Original Amount',
                          '₹${order.originalAmount.toStringAsFixed(0)}',
                        ),
                        _DetailRow(
                          'Savings',
                          '₹${order.savings.toStringAsFixed(0)}',
                        ),
                      ]),
                      const SizedBox(height: 24),
                      _buildItemsSection(),
                      buildOtpSection(),
                      if (order.deliveryBoy != null) ...[
                        const SizedBox(height: 24),
                        _buildDeliveryBoySection(context),
                      ],
                      if (order.deliveryAddress != null) ...[
                        const SizedBox(height: 24),
                        _buildAddressSection(context),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildOtpSection() {
    if (order.otp == null || order.isOtpVerified) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lock_outline, size: 16, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Text(
                'Delivery OTP',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            order.otp!,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Share with delivery partner for order verification',
            style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryBoySection(BuildContext context) {
    final db = order.deliveryBoy!;
    final name = db['name'] ?? 'Delivery Person';
    final phone = db['phone'] ?? 'N/A';
    final photo = db['photo'] ?? '';

    return _buildDetailSection('Delivery Person', [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            if (photo != null && photo.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  photo,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[200],
                    child: const Icon(Icons.person),
                  ),
                ),
              )
            else
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.person),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    phone.toString(),
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () =>
                  _dialNumber(context, phone?.toString() ?? ''), // call action
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE23744),
                foregroundColor: Colors.white,
              ),
              child: const Icon(Icons.call),
            ),
          ],
        ),
      ),
    ]);
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildItemsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Items (${order.items.length})',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...order.items.map((item) => _buildItemCard(item)),
      ],
    );
  }

  Widget _buildItemCard(dynamic item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          if (item.image != null && item.image.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.image,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
            )
          else
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.image_not_supported),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Quantity: ${item.quantity} | Count: ${item.count}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '₹${item.totalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (item.discountPercent > 0) ...[
                      const SizedBox(width: 8),
                      Text(
                        '${item.discountPercent.toInt()}% off',
                        style: TextStyle(
                          color: Colors.green[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection(BuildContext context) {
    final address = order.deliveryAddress!;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userModel = userProvider.user;

    final displayName = userModel?.name ?? address['name'] ?? 'N/A';
    final displayPhone = userModel?.phoneNumber ?? address['phone'] ?? 'N/A';

    return _buildDetailSection('Delivery Address', [
      _DetailRow('Name', displayName),
      _DetailRow('Phone', displayPhone),
      _DetailRow(
        'Address',
        [
          address['house'],
          address['area'],
          address['city'],
          address['state'],
          address['pincode'],
        ].where((e) => e != null && e.toString().isNotEmpty).join(', '),
      ),
    ]);
  }

  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}





