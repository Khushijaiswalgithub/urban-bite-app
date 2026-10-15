import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _mobileFocus = FocusNode();

  bool _isNameEditable = false;
  bool _isEmailEditable = false;

  UserProvider? _userProvider;

  @override
  void initState() {
    super.initState();
    _nameFocus.addListener(_onFocusChange);
    _emailFocus.addListener(_onFocusChange);
    _mobileFocus.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _nameFocus.removeListener(_onFocusChange);
    _emailFocus.removeListener(_onFocusChange);
    _mobileFocus.removeListener(_onFocusChange);
    _nameFocus.dispose();
    _emailFocus.dispose();
    _mobileFocus.dispose();
    _userProvider?.removeListener(_onUserProviderChanged);
    super.dispose();
  }

  void _onUpdateProfile() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final provider =
        _userProvider ?? Provider.of<UserProvider>(context, listen: false);
    provider
        .updateUserProfile(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
        )
        .then((_) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Profile updated')));
          setState(() {
            _isNameEditable = false;
            _isEmailEditable = false;
          });
        })
        .catchError((e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Update failed: $e')));
        });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = Provider.of<UserProvider>(context);
    if (_userProvider != provider) {
      _userProvider?.removeListener(_onUserProviderChanged);
      _userProvider = provider;
      _userProvider?.addListener(_onUserProviderChanged);
      _updateControllersFromUser();
    }
  }

  void _onUserProviderChanged() {
    if (!mounted) return;
    _updateControllersFromUser();
  }

  void _updateControllersFromUser() {
    final u = _userProvider?.user;
    _nameController.text = u?.name ?? '';
    _mobileController.text = (u?.phoneNumber ?? '').replaceFirst('+91', '');
    _emailController.text = u?.email ?? '';
    setState(() {});
  }

  Widget _buildProfileField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    bool readOnly = false,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffix,
    String? prefixText,
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
            readOnly: readOnly,
            keyboardType: keyboardType,
            validator: validator,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2E2E2E),
            ),
            decoration: InputDecoration(
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
              prefixText: prefixText,
              prefixStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2E2E2E),
              ),
              suffixIcon: suffix,
              filled: true,
              fillColor: readOnly ? const Color(0xFFF7F7F7) : Colors.white,
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
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFBF9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        leadingWidth: 72,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Center(
            child: GestureDetector(
              onTap: () => Navigator.of(context).maybePop(),
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
              'Profile',
              style: TextStyle(
                color: Color(0xFF2E2E2E),
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'View and update your profile',
              style: TextStyle(
                color: Colors.grey.shade600,
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
            final maxContentWidth = constraints.maxWidth > 700
                ? 700.0
                : constraints.maxWidth;
            final horizontalPadding = (constraints.maxWidth > 500)
                ? 28.0
                : 16.0;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 18,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        // Avatar
                        Center(
                          child: Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFFE23744).withOpacity(0.2),
                                    width: 2,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: constraints.maxWidth > 400 ? 50 : 40,
                                  backgroundColor: const Color(0xFFE23744),
                                  child: Text(
                                    (_nameController.text.isNotEmpty)
                                        ? _nameController.text[0].toUpperCase()
                                        : 'S',
                                    style: TextStyle(
                                      fontSize: constraints.maxWidth > 400 ? 36 : 28,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 2,
                                right: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFE23744),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Form Container Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Name field
                              _buildProfileField(
                                controller: _nameController,
                                focusNode: _nameFocus,
                                label: 'Name',
                                hint: 'Your name',
                                icon: Icons.person_outline,
                                readOnly: !_isNameEditable,
                                validator: (v) => (v == null || v.trim().isEmpty)
                                    ? 'Please enter a name'
                                    : null,
                                suffix: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _isNameEditable = true;
                                    });
                                    Future.delayed(Duration.zero, () {
                                      FocusScope.of(context).requestFocus(_nameFocus);
                                    });
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(64, 24),
                                  ),
                                  child: const Text(
                                    'CHANGE',
                                    style: TextStyle(
                                      color: Color(0xFFE23744),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Mobile field
                              _buildProfileField(
                                controller: _mobileController,
                                focusNode: _mobileFocus,
                                label: 'Mobile',
                                hint: 'Mobile number',
                                icon: Icons.phone_android_outlined,
                                readOnly: true,
                                prefixText: '+91 ',
                              ),
                              const SizedBox(height: 20),

                              // Email field
                              _buildProfileField(
                                controller: _emailController,
                                focusNode: _emailFocus,
                                label: 'Email',
                                hint: 'Email address',
                                icon: Icons.mail_outline,
                                readOnly: !_isEmailEditable,
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Please enter email';
                                  }
                                  if (!RegExp(r"^[\w-.]+@([\w-]+\.)+[\w-]{2,4}").hasMatch(v.trim())) {
                                    return 'Enter a valid email';
                                  }
                                  return null;
                                },
                                suffix: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _isEmailEditable = true;
                                    });
                                    Future.delayed(Duration.zero, () {
                                      FocusScope.of(context).requestFocus(_emailFocus);
                                    });
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(64, 24),
                                  ),
                                  child: const Text(
                                    'CHANGE',
                                    style: TextStyle(
                                      color: Color(0xFFE23744),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Update button
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 420),
                            child: SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _onUpdateProfile,
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  backgroundColor: const Color(0xFFE23744),
                                  elevation: 0,
                                ),
                                child: Consumer<UserProvider>(
                                  builder: (context, provider, child) =>
                                      provider.isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : const Text(
                                          'Update Profile',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
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
}




