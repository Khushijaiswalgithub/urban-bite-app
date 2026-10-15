// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:provider/provider.dart';
// import '../providers/user_provider.dart';
// import 'phone_login_screen.dart';
// import 'main_screen.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen>
//     with TickerProviderStateMixin {
//   late AnimationController _logoController;
//   late AnimationController _textController;
//   late AnimationController _progressController;
//   late Animation<double> _logoAnimation;
//   late Animation<double> _textAnimation;
//   late Animation<double> _progressAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _initAnimations();
//     _startAnimations();
//     _navigateToMain();
//   }

//   void _initAnimations() {
//     // Logo animation controller
//     _logoController = AnimationController(
//       duration: const Duration(milliseconds: 1000),
//       vsync: this,
//     );

//     // Text animation controller
//     _textController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );

//     // Progress animation controller
//     _progressController = AnimationController(
//       duration: const Duration(milliseconds: 1200),
//       vsync: this,
//     );

//     // Logo scale animation
//     _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
//     );

//     // Text fade animation
//     _textAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _textController, curve: Curves.easeInOut),
//     );

//     // Progress fade animation
//     _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _progressController, curve: Curves.easeIn),
//     );
//   }

//   void _startAnimations() async {
//     // Start logo animation immediately
//     _logoController.forward();

//     // Start text animation after 300ms
//     await Future.delayed(const Duration(milliseconds: 300));
//     if (mounted) _textController.forward();

//     // Start progress animation after 600ms
//     await Future.delayed(const Duration(milliseconds: 300));
//     if (mounted) _progressController.forward();
//   }

//   _navigateToMain() async {
//     // Wait for animations
//     await Future.delayed(const Duration(seconds: 2));

//     // Check if user is logged in
//     final user = FirebaseAuth.instance.currentUser;

//     if (!mounted) return;

//     if (user != null) {
//       // User is logged in, fetch user data using provider
//       final userProvider = Provider.of<UserProvider>(context, listen: false);
//       await userProvider.initialize();

//       if (!mounted) return;

//       Navigator.pushAndRemoveUntil(
//         context,
//         PageRouteBuilder(
//           pageBuilder: (context, animation, secondaryAnimation) =>
//               const MainScreen(),
//           transitionsBuilder: (context, animation, secondaryAnimation, child) {
//             return FadeTransition(opacity: animation, child: child);
//           },
//           transitionDuration: const Duration(milliseconds: 500),
//         ),
//         (route) => false,
//       );
//     } else {
//       // User is not logged in
//       Navigator.pushAndRemoveUntil(
//         context,
//         PageRouteBuilder(
//           pageBuilder: (context, animation, secondaryAnimation) =>
//               const PhoneLoginScreen(),
//           transitionsBuilder: (context, animation, secondaryAnimation, child) {
//             return FadeTransition(opacity: animation, child: child);
//           },
//           transitionDuration: const Duration(milliseconds: 500),
//         ),
//         (route) => false,
//       );
//     }
//   }

//   @override
//   void dispose() {
//     _logoController.dispose();
//     _textController.dispose();
//     _progressController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               Color(0xFF00C853), // Bright green
//               Color(0xFF4CAF50), // Medium green
//               Color(0xFF81C784), // Light green
//             ],
//             stops: [0.0, 0.5, 1.0],
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               // Top section with decorative elements
//               Expanded(
//                 flex: 2,
//                 child: Container(
//                   width: double.infinity,
//                   child: Stack(
//                     children: [
//                       // Decorative circles
//                       Positioned(
//                         top: 50,
//                         right: 30,
//                         child: Container(
//                           width: 80,
//                           height: 80,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             color: Colors.white.withOpacity(0.1),
//                           ),
//                         ),
//                       ),
//                       Positioned(
//                         top: 120,
//                         left: 50,
//                         child: Container(
//                           width: 60,
//                           height: 60,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             color: Colors.white.withOpacity(0.1),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//               // Main content section
//               Expanded(
//                 flex: 3,
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     // App Logo with animation
//                     AnimatedBuilder(
//                       animation: _logoAnimation,
//                       builder: (context, child) {
//                         return Transform.scale(
//                           scale: _logoAnimation.value,
//                           child: Container(
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.black.withOpacity(0.2),
//                                   blurRadius: 20,
//                                   offset: const Offset(0, 10),
//                                 ),
//                               ],
//                             ),
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(75),
//                               child: Container(
//                                 width: 150,
//                                 height: 150,
//                                 color: Colors.white,
//                                 child: Image.asset(
//                                   'assets/logo3.jpeg',
//                                   fit: BoxFit.cover,
//                                   errorBuilder: (context, error, stackTrace) {
//                                     return Container(
//                                       decoration: const BoxDecoration(
//                                         shape: BoxShape.circle,
//                                         color: Colors.white,
//                                       ),
//                                       child: const Icon(
//                                         Icons.shopping_bag,
//                                         size: 80,
//                                         color: Color(0xFF00C853),
//                                       ),
//                                     );
//                                   },
//                                 ),
//                               ),
//                             ),
//                           ),
//                         );
//                       },
//                     ),

//                     const SizedBox(height: 30),

//                     // App Name with animation
//                     AnimatedBuilder(
//                       animation: _textAnimation,
//                       builder: (context, child) {
//                         return Opacity(
//                           opacity: _textAnimation.value,
//                           child: Column(
//                             children: [
//                               const Text(
//                                 'Sandhya Mart',
//                                 style: TextStyle(
//                                   fontSize: 32,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.white,
//                                   letterSpacing: 1.2,
//                                 ),
//                               ),
//                               const SizedBox(height: 8),
//                               Text(
//                                 'Instant Grocery Delivery',
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   color: Colors.white.withOpacity(0.9),
//                                   fontWeight: FontWeight.w400,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     ),
//                   ],
//                 ),
//               ),

//               // Bottom section with loading indicator
//               Expanded(
//                 flex: 2,
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     // Loading Indicator with animation
//                     AnimatedBuilder(
//                       animation: _progressAnimation,
//                       builder: (context, child) {
//                         return Opacity(
//                           opacity: _progressAnimation.value,
//                           child: Column(
//                             children: [
//                               Container(
//                                 padding: const EdgeInsets.all(20),
//                                 decoration: BoxDecoration(
//                                   shape: BoxShape.circle,
//                                   color: Colors.white.withOpacity(0.2),
//                                 ),
//                                 child: const SizedBox(
//                                   width: 40,
//                                   height: 40,
//                                   child: CircularProgressIndicator(
//                                     strokeWidth: 3,
//                                     valueColor: AlwaysStoppedAnimation<Color>(
//                                       Colors.white,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(height: 20),
//                               Text(
//                                 'Loading...',
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   color: Colors.white.withOpacity(0.8),
//                                   fontWeight: FontWeight.w300,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     ),
//                   ],
//                 ),
//               ),

//               // Footer
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 30),
//                 child: Text(
//                   'Version 1.0.0',
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.white.withOpacity(0.6),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/notification_provider.dart';
import 'phone_login_screen.dart';
import 'main_screen.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _progressController;
  late AnimationController _itemsController;
  late AnimationController _shimmerController;
  late AnimationController _floatingController;
  
  late Animation<double> _logoAnimation;
  late Animation<double> _textAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimations();
    _navigateToMain();
  }

  void _initAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _itemsController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _textAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeIn),
    );

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
  }

  void _startAnimations() async {
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) _textController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) _progressController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) _itemsController.forward();
  }

  _navigateToMain() async {
    await Future.delayed(const Duration(milliseconds: 3500));
    final user = FirebaseAuth.instance.currentUser;
    if (!mounted) return;

    if (user != null) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.initialize();
      if (!mounted) return;

      Provider.of<NotificationProvider>(context, listen: false).addNotification(
        title: 'Welcome back to The urban bite! 🎉',
        body: 'Ready to order some delicious food?',
      );

      Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const MainScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
        (route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const PhoneLoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    _itemsController.dispose();
    _shimmerController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE23744), // Zomato Red
              Color(0xFFCB202D),
              Color(0xFFF44336),
              Color(0xFFFF5252),
            ],
            stops: [0.0, 0.3, 0.6, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Animated background patterns
            ...List.generate(8, (index) => _buildFloatingCircle(index)),
            
            // Main content
            SafeArea(
              child: Column(
                children: [
                  // Grocery items floating around top
                  Expanded(
                    flex: 2,
                    child: Stack(
                      children: [
                        _buildFloatingGroceryItem(
                          icon: Icons.local_pizza,
                          top: 40,
                          left: 30,
                          delay: 0,
                        ),
                        _buildFloatingGroceryItem(
                          icon: Icons.lunch_dining,
                          top: 80,
                          right: 40,
                          delay: 500,
                        ),
                        _buildFloatingGroceryItem(
                          icon: Icons.soup_kitchen,
                          top: 140,
                          left: 60,
                          delay: 1000,
                        ),
                        _buildFloatingGroceryItem(
                          icon: Icons.cake,
                          top: 100,
                          right: 90,
                          delay: 1500,
                        ),
                      ],
                    ),
                  ),

                  // Center logo section
                  Expanded(
                    flex: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo with shimmer effect
                        AnimatedBuilder(
                          animation: _logoAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _logoAnimation.value,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Pulsing glow effect
                                  Container(
                                    width: 180,
                                    height: 180,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.white.withOpacity(0.3),
                                          blurRadius: 30,
                                          spreadRadius: 10,
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Logo container
                                  Container(
                                    width: 160,
                                    height: 160,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 5,
                                      ),
                                    ),
                                    child: ClipOval(
                                      child: Image.asset(
                                        'assets/the_urban_bite_logo.png',
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white,
                                            ),
                                            child: const Icon(
                                              Icons.restaurant,
                                              size: 80,
                                              color: Color(0xFFE23744),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  // Shimmer overlay
                                  AnimatedBuilder(
                                    animation: _shimmerAnimation,
                                    builder: (context, child) {
                                      return ClipOval(
                                        child: Container(
                                          width: 160,
                                          height: 160,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Colors.transparent,
                                                Colors.white.withOpacity(0.3),
                                                Colors.transparent,
                                              ],
                                              stops: [
                                                _shimmerAnimation.value - 0.3,
                                                _shimmerAnimation.value,
                                                _shimmerAnimation.value + 0.3,
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 35),

                        // App name with animation
                        AnimatedBuilder(
                          animation: _textAnimation,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _textAnimation.value,
                              child: Transform.translate(
                                offset: Offset(0, 20 * (1 - _textAnimation.value)),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.restaurant,
                                          color: Colors.white,
                                          size: 32,
                                        ),
                                        const SizedBox(width: 12),
                                        const Text(
                                          'The urban bite',
                                          style: TextStyle(
                                            fontSize: 36,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            letterSpacing: 1.5,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black26,
                                                offset: Offset(2, 2),
                                                blurRadius: 4,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    // const SizedBox(height: 2),
                                    // Container(
                                    //   padding: const EdgeInsets.symmetric(
                                    //     horizontal: 20,
                                    //     vertical: 8,
                                    //   ),
                                    //   decoration: BoxDecoration(
                                    //     color: Colors.white.withOpacity(0.2),
                                    //     borderRadius: BorderRadius.circular(20),
                                    //   ),
                                    //   child: Row(
                                    //     mainAxisSize: MainAxisSize.min,
                                    //     children: [
                                    //       const Icon(
                                    //         Icons.shopping_bag_outlined,
                                    //         color: Colors.white,
                                    //         size: 18,
                                    //       ),
                                    //       const SizedBox(width: 8),
                                    //       Text(
                                    //         'Instant Grocery Delivery',
                                    //         style: TextStyle(
                                    //           fontSize: 16,
                                    //           color: Colors.white.withOpacity(0.95),
                                    //           fontWeight: FontWeight.w500,
                                    //         ),
                                    //       ),
                                    //     ],
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // Bottom section with grocery items
                  Expanded(
                    flex: 2,
                    child: Stack(
                      children: [
                        // Bottom floating items
                        _buildFloatingGroceryItem(
                          icon: Icons.restaurant,
                          bottom: 120,
                          left: 30,
                          delay: 800,
                        ),
                        _buildFloatingGroceryItem(
                          icon: Icons.icecream,
                          bottom: 140,
                          right: 50,
                          delay: 1200,
                        ),
                        
                        // Loading indicator
                        Center(
                          child: AnimatedBuilder(
                            animation: _progressAnimation,
                            builder: (context, child) {
                              return Opacity(
                                opacity: _progressAnimation.value,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white.withOpacity(0.2),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 50,
                                          height: 50,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 4,
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      'Preparing your delicious food...',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.white.withOpacity(0.9),
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Footer
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.white.withOpacity(0.7),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Fresh • Fast • Reliable',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Version 1.0.0',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingCircle(int index) {
    final size = 60.0 + (index * 20);
    final top = (index * 80.0) % 600;
    final left = (index * 100.0) % 350;
    
    return AnimatedBuilder(
      animation: _floatingController,
      builder: (context, child) {
        return Positioned(
          top: top + (math.sin(_floatingController.value * 2 * math.pi + index) * 20),
          left: left,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.05),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingGroceryItem({
    required IconData icon,
    double? top,
    double? bottom,
    double? left,
    double? right,
    required int delay,
  }) {
    return AnimatedBuilder(
      animation: _itemsController,
      builder: (context, child) {
        final delayedValue = (_itemsController.value - (delay / 2000)).clamp(0.0, 1.0);
        
        return AnimatedBuilder(
          animation: _floatingController,
          builder: (context, child) {
            return Positioned(
              top: top != null ? top + (math.sin(_floatingController.value * 2 * math.pi + delay) * 10) : null,
              bottom: bottom != null ? bottom + (math.cos(_floatingController.value * 2 * math.pi + delay) * 10) : null,
              left: left,
              right: right,
              child: Transform.scale(
                scale: delayedValue,
                child: Transform.rotate(
                  angle: math.sin(_floatingController.value * 2 * math.pi + delay) * 0.1,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}



