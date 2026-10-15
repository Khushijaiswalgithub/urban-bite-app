import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (!auth.isLoggedIn) {
      return const LoginScreen();
    }

    final screens = [
      const OrdersScreen(),
      // const ImportJsonScreen(),
      // const ExportJsonScreen(),
      const ProfileScreen()
    ];
    final titles = ['Orders','Profile'];

    return Scaffold(
      appBar: AppBar(
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            titles[index],
            key: ValueKey(titles[index]),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        surfaceTintColor: Theme.of(context).colorScheme.background,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            style: IconButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              // Show confirmation dialog
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('CANCEL'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                      ),
                      child: const Text('LOGOUT'),
                    ),
                  ],
                ),
              );

              if (confirmed != true || !mounted) return;

              await context.read<AuthProvider>().signOut();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            tooltip: 'Logout',
          ),
          const SizedBox(width: 8), // Add some padding on the right
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) =>
            FadeTransition(opacity: animation, child: child),
        child: screens[index],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        elevation: 3,
        height: 65,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        animationDuration: const Duration(milliseconds: 500),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(
              Icons.list_alt,
              color: Theme.of(context).colorScheme.primary,
            ),
            label: 'Orders',
          ),
          // NavigationDestination(
          //   icon: const Icon(Icons.file_upload_outlined),
          //   selectedIcon: Icon(
          //     Icons.file_upload,
          //     color: Theme.of(context).colorScheme.primary,
          //   ),
          //   label: 'Import',
          // ),
          // NavigationDestination(
          //   icon: const Icon(Icons.file_download_outlined),
          //   selectedIcon: Icon(
          //     Icons.file_download,
          //     color: Theme.of(context).colorScheme.primary,
          //   ),
          //   label: 'Export',
          // ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: Icon(
              Icons.person,
              color: Theme.of(context).colorScheme.primary,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
