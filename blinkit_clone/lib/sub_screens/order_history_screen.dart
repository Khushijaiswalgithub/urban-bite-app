// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import '../providers/order_provider.dart';
// import '../models/order_model.dart';
// import 'order_detail_screen.dart';

// class OrderHistoryScreen extends StatefulWidget {
//   const OrderHistoryScreen({super.key});

//   @override
//   State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
// }

// class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Provider.of<OrderProvider>(context, listen: false).fetchOrders();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'My Orders',
//           style: TextStyle(
//             color: Colors.black,
//             fontSize: 20,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: Consumer<OrderProvider>(
//         builder: (context, orderProvider, child) {
//           if (orderProvider.isLoading) {
//             return const Center(
//               child: CircularProgressIndicator(
//                 color: Colors.green,
//               ),
//             );
//           }

//           if (orderProvider.error != null) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(
//                     Icons.error_outline,
//                     size: 80,
//                     color: Colors.red,
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     'Error: ${orderProvider.error}',
//                     style: const TextStyle(
//                       fontSize: 16,
//                       color: Colors.red,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 16),
//                   ElevatedButton(
//                     onPressed: () {
//                       orderProvider.clearError();
//                       orderProvider.fetchOrders();
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.green,
//                       foregroundColor: Colors.white,
//                     ),
//                     child: const Text('Retry'),
//                   ),
//                 ],
//               ),
//             );
//           }

//           if (orderProvider.orders.isEmpty) {
//             return const Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.shopping_bag_outlined,
//                     size: 80,
//                     color: Colors.grey,
//                   ),
//                   SizedBox(height: 16),
//                   Text(
//                     'No orders yet',
//                     style: TextStyle(
//                       fontSize: 18,
//                       color: Colors.grey,
//                     ),
//                   ),
//                   SizedBox(height: 8),
//                   Text(
//                     'Start shopping to see your orders here',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey,
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }

//           return RefreshIndicator(
//             onRefresh: () async {
//               await orderProvider.fetchOrders();
//             },
//             color: Colors.green,
//             child: ListView.builder(
//               padding: const EdgeInsets.all(16),
//               itemCount: orderProvider.orders.length,
//               itemBuilder: (context, index) {
//                 final order = orderProvider.orders[index];
//                 return _buildOrderCard(context, order);
//               },
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildOrderCard(BuildContext context, OrderModel order) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             spreadRadius: 1,
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: InkWell(
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => OrderDetailScreen(order: order),
//             ),
//           );
//         },
//         borderRadius: BorderRadius.circular(12),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Order Header
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Order #${order.id.substring(0, 8)}',
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 4,
//                     ),
//                     decoration: BoxDecoration(
//                       color: _getStatusColor(order.status).withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text(
//                       _getStatusText(order.status),
//                       style: TextStyle(
//                         color: _getStatusColor(order.status),
//                         fontSize: 12,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
              
//               const SizedBox(height: 8),
              
//               // Order Date
//               Text(
//                 _formatDate(order.orderDate),
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.grey[600],
//                 ),
//               ),
              
//               const SizedBox(height: 12),
              
//               // Order Items Preview
//               SizedBox(
//                 height: 60,
//                 child: ListView.builder(
//                   scrollDirection: Axis.horizontal,
//                   itemCount: order.items.length > 3 ? 3 : order.items.length,
//                   itemBuilder: (context, index) {
//                     final item = order.items[index];
//                     return Container(
//                       margin: const EdgeInsets.only(right: 8),
//                       width: 50,
//                       height: 50,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(8),
//                         color: Colors.grey[100],
//                       ),
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(8),
//                         child: CachedNetworkImage(
//                           imageUrl: item.productImage,
//                           fit: BoxFit.cover,
//                           placeholder: (context, url) => const Center(
//                             child: CircularProgressIndicator(strokeWidth: 2),
//                           ),
//                           errorWidget: (context, url, error) => const Icon(
//                             Icons.image_not_supported,
//                             color: Colors.grey,
//                             size: 20,
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
              
//               if (order.items.length > 3) ...[
//                 const SizedBox(height: 8),
//                 Text(
//                   '+${order.items.length - 3} more items',
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//               ],
              
//               const SizedBox(height: 12),
              
//               // Order Summary
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     '${order.items.length} item${order.items.length > 1 ? 's' : ''}',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey[600],
//                     ),
//                   ),
//                   Text(
//                     '₹${order.totalAmount.toStringAsFixed(0)}',
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.green,
//                     ),
//                   ),
//                 ],
//               ),
              
//               const SizedBox(height: 12),
              
//               // Action Buttons
//               Row(
//                 children: [
//                   Expanded(
//                     child: OutlinedButton(
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => OrderDetailScreen(order: order),
//                           ),
//                         );
//                       },
//                       style: OutlinedButton.styleFrom(
//                         side: const BorderSide(color: Colors.green),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       child: const Text(
//                         'View Details',
//                         style: TextStyle(
//                           color: Colors.green,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   if (order.status == 'confirmed') ...[
//                     Expanded(
//                       child: ElevatedButton(
//                         onPressed: () {
//                           // Implement reorder functionality
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(
//                               content: Text('Reorder functionality coming soon!'),
//                               backgroundColor: Colors.green,
//                             ),
//                           );
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.green,
//                           foregroundColor: Colors.white,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                         child: const Text(
//                           'Reorder',
//                           style: TextStyle(
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Color _getStatusColor(String status) {
//     switch (status.toLowerCase()) {
//       case 'confirmed':
//         return Colors.green;
//       case 'pending':
//         return Colors.orange;
//       case 'delivered':
//         return Colors.blue;
//       case 'cancelled':
//         return Colors.red;
//       default:
//         return Colors.grey;
//     }
//   }

//   String _getStatusText(String status) {
//     switch (status.toLowerCase()) {
//       case 'confirmed':
//         return 'Confirmed';
//       case 'pending':
//         return 'Pending';
//       case 'delivered':
//         return 'Delivered';
//       case 'cancelled':
//         return 'Cancelled';
//       default:
//         return 'Unknown';
//     }
//   }

//   String _formatDate(DateTime date) {
//     final months = [
//       'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
//       'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
//     ];
    
//     return '${date.day} ${months[date.month - 1]} ${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
//   }
// }

