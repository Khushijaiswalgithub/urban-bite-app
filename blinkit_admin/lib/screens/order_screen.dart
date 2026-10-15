import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/order_model.dart';
import '../models/delivery_boy_model.dart';
import '../models/user_model.dart';
import '../providers/order_provider.dart';
import '../providers/delivery_boy_provider.dart';
import '../providers/user_provider.dart';

class OrderDashboardScreen extends StatefulWidget {
  const OrderDashboardScreen({Key? key}) : super(key: key);

  @override
  State<OrderDashboardScreen> createState() => _OrderDashboardScreenState();
}

class _OrderDashboardScreenState extends State<OrderDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy • hh:mm a');

  String _selectedStatus = 'all';
  List<OrderModel> _filteredOrders = [];
  bool _isSearching = false;

  final List<String> _statusOptions = [
    'all',
    'placed',
    'out_for_delivery',
    'delivered',
    'cancelled',
  ];

  final Map<String, String> _statusLabels = {
    'all': 'All Orders',
    'placed': 'Placed',
    'out_for_delivery': 'Out for delivery',
    'delivered': 'Delivered',
    'cancelled': 'Cancelled',
  };

  final Map<String, Color> _statusColors = {
    'placed': Colors.blue,
    'out_for_delivery': Colors.orange,
    'delivered': Colors.green,
    'cancelled': Colors.red,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statusOptions.length, vsync: this);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (!mounted) return;
    if (_searchController.text.isEmpty) {
      setState(() => _isSearching = false);
    } else {
      setState(() => _isSearching = true);
      _performSearch();
    }
  }

  void _performSearch() async {
    if (!mounted) return;
    final provider = Provider.of<OrderProvider>(context, listen: false);
    final query = _searchController.text;
    final results = await provider.searchOrders(query);
    if (!mounted) return;
    setState(() => _filteredOrders = results);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          _buildTabBar(),
          Expanded(child: _buildOrdersList()),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Order Management',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      elevation: 0,
      // actions: [
      //   IconButton(
      //     icon: const Icon(Icons.analytics_outlined),
      //     onPressed: _showAnalytics,
      //   ),
      //   IconButton(
      //     icon: const Icon(Icons.more_vert),
      //     onPressed: _showMoreOptions,
      //   ),
      // ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search orders, products, or customer ID...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _isSearching = false);
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          // Quick Stats Row
          _buildQuickStats(),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Consumer<OrderProvider>(
      builder: (context, provider, child) {
        return StreamBuilder<List<OrderModel>>(
          stream: provider.streamOrders(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox.shrink();

            final orders = snapshot.data!;
            final todayOrders = orders
                .where(
                  (o) => DateTime.now().difference(o.createdAt).inDays == 0,
                )
                .length;
            final pendingOrders = orders
                .where(
                  (o) => o.status == 'placed' || o.status == 'out_for_delivery',
                )
                .length;
            final totalRevenue = orders
                .where((o) => o.status == 'delivered')
                .fold(0.0, (sum, o) => sum + o.totalAmount);

            return Row(
              children: [
                _buildStatCard(
                  'Today',
                  todayOrders.toString(),
                  Icons.today,
                  Colors.blue,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  'Pending',
                  pendingOrders.toString(),
                  Icons.pending,
                  Colors.orange,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  'Revenue',
                  '₹${totalRevenue.toStringAsFixed(0)}',
                  Icons.payments,
                  Colors.green,
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(fontWeight: FontWeight.bold, color: color),
                ),
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: color.withOpacity(0.8)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: Theme.of(context).primaryColor,
        labelColor: Theme.of(context).primaryColor,
        unselectedLabelColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedStatus = _statusOptions[index];
            _isSearching = false;
            _searchController.clear();
          });
        },
        tabs: _statusOptions
            .map((status) => Tab(text: _statusLabels[status]))
            .toList(),
      ),
    );
  }

  Widget _buildOrdersList() {
    if (_isSearching) {
      return _buildSearchResults();
    }

    return Consumer<OrderProvider>(
      builder: (context, provider, child) {
        return StreamBuilder<List<OrderModel>>(
          stream: provider.streamOrders(
            status: _selectedStatus == 'all' ? null : _selectedStatus,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading orders',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => setState(() {}),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final orders = snapshot.data ?? [];

            if (orders.isEmpty) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              onRefresh: () async => setState(() {}),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: orders.length,
                itemBuilder: (context, index) => _buildOrderCard(orders[index]),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSearchResults() {
    if (_filteredOrders.isEmpty && _searchController.text.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('No orders found', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredOrders.length,
      itemBuilder: (context, index) => _buildOrderCard(_filteredOrders[index]),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            _selectedStatus == 'all'
                ? 'No orders yet'
                : 'No ${_statusLabels[_selectedStatus]?.toLowerCase()} orders',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Orders will appear here once customers start placing them.',
            style: TextStyle(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showOrderDetails(order),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${order.id.substring(0, 8).toUpperCase()}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _dateFormatter.format(order.createdAt),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(order.status),
                ],
              ),
              const SizedBox(height: 12),

              // Customer Info
              Row(
                children: [
                  Icon(Icons.person_outline, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'User ID: ${order.userId.substring(0, 8)}...',
                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Items Preview
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${order.items.length} item${order.items.length == 1 ? '' : 's'}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    ...order.items
                        .take(2)
                        .map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${item.count}x ${item.name}',
                                    style: const TextStyle(fontSize: 13),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  '₹${item.totalPrice.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                    if (order.items.length > 2)
                      Text(
                        '+ ${order.items.length - 2} more items',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Total and Actions
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (order.savings != null && order.savings! > 0) ...[
                          Text(
                            '₹${order.originalAmount?.toStringAsFixed(2) ?? '0.00'}',
                            style: const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 2),
                        ],
                        Row(
                          children: [
                            Text(
                              '₹${order.totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.green,
                              ),
                            ),
                            if (order.savings != null && order.savings! > 0)
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green[100],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Saved ₹${order.savings!.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.green[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _showEditOrderDialog(order),
                        tooltip: 'Edit / Assign',
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () => _showOrderActions(order),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final color = _statusColors[status] ?? Colors.grey;
    final label = _statusLabels[status] ?? status;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _showOrderDetails(OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => OrderDetailsDialog(order: order),
    );
  }

  void _showEditOrderDialog(OrderModel order) {
    final BuildContext parentContext = context;
    showDialog(
      context: parentContext,
      builder: (dialogContext) => EditOrderDialog(
        order: order,
        onSave: (newStatus, deliveryBoy) async {
          if (!mounted) return;
          final provider = Provider.of<OrderProvider>(
            parentContext,
            listen: false,
          );
          // Update status if changed
          if (newStatus != null && newStatus != order.status) {
            await provider.updateOrderStatus(order.id, newStatus);
          }
          // Assign delivery boy if provided
          if (deliveryBoy != null) {
            await provider.assignDeliveryBoy(order.id, {
              'id': deliveryBoy.id,
              'name': deliveryBoy.name,
              'phone': deliveryBoy.phone,
            });
          }

          if (!mounted) return;
          // Do not pop the underlying screen here. The dialog will close itself
          // when Save is pressed. Instead refresh this screen to show updates.
          setState(() {});
          ScaffoldMessenger.of(
            parentContext,
          ).showSnackBar(const SnackBar(content: Text('Order updated')));
        },
      ),
    );
  }

  void _showOrderActions(OrderModel order) {
    final BuildContext parentContext = context;
    showModalBottomSheet(
      context: parentContext,
      builder: (sheetContext) => OrderActionsSheet(
        order: order,
        onDelete: () async {
          if (!mounted) return;
          final provider = Provider.of<OrderProvider>(
            parentContext,
            listen: false,
          );
          await provider.deleteOrder(order.id);
          // Close the bottom sheet
          Navigator.pop(parentContext);
          if (!mounted) return;
          ScaffoldMessenger.of(parentContext).showSnackBar(
            const SnackBar(content: Text('Order deleted successfully')),
          );
        },
      ),
    );
  }

  // analytics and more options are intentionally omitted (not used)
}

// Order Details Dialog
class OrderDetailsDialog extends StatelessWidget {
  final OrderModel order;

  const OrderDetailsDialog({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = MediaQuery.of(context).size.width;
          final dialogWidth = screenWidth; // 90% of screen width

          return Container(
            width: dialogWidth,
            constraints: const BoxConstraints(maxHeight: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order Details',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Order #${order.id.substring(0, 8).toUpperCase()}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),

                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Order Info
                        _buildInfoRow('Order ID', order.id),
                        _buildInfoRow('Customer ID', order.userId),
                        _buildInfoRow('Status', order.status),
                        _buildInfoRow(
                          'Created At',
                          DateFormat(
                            'MMM dd, yyyy • hh:mm a',
                          ).format(order.createdAt),
                        ),

                        const SizedBox(height: 16),
                        // Customer Details (from UserProvider)
                        const Text(
                          'Customer Details',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        StreamBuilder<UserModel?>(
                          stream: Provider.of<UserProvider>(
                            context,
                            listen: false,
                          ).userStream(order.userId),
                          builder: (context, snap) {
                            if (snap.connectionState ==
                                ConnectionState.waiting) {
                              return const SizedBox(
                                height: 72,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            final user = snap.data;
                            final displayName =
                                user?.name ??
                                'User ${order.userId.substring(0, 8)}';
                            final phone = user?.phoneNumber ?? '';
                            final email = user?.email ?? '';
                            AddressModel? primaryAddress;
                            if (user != null && user.addresses.isNotEmpty) {
                              primaryAddress = user.addresses.firstWhere(
                                (a) => a.isActive,
                                orElse: () => user.addresses.first,
                              );
                            } else {
                              primaryAddress = null;
                            }
                            final pa = primaryAddress;

                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Theme.of(
                                      context,
                                    ).primaryColor.withOpacity(0.12),
                                    foregroundColor: Theme.of(
                                      context,
                                    ).primaryColor,
                                    child: Text(
                                      displayName
                                          .splitMapJoin(
                                            RegExp(r"\b"),
                                            onMatch: (m) => m[0]!.toUpperCase(),
                                          )
                                          .substring(0, 1),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                displayName,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            //     if (phone.isNotEmpty)
                                            //       IconButton(
                                            //         tooltip: 'Copy phone',
                                            //         onPressed: () async {
                                            //           await Clipboard.setData(
                                            //             ClipboardData(text: phone),
                                            //           );
                                            //           if (!context.mounted) return;
                                            //           ScaffoldMessenger.of(
                                            //             context,
                                            //           ).showSnackBar(
                                            //             const SnackBar(
                                            //               content: Text(
                                            //                 'Phone copied',
                                            //               ),
                                            //             ),
                                            //           );
                                            //         },
                                            //         icon: const Icon(
                                            //           Icons.copy,
                                            //           size: 18,
                                            //           color: Colors.grey,
                                            //         ),
                                            //       ),
                                          ],
                                        ),
                                        if (phone.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 4.0,
                                            ),
                                            child: Text(
                                              phone,
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ),
                                        if (email.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 6.0,
                                            ),
                                            child: Text(
                                              email,
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ),
                                        const SizedBox(height: 8),
                                        // if (pa != null)
                                        // Container(
                                        //   padding: const EdgeInsets.all(10),
                                        //   decoration: BoxDecoration(
                                        //     color: Colors.grey[50],
                                        //     borderRadius:
                                        //         BorderRadius.circular(6),
                                        //   ),
                                        //   child: Column(
                                        //     crossAxisAlignment:
                                        //         CrossAxisAlignment.start,
                                        //     children: [
                                        //       Text(
                                        //         '${pa.house}, ${pa.area}',
                                        //         style: const TextStyle(
                                        //           fontWeight: FontWeight.w600,
                                        //         ),
                                        //       ),
                                        //       const SizedBox(height: 4),
                                        //       Text(
                                        //         '${pa.city}, ${pa.state} - ${pa.pincode}',
                                        //       ),
                                        //       const SizedBox(height: 6),
                                        //       // Row(
                                        //       //   mainAxisAlignment:
                                        //       //       MainAxisAlignment.end,
                                        //       //   children: [
                                        //       //     TextButton.icon(
                                        //       //       onPressed: () async {
                                        //       //         final text =
                                        //       //             '${pa.house}, ${pa.area}, ${pa.city}, ${pa.state} - ${pa.pincode}';
                                        //       //         await Clipboard.setData(
                                        //       //           ClipboardData(
                                        //       //             text: text,
                                        //       //           ),
                                        //       //         );
                                        //       //         if (!context.mounted)
                                        //       //           return;
                                        //       //         ScaffoldMessenger.of(
                                        //       //           context,
                                        //       //         ).showSnackBar(
                                        //       //           const SnackBar(
                                        //       //             content: Text(
                                        //       //               'Address copied',
                                        //       //             ),
                                        //       //           ),
                                        //       //         );
                                        //       //       },
                                        //       //       icon: const Icon(
                                        //       //         Icons.copy,
                                        //       //         size: 16,
                                        //       //       ),
                                        //       //       label: const Text('Copy'),
                                        //       //     ),
                                        //       //     const SizedBox(width: 8),
                                        //       //     TextButton.icon(
                                        //       //       onPressed: () {
                                        //       //         ScaffoldMessenger.of(
                                        //       //           context,
                                        //       //         ).showSnackBar(
                                        //       //           const SnackBar(
                                        //       //             content: Text(
                                        //       //               'Open in maps not implemented',
                                        //       //             ),
                                        //       //           ),
                                        //       //         );
                                        //       //       },
                                        //       //       icon: const Icon(
                                        //       //         Icons.map,
                                        //       //         size: 16,
                                        //       //       ),
                                        //       //       label: const Text('Open'),
                                        //       //     ),
                                        //       //   ],
                                        //       // ),
                                        //     ],
                                        //   ),
                                        // )
                                        // else
                                        //   const Text(
                                        //     'No saved addresses',
                                        //     style: TextStyle(
                                        //       color: Colors.grey,
                                        //     ),
                                        //   ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 20),
                        const Text(
                          'Items',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Items List
                        ...order.items
                            .map(
                              (item) => Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Thumbnail
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: (item.image.isNotEmpty)
                                          ? (item.image.startsWith('http')
                                              ? Image.network(
                                                  item.image,
                                                  width: 56,
                                                  height: 56,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (c, e, s) =>
                                                      Container(
                                                        width: 56,
                                                        height: 56,
                                                        color: Colors.grey[200],
                                                        child: Icon(
                                                          Icons.image_not_supported,
                                                          color: Colors.grey[500],
                                                        ),
                                                      ),
                                                )
                                              : Image.asset(
                                                  item.image,
                                                  width: 56,
                                                  height: 56,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (c, e, s) =>
                                                      Container(
                                                        width: 56,
                                                        height: 56,
                                                        color: Colors.grey[200],
                                                        child: Icon(
                                                          Icons.image_not_supported,
                                                          color: Colors.grey[500],
                                                        ),
                                                      ),
                                                ))
                                          : Container(
                                              width: 56,
                                              height: 56,
                                              color: Colors.grey[200],
                                              child: Icon(
                                                Icons.image,
                                                color: Colors.grey[500],
                                              ),
                                            ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'Quantity: ${item.quantity} × ${item.count}',
                                          ),
                                          Text(
                                            'Price: ₹${item.price.toStringAsFixed(2)} each',
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Total: ₹${item.totalPrice.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              if (item.savings > 0)
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.green
                                                        .withOpacity(0.08),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    'Saved ₹${item.savings.toStringAsFixed(2)}',
                                                    style: const TextStyle(
                                                      color: Colors.green,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),

                        const SizedBox(height: 20),

                        // Total Section
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              if (order.originalAmount != null &&
                                  order.originalAmount! > order.totalAmount)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Original Amount'),
                                    Text(
                                      '₹${order.originalAmount!.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                  ],
                                ),
                              if (order.savings != null && order.savings! > 0)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Total Savings',
                                      style: TextStyle(color: Colors.green),
                                    ),
                                    Text(
                                      '₹${order.savings!.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              const Divider(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total Amount',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '₹${order.totalAmount.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Delivery Address if available
                        if (order.deliveryAddress != null) ...[
                          const SizedBox(height: 20),
                          const Text(
                            'Delivery Address',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Builder(
                              builder: (context) {
                                final addr =
                                    order.deliveryAddress ??
                                    <String, dynamic>{};
                                final name =
                                    addr['name'] ??
                                    addr['recipient'] ??
                                    addr['fullName'];
                                final phone =
                                    addr['phone'] ??
                                    addr['mobile'] ??
                                    addr['contact'];

                                final parts = <String>[];
                                void addIf(String key) {
                                  final v = addr[key];
                                  if (v != null &&
                                      v.toString().trim().isNotEmpty) {
                                    parts.add(v.toString().trim());
                                  }
                                }

                                for (final k in [
                                  'house',
                                  'address',
                                  'street',
                                  'line1',
                                  'line2',
                                  'area',
                                  'locality',
                                  'city',
                                  'state',
                                  'pincode',
                                  'zip',
                                  'postalCode',
                                ]) {
                                  addIf(k);
                                }

                                final addressLines = parts.isNotEmpty
                                    ? parts
                                    : (addr.isNotEmpty
                                          ? addr.entries
                                                .map(
                                                  (e) => '${e.key}: ${e.value}',
                                                )
                                                .toList()
                                          : ['No address provided']);

                                final addressText = addressLines.join(',\n');

                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      color: Theme.of(context).primaryColor,
                                      size: 28,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              // Expanded(
                                              //   child: Text(
                                              //     name?.toString() ??
                                              //         'Recipient',
                                              //     style: const TextStyle(
                                              //       fontWeight: FontWeight.w700,
                                              //       fontSize: 14,
                                              //     ),
                                              //   ),
                                              // ),
                                              if (phone != null &&
                                                  phone
                                                      .toString()
                                                      .trim()
                                                      .isNotEmpty)
                                                InkWell(
                                                  onTap: () async {
                                                    await Clipboard.setData(
                                                      ClipboardData(
                                                        text: phone.toString(),
                                                      ),
                                                    );
                                                    if (!context.mounted)
                                                      return;
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          'Phone copied',
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  child: const Padding(
                                                    padding: EdgeInsets.all(
                                                      6.0,
                                                    ),
                                                    child: Icon(
                                                      Icons.copy,
                                                      size: 18,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          if (phone != null &&
                                              phone
                                                  .toString()
                                                  .trim()
                                                  .isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 4.0,
                                              ),
                                              child: Text(
                                                phone.toString(),
                                                style: TextStyle(
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            ),
                                          const SizedBox(height: 8),
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[50],
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: SelectableText(
                                              addressText,
                                              style: TextStyle(
                                                color: Colors.grey[800],
                                                height: 1.25,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Column(
                                    //   children: [
                                    //     IconButton(
                                    //       tooltip: 'Copy address',
                                    //       onPressed: () async {
                                    //         await Clipboard.setData(
                                    //           ClipboardData(text: addressText),
                                    //         );
                                    //         if (!context.mounted) return;
                                    //         ScaffoldMessenger.of(
                                    //           context,
                                    //         ).showSnackBar(
                                    //           const SnackBar(
                                    //             content: Text('Address copied'),
                                    //           ),
                                    //         );
                                    //       },
                                    //       icon: const Icon(Icons.copy_outlined),
                                    //     ),
                                    // IconButton(
                                    //   tooltip: 'Open in maps',
                                    //   onPressed: () {
                                    //     // Placeholder: opening maps requires url_launcher; keep simple feedback for now.
                                    //     ScaffoldMessenger.of(
                                    //       context,
                                    //     ).showSnackBar(
                                    //       const SnackBar(
                                    //         content: Text(
                                    //           'Open in maps not implemented',
                                    //         ),
                                    //       ),
                                    //     );
                                    //   },
                                    //   icon: const Icon(Icons.map_outlined),
                                    // ),
                                    //   ],
                                    // ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),

                        // Delivery Boy assignment
                        // const SizedBox(height: 8),
                        // const Text(
                        //   'Assign Delivery Boy',
                        //   style: TextStyle(
                        //     fontWeight: FontWeight.bold,
                        //     fontSize: 16,
                        //   ),
                        // ),
                        // const SizedBox(height: 8),
                        // Consumer<DeliveryBoyProvider>(
                        //   builder: (context, dProvider, child) {
                        //     return StreamBuilder<List<DeliveryBoyModel>>(
                        //       stream: dProvider.streamAll(),
                        //       builder: (context, snap) {
                        //         if (!snap.hasData) return const SizedBox.shrink();
                        //         final list = snap.data!;
                        //         return Row(
                        //           children: [
                        //             Expanded(
                        //               child: DropdownButtonFormField<String>(
                        //                 items: list
                        //                     .map(
                        //                       (d) => DropdownMenuItem(
                        //                         value: d.id,
                        //                         child: Text(
                        //                           '${d.name} (${d.phone})',
                        //                         ),
                        //                       ),
                        //                     )
                        //                     .toList(),
                        //                 onChanged: (v) {},
                        //                 decoration: const InputDecoration(
                        //                   border: OutlineInputBorder(),
                        //                   labelText: 'Select delivery boy',
                        //                 ),
                        //               ),
                        //             ),
                        //             const SizedBox(width: 8),
                        //             ElevatedButton(
                        //               onPressed: () async {
                        //                 // Use a dialog to pick and assign
                        //                 final pick =
                        //                     await showDialog<DeliveryBoyModel?>(
                        //                       context: context,
                        //                       builder: (c) => SimpleDialog(
                        //                         title: const Text(
                        //                           'Choose Delivery Boy',
                        //                         ),
                        //                         children: list
                        //                             .map(
                        //                               (d) => SimpleDialogOption(
                        //                                 onPressed: () =>
                        //                                     Navigator.pop(c, d),
                        //                                 child: Text(
                        //                                   '${d.name} (${d.phone})',
                        //                                 ),
                        //                               ),
                        //                             )
                        //                             .toList(),
                        //                       ),
                        //                     );
                        //                 if (pick == null) return;
                        //                 final orderProvider =
                        //                     Provider.of<OrderProvider>(
                        //                       context,
                        //                       listen: false,
                        //                     );
                        //                 await orderProvider
                        //                     .assignDeliveryBoy(order.id, {
                        //                       'id': pick.id,
                        //                       'name': pick.name,
                        //                       'phone': pick.phone,
                        //                     });
                        //                 if (!context.mounted) return;
                        //                 ScaffoldMessenger.of(context).showSnackBar(
                        //                   const SnackBar(
                        //                     content: Text('Delivery boy assigned'),
                        //                   ),
                        //                 );
                        //                 Navigator.pop(context); // close details
                        //               },
                        //               child: const Text('Assign'),
                        //             ),
                        //           ],
                        //         );
                        //       },
                        //     );
                        //   },
                        // ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          const Text(': '),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

// Status Update Dialog
class StatusUpdateDialog extends StatefulWidget {
  final OrderModel order;
  final Function(String) onStatusUpdate;

  const StatusUpdateDialog({
    Key? key,
    required this.order,
    required this.onStatusUpdate,
  }) : super(key: key);

  @override
  State<StatusUpdateDialog> createState() => _StatusUpdateDialogState();
}

class _StatusUpdateDialogState extends State<StatusUpdateDialog> {
  late String _selectedStatus;

  final List<String> _statuses = [
    'placed',
    'out_for_delivery',
    'delivered',
    'cancelled',
  ];

  final Map<String, String> _statusLabels = {
    'placed': 'Placed',
    'delivered': 'Delivered',
    'cancelled': 'Cancelled',
    'out_for_delivery': 'Out for delivery',
  };

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.order.status;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update Order Status'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Order #${widget.order.id.substring(0, 8).toUpperCase()}'),
          const SizedBox(height: 16),
          Builder(
            builder: (context) {
              // Ensure the current status is included in the list to avoid Dropdown assertion
              final localStatuses = List<String>.from(_statuses);
              if (!_selectedStatus.isEmpty &&
                  !localStatuses.contains(_selectedStatus)) {
                localStatuses.insert(0, _selectedStatus);
              }

              return DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: localStatuses
                    .map(
                      (status) => DropdownMenuItem(
                        value: status,
                        child: Text(
                          _statusLabels[status] ??
                              status
                                  .replaceAll('_', ' ')
                                  .splitMapJoin(
                                    RegExp(r"\b"),
                                    onMatch: (m) => m[0]!.toUpperCase(),
                                    onNonMatch: (s) => s,
                                  ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedStatus = value);
                  }
                },
              );
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onStatusUpdate(_selectedStatus);
            Navigator.pop(context);
          },
          child: const Text('Update'),
        ),
      ],
    );
  }
}

// Order Actions Bottom Sheet
class OrderActionsSheet extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onDelete;

  const OrderActionsSheet({
    Key? key,
    required this.order,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.delete, color: Colors.red),
          title: const Text(
            'Delete Order',
            style: TextStyle(color: Colors.red),
          ),
          onTap: () {
            // Show confirmation dialog
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete Order'),
                content: const Text(
                  'Are you sure you want to delete this order? This action cannot be undone.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      onDelete();
                    },
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

// Edit Order Dialog: combine status change and delivery boy assignment
class EditOrderDialog extends StatefulWidget {
  final OrderModel order;
  final Future<void> Function(String? newStatus, DeliveryBoyModel? deliveryBoy)
  onSave;

  const EditOrderDialog({Key? key, required this.order, required this.onSave})
    : super(key: key);

  @override
  State<EditOrderDialog> createState() => _EditOrderDialogState();
}

class _EditOrderDialogState extends State<EditOrderDialog> {
  late String? _selectedStatus;
  String? _selectedDeliveryBoyId;
  List<DeliveryBoyModel> _deliveryBoyList = [];
  final List<String> _statuses = [
    'placed',
    'out_for_delivery',
    'delivered',
    'cancelled',
  ];
  final Map<String, String> _statusLabels = {
    'placed': 'Placed',
    'delivered': 'Delivered',
    'cancelled': 'Cancelled',
    'out_for_delivery': 'Out for delivery',
  };

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.order.status;
    // Initialize selected delivery boy id from the order if already assigned
    try {
      final assigned = widget.order.deliveryBoy;
      if (assigned != null && assigned['id'] != null) {
        _selectedDeliveryBoyId = assigned['id'].toString();
      }
    } catch (_) {
      // ignore and leave null
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Expanded(child: Text('Edit Order')),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order #${widget.order.id.substring(0, 8).toUpperCase()}'),
            const SizedBox(height: 12),
            // Status selector
            Builder(
              builder: (context) {
                final localStatuses = List<String>.from(_statuses);
                if (_selectedStatus != null &&
                    !localStatuses.contains(_selectedStatus)) {
                  localStatuses.insert(0, _selectedStatus!);
                }

                return DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items: localStatuses
                      .map(
                        (s) => DropdownMenuItem(
                          value: s,
                          child: Text(
                            _statusLabels[s] ??
                                s
                                    .replaceAll('_', ' ')
                                    .splitMapJoin(
                                      RegExp(r"\b"),
                                      onMatch: (m) => m[0]!.toUpperCase(),
                                      onNonMatch: (s) => s,
                                    ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _selectedStatus = v),
                );
              },
            ),
            const SizedBox(height: 12),
            const Text(
              'Assign Delivery Boy',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Consumer<DeliveryBoyProvider>(
              builder: (context, dProvider, child) {
                return StreamBuilder<List<DeliveryBoyModel>>(
                  stream: dProvider.streamAll(),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final rawList = snap.data ?? [];
                    // Deduplicate delivery boys by id to avoid duplicate DropdownMenuItem values
                    final Map<String?, DeliveryBoyModel> uniqueMap = {};
                    for (var d in rawList) {
                      if (d.id == null) continue;
                      uniqueMap[d.id] = d;
                    }
                    final list = uniqueMap.values.toList();
                    // keep latest list for resolving id -> model on save
                    _deliveryBoyList = list;

                    final items = list
                        .map(
                          (d) => DropdownMenuItem<String?>(
                            value: d.id,
                            child: Text('${d.name}'),
                          ),
                        )
                        .toList();

                    // If there are no delivery boys available, show a disabled
                    // read-only field indicating that none are available.
                    if (items.isEmpty) {
                      return TextFormField(
                        initialValue: 'No delivery boys available',
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        enabled: false,
                      );
                    }

                    // Show hint 'Not assigned' when the order currently has no
                    // assigned delivery boy (_selectedDeliveryBoyId == null).
                    // Ensure the currently selected id exists exactly once in items.
                    final hasSelected =
                        _selectedDeliveryBoyId != null &&
                        items
                                .where(
                                  (it) => it.value == _selectedDeliveryBoyId,
                                )
                                .length ==
                            1;

                    return DropdownButtonFormField<String?>(
                      value: hasSelected ? _selectedDeliveryBoyId : null,
                      hint: const Text('Not assigned'),
                      items: items,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (v) =>
                          setState(() => _selectedDeliveryBoyId = v),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            // resolve selected delivery boy model by id
            DeliveryBoyModel? selected;
            if (_selectedDeliveryBoyId != null) {
              final matches = _deliveryBoyList.where(
                (d) => d.id == _selectedDeliveryBoyId,
              );
              if (matches.isNotEmpty) selected = matches.first;
            }

            await widget.onSave(_selectedStatus, selected);
            if (!context.mounted) return;
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
