import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/product_provider.dart';
import '../providers/category_provider.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String _searchQuery = '';
  String _filterCategory = 'All';

  Future<void> _showProductForm(
    BuildContext context, {
    ProductModel? product,
  }) async {
    final isNew = product == null;
    final provider = Provider.of<ProductProvider>(context, listen: false);
    final categoryProvider = Provider.of<CategoryProvider>(
      context,
      listen: false,
    );

    final supCats = await categoryProvider.fetchAllSupCategories();

    final nameCtrl = TextEditingController(text: product?.name ?? '');
    final urlInputCtrl = TextEditingController();
    final priceCtrl = TextEditingController(
      text: product?.price.toString() ?? '0',
    );
    final qtyCtrl = TextEditingController(text: product?.quantity ?? '0');
    final discountCtrl = TextEditingController(
      text: product?.discountPercent.toString() ?? '0',
    );
    final superCatCtrl = TextEditingController(
      text: product?.superCategory ?? '',
    );
    final subCatCtrl = TextEditingController(text: product?.subCategory ?? '');
    final subSubCatCtrl = TextEditingController(text: product?.subSubCategory ?? '');
    final descCtrl = TextEditingController(text: product?.description ?? '');
    final detailCtrl = TextEditingController(
      text: product?.productDetail ?? '',
    );
    final returnCtrl = TextEditingController(text: product?.returnPolicy ?? '');
    final restaurantCtrl = TextEditingController(text: product?.restaurantName ?? '');
    final ratingCtrl = TextEditingController(text: product?.rating.toString() ?? '4.0');
    final deliveryTimeCtrl = TextEditingController(text: product?.deliveryTime.toString() ?? '20');
    bool localIsVeg = product?.isVeg ?? true;

    final variantQtyCtrl = TextEditingController();
    final variantPriceCtrl = TextEditingController();
    final variantDiscountCtrl = TextEditingController();
    final List<ProductVariant> localVariants = List.from(product?.variants ?? []);
    final videoCtrl = TextEditingController(text: product?.video ?? '');

    final imageCtrls = <TextEditingController>[];
    if (product != null && product.images.isNotEmpty) {
      for (var img in product.images) {
        imageCtrls.add(TextEditingController(text: img));
      }
    } else {
      imageCtrls.add(TextEditingController());
    }

    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            String selectedSuper = superCatCtrl.text.isNotEmpty
                ? superCatCtrl.text
                : ('');
            List<Category> currentSubCats = [];
            try {
              final sup = supCats.firstWhere((s) => s.name == selectedSuper);
              currentSubCats = sup.categories;
            } catch (_) {
              currentSubCats = [];
            }
            String selectedSub = subCatCtrl.text;
            List<Category> currentSubSubCats = [];
            try {
              final subC = currentSubCats.firstWhere((s) => s.name == selectedSub);
              currentSubSubCats = subC.subCategories ?? [];
            } catch (_) {
              currentSubSubCats = [];
            }
            String selectedSubSub = subSubCatCtrl.text;

            return Dialog(
              insetPadding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = MediaQuery.of(context).size.width;
                  return Container(
                    width: width,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Theme.of(ctx).primaryColor.withOpacity(0.1),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isNew ? Icons.add_shopping_cart : Icons.edit,
                                color: Theme.of(ctx).primaryColor,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  isNew ? 'Add New Product' : 'Edit Product',
                                  style: Theme.of(ctx).textTheme.headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => Navigator.of(ctx).pop(),
                              ),
                            ],
                          ),
                        ),
                        // Content
                        Flexible(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(24),
                            child: Form(
                              key: formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Basic Information Section
                                  _SectionHeader(title: 'Basic Information'),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: nameCtrl,
                                    decoration: _inputDecoration(
                                      label: 'Product Name',
                                      icon: Icons.shopping_bag_outlined,
                                    ),
                                    validator: (v) =>
                                        (v == null || v.trim().isEmpty)
                                        ? 'Product name is required'
                                        : null,
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: TextFormField(
                                          controller: priceCtrl,
                                          keyboardType:
                                              const TextInputType.numberWithOptions(
                                                decimal: true,
                                              ),
                                          decoration: _inputDecoration(
                                            label: 'Price (₹)',
                                            icon: Icons.currency_rupee,
                                          ),
                                          validator: (v) =>
                                              (v == null ||
                                                  double.tryParse(v) == null)
                                              ? 'Invalid price'
                                              : null,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: TextFormField(
                                          controller: discountCtrl,
                                          keyboardType:
                                              const TextInputType.numberWithOptions(
                                                decimal: true,
                                              ),
                                          decoration: _inputDecoration(
                                            label: 'Discount %',
                                            icon: Icons.percent,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: qtyCtrl,
                                    decoration: _inputDecoration(
                                      label: 'Quantity',
                                      icon: Icons.inventory_2_outlined,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: restaurantCtrl,
                                    decoration: _inputDecoration(
                                      label: 'Restaurant Name',
                                      icon: Icons.storefront_outlined,
                                    ),
                                    validator: (v) =>
                                        (v == null || v.trim().isEmpty)
                                        ? 'Restaurant name is required'
                                        : null,
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: ratingCtrl,
                                          keyboardType:
                                              const TextInputType.numberWithOptions(
                                                decimal: true,
                                              ),
                                          decoration: _inputDecoration(
                                            label: 'Rating (e.g. 4.5)',
                                            icon: Icons.star_border,
                                          ),
                                          validator: (v) =>
                                              (v == null ||
                                                  double.tryParse(v) == null)
                                              ? 'Invalid rating'
                                              : null,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: TextFormField(
                                          controller: deliveryTimeCtrl,
                                          keyboardType: TextInputType.number,
                                          decoration: _inputDecoration(
                                            label: 'Delivery Time (mins)',
                                            icon: Icons.access_time,
                                          ),
                                          validator: (v) =>
                                              (v == null ||
                                                  int.tryParse(v) == null)
                                              ? 'Invalid time'
                                              : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Wrap(
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    spacing: 12,
                                    runSpacing: 12,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.restaurant_menu, color: Colors.grey, size: 20),
                                          const SizedBox(width: 12),
                                          const Text(
                                            'Food Type:',
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                      ChoiceChip(
                                        avatar: const Icon(Icons.circle, color: Colors.green, size: 14),
                                        label: const Text('Veg'),
                                        selected: localIsVeg,
                                        selectedColor: Colors.green.shade50,
                                        checkmarkColor: Colors.green,
                                        labelStyle: TextStyle(
                                          color: localIsVeg ? Colors.green.shade700 : Colors.black87,
                                          fontWeight: localIsVeg ? FontWeight.bold : FontWeight.normal,
                                        ),
                                        onSelected: (selected) {
                                          if (selected) {
                                            setState(() {
                                              localIsVeg = true;
                                            });
                                          }
                                        },
                                      ),
                                      ChoiceChip(
                                        avatar: const Icon(Icons.circle, color: Colors.red, size: 14),
                                        label: const Text('Non-Veg'),
                                        selected: !localIsVeg,
                                        selectedColor: Colors.red.shade50,
                                        checkmarkColor: Colors.red,
                                        labelStyle: TextStyle(
                                          color: !localIsVeg ? Colors.red.shade700 : Colors.black87,
                                          fontWeight: !localIsVeg ? FontWeight.bold : FontWeight.normal,
                                        ),
                                        onSelected: (selected) {
                                          if (selected) {
                                            setState(() {
                                              localIsVeg = false;
                                            });
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),

                                  // Categories Section
                                  _SectionHeader(title: 'Categories'),
                                  const SizedBox(height: 16),
                                  DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    value: selectedSuper.isNotEmpty
                                        ? selectedSuper
                                        : null,
                                    decoration: _inputDecoration(
                                      label: 'Super Category',
                                      icon: Icons.category_outlined,
                                    ),
                                    items: supCats
                                        .map(
                                          (s) => DropdownMenuItem(
                                            value: s.name,
                                            child: Text(s.name),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (val) {
                                      setState(() {
                                        selectedSuper = val ?? '';
                                        superCatCtrl.text = selectedSuper;
                                        try {
                                          final sup = supCats.firstWhere(
                                            (s) => s.name == selectedSuper,
                                          );
                                          currentSubCats = sup.categories;
                                        } catch (_) {
                                          currentSubCats = [];
                                        }
                                        selectedSub = '';
                                        subCatCtrl.text = '';
                                        selectedSubSub = '';
                                        subSubCatCtrl.text = '';
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    value: selectedSub.isNotEmpty
                                        ? selectedSub
                                        : null,
                                    decoration: _inputDecoration(
                                      label: 'Sub Category',
                                      icon: Icons.label_outline,
                                    ),
                                    items: currentSubCats
                                        .map(
                                          (c) => DropdownMenuItem(
                                            value: c.name,
                                            child: Text(c.name),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (val) {
                                      setState(() {
                                        selectedSub = val ?? '';
                                        subCatCtrl.text = selectedSub;
                                        try {
                                          final subC = currentSubCats.firstWhere((s) => s.name == selectedSub);
                                          currentSubSubCats = subC.subCategories ?? [];
                                        } catch (_) {
                                          currentSubSubCats = [];
                                        }
                                        selectedSubSub = '';
                                        subSubCatCtrl.text = '';
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    value: selectedSubSub.isNotEmpty ? selectedSubSub : null,
                                    decoration: _inputDecoration(
                                      label: 'Sub-Sub Category',
                                      icon: Icons.label_outline,
                                    ),
                                    items: currentSubSubCats
                                        .map((c) => DropdownMenuItem(
                                              value: c.name,
                                              child: Text(c.name),
                                            ))
                                        .toList(),
                                    onChanged: (val) {
                                      setState(() {
                                        selectedSubSub = val ?? '';
                                        subSubCatCtrl.text = selectedSubSub;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 24),

                                  // Product Details Section
                                  _SectionHeader(title: 'Product Details'),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: descCtrl,
                                    decoration: _inputDecoration(
                                      label: 'Short Description',
                                      icon: Icons.description_outlined,
                                    ),
                                    maxLines: 2,
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: detailCtrl,
                                    decoration: _inputDecoration(
                                      label: 'Detailed Description',
                                      icon: Icons.subject,
                                    ),
                                    maxLines: 3,
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: returnCtrl,
                                    decoration: _inputDecoration(
                                      label: 'Return Policy',
                                      icon: Icons.sync,
                                    ),
                                    maxLines: 2,
                                  ),
                                  const SizedBox(height: 24),

                                  // Quantity Variants Section
                                  _SectionHeader(title: 'Quantity Variants (Optional)'),
                                  const SizedBox(height: 12),
                                  if (localVariants.isNotEmpty) ...[
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.grey.shade200),
                                      ),
                                      child: ListView.separated(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: localVariants.length,
                                        separatorBuilder: (_, __) => const Divider(height: 1),
                                        itemBuilder: (context, idx) {
                                          final v = localVariants[idx];
                                          return ListTile(
                                            dense: true,
                                            title: Text(
                                              'Variant: ${v.quantity}',
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                            ),
                                            subtitle: Text(
                                              'Price: ₹${v.price.toStringAsFixed(0)} | Discount: ${v.discountPercent.toStringAsFixed(0)}%',
                                              style: TextStyle(color: Colors.grey.shade600),
                                            ),
                                            trailing: IconButton(
                                              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                              onPressed: () {
                                                setState(() {
                                                  localVariants.removeAt(idx);
                                                });
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: TextFormField(
                                          controller: variantQtyCtrl,
                                          decoration: _inputDecoration(
                                            label: 'Qty (e.g. 500g)',
                                            icon: Icons.inventory_2_outlined,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        flex: 2,
                                        child: TextFormField(
                                          controller: variantPriceCtrl,
                                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                          decoration: _inputDecoration(
                                            label: 'Price (₹)',
                                            icon: Icons.currency_rupee,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        flex: 2,
                                        child: TextFormField(
                                          controller: variantDiscountCtrl,
                                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                          decoration: _inputDecoration(
                                            label: 'Disc %',
                                            icon: Icons.percent,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton(
                                        onPressed: () {
                                          final vQty = variantQtyCtrl.text.trim();
                                          final vPrice = double.tryParse(variantPriceCtrl.text.trim());
                                          final vDisc = double.tryParse(variantDiscountCtrl.text.trim()) ?? 0.0;
                                          if (vQty.isNotEmpty && vPrice != null) {
                                            setState(() {
                                              localVariants.add(
                                                ProductVariant(
                                                  quantity: vQty,
                                                  price: vPrice,
                                                  discountPercent: vDisc,
                                                ),
                                              );
                                              variantQtyCtrl.clear();
                                              variantPriceCtrl.clear();
                                              variantDiscountCtrl.clear();
                                            });
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Please fill quantity and price for variant'),
                                                backgroundColor: Colors.orange,
                                              ),
                                            );
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: const Icon(Icons.add),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),

                                  // Images Section
                                  _SectionHeader(title: 'Product Media'),
                                  const SizedBox(height: 16),
                                  Consumer<ProductProvider>(
                                    builder: (context, provider, _) {
                                      return Column(
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: TextFormField(
                                                  controller: urlInputCtrl,
                                                  decoration: _inputDecoration(
                                                    label: 'Paste Image URL',
                                                    icon: Icons.link,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              ElevatedButton(
                                                onPressed: () {
                                                  final url = urlInputCtrl.text.trim();
                                                  if (url.isNotEmpty) {
                                                    setState(() {
                                                      imageCtrls.add(
                                                        TextEditingController(text: url),
                                                      );
                                                      urlInputCtrl.clear();
                                                    });
                                                  }
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 16,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                ),
                                                child: const Icon(Icons.add),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: TextFormField(
                                                  controller: videoCtrl,
                                                  decoration: _inputDecoration(
                                                    label: 'Paste Video URL or Upload',
                                                    icon: Icons.videocam_outlined,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              OutlinedButton.icon(
                                                icon: const Icon(Icons.video_call),
                                                label: const Text('Video'),
                                                onPressed: provider.loading ? null : () async {
                                                  final picker = ImagePicker();
                                                  final xfile = await picker.pickVideo(source: ImageSource.gallery);
                                                  if (xfile != null) {
                                                    final bytes = await xfile.readAsBytes();
                                                    String ext = 'mp4';
                                                    if (xfile.name.contains('.')) {
                                                      ext = xfile.name.split('.').last;
                                                    }
                                                    final url = await provider.uploadProductVideoBytes(bytes, ext);
                                                    if (url != null) {
                                                      setState(() {
                                                        videoCtrl.text = url;
                                                      });
                                                    } else {
                                                      if (!mounted) return;
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(
                                                          content: Text(provider.error ?? 'Failed to upload video'),
                                                          backgroundColor: Colors.red,
                                                        ),
                                                      );
                                                    }
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          const Text(
                                            'OR',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          OutlinedButton.icon(
                                            icon: provider.loading
                                                ? const SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                        ),
                                                  )
                                                : const Icon(
                                                    Icons.add_photo_alternate,
                                                  ),
                                            label: Text(
                                              provider.loading
                                                  ? 'Uploading...'
                                                  : 'Add Image',
                                            ),
                                            style: OutlinedButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 24,
                                                    vertical: 12,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            onPressed: provider.loading
                                                ? null
                                                : () async {
                                                    final picker =
                                                        ImagePicker();
                                                    final xfile = await picker
                                                        .pickImage(
                                                          source: ImageSource
                                                              .gallery,
                                                          imageQuality: 85,
                                                        );
                                                    if (xfile != null) {
                                                      final bytes = await xfile
                                                          .readAsBytes();
                                                      final url = await provider
                                                          .uploadProductImageBytes(
                                                            bytes,
                                                          );
                                                      if (url != null) {
                                                        setState(() {
                                                          imageCtrls.add(
                                                            TextEditingController(
                                                              text: url,
                                                            ),
                                                          );
                                                        });
                                                      } else {
                                                        if (!mounted) return;
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                              provider.error ??
                                                                  'Failed to upload image',
                                                            ),
                                                            backgroundColor:
                                                                Colors.red,
                                                          ),
                                                        );
                                                      }
                                                    }
                                                  },
                                          ),
                                          const SizedBox(height: 16),
                                          if (imageCtrls.isNotEmpty &&
                                              imageCtrls.any(
                                                (c) => c.text.isNotEmpty,
                                              ))
                                            GridView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              gridDelegate:
                                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount: 3,
                                                    crossAxisSpacing: 12,
                                                    mainAxisSpacing: 12,
                                                  ),
                                              itemCount: imageCtrls.length,
                                              itemBuilder: (ctx, i) {
                                                final ctrl = imageCtrls[i];
                                                if (ctrl.text.isEmpty)
                                                  return const SizedBox();
                                                return Stack(
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                        border: Border.all(
                                                          color: Colors
                                                              .grey
                                                              .shade300,
                                                        ),
                                                        image: DecorationImage(
                                                          image: ctrl.text.startsWith('http')
                                                              ? NetworkImage(ctrl.text) as ImageProvider
                                                              : AssetImage(ctrl.text),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    Positioned(
                                                      top: 4,
                                                      right: 4,
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                              color: Colors.red,
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                        child: IconButton(
                                                          icon: const Icon(
                                                            Icons.close,
                                                            color: Colors.white,
                                                            size: 18,
                                                          ),
                                                          padding:
                                                              EdgeInsets.zero,
                                                          constraints:
                                                              const BoxConstraints(
                                                                minWidth: 32,
                                                                minHeight: 32,
                                                              ),
                                                          onPressed: () =>
                                                              setState(() {
                                                                imageCtrls
                                                                    .removeAt(
                                                                      i,
                                                                    );
                                                              }),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Footer Actions
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                                child: const Text('Cancel'),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                icon: Icon(isNew ? Icons.add : Icons.check),
                                label: Text(
                                  isNew ? 'Add Product' : 'Save Changes',
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () async {
                                  if (!formKey.currentState!.validate()) return;
                                  final navigator = Navigator.of(ctx);
                                  final messenger = ScaffoldMessenger.of(
                                    context,
                                  );

                                  final name = nameCtrl.text.trim();
                                  final price =
                                      double.tryParse(priceCtrl.text) ?? 0.0;
                                  final qty = qtyCtrl.text.trim();
                                  final discount =
                                      double.tryParse(discountCtrl.text) ?? 0.0;
                                  final images = imageCtrls
                                      .map((c) => c.text.trim())
                                      .where((s) => s.isNotEmpty)
                                      .toList();

                                  final prod = ProductModel(
                                    id: product?.id,
                                    name: name,
                                    images: images,
                                    quantity: qty,
                                    price: price,
                                    discountPercent: discount,
                                    superCategory:
                                        superCatCtrl.text.trim().isEmpty
                                        ? null
                                        : superCatCtrl.text.trim(),
                                    subCategory: subCatCtrl.text.trim().isEmpty
                                        ? null
                                        : subCatCtrl.text.trim(),
                                    subSubCategory: subSubCatCtrl.text.trim().isEmpty
                                        ? null
                                        : subSubCatCtrl.text.trim(),
                                    description: descCtrl.text.trim().isEmpty
                                        ? null
                                        : descCtrl.text.trim(),
                                    productDetail:
                                        detailCtrl.text.trim().isEmpty
                                        ? null
                                        : detailCtrl.text.trim(),
                                    returnPolicy: returnCtrl.text.trim().isEmpty
                                        ? null
                                        : returnCtrl.text.trim(),
                                    restaurantName: restaurantCtrl.text.trim().isEmpty
                                        ? null
                                        : restaurantCtrl.text.trim(),
                                    variants: localVariants,
                                    rating: double.tryParse(ratingCtrl.text.trim()) ?? 4.0,
                                    deliveryTime: int.tryParse(deliveryTimeCtrl.text.trim()) ?? 20,
                                    isVeg: localIsVeg,
                                    video: videoCtrl.text.trim().isEmpty ? null : videoCtrl.text.trim(),
                                  );

                                  if (isNew) {
                                    final id = await provider.addProduct(prod);
                                    if (!mounted) return;
                                    if (id != null) {
                                      navigator.pop();
                                      messenger.showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Product added successfully',
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    } else {
                                      messenger.showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            provider.error ?? 'Failed to add',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  } else {
                                    final ok = await provider.updateProduct(
                                      prod,
                                    );
                                    if (!mounted) return;
                                    if (ok) {
                                      navigator.pop();
                                      messenger.showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Product updated successfully',
                                          ),
                                          backgroundColor: Colors.green,
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
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ), // end Column
                  ); // end Container (returned inside builder)
                }, // end builder
              ), // end LayoutBuilder
            ); // end Dialog
          },
        );
      },
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE23744), width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }

  Future<void> _confirmDelete(BuildContext context, ProductModel p) async {
    final provider = Provider.of<ProductProvider>(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            const SizedBox(width: 12),
            const Text('Delete Product'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${p.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (ok == true) {
      final id = p.id;
      if (id == null || id.isEmpty) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Product id not available'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      final res = await provider.deleteProduct(id);
      if (!mounted) return;
      if (res) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Product deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Delete failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Products'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Filter functionality
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
          ),
          // Products List
          Expanded(
            child: StreamBuilder<List<ProductModel>>(
              stream: provider.productsStream(),
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${snap.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  );
                }
                var list = snap.data ?? [];

                // Apply search filter
                if (_searchQuery.isNotEmpty) {
                  list = list
                      .where(
                        (p) => p.name.toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        ),
                      )
                      .toList();
                }

                if (list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'No products found'
                              : 'No products yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'Try a different search term'
                              : 'Add your first product to get started',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  itemBuilder: (ctx, i) {
                    final p = list[i];
                    final discountedPrice =
                        p.price * (1 - p.discountPercent / 100);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: InkWell(
                        onTap: () => _showProductForm(context, product: p),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              // Product Image
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.grey.shade100,
                                  image: p.images.isNotEmpty
                                      ? DecorationImage(
                                          image: p.images.first.startsWith('http')
                                              ? NetworkImage(p.images.first) as ImageProvider
                                              : AssetImage(p.images.first),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: p.images.isEmpty
                                    ? Icon(
                                        Icons.shopping_bag_outlined,
                                        size: 32,
                                        color: Colors.grey.shade400,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              // Product Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 4,
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      children: [
                                        if (p.subCategory != null)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade50,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              p.subCategory!,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.blue.shade700,
                                              ),
                                            ),
                                          ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: p.isVeg ? Colors.green.shade50 : Colors.red.shade50,
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(
                                              color: p.isVeg ? Colors.green.shade200 : Colors.red.shade200,
                                              width: 0.5,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.circle,
                                                color: p.isVeg ? Colors.green : Colors.red,
                                                size: 8,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                p.isVeg ? 'VEG' : 'NON-VEG',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: p.isVeg ? Colors.green.shade800 : Colors.red.shade800,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        if (p.discountPercent > 0) ...[
                                          Text(
                                            '₹${discountedPrice.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.green,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '₹${p.price.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontSize: 13,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          // const SizedBox(width: 6),
                                          // Container(
                                          //   padding: const EdgeInsets.symmetric(
                                          //     horizontal: 6,
                                          //     vertical: 2,
                                          //   ),
                                          //   decoration: BoxDecoration(
                                          //     color: Colors.red.shade50,
                                          //     borderRadius:
                                          //         BorderRadius.circular(4),
                                          //   ),
                                          //   child: Text(
                                          //     '${p.discountPercent.toInt()}% OFF',
                                          //     style: TextStyle(
                                          //       fontSize: 11,
                                          //       color: Colors.red.shade700,
                                          //       fontWeight: FontWeight.bold,
                                          //     ),
                                          //   ),
                                          // ),
                                        ] else
                                          Text(
                                            '₹${p.price.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.inventory_2_outlined,
                                          size: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          ' ${p.quantity}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Action Buttons
                              Column(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 20),
                                    onPressed: () =>
                                        _showProductForm(context, product: p),
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.blue.shade50,
                                      foregroundColor: Colors.blue.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  IconButton(
                                    icon: const Icon(Icons.delete, size: 20),
                                    onPressed: () => _confirmDelete(context, p),
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.red.shade50,
                                      foregroundColor: Colors.red.shade700,
                                    ),
                                  ),
                                ],
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProductForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
        elevation: 4,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
