// import 'package:flutter/material.dart';

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const Center(
//       child: Text('Home Screen', style: TextStyle(fontSize: 24)),
//     );
//   }
// }

import 'package:blinkit_clone/screens/addresses_screen.dart';
import 'package:blinkit_clone/sub_screens/grocery_screen.dart';
import 'package:blinkit_clone/sub_screens/search_screen.dart';
import 'package:blinkit_clone/widgets/account_screen.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/banner_provider.dart';
import '../sub_screens/banner_products_screen.dart';
import '../providers/category_provider.dart';
import '../providers/user_provider.dart';
import '../providers/product_provider.dart';
import '../providers/notification_provider.dart';
import '../screens/notifications_screen.dart';
import '../sub_screens/product_card.dart';
import '../utils/db_seeder.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final PageController _bannerController;
  Timer? _bannerTimer;
  int _currentBannerIndex = 0;
  String _selectedSort = 'default'; // 'default', 'low_to_high', 'high_to_low'
  bool _filterRating = false;
  bool _filterTime = false;
  bool _filterOffers = false;
  String _selectedVegFilter = 'all'; // 'all', 'veg', 'non_veg'

  static const Duration _kAutoScrollDuration = Duration(seconds: 4);
  static const Duration _kPageAnimationDuration = Duration(milliseconds: 600);
  static const Curve _kPageAnimationCurve = Curves.easeInOut;
  @override
  void initState() {
    super.initState();
    // Fetch banners when the screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<BannerProvider>(context, listen: false);
      provider.fetchBanners();
      // also fetch categories for the categories section
      final catProvider = Provider.of<CategoryProvider>(context, listen: false);
      catProvider.fetchCategories();
      // fetch products for the recommended dishes section
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      productProvider.fetchProducts();
      // ensure user data (addresses) is initialized so address shows up
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.initialize();

      // Initialize real-time notification listeners
      try {
        final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
        notificationProvider.listenToProducts();
        final currentUser = userProvider.getCurrentUser();
        if (currentUser != null) {
          notificationProvider.listenToOrders(currentUser.uid);
        }
      } catch (e) {
        debugPrint('Error starting notification listeners in initState: $e');
      }

      // Trigger database seeder sequentially to write seed flag documents
      DatabaseSeeder.seedVegMenuFromCsv(context: context).then((_) {
        if (mounted) {
          DatabaseSeeder.seedNonVegMenuFromCsv(context: context);
        }
      });
    });

    _bannerController = PageController(viewportFraction: 0.92);
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  void _startBannerAutoScroll(int itemCount) {
    _bannerTimer?.cancel();
    if (itemCount <= 1) return;
    _bannerTimer = Timer.periodic(_kAutoScrollDuration, (_) {
      if (!_bannerController.hasClients) return;
      final next = (_currentBannerIndex + 1) % itemCount;
      _bannerController.animateToPage(
        next,
        duration: _kPageAnimationDuration,
        curve: _kPageAnimationCurve,
      );
    });
  }

  void _stopBannerAutoScroll() {
    _bannerTimer?.cancel();
    _bannerTimer = null;
  }

  Widget _buildCategoryItem({
    required String name,
    required Widget child,
    required bool isSelected,
    required VoidCallback onTap,
    bool isGrid = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(right: isGrid ? 0.0 : 18.0),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: isGrid ? 60 : 65,
              height: isGrid ? 60 : 65,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: child,
            ),
            const SizedBox(height: 6),
            Text(
              name,
              textAlign: isGrid ? TextAlign.center : TextAlign.start,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: isGrid ? 11 : 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(height: 4),
              Container(
                width: 15,
                height: 2,
                color: const Color(0xFFE23744),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Sort by",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Default", style: TextStyle(fontWeight: FontWeight.w500)),
                trailing: _selectedSort == 'default'
                    ? const Icon(Icons.check_circle, color: Color(0xFFE23744))
                    : null,
                onTap: () {
                  setState(() => _selectedSort = 'default');
                  Navigator.pop(ctx);
                },
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Price: Low to High", style: TextStyle(fontWeight: FontWeight.w500)),
                trailing: _selectedSort == 'low_to_high'
                    ? const Icon(Icons.check_circle, color: Color(0xFFE23744))
                    : null,
                onTap: () {
                  setState(() => _selectedSort = 'low_to_high');
                  Navigator.pop(ctx);
                },
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Price: High to Low", style: TextStyle(fontWeight: FontWeight.w500)),
                trailing: _selectedSort == 'high_to_low'
                    ? const Icon(Icons.check_circle, color: Color(0xFFE23744))
                    : null,
                onTap: () {
                  setState(() => _selectedSort = 'high_to_low');
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Filters & Sort",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setModalState(() {
                              _selectedSort = 'default';
                              _filterRating = false;
                              _filterTime = false;
                              _filterOffers = false;
                              _selectedVegFilter = 'all';
                            });
                            setState(() {});
                          },
                          child: const Text(
                            "Clear All",
                            style: TextStyle(color: Color(0xFFE23744), fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Sort by",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedSort,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'default', child: Text("Default")),
                        DropdownMenuItem(value: 'low_to_high', child: Text("Price: Low to High")),
                        DropdownMenuItem(value: 'high_to_low', child: Text("Price: High to Low")),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => _selectedSort = val);
                          setState(() {});
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Filter by",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
                    ),
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      activeColor: const Color(0xFFE23744),
                      title: const Text("Rating 4.0+", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                      value: _filterRating,
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => _filterRating = val);
                          setState(() {});
                        }
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                    CheckboxListTile(
                      activeColor: const Color(0xFFE23744),
                      title: const Text("20-30 min delivery", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                      value: _filterTime,
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => _filterTime = val);
                          setState(() {});
                        }
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                    CheckboxListTile(
                      activeColor: const Color(0xFFE23744),
                      title: const Text("Offers & Discounts", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                      value: _filterOffers,
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => _filterOffers = val);
                          setState(() {});
                        }
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Food Preference",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ChoiceChip(
                          label: const Text("All"),
                          selected: _selectedVegFilter == 'all',
                          selectedColor: const Color(0xFFFFEBEB),
                          checkmarkColor: const Color(0xFFE23744),
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color: _selectedVegFilter == 'all' ? const Color(0xFFE23744) : Colors.grey.shade300,
                          ),
                          labelStyle: TextStyle(
                            color: _selectedVegFilter == 'all' ? const Color(0xFFE23744) : Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          onSelected: (val) {
                            if (val) {
                              setModalState(() => _selectedVegFilter = 'all');
                              setState(() {});
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text("Veg 🟢"),
                          selected: _selectedVegFilter == 'veg',
                          selectedColor: const Color(0xFFFFEBEB),
                          checkmarkColor: const Color(0xFFE23744),
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color: _selectedVegFilter == 'veg' ? const Color(0xFFE23744) : Colors.grey.shade300,
                          ),
                          labelStyle: TextStyle(
                            color: _selectedVegFilter == 'veg' ? const Color(0xFFE23744) : Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          onSelected: (val) {
                            if (val) {
                              setModalState(() => _selectedVegFilter = 'veg');
                              setState(() {});
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text("Non-Veg 🔴"),
                          selected: _selectedVegFilter == 'non_veg',
                          selectedColor: const Color(0xFFFFEBEB),
                          checkmarkColor: const Color(0xFFE23744),
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color: _selectedVegFilter == 'non_veg' ? const Color(0xFFE23744) : Colors.grey.shade300,
                          ),
                          labelStyle: TextStyle(
                            color: _selectedVegFilter == 'non_veg' ? const Color(0xFFE23744) : Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          onSelected: (val) {
                            if (val) {
                              setModalState(() => _selectedVegFilter = 'non_veg');
                              setState(() {});
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE23744),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                        },
                        child: const Text(
                          "Apply Filters",
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
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
  }

  Widget _buildFilterChip(
    String label, {
    bool hasDropdown = false,
    bool hasTagIcon = false,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(
            color: isActive ? const Color(0xFFE23744) : Colors.grey.shade300,
            width: isActive ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
          color: isActive ? const Color(0xFFFFEBEB) : Colors.white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasTagIcon) ...[
              Icon(
                Icons.local_offer_outlined,
                size: 14,
                color: isActive ? const Color(0xFFE23744) : Colors.black54,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? const Color(0xFFE23744) : Colors.black87,
              ),
            ),
            if (hasDropdown) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down,
                size: 14,
                color: isActive ? const Color(0xFFE23744) : Colors.black54,
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFBF9),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top Header: location, notification icon, profile icon
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Location selector
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddressesScreen(),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFEBEB), // light pink
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.location_on,
                              color: Color(0xFFE23744), // Zomato red
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Text(
                                    'Deliver to',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(width: 2),
                                  Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Colors.grey,
                                    size: 14,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Consumer<UserProvider>(
                                builder: (context, userProv, _) {
                                  final user = userProv.user;
                                  String addressText = 'Search for a location';
                                  if (user != null &&
                                      user.addresses.isNotEmpty) {
                                    final a = user.addresses.first;
                                    final parts = <String>[];
                                    if (a.area.isNotEmpty) parts.add(a.area);
                                    if (a.city.isNotEmpty) parts.add(a.city);
                                    addressText = parts.join(', ');
                                  }

                                  return Text(
                                    addressText.length > 20
                                        ? '${addressText.substring(0, 20)}...'
                                        : addressText,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Action Icons
                    Row(
                      children: [
                        Consumer<NotificationProvider>(
                          builder: (context, notifProv, _) {
                            final count = notifProv.unreadCount;
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const NotificationsScreen(),
                                  ),
                                );
                              },
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  const Icon(
                                    Icons.notifications_none_outlined,
                                    color: Colors.black87,
                                    size: 26,
                                  ),
                                  if (count > 0)
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
                                            '$count',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 8,
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
                        const SizedBox(width: 14),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AccountScreen(),
                              ),
                            );
                          },
                          child: const Icon(
                            Icons.person_outline,
                            color: Colors.black87,
                            size: 26,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            // Search Bar Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SearchScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.search,
                              color: Colors.grey,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Search for restaurants, cuisines, or dishes...',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Filter Tune icon button
                  GestureDetector(
                    onTap: _showFilterBottomSheet,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEB), // light pink
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.tune,
                        color: Color(0xFFE23744), // Zomato red
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Delivery Promo Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFA5757), Color(0xFFFA7C30)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFA5757).withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Left Text Details
                    Expanded(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.flash_on,
                                  color: Colors.orange.shade800,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'LIGHTNING FAST',
                                  style: TextStyle(
                                    color: Colors.orange.shade800,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Food delivery\nin 20 minutes',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Hot meals. Fast delivery.\nRight at your door.',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text(
                                  'Order Now',
                                  style: TextStyle(
                                    color: Color(0xFFE23744),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward,
                                  color: Color(0xFFE23744),
                                  size: 14,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Right image with overlay circular badge
                    Expanded(
                      flex: 5,
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.centerRight,
                        children: [
                          Image.asset(
                            'assets/delivery_rider.png',
                            height: 110,
                            fit: BoxFit.contain,
                          ),
                          Positioned(
                            top: -10,
                            right: -5,
                            child: Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.orange.shade100,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text(
                                    '20',
                                    style: TextStyle(
                                      color: Color(0xFFE23744),
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      height: 1.1,
                                    ),
                                  ),
                                  Text(
                                    'MIN',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 7,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            // banner widget
            SizedBox(
              height: 170,
              child: Consumer<BannerProvider>(
                builder: (context, bannerProv, _) {
                  if (bannerProv.isLoading) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    );
                  }

                  final banners = bannerProv.banners;
                  if (banners.isEmpty) {
                    return Center(
                      child: Text(
                        'No banners available',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  // ensure auto-scroll starts when banners are available
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _startBannerAutoScroll(banners.length);
                  });

                  return Column(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTapDown: (_) => _stopBannerAutoScroll(),
                          onTapUp: (_) =>
                              _startBannerAutoScroll(banners.length),
                          onTapCancel: () =>
                              _startBannerAutoScroll(banners.length),
                          child: PageView.builder(
                            controller: _bannerController,
                            itemCount: banners.length,
                            onPageChanged: (idx) {
                              setState(() => _currentBannerIndex = idx);
                            },
                            itemBuilder: (context, index) {
                              final b = banners[index];
                              return AnimatedBuilder(
                                animation: _bannerController,
                                builder: (context, child) {
                                  double value = 1.0;
                                  if (_bannerController.hasClients &&
                                      _bannerController
                                          .position
                                          .haveDimensions) {
                                    final page =
                                        _bannerController.page ??
                                        _bannerController.initialPage
                                            .toDouble();
                                    final raw =
                                        1 - ((page - index).abs() * 0.12);
                                    value = raw.clamp(0.88, 1.0).toDouble();
                                  }
                                  return Transform.scale(
                                    scale: value,
                                    child: child,
                                  );
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      // only navigate when this banner has products
                                      if (b.products.isNotEmpty) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (ctx) =>
                                                BannerProductsScreen(
                                                  productIds: b.products,
                                                ),
                                          ),
                                        );
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        image: DecorationImage(
                                          image: NetworkImage(b.bannerImage),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // indicators
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(banners.length, (i) {
                          final isActive = i == _currentBannerIndex;
                          return AnimatedContainer(
                            duration: Duration(milliseconds: 350),
                            margin: EdgeInsets.symmetric(horizontal: 4),
                            width: isActive ? 18 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isActive ? Colors.white : Colors.white54,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          );
                        }),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            // Main Categories Grid section
            Consumer<CategoryProvider>(
              builder: (context, catProv, _) {
                if (catProv.isLoading) {
                  return const SizedBox(
                    height: 110,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final supCats = catProv.categories;
                if (supCats.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: supCats.map((supCat) {
                    final subCats = supCat.categories;
                    if (subCats.isEmpty) return const SizedBox.shrink();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 12.0),
                          child: Text(
                            supCat.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: subCats.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.75,
                            ),
                            itemBuilder: (context, index) {
                              final subCat = subCats[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => GroceryScreen(
                                        selectedCategory: subCat,
                                        superCategoryName: supCat.name,
                                      ),
                                    ),
                                  );
                                },
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF4F6F8),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: subCat.image.startsWith('http')
                                              ? Image.network(
                                                  subCat.image,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) => const Center(
                                                    child: Icon(Icons.restaurant, color: Color(0xFFE23744), size: 24),
                                                  ),
                                                )
                                              : Image.asset(
                                                  subCat.image,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) => const Center(
                                                    child: Icon(Icons.restaurant, color: Color(0xFFE23744), size: 24),
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      subCat.name,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                        height: 1.1,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 5),

            // Filters Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildFilterChip(
                      _selectedSort == 'default'
                          ? "Sort"
                          : (_selectedSort == 'low_to_high'
                              ? "Sort: Low to High"
                              : "Sort: High to Low"),
                      hasDropdown: true,
                      isActive: _selectedSort != 'default',
                      onTap: _showSortBottomSheet,
                    ),
                    _buildFilterChip(
                      "All",
                      isActive: _selectedVegFilter == 'all',
                      onTap: () {
                        setState(() {
                          _selectedVegFilter = 'all';
                        });
                      },
                    ),
                    _buildFilterChip(
                      "Veg 🟢",
                      isActive: _selectedVegFilter == 'veg',
                      onTap: () {
                        setState(() {
                          _selectedVegFilter = 'veg';
                        });
                      },
                    ),
                    _buildFilterChip(
                      "Non-Veg 🔴",
                      isActive: _selectedVegFilter == 'non_veg',
                      onTap: () {
                        setState(() {
                          _selectedVegFilter = 'non_veg';
                        });
                      },
                    ),
                    _buildFilterChip(
                      "Rating 4.0+",
                      isActive: _filterRating,
                      onTap: () {
                        setState(() {
                          _filterRating = !_filterRating;
                        });
                      },
                    ),
                    _buildFilterChip(
                      "20-30 min",
                      isActive: _filterTime,
                      onTap: () {
                        setState(() {
                          _filterTime = !_filterTime;
                        });
                      },
                    ),
                    _buildFilterChip(
                      "Offers",
                      hasTagIcon: true,
                      isActive: _filterOffers,
                      onTap: () {
                        setState(() {
                          _filterOffers = !_filterOffers;
                        });
                      },
                    ),
                    // Filter sliders icon button
                    GestureDetector(
                      onTap: _showFilterBottomSheet,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                        child: const Icon(
                          Icons.tune,
                          size: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Popular Near You section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Popular near you',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GroceryScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'See all',
                      style: TextStyle(
                        color: Color(0xFFE23744),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Product Grid / Feed
            Consumer<ProductProvider>(
              builder: (context, prodProv, _) {
                if (prodProv.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final products = prodProv.products;
                final foodProducts = products.where((p) => p.restaurantName == "The Urban Bite").toList();
                final displayProducts = foodProducts.isNotEmpty ? foodProducts : products;

                List<ProductModel> filtered = displayProducts.toList();

                if (_selectedVegFilter == 'veg') {
                  filtered = filtered.where((p) => p.isVeg).toList();
                } else if (_selectedVegFilter == 'non_veg') {
                  filtered = filtered.where((p) => !p.isVeg).toList();
                }

                if (_filterRating) {
                  filtered = filtered.where((p) => p.rating >= 4.0).toList();
                }

                if (_filterTime) {
                  filtered = filtered.where((p) => p.deliveryTime >= 20 && p.deliveryTime <= 30).toList();
                }

                if (_filterOffers) {
                  filtered = filtered.where((p) => p.discountPercent > 0).toList();
                }

                if (_selectedSort == 'low_to_high') {
                  filtered.sort((a, b) {
                    final aPrice = a.price * (1 - a.discountPercent / 100);
                    final bPrice = b.price * (1 - b.discountPercent / 100);
                    return aPrice.compareTo(bPrice);
                  });
                } else if (_selectedSort == 'high_to_low') {
                  filtered.sort((a, b) {
                    final aPrice = a.price * (1 - a.discountPercent / 100);
                    final bPrice = b.price * (1 - b.discountPercent / 100);
                    return bPrice.compareTo(aPrice);
                  });
                }

                if (filtered.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Center(child: Text('No matching dishes available')),
                  );
                }

                final recommendedDishes = filtered.take(6).toList();

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recommendedDishes.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 15,
                      crossAxisSpacing: 15,
                      childAspectRatio: 0.72,
                    ),
                    itemBuilder: (context, index) {
                      final p = recommendedDishes[index];
                      return ProductCard(product: p);
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
     ),
    );
  }
}





