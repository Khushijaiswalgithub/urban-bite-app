import 'package:blinkit_admin/screens/deliveyboy_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/banner_provider.dart';
import 'providers/category_provider.dart';
import 'providers/product_provider.dart';
import 'providers/order_provider.dart';
import 'screens/users_screen.dart';
import 'screens/banners_screen.dart';
import 'screens/categories_screen.dart';
import 'screens/products_screen.dart';
import 'screens/order_screen.dart';
import 'screens/delivery_charge_admin_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _infoCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required AsyncSnapshot<int> snapshot,
    required Color color,
    required int index,
  }) {
    // snapshot is forwarded to child widgets that may use it; no local use here

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        // Some curves (e.g. easeOutBack) may overshoot beyond 1.0 which
        // causes an assertion failure in Opacity. Clamp the value to the
        // valid range [0.0, 1.0] before passing it to Opacity.
        final double clamped = value.clamp(0.0, 1.0);
        return Transform.scale(
          scale: value,
          child: Opacity(opacity: clamped, child: child),
        );
      },
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1),
        ),
        child: InkWell(
          onTap: () => _navigateToScreen(context, label),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color.withOpacity(0.05), color.withOpacity(0.02)],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Hero(
                    tag: 'icon_$label',
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [color.withOpacity(0.8), color],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(icon, color: Colors.white, size: 32),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                      letterSpacing: 0.5,
                    ),
                  ),
                  // const SizedBox(height: 12),
                  // if (loading)
                  //   SizedBox(
                  //     height: 32,
                  //     width: 32,
                  //     child: CircularProgressIndicator(
                  //       strokeWidth: 3,
                  //       valueColor: AlwaysStoppedAnimation<Color>(color),
                  //     ),
                  //   )
                  // else if (hasError)
                  //   Column(
                  //     children: [
                  //       Icon(
                  //         Icons.error_outline,
                  //         color: Colors.red[400],
                  //         size: 28,
                  //       ),
                  //       const SizedBox(height: 4),
                  //       Text(
                  //         'Failed to load',
                  //         style: TextStyle(
                  //           color: Colors.red[400],
                  //           fontSize: 11,
                  //           fontWeight: FontWeight.w500,
                  //         ),
                  //       ),
                  //     ],
                  //   )
                  // else
                  //   TweenAnimationBuilder<int>(
                  //     duration: const Duration(milliseconds: 1000),
                  //     tween: IntTween(begin: 0, end: snapshot.data ?? 0),
                  //     builder: (context, value, child) {
                  //       return Text(
                  //         '$value',
                  //         style: TextStyle(
                  //           fontSize: 12,
                  //           fontWeight: FontWeight.bold,
                  //           color: color,
                  //           letterSpacing: -0.5,
                  //         ),
                  //       );
                  //     },
                  //   ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToScreen(BuildContext context, String label) {
    final Widget? screen;
    switch (label) {
      case 'Users':
        screen = const UsersScreen();
        break;
      case 'Orders':
        screen = const OrderDashboardScreen();
        break;
      case 'Banners':
        screen = const BannersScreen();
        break;
      case 'Categories':
        screen = const CategoriesScreen();
        break;
      case 'Products':
        screen = const ProductsScreen();
        break;
      case 'Delivery Boys':
        screen = const DeliveryBoysScreen();
        break;
      case 'Deliv..Chrge..':
        screen = const DeliveryChargeAdminPage();
        break;
      default:
        screen = null;
    }

    if (screen != null) {
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              screen ?? const SizedBox.shrink(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;
            var tween = Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(position: offsetAnimation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Streams for counts
    final usersStream = FirebaseFirestore.instance
        .collection('users')
        .snapshots()
        .map((s) => s.docs.length);
    final bannersStream = Provider.of<BannerProvider>(
      context,
      listen: false,
    ).bannersStream().map((l) => l.length);
    final categoriesStream = Provider.of<CategoryProvider>(
      context,
      listen: false,
    ).supCategoriesStream().map((l) => l.length);
    final productsStream = Provider.of<ProductProvider>(
      context,
      listen: false,
    ).productsStream().map((l) => l.length);
    final ordersStream = Provider.of<OrderProvider>(
      context,
      listen: false,
    ).streamOrders().map((l) => l.length);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey[800],
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.refresh_rounded),
          //   onPressed: () {
          //     setState(() {
          //       _controller.reset();
          //       _controller.forward();
          //     });
          //   },
          //   tooltip: 'Refresh',
          // ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Confirm logout
              final doLogout = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Log out'),
                  content: const Text(
                    'Are you sure you want to log out from admin?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );

              if (doLogout == true) {
                await FirebaseAuth.instance.signOut();
                // authStateChanges in main.dart will handle showing LoginScreen
              }
            },
            tooltip: 'Logout',
          ),
          SizedBox(width: 8),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _controller.reset();
              _controller.forward();
            });
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(
                  //     horizontal: 4,
                  //     vertical: 8,
                  //   ),
                  //   child: Text(
                  //     'Overview',
                  //     style: TextStyle(
                  //       fontSize: 24,
                  //       fontWeight: FontWeight.bold,
                  //       color: Colors.grey[800],
                  //       letterSpacing: 0.5,
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
                      return GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.0,
                        children: [
                          StreamBuilder<int>(
                            stream: usersStream,
                            builder: (ctx, snap) => _infoCard(
                              ctx,
                              icon: Icons.people_rounded,
                              label: 'Users',
                              snapshot: snap,
                              color: Colors.blue,
                              index: 0,
                            ),
                          ),
                          StreamBuilder<int>(
                            stream: ordersStream,
                            builder: (ctx, snap) => _infoCard(
                              ctx,
                              icon: Icons.receipt_long_rounded,
                              label: 'Orders',
                              snapshot: snap,
                              color: Colors.teal,
                              index: 1,
                            ),
                          ),
                          StreamBuilder<int>(
                            stream: bannersStream,
                            builder: (ctx, snap) => _infoCard(
                              ctx,
                              icon: Icons.image_rounded,
                              label: 'Banners',
                              snapshot: snap,
                              color: Colors.purple,
                              index: 2,
                            ),
                          ),
                          StreamBuilder<int>(
                            stream: categoriesStream,
                            builder: (ctx, snap) => _infoCard(
                              ctx,
                              icon: Icons.category_rounded,
                              label: 'Categories',
                              snapshot: snap,
                              color: Colors.orange,
                              index: 3,
                            ),
                          ),
                          StreamBuilder<int>(
                            stream: productsStream,
                            builder: (ctx, snap) => _infoCard(
                              ctx,
                              icon: Icons.shopping_bag_rounded,
                              label: 'Products',
                              snapshot: snap,
                              color: Colors.green,
                              index: 4,
                            ),
                          ),
                          StreamBuilder<int>(
                            stream: FirebaseFirestore.instance
                                .collection('delivery_boys')
                                .snapshots()
                                .map((s) => s.docs.length),
                            builder: (ctx, snap) => _infoCard(
                              ctx,
                              icon: Icons.motorcycle_rounded,
                              label: 'Delivery Boys',
                              snapshot: snap,
                              color: Colors.indigo,
                              index: 5,
                            ),
                          ),
                          StreamBuilder<int>(
                            stream: FirebaseFirestore.instance
                                .collection('delivery_rules')
                                .snapshots()
                                .map((s) => s.docs.length),
                            builder: (ctx, snap) => _infoCard(
                              ctx,
                              icon: Icons.local_shipping_rounded,
                              label: 'Deliv..Chrge..',
                              snapshot: snap,
                              color: Colors.brown,
                              index: 6,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
