import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  Widget _getIconForNotification(String title) {
    final lowerTitle = title.toLowerCase();
    IconData iconData = Icons.notifications_outlined;
    Color iconColor = const Color(0xFFE23744); // default Zomato red
    Color bgColor = const Color(0xFFFFEBEB);

    if (lowerTitle.contains('offer') || lowerTitle.contains('discount') || lowerTitle.contains('promo')) {
      iconData = Icons.local_offer_outlined;
      iconColor = Colors.orange.shade800;
      bgColor = Colors.orange.shade50;
    } else if (lowerTitle.contains('order') || lowerTitle.contains('placed') || lowerTitle.contains('delivery')) {
      iconData = Icons.shopping_bag_outlined;
      iconColor = const Color(0xFFE23744);
      bgColor = const Color(0xFFFFEBEB);
    } else if (lowerTitle.contains('welcome') || lowerTitle.contains('login') || lowerTitle.contains('successful')) {
      iconData = Icons.check_circle_outline_outlined;
      iconColor = const Color(0xFF00C853); // Zomato green / success
      bgColor = const Color(0xFFE8F5E9);
    } else if (lowerTitle.contains('new') || lowerTitle.contains('added')) {
      iconData = Icons.new_releases_outlined;
      iconColor = Colors.purple.shade700;
      bgColor = Colors.purple.shade50;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: iconColor, size: 22),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Color(0xFF2E2E2E),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF2E2E2E), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, _) {
              if (provider.notifications.isEmpty) return const SizedBox.shrink();
              return TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Clear All Notifications?'),
                      content: const Text('Are you sure you want to delete all notifications?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                        ),
                        TextButton(
                          onPressed: () {
                            provider.clearAll();
                            Navigator.pop(ctx);
                          },
                          child: const Text('Clear All', style: TextStyle(color: Color(0xFFE23744), fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text(
                  'Clear All',
                  style: TextStyle(
                    color: Color(0xFFE23744),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, _) {
          final list = provider.notifications;
          if (list.isEmpty) {
            return Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFEBEB), Color(0xFFFFD4D4)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE23744).withOpacity(0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.notifications_none_outlined,
                          color: Color(0xFFE23744),
                          size: 64,
                        ),
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        'No notifications yet',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E2E2E),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'We will notify you here when offers appear, food items are added, or when your order updates in real time!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            itemCount: list.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final notif = list[index];
              return Dismissible(
                key: Key(notif.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.centerRight,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE23744),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.white),
                ),
                onDismissed: (_) {
                  provider.deleteNotification(notif.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notification deleted'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                child: GestureDetector(
                  onTap: () {
                    if (!notif.isRead) {
                      provider.markAsRead(notif.id);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: notif.isRead ? Colors.white : const Color(0xFFFFECEF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: notif.isRead ? Colors.grey.shade100 : const Color(0xFFFFD4D9),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Colored Circle Icon
                        _getIconForNotification(notif.title),
                        const SizedBox(width: 14),
                        // Text Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notif.title,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: notif.isRead ? FontWeight.bold : FontWeight.w800,
                                  color: const Color(0xFF2E2E2E),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                notif.body,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: notif.isRead ? FontWeight.normal : FontWeight.w500,
                                  color: Colors.grey[700],
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _formatTimestamp(notif.timestamp),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[400],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Close / Delete icon
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(Icons.close, color: Colors.grey[400], size: 18),
                          onPressed: () {
                            provider.deleteNotification(notif.id);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}





