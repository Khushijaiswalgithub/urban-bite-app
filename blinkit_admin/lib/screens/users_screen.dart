import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showUserDetails(
    BuildContext context,
    String uid,
    Map<String, dynamic> data,
  ) {
    final name = (data['name'] ?? '').toString();
    final email = (data['email'] ?? '').toString();
    final phone = (data['phoneNumber'] ?? '').toString();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            ListTile(
              leading: _buildAvatar(name, uid),
              title: Text(
                name.isEmpty ? uid : name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(uid, style: const TextStyle(fontSize: 12)),
            ),
            const SizedBox(height: 8),
            if (email.isNotEmpty)
              _infoRow(context, Icons.email, 'Email', email),
            if (phone.isNotEmpty)
              _infoRow(context, Icons.phone, 'Phone', phone),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: uid));
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('UID copied')),
                      );
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy UID'),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, size: 22, color: Theme.of(context).iconTheme.color),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(value),
      trailing: IconButton(
        icon: const Icon(Icons.copy),
        onPressed: () {
          Clipboard.setData(ClipboardData(text: value));
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('$label copied')));
        },
      ),
    );
  }

  Widget _buildAvatar(String name, String uid) {
    if (name.isNotEmpty) {
      final initials = name
          .trim()
          .split(' ')
          .where((s) => s.isNotEmpty)
          .map((s) => s[0])
          .take(2)
          .join()
          .toUpperCase();
      return CircleAvatar(child: Text(initials));
    }
    return CircleAvatar(child: Text(uid.substring(0, 2).toUpperCase()));
  }

  @override
  Widget build(BuildContext context) {
    final usersStream = FirebaseFirestore.instance
        .collection('users')
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SizedBox(
              height: 40,
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search by name, email or phone',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (v) => setState(() => _query = v.trim()),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: usersStream,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Failed to load users',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(snap.error.toString(), textAlign: TextAlign.center),
                ],
              ),
            );
          }

          var docs = snap.data?.docs ?? [];

          // Apply simple client-side search filtering
          if (_query.isNotEmpty) {
            final q = _query.toLowerCase();
            docs = docs.where((d) {
              final data = (d.data() as Map<String, dynamic>?) ?? {};
              final name = (data['name'] ?? '').toString().toLowerCase();
              final email = (data['email'] ?? '').toString().toLowerCase();
              final phone = (data['phoneNumber'] ?? '')
                  .toString()
                  .toLowerCase();
              return name.contains(q) ||
                  email.contains(q) ||
                  phone.contains(q) ||
                  d.id.toLowerCase().contains(q);
            }).toList();
          }

          if (docs.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                // Force a rebuild; stream will naturally fetch latest
                setState(() {});
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                  Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No users found',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Try adjusting your search or pull to refresh.',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              // No-op: stream updates automatically; just rebuild
              setState(() {});
            },
            child: ListView.separated(
              itemCount: docs.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (ctx, i) {
                final doc = docs[i];
                final d = doc.data() as Map<String, dynamic>? ?? {};
                final uid = doc.id;
                final name = d['name']?.toString() ?? '';
                final phone = d['phoneNumber']?.toString() ?? '';
                final email = d['email']?.toString() ?? '';

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: _buildAvatar(name, uid),
                  title: Text(
                    name.isEmpty ? uid : name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (phone.isNotEmpty) Text(phone),
                      if (email.isNotEmpty)
                        Text(email, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => _showUserDetails(context, uid, d),
                    tooltip: 'Details',
                  ),
                  onTap: () => _showUserDetails(context, uid, d),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
