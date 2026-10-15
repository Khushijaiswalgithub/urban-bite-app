import 'package:blinkit_clone/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'main_screen.dart';
import 'map_picker_screen.dart';

class AddressScreen extends StatefulWidget {
  final String phoneNumber;

  const AddressScreen({super.key, required this.phoneNumber});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _houseController = TextEditingController();
  final _areaController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _landmarkController = TextEditingController();

  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  String _selectedAddressType = 'Home';
  final List<String> _addressTypes = ['Home', 'Work', 'Other'];

  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimations();
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

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
  }

  void _startAnimations() {
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _slideController.forward();
    });
  }

  void _setupFocusListeners() {
    for (var node in _focusNodes) {
      node.addListener(() {
        setState(() {});
      });
    }
  }

  void _submitAddress() async {
    if (!_formKey.currentState!.validate()) return;

    HapticFeedback.selectionClick();

    try {
      final address = AddressModel(
        house: _houseController.text.trim(),
        area: _areaController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        pincode: _pincodeController.text.trim(),
      );

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.addAddress(address);

      if (!mounted) return;

      // Show success feedback
      HapticFeedback.heavyImpact();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white),
              const SizedBox(width: 8),
              const Text('Address saved successfully'),
            ],
          ),
          backgroundColor: const Color(0xFFE23744),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const MainScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0, 0.1),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(parent: animation, curve: Curves.easeOut),
                    ),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              const Text('Error saving address'),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  // void _submitAddress() async {
  //   if (!_formKey.currentState!.validate()) return;

  //   setState(() {
  //     _isLoading = true;
  //   });

  //   HapticFeedback.selectionClick();

  //   try {
  //     final address =
  //         '${_houseController.text}, ${_areaController.text}, '
  //         '${_cityController.text}, ${_stateController.text} - ${_pincodeController.text}';

  //     final userProvider = Provider.of<UserProvider>(context, listen: false);
  //     await userProvider.addAddress(address);

  //     if (!mounted) return;

  //     // Show success feedback
  //     HapticFeedback.heavyImpact();

  //     Navigator.pushReplacement(
  //       context,
  //       PageRouteBuilder(
  //         pageBuilder: (context, animation, secondaryAnimation) =>
  //             const MainScreen(),
  //         transitionsBuilder: (context, animation, secondaryAnimation, child) {
  //           return FadeTransition(
  //             opacity: animation,
  //             child: SlideTransition(
  //               position:
  //                   Tween<Offset>(
  //                     begin: const Offset(0, 0.1),
  //                     end: Offset.zero,
  //                   ).animate(
  //                     CurvedAnimation(parent: animation, curve: Curves.easeOut),
  //                   ),
  //               child: child,
  //             ),
  //           );
  //         },
  //         transitionDuration: const Duration(milliseconds: 500),
  //       ),
  //     );
  //   } catch (e) {
  //     if (!mounted) return;
  //     HapticFeedback.heavyImpact();
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Row(
  //           children: [
  //             const Icon(Icons.error_outline, color: Colors.white),
  //             const SizedBox(width: 8),
  //             const Text('Error saving address'),
  //           ],
  //         ),
  //         backgroundColor: Colors.red.shade600,
  //         behavior: SnackBarBehavior.floating,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(12),
  //         ),
  //         margin: const EdgeInsets.all(16),
  //       ),
  //     );
  //   }

  //   setState(() {
  //     _isLoading = false;
  //   });
  // }

  void _useCurrentLocation() {
    // Simulate getting current location
    HapticFeedback.selectionClick();

    // Show loading state
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Color(0xFFE23744)),
            const SizedBox(height: 16),
            const Text('Getting your location...'),
          ],
        ),
      ),
    );

    // Simulate location fetch
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);

      // Fill dummy location data
      _areaController.text = 'MG Road';
      _cityController.text = 'Gorakhpur';
      _stateController.text = 'Uttar Pradesh';
      _pincodeController.text = '273001';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white),
              const SizedBox(width: 8),
              const Text('Location detected successfully!'),
            ],
          ),
          backgroundColor: const Color(0xFFE23744),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );

      setState(() {});
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _houseController.dispose();
    _areaController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _landmarkController.dispose();

    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFBF9),
      resizeToAvoidBottomInset:
          true, // Important: This ensures proper keyboard handling
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        leadingWidth: 56,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF0F0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Color(0xFFE23744),
                  size: 20,
                ),
              ),
            ),
          ),
        ),
        toolbarHeight: 80,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Delivery Address',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Help us deliver your order to the right place',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.grey.shade200,
            height: 1,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 8.0,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      constraints.maxHeight -
                      16, // Account for vertical padding
                ),
                child: IntrinsicHeight(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 12),

                            // Current location button
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  // Open map picker and await selected address
                                  final result =
                                      await Navigator.push<AddressModel?>(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const MapPickerScreen(),
                                        ),
                                      );

                                  if (result != null) {
                                    // populate fields
                                    _houseController.text = result.house;
                                    _areaController.text = result.area;
                                    _cityController.text = result.city;
                                    _stateController.text = result.state;
                                    _pincodeController.text = result.pincode;

                                    // Save address using provider
                                    try {
                                      final userProvider =
                                          Provider.of<UserProvider>(
                                            context,
                                            listen: false,
                                          );
                                      await userProvider.addAddress(result);

                                      if (!mounted) return;

                                      HapticFeedback.heavyImpact();
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Row(
                                            children: [
                                              const Icon(
                                                Icons.check_circle_outline,
                                                color: Colors.white,
                                              ),
                                              const SizedBox(width: 8),
                                              const Text(
                                                'Location saved successfully',
                                              ),
                                            ],
                                          ),
                                          backgroundColor: const Color(
                                            0xFFE23744,
                                          ),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          margin: const EdgeInsets.all(16),
                                        ),
                                      );

                                      Navigator.pushReplacement(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder:
                                              (
                                                context,
                                                animation,
                                                secondaryAnimation,
                                              ) => const MainScreen(),
                                          transitionsBuilder:
                                              (
                                                context,
                                                animation,
                                                secondaryAnimation,
                                                child,
                                              ) {
                                                return FadeTransition(
                                                  opacity: animation,
                                                  child: SlideTransition(
                                                    position:
                                                        Tween<Offset>(
                                                          begin: const Offset(
                                                            0,
                                                            0.1,
                                                          ),
                                                          end: Offset.zero,
                                                        ).animate(
                                                          CurvedAnimation(
                                                            parent: animation,
                                                            curve:
                                                                Curves.easeOut,
                                                          ),
                                                        ),
                                                    child: child,
                                                  ),
                                                );
                                              },
                                          transitionDuration: const Duration(
                                            milliseconds: 500,
                                          ),
                                        ),
                                      );
                                    } catch (e) {
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Row(
                                            children: [
                                              const Icon(
                                                Icons.error_outline,
                                                color: Colors.white,
                                              ),
                                              const SizedBox(width: 8),
                                              const Text(
                                                'Error saving location',
                                              ),
                                            ],
                                          ),
                                          backgroundColor: Colors.red.shade600,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          margin: const EdgeInsets.all(16),
                                        ),
                                      );
                                    }
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  side: const BorderSide(
                                    color: Color(0xFFE23744),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.my_location,
                                  color: Color(0xFFE23744),
                                ),
                                label: const Text(
                                  'Use Current Location',
                                  style: TextStyle(
                                    color: Color(0xFFE23744),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Divider with text
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(color: Colors.grey.shade300),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Text(
                                    'OR ENTER MANUALLY',
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(color: Colors.grey.shade300),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Address Type Selection
                            const Text(
                              'Address Type',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2E2E2E),
                              ),
                            ),

                            const SizedBox(height: 12),

                            Row(
                              children: _addressTypes.map((type) {
                                final isSelected = _selectedAddressType == type;
                                final isLast = type == _addressTypes.last;

                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedAddressType = type;
                                      });
                                      HapticFeedback.selectionClick();
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      margin: EdgeInsets.only(
                                        right: isLast ? 0 : 8,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? const Color(0xFFFFF0F0)
                                            : Colors.white,
                                        border: Border.all(
                                          color: isSelected
                                              ? const Color(0xFFE23744)
                                              : Colors.grey.shade300,
                                          width: isSelected ? 1.5 : 1,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            type == 'Home'
                                                ? Icons.home
                                                : type == 'Work'
                                                ? Icons.work
                                                : Icons.location_on,
                                            size: 16,
                                            color: isSelected
                                                ? const Color(0xFFE23744)
                                                : Colors.grey.shade600,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            type,
                                            style: TextStyle(
                                              color: isSelected
                                                  ? const Color(0xFFE23744)
                                                  : Colors.grey.shade600,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 24),

                            // Form fields
                            _buildTextField(
                              controller: _houseController,
                              focusNode: _focusNodes[0],
                              label: 'House/Flat Number *',
                              hint: 'e.g., 123, Block A',
                              icon: Icons.home_outlined,
                              validator: (value) =>
                                  value?.trim().isEmpty ?? true
                                  ? 'House number is required'
                                  : null,
                            ),

                            const SizedBox(height: 20),

                            _buildTextField(
                              controller: _areaController,
                              focusNode: _focusNodes[1],
                              label: 'Area/Street *',
                              hint: 'e.g., MG Road, Sector 15',
                              icon: Icons.location_city_outlined,
                              validator: (value) =>
                                  value?.trim().isEmpty ?? true
                                  ? 'Area is required'
                                  : null,
                            ),

                            const SizedBox(height: 20),

                            _buildTextField(
                              controller: _landmarkController,
                              focusNode: _focusNodes[2],
                              label: 'Nearby Landmark (Optional)',
                              hint: 'e.g., Near City Mall',
                              icon: Icons.place_outlined,
                            ),

                            const SizedBox(height: 20),

                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: _cityController,
                                    focusNode: _focusNodes[3],
                                    label: 'City *',
                                    hint: 'Enter city',
                                    icon: Icons.location_city,
                                    validator: (value) =>
                                        value?.trim().isEmpty ?? true
                                        ? 'City is required'
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _stateController,
                                    focusNode: _focusNodes[4],
                                    label: 'State *',
                                    hint: 'Enter state',
                                    icon: Icons.map_outlined,
                                    validator: (value) =>
                                        value?.trim().isEmpty ?? true
                                        ? 'State is required'
                                        : null,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            _buildTextField(
                              controller: _pincodeController,
                              focusNode: _focusNodes[5],
                              label: 'PIN Code *',
                              hint: 'Enter 6-digit PIN code',
                              icon: Icons.pin_drop_outlined,
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              validator: (value) {
                                if (value?.trim().isEmpty ?? true)
                                  return 'PIN code is required';
                                if (value!.length != 6)
                                  return 'PIN code must be 6 digits';
                                return null;
                              },
                            ),

                            const SizedBox(height: 32),

                            // Save button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed:
                                    context.watch<UserProvider>().isLoading
                                    ? null
                                    : _submitAddress,
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white.withOpacity(
                                                      0.8,
                                                    ),
                                                  ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          const Text(
                                            'Saving Address...',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      )
                                    : const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.check_circle, size: 20),
                                          SizedBox(width: 8),
                                          Text(
                                            'Save & Continue',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Privacy note
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF0F0),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFFFD6D6)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.security,
                                    color: Color(0xFFE23744),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Your address is encrypted and secure. We only use it for delivery purposes.',
                                      style: TextStyle(
                                        color: const Color(0xFF8C2D37),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Extra spacing at the bottom for keyboard
                            SizedBox(
                              height:
                                  MediaQuery.of(context).viewInsets.bottom + 40,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
  }) {
    final isFocused = focusNode.hasFocus;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2E2E2E),
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: const Color(0xFFE23744).withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            maxLength: maxLength,
            validator: validator,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2E2E2E),
            ),
            decoration: InputDecoration(
              counterText: '',
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Icon(
                icon,
                color: isFocused
                    ? const Color(0xFFE23744)
                    : Colors.grey.shade400,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFE23744),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red.shade600),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red.shade600, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            inputFormatters: keyboardType == TextInputType.number
                ? [FilteringTextInputFormatter.digitsOnly]
                : null,
          ),
        ),
      ],
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../providers/user_provider.dart';
// import 'main_screen.dart';

// class AddressScreen extends StatefulWidget {
//   final String phoneNumber;

//   const AddressScreen({super.key, required this.phoneNumber});

//   @override
//   State<AddressScreen> createState() => _AddressScreenState();
// }

// class _AddressScreenState extends State<AddressScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _houseController = TextEditingController();
//   final _areaController = TextEditingController();
//   final _cityController = TextEditingController();
//   final _stateController = TextEditingController();
//   final _pincodeController = TextEditingController();
//   bool _isLoading = false;

//   void _submitAddress() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final address =
//           '${_houseController.text}, ${_areaController.text}, '
//           '${_cityController.text}, ${_stateController.text} - ${_pincodeController.text}';

//       final userProvider = Provider.of<UserProvider>(context, listen: false);
//       await userProvider.addAddress(address);

//       if (!mounted) return;
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const MainScreen()),
//       );
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Error saving address')));
//     }

//     setState(() {
//       _isLoading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Add Delivery Address'),
//         backgroundColor: Colors.green,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               TextFormField(
//                 controller: _houseController,
//                 decoration: const InputDecoration(
//                   labelText: 'House/Flat Number',
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) =>
//                     value?.isEmpty ?? true ? 'Required field' : null,
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _areaController,
//                 decoration: const InputDecoration(
//                   labelText: 'Area/Street',
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) =>
//                     value?.isEmpty ?? true ? 'Required field' : null,
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _cityController,
//                 decoration: const InputDecoration(
//                   labelText: 'City',
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) =>
//                     value?.isEmpty ?? true ? 'Required field' : null,
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _stateController,
//                 decoration: const InputDecoration(
//                   labelText: 'State',
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) =>
//                     value?.isEmpty ?? true ? 'Required field' : null,
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _pincodeController,
//                 keyboardType: TextInputType.number,
//                 maxLength: 6,
//                 decoration: const InputDecoration(
//                   labelText: 'PIN Code',
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) {
//                   if (value?.isEmpty ?? true) return 'Required field';
//                   if (value!.length != 6) return 'PIN code must be 6 digits';
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 30),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _isLoading ? null : _submitAddress,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                   ),
//                   child: _isLoading
//                       ? const CircularProgressIndicator(color: Colors.white)
//                       : const Text(
//                           'Save & Continue',
//                           style: TextStyle(fontSize: 16, color: Colors.white),
//                         ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }





