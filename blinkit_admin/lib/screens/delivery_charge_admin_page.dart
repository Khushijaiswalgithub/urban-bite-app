import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DeliveryChargeAdminPage extends StatefulWidget {
  const DeliveryChargeAdminPage({super.key});

  @override
  State<DeliveryChargeAdminPage> createState() =>
      _DeliveryChargeAdminPageState();
}

class _DeliveryChargeAdminPageState extends State<DeliveryChargeAdminPage> {
  final CollectionReference _rulesColl = FirebaseFirestore.instance.collection(
    'delivery_rules',
  );
  // final DocumentReference _settingsDoc = FirebaseFirestore.instance.doc(
  //   'settings/delivery',
  // );

  List<QueryDocumentSnapshot> _cachedRules = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Charge Rules'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _openForm(context),
            tooltip: 'Add rule',
          ),
        ],
      ),
      body: Column(
        children: [
          // StreamBuilder<DocumentSnapshot>(
          //   stream: _settingsDoc.snapshots(),
          //   builder: (context, snap) {
          //     bool enabled = true;
          //     if (snap.hasData && snap.data!.exists) {
          //       final data = snap.data!.data() as Map<String, dynamic>?;
          //       enabled = data?['enabled'] ?? true;
          //     }

          //     return SwitchListTile(
          //       title: const Text('Enable delivery charges'),
          //       value: enabled,
          //       onChanged: (v) => _settingsDoc.set({'enabled': v}),
          //     );
          //   },
          // ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _rulesColl.orderBy('min').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;
                _cachedRules = docs;

                // Build an in-memory list of ranges for overlap detection
                final ranges = _cachedRules.map((d) {
                  final data = d.data() as Map<String, dynamic>;
                  final double min = (data['min'] as num).toDouble();
                  final double? max = data['max'] == null
                      ? null
                      : (data['max'] as num).toDouble();
                  return {'id': d.id, 'min': min, 'max': max};
                }).toList();

                // detect overlaps per rule
                final overlaps = <String, bool>{};
                for (var i = 0; i < ranges.length; i++) {
                  final a = ranges[i];
                  final aMin = a['min'] as double;
                  final aMax = a['max'] as double?;
                  bool isOverlap = false;
                  for (var j = 0; j < ranges.length; j++) {
                    if (i == j) continue;
                    final b = ranges[j];
                    final bMin = b['min'] as double;
                    final bMax = b['max'] as double?;
                    if (_rangesOverlap(aMin, aMax, bMin, bMax)) {
                      isOverlap = true;
                      break;
                    }
                  }
                  overlaps[a['id'] as String] = isOverlap;
                }

                if (docs.isEmpty) {
                  return const Center(
                    child: Text('No delivery rules. Tap + to add.'),
                  );
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final double min = (data['min'] as num).toDouble();
                    final double? max = data['max'] == null
                        ? null
                        : (data['max'] as num).toDouble();
                    final double charge = (data['charge'] as num).toDouble();

                    final title = max == null
                        ? '₹${min.toStringAsFixed(2)}+ : ₹${charge.toStringAsFixed(2)}'
                        : '₹${min.toStringAsFixed(2)} – ₹${max.toStringAsFixed(2)} : ₹${charge.toStringAsFixed(2)}';

                    final isOverlap = overlaps[doc.id] ?? false;

                    return Card(
                      color: isOverlap ? Colors.red.withOpacity(0.08) : null,
                      child: ListTile(
                        title: Text(title),
                        subtitle: isOverlap
                            ? const Text(
                                'Overlaps with other rule',
                                style: TextStyle(color: Colors.red),
                              )
                            : null,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _openForm(context, doc: doc),
                              tooltip: 'Edit',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _confirmDelete(context, doc),
                              tooltip: 'Delete',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  bool _rangesOverlap(double aMin, double? aMax, double bMin, double? bMax) {
    final aUpper = aMax ?? double.infinity;
    final bUpper = bMax ?? double.infinity;
    // overlap when intervals intersect
    return aMin <= bUpper && bMin <= aUpper;
  }

  Future<void> _openForm(
    BuildContext context, {
    QueryDocumentSnapshot? doc,
  }) async {
    final isEditing = doc != null;
    final formKey = GlobalKey<FormState>();
    final minController = TextEditingController();
    final maxController = TextEditingController();
    final chargeController = TextEditingController();

    if (isEditing) {
      final data = doc.data() as Map<String, dynamic>;
      minController.text = (data['min'] as num).toString();
      maxController.text = data['max'] == null
          ? ''
          : (data['max'] as num).toString();
      chargeController.text = (data['charge'] as num).toString();
    }

    String? formError;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(isEditing ? 'Edit rule' : 'Add rule'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: minController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Min order total (₹)',
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Enter min';
                          final n = double.tryParse(v);
                          if (n == null) return 'Invalid number';
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: maxController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText:
                              'Max order total (₹) — leave empty for no max',
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return null;
                          final n = double.tryParse(v);
                          if (n == null) return 'Invalid number';
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: chargeController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Delivery charge (₹)',
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty)
                            return 'Enter charge';
                          final n = double.tryParse(v);
                          if (n == null) return 'Invalid number';
                          if (n < 0) return 'Charge must be ≥ 0';
                          return null;
                        },
                      ),
                      if (formError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            formError!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;

                    final min = double.parse(minController.text.trim());
                    final maxText = maxController.text.trim();
                    final double? max = maxText.isEmpty
                        ? null
                        : double.parse(maxText);
                    final charge = double.parse(chargeController.text.trim());

                    if (max != null && min > max) {
                      setState(() {
                        formError = 'Min must be ≤ max';
                      });
                      return;
                    }

                    // check overlap with existing rules
                    final existing = _cachedRules.map((d) => d).toList();
                    bool hasOverlap = false;
                    for (final r in existing) {
                      if (isEditing && r.id == doc.id) continue;
                      final data = r.data() as Map<String, dynamic>;
                      final rMin = (data['min'] as num).toDouble();
                      final rMax = data['max'] == null
                          ? null
                          : (data['max'] as num).toDouble();
                      if (_rangesOverlap(min, max, rMin, rMax)) {
                        hasOverlap = true;
                        break;
                      }
                    }

                    if (hasOverlap) {
                      setState(() {
                        formError = 'Range overlaps with existing rule';
                      });
                      return;
                    }

                    try {
                      if (isEditing) {
                        await _rulesColl.doc(doc.id).update({
                          'min': min,
                          'max': max,
                          'charge': charge,
                        });
                      } else {
                        await _rulesColl.add({
                          'min': min,
                          'max': max,
                          'charge': charge,
                        });
                      }
                      Navigator.of(context).pop();
                    } catch (e) {
                      setState(() {
                        formError = 'Failed to save: $e';
                      });
                    }
                  },
                  child: Text(isEditing ? 'Update' : 'Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, QueryDocumentSnapshot doc) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete rule'),
          content: const Text('Are you sure you want to delete this rule?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _rulesColl.doc(doc.id).delete();
                  Navigator.of(context).pop();
                } catch (e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
