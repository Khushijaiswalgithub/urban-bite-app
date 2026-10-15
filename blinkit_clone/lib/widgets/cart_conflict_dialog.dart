import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';

Future<void> handleCartConflict({
  required BuildContext context,
  required RestaurantConflictException exception,
  required ProductModel product,
  VoidCallback? onSuccess,
}) async {
  final cart = Provider.of<CartProvider>(context, listen: false);

  await showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: const Text(
        'Replace Cart Items?',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Text(
        'Your cart already contains items from "${exception.existingRestaurant}". '
        'Do you want to discard these items and add "${product.name}" from "${exception.newRestaurant}" instead?',
        style: const TextStyle(fontSize: 14),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
          ),
        ),
        TextButton(
          onPressed: () {
            cart.addItem(product, force: true);
            Navigator.pop(ctx);

            if (onSuccess != null) {
              onSuccess();
            } else {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${product.name} added to cart from ${exception.newRestaurant}!'),
                  backgroundColor: const Color(0xFFE23744), // Zomato red
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
          child: const Text(
            'Replace',
            style: TextStyle(
              color: Color(0xFFE23744), // Zomato red
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}





