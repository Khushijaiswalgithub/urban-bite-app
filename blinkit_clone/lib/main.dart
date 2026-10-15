import 'package:blinkit_clone/providers/cart_provider.dart';
import 'package:blinkit_clone/providers/wishlist_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/user_provider.dart';
import 'providers/banner_provider.dart';
import 'providers/product_provider.dart';
import 'providers/category_provider.dart';
import 'providers/order_provider.dart';
import 'providers/notification_provider.dart';
import 'services/notification_service.dart';
import 'screens/splash_screen.dart';
import 'utils/db_seeder.dart';
 
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Show a temporary loading screen to clear the native splash screen
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator(color: Color(0xFFE23744)),
      ),
    ),
  ));

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    debugPrint("Firebase init error: $e");
  }

  // Initialize native notifications service without awaiting to prevent permission dialog blocks
  NotificationService.init();

  
  // Load the actual app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => BannerProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MaterialApp(
        title: 'The Urban Bite',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE23744)),
          primaryColor: const Color(0xFFE23744),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}




