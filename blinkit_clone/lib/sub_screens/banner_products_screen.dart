import 'package:blinkit_clone/sub_screens/product_gird2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../models/product_model.dart';

class BannerProductsScreen extends StatefulWidget {
  final List<String> productIds;

  const BannerProductsScreen({Key? key, required this.productIds}) : super(key: key);

  @override
  State<BannerProductsScreen> createState() => _BannerProductsScreenState();
}

class _BannerProductsScreenState extends State<BannerProductsScreen> {
  bool _isLoading = true;
  List<ProductModel> _products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    final provider = Provider.of<ProductProvider>(context, listen: false);
    final ids = widget.productIds;
    final List<ProductModel> loaded = [];

    for (final id in ids) {
      try {
        final p = await provider.fetchProductById(id);
        if (p != null) loaded.add(p);
      } catch (e) {
        // ignore individual product errors and continue
        debugPrint('Error loading product $id: $e');
      }
    }

    if (mounted) {
      setState(() {
        _products = loaded;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: ProductGrid2(products: _products, isLoading: _isLoading),
            ),
    );
  }
}

