import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:blinkit_clone/providers/user_provider.dart';
import 'package:blinkit_clone/providers/notification_provider.dart';
import 'package:blinkit_clone/screens/main_screen.dart';
import 'package:blinkit_clone/screens/signup_screen.dart';
import 'dart:async';

class OTPScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const OTPScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> with TickerProviderStateMixin {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  bool _hasError = false;
  int _resendTimer = 30;
  bool _canResend = false;
  Timer? _timer;

  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _shakeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimations();
    _startResendTimer();
    _setupFocusListeners();
  }

  void _initAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 24).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  void _startAnimations() {
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _slideController.forward();
    });
  }

  void _setupFocusListeners() {
    for (int i = 0; i < 6; i++) {
      _focusNodes[i].addListener(() {
        setState(() {});
      });
    }
  }

  void _startResendTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendTimer > 0) {
          _resendTimer--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  void _onOTPChanged(String value, int index) {
    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        _verifyOTP();
      }
    } else {
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }

    setState(() {
      _hasError = false;
    });
  }

  String get _otpCode {
    return _controllers.map((controller) => controller.text).join();
  }

  void _verifyOTP() async {
    if (_otpCode.length != 6) {
      _showError();
      return;
    }

    setState(() {
      _hasError = false;
    });

    HapticFeedback.selectionClick();

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final result = await userProvider.verifyOTP(
        verificationId: widget.verificationId,
        otp: _otpCode,
      );

      if (!result.$1) {
        if (!mounted) return;
        _showError();
        _showErrorSnackBar('Invalid OTP. Please try again.');
        return;
      }

      if (!mounted) return;

      final userExists = await userProvider.checkUserExists(widget.phoneNumber);

      if (!mounted) return;

      if (userExists) {
        _showSuccessSnackBar('Login successful!');

        // Start order status updates listener and send a welcome notification
        final uid = userProvider.getCurrentUser()?.uid;
        if (uid != null) {
          try {
            final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
            notificationProvider.listenToOrders(uid);
            notificationProvider.addNotification(
              title: 'Welcome back to The urban bite! 🎉',
              body: 'Craving something delicious? Start ordering now!',
            );
          } catch (_) {}
        }

        Navigator.pushAndRemoveUntil(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const MainScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: const Duration(milliseconds: 500),
          ),
          (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                SignupScreen(phoneNumber: widget.phoneNumber),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(1.0, 0.0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeInOut,
                          ),
                        ),
                    child: child,
                  );
                },
            transitionDuration: const Duration(milliseconds: 400),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showError();
      _showErrorSnackBar('Invalid OTP. Please try again.');
    }
  }

  void _showError() {
    setState(() {
      _hasError = true;
    });

    HapticFeedback.heavyImpact();
    _shakeController.forward().then((_) {
      _shakeController.reverse();
    });

    // Clear all fields
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  void _resendOTP() async {
    if (!_canResend) return;

    setState(() {
      _canResend = false;
      _resendTimer = 30;
    });

    HapticFeedback.selectionClick();
    _startResendTimer();

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.verifyPhone(
        phoneNumber: widget.phoneNumber,
        onCodeSent: (String newVerificationId) {
          _showSuccessSnackBar('OTP sent successfully!');
        },
        onError: (String error) {
          _showErrorSnackBar('Failed to resend OTP: $error');
        },
        onVerificationComplete: (_) {},
      );
    } catch (e) {
      _showErrorSnackBar('Error resending OTP');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF00C853),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _slideController.dispose();
    _fadeController.dispose();
    _shakeController.dispose();

    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFBF9), // warm premium background
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: Colors.grey.shade100,
              width: 1,
            ),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xFFE23744),
              size: 18,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text(
          'Verify OTP',
          style: TextStyle(
            color: Color(0xFF2E2E2E),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background decorative gradients
          Positioned(
            top: -80,
            left: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFE23744).withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -120,
            right: -120,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFE23744).withOpacity(0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main scrollable content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // OTP Icon with card container
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFE23744),
                                Color(0xFFFF5252),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFE23744).withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.sms_outlined,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 28),

                        const Text(
                          'Verification Code',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF2E2E2E),
                            letterSpacing: -0.5,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'We have sent a verification code to',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w400,
                          ),
                        ),

                        const SizedBox(height: 12),
                        
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE23744).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.phone,
                                color: Color(0xFFE23744),
                                size: 14,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '+91 ${widget.phoneNumber}',
                                style: const TextStyle(
                                  color: Color(0xFFE23744),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 36),

                        // Form card
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                            border: Border.all(
                              color: Colors.grey.shade100,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              // OTP Input Fields with shake animation
                              AnimatedBuilder(
                                animation: _shakeAnimation,
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(
                                      _shakeAnimation.value *
                                          ((_shakeController.value * 4).round() % 2 == 0 ? 1 : -1),
                                      0,
                                    ),
                                    child: child,
                                  );
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: List.generate(6, (index) {
                                    return _buildOTPField(index);
                                  }),
                                ),
                              ),

                              const SizedBox(height: 32),

                              // Verify Button
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: context.watch<UserProvider>().isLoading ||
                                          _otpCode.length != 6
                                      ? null
                                      : _verifyOTP,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFE23744),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    disabledBackgroundColor: Colors.grey.shade300,
                                  ),
                                  child: context.watch<UserProvider>().isLoading
                                      ? Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(
                                                  Colors.white.withOpacity(0.8),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            const Text(
                                              'Verifying...',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: const [
                                            Icon(Icons.verified_user, size: 18),
                                            SizedBox(width: 10),
                                            Text(
                                              'Verify OTP',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Resend OTP Section
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Didn't receive the code? ",
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: _canResend ? _resendOTP : null,
                                    child: Text(
                                      _canResend
                                          ? 'Resend OTP'
                                          : 'Resend in ${_resendTimer}s',
                                      style: TextStyle(
                                        color: _canResend
                                            ? const Color(0xFFE23744)
                                            : Colors.grey.shade400,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        decoration: _canResend
                                            ? TextDecoration.underline
                                            : null,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOTPField(int index) {
    final isFocused = _focusNodes[index].hasFocus;
    final hasValue = _controllers[index].text.isNotEmpty;

    return Container(
      width: 38,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _hasError
              ? Colors.red.shade400
              : isFocused
                  ? const Color(0xFFE23744)
                  : hasValue
                      ? const Color(0xFFE23744).withOpacity(0.5)
                      : Colors.grey.shade300,
          width: isFocused ? 1.5 : 1,
        ),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: const Color(0xFFE23744).withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: _hasError ? Colors.red.shade600 : const Color(0xFF2E2E2E),
        ),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (value) => _onOTPChanged(value, index),
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:blinkit_clone/screens/main_screen.dart';
// import 'package:blinkit_clone/screens/signup_screen.dart';

// class OTPScreen extends StatefulWidget {
//   final String verificationId;
//   final String phoneNumber;

//   const OTPScreen({
//     super.key,
//     required this.verificationId,
//     required this.phoneNumber,
//   });

//   @override
//   State<OTPScreen> createState() => _OTPScreenState();
// }

// class _OTPScreenState extends State<OTPScreen> {
//   final _otpController = TextEditingController();
//   bool _isLoading = false;

//   void _verifyOTP() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       PhoneAuthCredential credential = PhoneAuthProvider.credential(
//         verificationId: widget.verificationId,
//         smsCode: _otpController.text,
//       );

//       await FirebaseAuth.instance.signInWithCredential(credential);
//       await _checkUserExists();
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Invalid OTP')));
//     }

//     setState(() {
//       _isLoading = false;
//     });
//   }

//   Future<void> _checkUserExists() async {
//     final userDoc = await FirebaseFirestore.instance
//         .collection('users')
//         .doc(widget.phoneNumber)
//         .get();

//     if (!mounted) return;

//     if (userDoc.exists) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const MainScreen()),
//       );
//     } else {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => SignupScreen(phoneNumber: widget.phoneNumber),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Verify OTP'),
//         backgroundColor: Colors.green,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               'Enter the OTP sent to +91 ${widget.phoneNumber}',
//               style: const TextStyle(fontSize: 16),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 20),
//             TextField(
//               controller: _otpController,
//               keyboardType: TextInputType.number,
//               maxLength: 6,
//               decoration: const InputDecoration(
//                 labelText: 'OTP',
//                 hintText: 'Enter 6-digit OTP',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 20),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: _isLoading ? null : _verifyOTP,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.green,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                 ),
//                 child: _isLoading
//                     ? const CircularProgressIndicator(color: Colors.white)
//                     : const Text(
//                         'Verify OTP',
//                         style: TextStyle(fontSize: 16, color: Colors.white),
//                       ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }





