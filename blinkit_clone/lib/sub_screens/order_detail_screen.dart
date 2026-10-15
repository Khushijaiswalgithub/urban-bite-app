// import 'package:flutter/material.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import '../models/order_model.dart';

// class OrderDetailScreen extends StatelessWidget {
//   final OrderModel order;

//   const OrderDetailScreen({
//     super.key,
//     required this.order,
//   });

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
//         title: Text(
//           'Order #${order.id.substring(0, 8)}',
//           style: const TextStyle(
//             color: Colors.black,
//             fontSize: 20,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Order Status Card
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.grey.withOpacity(0.1),
//                     spreadRadius: 1,
//                     blurRadius: 4,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Text(
//                         'Order Status',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 12,
//                           vertical: 6,
//                         ),
//                         decoration: BoxDecoration(
//                           color: _getStatusColor(order.status).withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Text(
//                           _getStatusText(order.status),
//                           style: TextStyle(
//                             color: _getStatusColor(order.status),
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Ordered on ${_formatDate(order.orderDate)}',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey[600],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
            
//             const SizedBox(height: 16),
            
//             // Order Items
//             Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.grey.withOpacity(0.1),
//                     spreadRadius: 1,
//                     blurRadius: 4,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Padding(
//                     padding: EdgeInsets.all(16),
//                     child: Text(
//                       'Order Items',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                   ListView.separated(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     itemCount: order.items.length,
//                     separatorBuilder: (context, index) => Divider(
//                       height: 1,
//                       color: Colors.grey[200],
//                     ),
//                     itemBuilder: (context, index) {
//                       final item = order.items[index];
//                       return Padding(
//                         padding: const EdgeInsets.all(16),
//                         child: Row(
//                           children: [
//                             Container(
//                               width: 60,
//                               height: 60,
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(8),
//                                 color: Colors.grey[100],
//                               ),
//                               child: ClipRRect(
//                                 borderRadius: BorderRadius.circular(8),
//                                 child: CachedNetworkImage(
//                                   imageUrl: item.productImage,
//                                   fit: BoxFit.cover,
//                                   placeholder: (context, url) => const Center(
//                                     child: CircularProgressIndicator(strokeWidth: 2),
//                                   ),
//                                   errorWidget: (context, url, error) => const Icon(
//                                     Icons.image_not_supported,
//                                     color: Colors.grey,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 12),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     item.productName,
//                                     style: const TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                   if (item.productNameHindi.isNotEmpty) ...[
//                                     const SizedBox(height: 2),
//                                     Text(
//                                       item.productNameHindi,
//                                       style: TextStyle(
//                                         fontSize: 14,
//                                         color: Colors.grey[600],
//                                       ),
//                                     ),
//                                   ],
//                                   const SizedBox(height: 4),
//                                   Text(
//                                     'Qty: ${item.quantity} ${item.unit}',
//                                     style: TextStyle(
//                                       fontSize: 14,
//                                       color: Colors.grey[600],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.end,
//                               children: [
//                                 if (item.originalPrice != item.discountedPrice) ...[
//                                   Text(
//                                     '₹${item.originalPrice.toStringAsFixed(0)}',
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       color: Colors.grey[500],
//                                       decoration: TextDecoration.lineThrough,
//                                     ),
//                                   ),
//                                 ],
//                                 Text(
//                                   '₹${item.totalPrice.toStringAsFixed(0)}',
//                                   style: const TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.green,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),
            
//             const SizedBox(height: 16),
            
//             // Bill Summary
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.grey.withOpacity(0.1),
//                     spreadRadius: 1,
//                     blurRadius: 4,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Row(
//                     children: [
//                       Icon(Icons.receipt_outlined, size: 20),
//                       SizedBox(width: 8),
//                       Text(
//                         'Bill Summary',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//                   _buildBillRow('Subtotal', '₹${order.subtotal.toStringAsFixed(0)}'),
//                   const SizedBox(height: 8),
//                   _buildBillRow('Discount', '-₹${order.discount.toStringAsFixed(0)}', isGreen: true),
//                   const SizedBox(height: 8),
//                   _buildBillRow('Taxes & Charges', '₹${order.taxes.toStringAsFixed(0)}'),
//                   const SizedBox(height: 8),
//                   _buildBillRow('Delivery Charges', '₹${order.deliveryCharges.toStringAsFixed(0)}', isGreen: order.deliveryCharges == 0),
//                   const Divider(height: 24),
//                   _buildBillRow('Total Amount', '₹${order.totalAmount.toStringAsFixed(0)}', isBold: true),
//                 ],
//               ),
//             ),
            
//             if (order.deliveryAddress != null) ...[
//               const SizedBox(height: 16),
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.grey.withOpacity(0.1),
//                       spreadRadius: 1,
//                       blurRadius: 4,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Row(
//                       children: [
//                         Icon(Icons.location_on_outlined, size: 20),
//                         SizedBox(width: 8),
//                         Text(
//                           'Delivery Address',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       order.deliveryAddress!,
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey[700],
//                       ),
//                     ),
//                     if (order.phoneNumber != null) ...[
//                       const SizedBox(height: 4),
//                       Text(
//                         'Phone: ${order.phoneNumber}',
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Colors.grey[700],
//                         ),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildBillRow(String label, String amount, {bool isGreen = false, bool isBold = false}) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
//             color: Colors.black87,
//           ),
//         ),
//         Text(
//           amount,
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
//             color: isGreen ? Colors.green : Colors.black87,
//           ),
//         ),
//       ],
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

