import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

import '../providers/category_provider.dart';
import '../models/category_model.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showSupCatForm(
    BuildContext context, {
    String? docId,
    SupCatModel? supCat,
  }) async {
    final isNew = supCat == null;
    final nameCtrl = TextEditingController(text: supCat?.name ?? '');
    final formKey = GlobalKey<FormState>();
    final provider = Provider.of<CategoryProvider>(context, listen: false);

    List<Map<String, TextEditingController>> childCtrls = [];
    List<List<Map<String, TextEditingController>>> subSubsCtrls = [];
    
    for (var c in (supCat?.categories ?? [])) {
      childCtrls.add({
        'name': TextEditingController(text: c.name),
        'image': TextEditingController(text: c.image),
      });
      subSubsCtrls.add((c.subCategories ?? []).map<Map<String, TextEditingController>>((sc) => {
        'name': TextEditingController(text: sc.name),
        'image': TextEditingController(text: sc.image),
      }).toList());
    }

    void addChild() {
      childCtrls.add({
        'name': TextEditingController(),
        'image': TextEditingController(),
      });
      subSubsCtrls.add([]);
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.9,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (_, scrollController) {
                return Container(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(ctx).viewInsets.bottom,
                  ),
                  child: Column(
                    children: [
                      // Handle bar
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      // Header
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isNew ? Icons.add_circle : Icons.edit,
                              color: Theme.of(context).primaryColor,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              isNew ? 'Add Category' : 'Edit Category',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                      // Content
                      Expanded(
                        child: Form(
                          key: formKey,
                          child: ListView(
                            controller: scrollController,
                            padding: const EdgeInsets.all(20),
                            children: [
                              // Main Category Name
                              Text(
                                'Main Category',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[700],
                                    ),
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: nameCtrl,
                                decoration: InputDecoration(
                                  labelText: 'Category Name',
                                  hintText: 'e.g., Electronics, Fashion',
                                  prefixIcon: const Icon(Icons.category),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                ),
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                    ? 'Required'
                                    : null,
                              ),
                              const SizedBox(height: 24),
                              // Child Categories Header
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Sub-Categories',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[700],
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${childCtrls.length} items',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                  FilledButton.icon(
                                    onPressed: () {
                                      setState(() => addChild());
                                    },
                                    icon: const Icon(Icons.add, size: 20),
                                    label: const Text('Add'),
                                    style: FilledButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Child Categories List
                              if (childCtrls.isEmpty)
                                Container(
                                  padding: const EdgeInsets.all(32),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                      style: BorderStyle.solid,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.inventory_2_outlined,
                                        size: 48,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'No sub-categories yet',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                ...childCtrls.asMap().entries.map((entry) {
                                  final i = entry.key;
                                  final ctrls = entry.value;
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  8,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .primaryColor
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  '${i + 1}',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(
                                                      context,
                                                    ).primaryColor,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  'Sub-category ${i + 1}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete_outline,
                                                  color: Colors.red,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    childCtrls.removeAt(i);
                                                    subSubsCtrls.removeAt(i);
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          TextFormField(
                                            controller: ctrls['name'],
                                            decoration: InputDecoration(
                                              labelText: 'Name',
                                              hintText: 'e.g., Smartphones',
                                              prefixIcon: const Icon(
                                                Icons.label_outline,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              filled: true,
                                              fillColor: Colors.white,
                                            ),
                                            validator: (v) =>
                                                (v == null || v.trim().isEmpty)
                                                ? 'Required'
                                                : null,
                                          ),
                                          const SizedBox(height: 8),
                                          const Text(
                                            'Sub-Category Image',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          TextFormField(
                                            controller: ctrls['image'],
                                            decoration: InputDecoration(
                                              labelText: 'Image URL',
                                              hintText: 'Paste image URL here...',
                                              prefixIcon: const Icon(
                                                Icons.link,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              filled: true,
                                              fillColor: Colors.white,
                                            ),
                                            onChanged: (val) {
                                              setState(() {});
                                            },
                                          ),
                                          const SizedBox(height: 12),
                                          const Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              '— OR —',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[50],
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: Colors.grey[300]!,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                // Image Preview
                                                Container(
                                                  width: 80,
                                                  height: 80,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                    border: Border.all(
                                                      color: Colors.grey[300]!,
                                                      width: 2,
                                                    ),
                                                  ),
                                                  child:
                                                      ctrls['image']!
                                                          .text
                                                          .isNotEmpty
                                                      ? ClipRRect(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                6,
                                                              ),
                                                          child: ctrls['image']!.text.startsWith('http')
                                                              ? Image.network(
                                                                  ctrls['image']!.text,
                                                                  fit: BoxFit.cover,
                                                                  errorBuilder: (_, __, ___) => const Icon(
                                                                    Icons.broken_image,
                                                                    color: Colors.grey,
                                                                  ),
                                                                )
                                                              : Image.asset(
                                                                  ctrls['image']!.text,
                                                                  fit: BoxFit.cover,
                                                                  errorBuilder: (_, __, ___) => const Icon(
                                                                    Icons.broken_image,
                                                                    color: Colors.grey,
                                                                  ),
                                                                ),
                                                        )
                                                      : Icon(
                                                          Icons
                                                              .add_photo_alternate_outlined,
                                                          color:
                                                              Colors.grey[400],
                                                          size: 32,
                                                        ),
                                                ),
                                                const SizedBox(width: 12),
                                                // Upload Button
                                                Expanded(
                                                  child: Consumer<CategoryProvider>(
                                                    builder: (context, provider, _) {
                                                      return Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          ElevatedButton.icon(
                                                            icon:
                                                                provider.loading
                                                                ? const SizedBox(
                                                                    width: 16,
                                                                    height: 16,
                                                                    child: CircularProgressIndicator(
                                                                      strokeWidth:
                                                                          2,
                                                                    ),
                                                                  )
                                                                : const Icon(
                                                                    Icons
                                                                        .image,
                                                                    size: 18,
                                                                  ),
                                                            label: Text(
                                                              provider.loading
                                                                  ? 'Uploading...'
                                                                  : 'Upload Image',
                                                            ),
                                                            onPressed:
                                                                provider.loading
                                                                ? null
                                                                : () async {
                                                                    final picker =
                                                                        ImagePicker();
                                                                    final xfile = await picker.pickImage(
                                                                      source: ImageSource
                                                                          .gallery,
                                                                      imageQuality:
                                                                          85,
                                                                    );
                                                                    if (xfile !=
                                                                        null) {
                                                                      final bytes =
                                                                          await xfile
                                                                              .readAsBytes();
                                                                      final url =
                                                                          await provider.uploadCategoryImageBytes(
                                                                            bytes,
                                                                          );
                                                                      if (url !=
                                                                          null) {
                                                                        setState(() {
                                                                          ctrls['image']!.text =
                                                                              url;
                                                                        });
                                                                      } else {
                                                                        if (!mounted)
                                                                          return;
                                                                        ScaffoldMessenger.of(
                                                                          context,
                                                                        ).showSnackBar(
                                                                          SnackBar(
                                                                            content: Text(
                                                                              provider.error ??
                                                                                  'Failed to upload',
                                                                            ),
                                                                            backgroundColor:
                                                                                Colors.red,
                                                                          ),
                                                                        );
                                                                      }
                                                                    }
                                                                  },
                                                            style: ElevatedButton.styleFrom(
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      8,
                                                                    ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          const Divider(),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                'Sub-SubCategories',
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                              TextButton.icon(
                                                onPressed: () {
                                                  setState(() {
                                                    subSubsCtrls[i].add({
                                                      'name': TextEditingController(),
                                                      'image': TextEditingController(),
                                                    });
                                                  });
                                                },
                                                icon: const Icon(Icons.add, size: 16),
                                                label: const Text('Add'),
                                              ),
                                            ],
                                          ),
                                          if (subSubsCtrls[i].isEmpty)
                                            const Padding(
                                              padding: EdgeInsets.symmetric(vertical: 8.0),
                                              child: Text('No sub-subcategories', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                            )
                                          else
                                            ...subSubsCtrls[i].asMap().entries.map((subEntry) {
                                              final subI = subEntry.key;
                                              final subCtrls = subEntry.value;
                                              return Container(
                                                margin: const EdgeInsets.only(top: 8),
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[50],
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(color: Colors.grey[200]!),
                                                ),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: TextFormField(
                                                            controller: subCtrls['name'],
                                                            decoration: const InputDecoration(
                                                              labelText: 'Sub-Sub Name',
                                                              isDense: true,
                                                            ),
                                                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                                                          ),
                                                        ),
                                                        IconButton(
                                                          icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                                          onPressed: () {
                                                            setState(() {
                                                              subSubsCtrls[i].removeAt(subI);
                                                            });
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }).toList(),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                            ],
                          ),
                        ),
                      ),
                      // Bottom Action Buttons
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, -5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Cancel'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: FilledButton.icon(
                                onPressed: () async {
                                  if (!formKey.currentState!.validate()) return;

                                  final navigator = Navigator.of(ctx);
                                  final messenger = ScaffoldMessenger.of(
                                    context,
                                  );

                                  final children = childCtrls.asMap().entries
                                      .map(
                                        (entry) => Category(
                                          name: entry.value['name']!.text.trim(),
                                          image: entry.value['image']!.text.trim(),
                                          subCategories: subSubsCtrls[entry.key]
                                              .map((sc) => Category(
                                                name: sc['name']!.text.trim(),
                                                image: sc['image']!.text.trim(),
                                              ))
                                              .where((c) => c.name.isNotEmpty)
                                              .toList(),
                                        ),
                                      )
                                      .where((c) => c.name.isNotEmpty)
                                      .toList();

                                  final newSup = SupCatModel(
                                    name: nameCtrl.text.trim(),
                                    categories: children,
                                  );

                                  if (isNew) {
                                    final id = await provider.addSupCategory(
                                      newSup,
                                    );
                                    if (!mounted) return;
                                    if (id != null) {
                                      navigator.pop();
                                      messenger.showSnackBar(
                                        SnackBar(
                                          content: const Row(
                                            children: [
                                              Icon(
                                                Icons.check_circle,
                                                color: Colors.white,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                'Category added successfully',
                                              ),
                                            ],
                                          ),
                                          backgroundColor: Colors.green,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                      );
                                    } else {
                                      messenger.showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            provider.error ?? 'Failed to add',
                                          ),
                                          backgroundColor: Colors.red,
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                  } else {
                                    final ok = await provider.updateSupCategory(
                                      docId!,
                                      newSup,
                                    );
                                    if (!mounted) return;
                                    if (ok) {
                                      navigator.pop();
                                      messenger.showSnackBar(
                                        SnackBar(
                                          content: const Row(
                                            children: [
                                              Icon(
                                                Icons.check_circle,
                                                color: Colors.white,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                'Category updated successfully',
                                              ),
                                            ],
                                          ),
                                          backgroundColor: Colors.green,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                      );
                                    } else {
                                      messenger.showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            provider.error ??
                                                'Failed to update',
                                          ),
                                          backgroundColor: Colors.red,
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                  }
                                },
                                icon: const Icon(Icons.save),
                                label: Text(
                                  isNew ? 'Add Category' : 'Save Changes',
                                ),
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    String docId,
    SupCatModel supCat,
  ) async {
    final provider = Provider.of<CategoryProvider>(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(
          Icons.warning_amber_rounded,
          color: Colors.orange,
          size: 48,
        ),
        title: const Text(
          'Delete Category',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Are you sure you want to delete "${supCat.name}"?',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This will also delete ${supCat.categories.length} sub-categories',
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(ctx).pop(true),
            icon: const Icon(Icons.delete_forever),
            label: const Text('Delete'),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (ok == true) {
      final res = await provider.deleteSupCategory(docId);
      if (!mounted) return;
      if (res) {
        messenger.showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Category deleted successfully'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Delete failed'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CategoryProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Categories',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              showSearch(
                context: context,
                delegate: CategorySearchDelegate(provider),
              );
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.05),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search categories...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          // Categories List
          Expanded(
            child: Stack(
              children: [
                StreamBuilder<List<MapEntry<String, SupCatModel>>>(
                  stream: provider.supCategoriesWithIdStream(),
                  builder: (ctx, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snap.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error: ${snap.error}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      );
                    }

                    final allList = snap.data ?? [];
                    final list = _searchQuery.isEmpty
                        ? allList
                        : allList
                              .where(
                                (entry) =>
                                    entry.value.name.toLowerCase().contains(
                                      _searchQuery,
                                    ) ||
                                    entry.value.categories.any(
                                      (cat) => cat.name.toLowerCase().contains(
                                        _searchQuery,
                                      ),
                                    ),
                              )
                              .toList();

                    if (allList.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.category_outlined,
                              size: 100,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'No categories yet',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap the + button to create your first category',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      );
                    }

                    if (list.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 80,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No results found',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try different keywords',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: list.length,
                      itemBuilder: (ctx, i) {
                        final entry = list[i];
                        final docId = entry.key;
                        final c = entry.value;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Theme(
                            data: Theme.of(
                              context,
                            ).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.category,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              title: Text(
                                c.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.inventory_2_outlined,
                                      size: 14,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${c.categories.length} sub-categ...',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () => _showSupCatForm(
                                      context,
                                      docId: docId,
                                      supCat: c,
                                    ),
                                    icon: const Icon(Icons.edit_outlined),
                                    tooltip: 'Edit',
                                  ),
                                  IconButton(
                                    onPressed: () =>
                                        _confirmDelete(context, docId, c),
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                    tooltip: 'Delete',
                                  ),
                                ],
                              ),
                              children: [
                                if (c.categories.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Center(
                                      child: Text(
                                        'No sub-categories',
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                  ...c.categories.map((cat) {
                                    return Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: ListTile(
                                        leading: cat.image.isNotEmpty
                                            ? Container(
                                                width: 50,
                                                height: 50,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: Colors.grey[300]!,
                                                  ),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(7),
                                                  child: cat.image.startsWith('http')
                                                      ? Image.network(
                                                          cat.image,
                                                          fit: BoxFit.cover,
                                                          errorBuilder: (_, __, ___) => const Icon(
                                                            Icons.broken_image,
                                                            color: Colors.grey,
                                                          ),
                                                        )
                                                      : Image.asset(
                                                          cat.image,
                                                          fit: BoxFit.cover,
                                                          errorBuilder: (_, __, ___) => const Icon(
                                                            Icons.broken_image,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                ),
                                              )
                                            : Container(
                                                width: 50,
                                                height: 50,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[200],
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Icon(
                                                  Icons.image_not_supported,
                                                  color: Colors.grey[400],
                                                ),
                                              ),
                                        title: Text(
                                          cat.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        subtitle: cat.image.isNotEmpty
                                            ? Text(
                                                'Image uploaded',
                                                style: TextStyle(
                                                  color: Colors.green[700],
                                                  fontSize: 12,
                                                ),
                                              )
                                            : Text(
                                                'No image',
                                                style: TextStyle(
                                                  color: Colors.grey[500],
                                                  fontSize: 12,
                                                ),
                                              ),
                                      ),
                                    );
                                  }).toList(),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                if (provider.loading)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black54,
                      child: const Center(
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text(
                                  'Processing...',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSupCatForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Category'),
      ),
    );
  }
}

// Search Delegate for better search experience
class CategorySearchDelegate extends SearchDelegate {
  final CategoryProvider provider;

  CategorySearchDelegate(this.provider);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    return StreamBuilder<List<MapEntry<String, SupCatModel>>>(
      stream: provider.supCategoriesWithIdStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final allCategories = snapshot.data ?? [];
        final results = query.isEmpty
            ? allCategories
            : allCategories
                  .where(
                    (entry) =>
                        entry.value.name.toLowerCase().contains(
                          query.toLowerCase(),
                        ) ||
                        entry.value.categories.any(
                          (cat) => cat.name.toLowerCase().contains(
                            query.toLowerCase(),
                          ),
                        ),
                  )
                  .toList();

        if (results.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                const Text(
                  'No results found',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final entry = results[index];
            final category = entry.value;
            return ListTile(
              leading: const Icon(Icons.category),
              title: Text(category.name),
              subtitle: Text('${category.categories.length} sub-categ.'),
              onTap: () {
                close(context, category);
              },
            );
          },
        );
      },
    );
  }
}
