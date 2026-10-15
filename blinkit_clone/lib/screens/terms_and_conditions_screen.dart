import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({Key? key}) : super(key: key);

  static const _lastUpdated = 'August 30, 2025';

  static const List<Map<String, String>> _sections = [
    {
      'title': 'Introduction',
      'content':
          'Welcome to The urban bite. These Terms and Conditions ("Terms") govern your access to and use of our mobile application. By using the app you accept these Terms in full.',
    },
    {
      'title': 'Using the App',
      'content':
          'You agree to use the app in compliance with all applicable laws. You must not use the service for any illegal purpose or to transmit harmful or abusive material.',
    },
    {
      'title': 'Account & Security',
      'content':
          'If you create an account, keep your credentials secure. You are responsible for all activity that occurs under your account. Notify us immediately if you suspect unauthorized access.',
    },
    {
      'title': 'Orders & Payments',
      'content':
          'Products and services available through the app may be subject to separate terms and conditions and payment policies. Prices and availability may change without notice.',
    },
    {
      'title': 'Privacy',
      'content':
          'Our Privacy Policy explains how we collect, use, and share information. By using the app you consent to the collection and use of information as described in our Privacy Policy.',
    },
    {
      'title': 'Intellectual Property',
      'content':
          'All content, logos, and trademarks displayed in the app are the property of their respective owners. You may not use any of our intellectual property without permission.',
    },
    {
      'title': 'User Conduct',
      'content':
          'You agree not to impersonate others, post harmful content, or interfere with other users. We reserve the right to suspend or terminate accounts that violate these Terms.',
    },
    {
      'title': 'Disclaimers & Limitation of Liability',
      'content':
          'The app is provided "as is" without warranties of any kind. To the fullest extent permitted by law, we are not liable for indirect or consequential damages.',
    },
    {
      'title': 'Changes to Terms',
      'content':
          'We may update these Terms from time to time. When we do, we will revise the "Last updated" date. Continued use after changes indicates acceptance.',
    },
    {
      'title': 'Contact',
      'content':
          'If you have questions about these Terms, please contact the app maintainers via the contact information provided in the app or repository.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

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
              'Terms & Conditions',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Read our terms and conditions',
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
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: color.withOpacity(0.06),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Please read these terms carefully. They govern your use of The urban bite application.',
                    style: TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Last updated: $_lastUpdated',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                itemCount: _sections.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final section = _sections[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      title: Text(
                        section['title'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      leading: CircleAvatar(
                        radius: 16,
                        backgroundColor: color.withOpacity(0.15),
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      trailing: Icon(Icons.expand_more, color: Colors.black54),
                      children: [
                        SelectableText(
                          section['content'] ?? '',
                          style: const TextStyle(height: 1.4, fontSize: 14),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Copy section',
                                icon: const Icon(Icons.copy, size: 20),
                                onPressed: () async {
                                  final data = section['content'] ?? '';
                                  await Clipboard.setData(
                                    ClipboardData(text: data),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Section copied'),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFE23744),
                        side: const BorderSide(color: Color(0xFFE23744)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Close',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE23744),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Accept',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
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
}





