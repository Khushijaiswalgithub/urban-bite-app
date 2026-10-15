// Main entry with Firebase init, Provider setup, Material 3 theme, and routing
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_app/firebase_options.dart';
import 'package:delivery_app/providers/user_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart' show AuthProvider;
import 'providers/location_provider.dart';
import 'providers/orders_provider.dart';
import 'providers/delivery_boy_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

// TODO: Add firebase_options.dart via FlutterFire CLI and uncomment:
// import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Show a temporary loading screen to clear the native splash screen
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator(color: Color(0xFFFC8019)),
      ),
    ),
  ));

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
    );
  } catch (e) {
    debugPrint("Firebase init error: $e");
  }

  runApp(const DeliveryApp());
}

class DeliveryApp extends StatelessWidget {
  const DeliveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => OrdersProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        // Provider for fetching delivery boy profile details
        ChangeNotifierProvider(create: (_) => DeliveryBoyProvider()),
      ],
      child: MaterialApp(
        title: 'The urban bite Rider',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFFFC8019),
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFFFC8019),
          brightness: Brightness.dark,
        ),
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            if (auth.isLoggedIn) {
              return const HomeScreen();
            }
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
