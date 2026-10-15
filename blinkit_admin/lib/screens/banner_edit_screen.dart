import 'dart:typed_data';

import 'package:blinkit_admin/models/banner_model.dart';
import 'package:blinkit_admin/models/product_model.dart';
import 'package:blinkit_admin/providers/banner_provider.dart';
import 'package:blinkit_admin/providers/product_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class BannerEditScreen extends StatefulWidget {
  final BannerModel? banner; // null => create

  const BannerEditScreen({Key? key, this.banner}) : super(key: key);

  @override
  State<BannerEditScreen> createState() => _BannerEditScreenState();
}

class _BannerEditScreenState extends State<BannerEditScreen> {
  bool _active = true;
  String? _bannerImageUrl;
  Uint8List? _pickedImageBytes;
  final Set<String> _selectedProductIds = {};
  final _imageUrlController = TextEditingController();

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final b = widget.banner;
    if (b != null) {
      _active = b.active;
      _bannerImageUrl = b.bannerImage.isNotEmpty ? b.bannerImage : null;
      _imageUrlController.text = b.bannerImage;
      _selectedProductIds.addAll(b.products);
    }
  }

  @override
  void dispose() {
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() {
      _pickedImageBytes = bytes;
      _bannerImageUrl = null; // use picked bytes instead of existing url
      _imageUrlController.clear();
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final bannerProvider = Provider.of<BannerProvider>(context, listen: false);

    try {
      String imageUrl = _imageUrlController.text.trim();

      if (_pickedImageBytes != null) {
        final uploaded = await bannerProvider.uploadBannerImageBytes(
          _pickedImageBytes!,
        );
        if (uploaded == null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Image upload failed')));
          setState(() => _saving = false);
          return;
        }
        imageUrl = uploaded;
      }

      final model = BannerModel(
        id: widget.banner?.id ?? '',
        bannerImage: imageUrl,
        products: _selectedProductIds.toList(),
        active: _active,
      );

      bool ok;
      if (widget.banner == null) {
        final id = await bannerProvider.addBanner(model);
        ok = id != null;
      } else {
        ok = await bannerProvider.updateBanner(
          model.copyWith(id: widget.banner!.id),
        );
      }

      if (ok) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Banner saved')));
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(bannerProvider.error ?? 'Failed to save banner'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.banner == null ? 'Create Banner' : 'Edit Banner'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Active',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  Switch(
                    value: _active,
                    onChanged: (v) => setState(() => _active = v),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Image Preview Card
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                clipBehavior: Clip.antiAlias,
                child: _pickedImageBytes != null
                    ? Image.memory(_pickedImageBytes!, fit: BoxFit.cover)
                    : _imageUrlController.text.isNotEmpty
                        ? (_imageUrlController.text.startsWith('http')
                            ? Image.network(
                                _imageUrlController.text,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      size: 48,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              )
                            : Image.asset(
                                _imageUrlController.text,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      size: 48,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ))
                        : const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_outlined,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'No image selected',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
              ),
              const SizedBox(height: 16),
              // Option 1: Paste URL
              TextFormField(
                controller: _imageUrlController,
                decoration: InputDecoration(
                  labelText: 'Banner Image URL',
                  hintText: 'Paste image URL here...',
                  prefixIcon: const Icon(Icons.link),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (val) {
                  setState(() {
                    _pickedImageBytes = null;
                  });
                },
              ),
              const SizedBox(height: 12),
              // OR Separator
              const Center(
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
              // Option 2: Upload from gallery button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('Upload from Gallery'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _pickImage,
                ),
              ),
              const SizedBox(height: 16),
              Consumer<ProductProvider>(
                builder: (context, productProv, _) {
                  return FutureBuilder<List<ProductModel>>(
                    future: productProv.fetchAllProducts(),
                    builder: (context, snap) {
                      if (!snap.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final products = snap.data!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select products (${_selectedProductIds.length})',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: products.length,
                            itemBuilder: (context, idx) {
                              final p = products[idx];
                              final pid = p.id ?? '';
                              final selected = _selectedProductIds.contains(
                                pid,
                              );
                              return CheckboxListTile(
                                value: selected,
                                title: Text(p.name),
                                subtitle: Text(pid),
                                onChanged: (v) {
                                  setState(() {
                                    if (v == true)
                                      _selectedProductIds.add(pid);
                                    else
                                      _selectedProductIds.remove(pid);
                                  });
                                },
                              );
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const CircularProgressIndicator()
                      : const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
