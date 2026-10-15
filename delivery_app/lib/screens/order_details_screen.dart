import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../models/order_model.dart';
import '../providers/orders_provider.dart';
import '../providers/location_provider.dart';
import '../providers/user_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/user/user_model.dart';
import '../models/user/address_model.dart';

class OrderDetailsScreen extends StatefulWidget {
  final OrderModel order;
  const OrderDetailsScreen({super.key, required this.order});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  final Completer<GoogleMapController> _mapController = Completer();
  final TextEditingController _otpController = TextEditingController();
  late Stream<OrderModel> _orderStream;

  @override
  void initState() {
    super.initState();
    _orderStream = FirebaseFirestore.instance
        .collection('orders')
        .doc(widget.order.id)
        .snapshots()
        .map((doc) => OrderModel.fromMap(doc.data() ?? {}, id: doc.id));
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  int _getStatusStep(String status) {
    switch (status.toLowerCase()) {
      case 'placed':
        return 0;
      case 'picked up':
      case 'picked_up':
        return 1;
      case 'out_for_delivery':
      case 'on the way':
      case 'on_the_way':
        return 2;
      case 'delivered':
        return 3;
      default:
        return 0;
    }
  }

  Widget _buildTimeline(int currentStep) {
    final steps = ['Placed', 'Picked Up', 'On the Way', 'Delivered'];
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Delivery Timeline',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: List.generate(steps.length, (index) {
                final isCompleted = index < currentStep;
                final isActive = index == currentStep;
                final color = isCompleted
                    ? primaryColor
                    : (isActive ? primaryColor : Colors.grey.shade300);

                return Expanded(
                  flex: index < steps.length - 1 ? 2 : 0,
                  child: Row(
                    children: [
                      // Circle Indicator
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isActive ? Colors.white : color,
                          border: Border.all(
                            color: color,
                            width: isActive ? 6 : 2,
                          ),
                          boxShadow: isActive || isCompleted
                              ? [
                                  BoxShadow(
                                    color: primaryColor.withOpacity(0.15),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : null,
                        ),
                        child: Center(
                          child: isCompleted
                              ? const Icon(Icons.check, size: 14, color: Colors.white)
                              : (isActive
                                  ? null
                                  : Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade600,
                                      ),
                                    )),
                        ),
                      ),
                      // Line Connector
                      if (index < steps.length - 1)
                        Expanded(
                          child: Container(
                            height: 3,
                            decoration: BoxDecoration(
                              color: index < currentStep
                                  ? primaryColor
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: steps.map((step) {
                final stepIndex = steps.indexOf(step);
                final isActive = stepIndex == currentStep;
                final isCompleted = stepIndex <= currentStep;
                return Expanded(
                  child: Text(
                    step,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                      color: isActive
                          ? primaryColor
                          : (isCompleted ? Colors.grey.shade700 : Colors.grey.shade400),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(OrderModel order) {
    final step = _getStatusStep(order.status);
    final colorScheme = Theme.of(context).colorScheme;

    if (step == 0) {
      return Card(
        elevation: 0,
        color: colorScheme.primaryContainer.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.primaryContainer.withOpacity(0.25)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.storefront, color: colorScheme.primary, size: 22),
                  const SizedBox(width: 8),
                  const Text(
                    'Ready for Pickup',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Arrive at the merchant store, verify and collect all items, then tap below to confirm pickup and start your delivery run.',
                style: TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      title: const Text('Confirm Pickup'),
                      content: const Text('Have you successfully collected all order items from the store?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('CANCEL'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
                          child: const Text('CONFIRM'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await context.read<OrdersProvider>().updateOrderStatus(
                          orderId: order.id,
                          newStatus: 'picked up',
                        );
                  }
                },
                icon: const Icon(Icons.check_circle_outline, size: 20),
                label: const Text(
                  'CONFIRM PICKUP',
                  style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 1,
                ),
              ),
            ],
          ),
        ),
      );
    } else if (step == 1) {
      return Card(
        elevation: 0,
        color: Colors.blue.shade50.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.blue.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.local_shipping_outlined, color: Colors.blue.shade700, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Start Delivery Run',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Items collected. Mark the order as "Out for Delivery" to notify the customer that you are on your way.',
                style: TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  await context.read<OrdersProvider>().updateOrderStatus(
                        orderId: order.id,
                        newStatus: 'out_for_delivery',
                      );
                },
                icon: const Icon(Icons.navigation_outlined, size: 20),
                label: const Text(
                  'START DELIVERY RUN',
                  style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 1,
                ),
              ),
            ],
          ),
        ),
      );
    } else if (step == 2) {
      return Card(
        elevation: 0,
        color: Colors.amber.shade50.withOpacity(0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.amber.shade300),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.vpn_key_outlined, color: Colors.amber.shade800, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Verify Delivery OTP',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.amber.shade900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Verify the 6-digit OTP code provided by the customer to complete this delivery.',
                style: TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _otpController,
                decoration: InputDecoration(
                  hintText: 'Enter customer OTP',
                  prefixIcon: const Icon(Icons.lock_outline),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.amber.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.amber.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.amber.shade700, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                keyboardType: TextInputType.number,
                style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 3, fontSize: 16),
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: () async {
                  final success = await context.read<OrdersProvider>().verifyOtp(
                        orderId: order.id,
                        otp: _otpController.text.trim(),
                      );
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(success ? Icons.check_circle : Icons.error, color: Colors.white),
                          const SizedBox(width: 12),
                          Text(success
                              ? 'Delivery completed successfully!'
                              : 'Invalid OTP, please try again'),
                        ],
                      ),
                      backgroundColor: success ? Colors.green : Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  );
                  if (success) {
                    _otpController.clear();
                  }
                },
                icon: const Icon(Icons.verified_outlined, size: 20),
                label: const Text(
                  'VERIFY & COMPLETE DELIVERY',
                  style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 1,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Card(
        elevation: 0,
        color: Colors.green.shade50.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.green.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, color: Colors.green.shade700, size: 36),
              ),
              const SizedBox(height: 14),
              Text(
                'Order Delivered',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.green.shade800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'This order was verified and delivered successfully.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.green.shade900),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.order.userId.isNotEmpty) {
        try {
          context.read<UserProvider>().loadForUid(widget.order.userId);
        } catch (_) {}
      }
    });

    return StreamBuilder<OrderModel>(
      stream: _orderStream,
      initialData: widget.order,
      builder: (context, snapshot) {
        final order = snapshot.data ?? widget.order;
        final addr = order.deliveryAddress;
        final double lat = (addr?['latitude'] as num?)?.toDouble() ?? 0.0;
        final double lng = (addr?['longitude'] as num?)?.toDouble() ?? 0.0;
        final LatLng dest = LatLng(lat, lng);
        final colorScheme = Theme.of(context).colorScheme;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Order #${order.id.isNotEmpty && order.id.length >= 6 ? order.id.substring(0, 6).toUpperCase() : order.id}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            elevation: 0,
            scrolledUnderElevation: 2,
          ),
          floatingActionButton: FloatingActionButton.extended(
            icon: const Icon(Icons.navigation, color: Colors.white),
            label: const Text('Navigate', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            backgroundColor: colorScheme.primary,
            onPressed: () {
              context.read<LocationProvider>().openNavigation(
                latitude: lat,
                longitude: lng,
              );
            },
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              // Timeline Status Stepper
              _buildTimeline(_getStatusStep(order.status)),
              const SizedBox(height: 12),

              // Dynamic Action Card
              _buildActionCard(order),
              const SizedBox(height: 12),

              // Customer details card
              Consumer<UserProvider>(
                builder: (context, userProv, _) {
                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Customer Details',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (userProv.isLoading)
                            Row(
                              children: const [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                SizedBox(width: 12),
                                Text('Loading customer profile...'),
                              ],
                            )
                          else if (userProv.error != null)
                            Row(
                              children: [
                                Icon(Icons.error_outline, color: colorScheme.error),
                                const SizedBox(width: 8),
                                Expanded(child: Text(userProv.error!)),
                              ],
                            )
                          else if (userProv.user == null)
                            Text(
                              'User profile details not found',
                              style: TextStyle(color: Colors.grey.shade600),
                            )
                          else
                            _CustomerDetails(
                              user: userProv.user!,
                              addressFromOrder: addr,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              // Ordered Items Card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ordered Items',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...order.items.map(
                        (it) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: it.image.isNotEmpty
                                      ? Image.network(
                                          it.image,
                                          fit: BoxFit.cover,
                                          errorBuilder: (c, e, s) => const Icon(Icons.inventory_2, color: Colors.grey),
                                        )
                                      : const Icon(Icons.inventory_2, color: Colors.grey),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      it.name,
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${it.quantity} • ₹ ${it.price.toStringAsFixed(2)}',
                                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'x${it.count}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Divider(),
                      ),
                      Row(
                        children: [
                          const Text(
                            'Grand Total',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const Spacer(),
                          Text(
                            '₹ ${order.totalAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Map card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Delivery Location',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 200,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(target: dest, zoom: 14),
                            markers: {
                              Marker(
                                markerId: const MarkerId('dest'),
                                position: dest,
                                infoWindow: const InfoWindow(title: 'Delivery Location'),
                              ),
                            },
                            onMapCreated: (c) => _mapController.complete(c),
                            myLocationEnabled: false,
                            myLocationButtonEnabled: false,
                            zoomControlsEnabled: false,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }
}

class _CustomerDetails extends StatelessWidget {
  final UserModel user;
  final Map<String, dynamic>? addressFromOrder;

  const _CustomerDetails({required this.user, required this.addressFromOrder});

  Widget _buildPrimaryAddress(BuildContext context) {
    if (user.addresses.isEmpty) return const Text('No saved addresses');
    final AddressModel a = user.addresses.first;
    final parts = [
      a.line1,
      a.line2,
      a.city,
      a.state,
      a.postcode,
    ].where((e) => e != null && e.isNotEmpty).map((e) => e!).toList();
    return Text(
      parts.join(', '),
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white70
                : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final initials = (user.name ?? user.uid)
        .split(' ')
        .where((s) => s.isNotEmpty)
        .map((s) => s[0])
        .take(2)
        .join()
        .toUpperCase();
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: colorScheme.primary.withOpacity(0.1),
              child: Text(
                initials,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name ?? 'Unnamed Customer',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.phone, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          user.phoneNumber ?? '-',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.email, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          user.email ?? '-',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Primary Customer Address',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade400
                : Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 4),
        _buildPrimaryAddress(context),
        const SizedBox(height: 12),
        Text(
          'Delivery Address (This Order)',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade400
                : Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          addressFromOrder != null
              ? '${addressFromOrder!['house'] ?? ''} ${addressFromOrder!['area'] ?? ''}, ${addressFromOrder!['city'] ?? ''} - ${addressFromOrder!['pincode'] ?? ''}'
              : 'Not available',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white70
                    : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () async {
              final raw = user.phoneNumber ?? '';
              final phone = raw.replaceAll(RegExp(r'[^0-9+]'), '');
              if (phone.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No phone number available')),
                );
                return;
              }
              final uri = Uri(scheme: 'tel', path: phone);
              try {
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cannot launch dialer')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to call: $e')),
                );
              }
            },
            icon: const Icon(Icons.call, size: 18),
            label: const Text('CALL CUSTOMER', style: TextStyle(fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.primary,
              side: BorderSide(color: colorScheme.primary.withOpacity(0.5)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
