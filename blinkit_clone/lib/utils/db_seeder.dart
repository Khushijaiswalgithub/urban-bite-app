import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart' show BuildContext;
import 'package:provider/provider.dart';
import 'dart:math' show Random;
import '../models/category_model.dart';
import '../models/banner_model.dart';
import '../models/product_model.dart';
import '../providers/category_provider.dart';
import '../providers/product_provider.dart';

class DatabaseSeeder {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> seedDatabaseIfEmpty() async {
    try {
      debugPrint('Seeding database with food delivery data...');

      // 1. Seed Categories
      final List<SupCatModel> foodCategories = [
        SupCatModel(
          name: "What are you craving?",
          categories: [
            Category(
              name: "Biryani",
              image: "https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=500&auto=format&fit=crop&q=60",
              subCategories: [
                Category(name: 'Chicken', image: 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=500&auto=format&fit=crop&q=60'),
                Category(name: 'Mutton', image: 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=500&auto=format&fit=crop&q=60'),
                Category(name: 'Veg', image: 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=500&auto=format&fit=crop&q=60'),
              ],
            ),
            Category(
              name: "Burgers",
              image: "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500&auto=format&fit=crop&q=60",
              subCategories: [
                Category(name: 'Chicken', image: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500&auto=format&fit=crop&q=60'),
                Category(name: 'Veg', image: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500&auto=format&fit=crop&q=60'),
              ],
            ),
            Category(
              name: "Pizzas",
              image: "https://images.unsplash.com/photo-1513104890138-7c749659a591?w=500&auto=format&fit=crop&q=60",
              subCategories: [
                Category(name: 'Veg', image: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=500&auto=format&fit=crop&q=60'),
                Category(name: 'Non-Veg', image: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=500&auto=format&fit=crop&q=60'),
              ],
            ),
            Category(
              name: "Cakes",
              image: "https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=500&auto=format&fit=crop&q=60",
              subCategories: [
                Category(name: 'Chocolate', image: 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=500&auto=format&fit=crop&q=60'),
                Category(name: 'Butterscotch', image: 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=500&auto=format&fit=crop&q=60'),
              ],
            ),
            Category(
              name: "Chinese",
              image: "https://images.unsplash.com/photo-1585032226651-759b368d7246?w=500&auto=format&fit=crop&q=60",
              subCategories: [
                Category(name: 'Noodles', image: 'https://images.unsplash.com/photo-1585032226651-759b368d7246?w=500&auto=format&fit=crop&q=60'),
                Category(name: 'Starters', image: 'https://images.unsplash.com/photo-1585032226651-759b368d7246?w=500&auto=format&fit=crop&q=60'),
              ],
            ),
            Category(
              name: "Rolls",
              image: "https://images.unsplash.com/photo-1626700051175-6518c4793f4f?w=500&auto=format&fit=crop&q=60",
              subCategories: [
                Category(name: 'Paneer', image: 'https://images.unsplash.com/photo-1626700051175-6518c4793f4f?w=500&auto=format&fit=crop&q=60'),
                Category(name: 'Chicken', image: 'https://images.unsplash.com/photo-1626700051175-6518c4793f4f?w=500&auto=format&fit=crop&q=60'),
              ],
            ),
            Category(
              name: "North Indian",
              image: "https://images.unsplash.com/photo-1601050690597-df056fb4ce78?w=500&auto=format&fit=crop&q=60",
            ),
            Category(
              name: "South Indian",
              image: "https://images.unsplash.com/photo-1668236543090-82eba5ee5976?w=500&auto=format&fit=crop&q=60",
            ),
          ],
        )
      ];

      for (int i = 0; i < foodCategories.length; i++) {
        await _firestore
            .collection('categories')
            .doc('food_category_$i')
            .set(foodCategories[i].toMap());
      }

      // 2. Seed Banners
      final List<BannerModel> foodBanners = [
        BannerModel(
          id: "banner_1",
          bannerImage: "https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=1000&auto=format&fit=crop&q=80",
          products: ["biryani_1", "pizza_1"],
          active: true,
        ),
        BannerModel(
          id: "banner_2",
          bannerImage: "https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=1000&auto=format&fit=crop&q=80",
          products: ["burger_1", "noodles_1"],
          active: true,
        ),
        BannerModel(
          id: "banner_3",
          bannerImage: "https://images.unsplash.com/photo-1482049016688-2d3e1b311543?w=1000&auto=format&fit=crop&q=80",
          products: ["cake_1", "roll_1"],
          active: true,
        ),
      ];

      for (var b in foodBanners) {
        await _firestore.collection('banners').doc(b.id).set(b.toMap());
      }

      // 3. Seed Products (Dishes)
      final List<ProductModel> foodProducts = [
        ProductModel(
          id: "biryani_1",
          name: "Chicken Dum Biryani",
          images: ["https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=500&auto=format&fit=crop&q=80"],
          quantity: "1 plate",
          price: 250.0,
          discountPercent: 10.0,
          superCategory: "What are you craving?",
          subCategory: "Biryani",
          subSubCategory: "Chicken",
          description: "Fragrant basmati rice layered with spiced marinated chicken and slow-cooked to perfection.",
          productDetail: "Contains chicken pieces, basmati rice, eggs, raita, and salan.",
          returnPolicy: "Non-returnable item.",
          restaurantName: "The urban bite",
          variants: [
            ProductVariant(quantity: "Half (1 plate)", price: 250.0, discountPercent: 10.0),
            ProductVariant(quantity: "Full (2 plates)", price: 450.0, discountPercent: 15.0),
          ],
          rating: 4.5,
          deliveryTime: 25,
          isVeg: false,
        ),
        ProductModel(
          id: "pizza_1",
          name: "Pepperoni Pizza Classic",
          images: ["https://images.unsplash.com/photo-1513104890138-7c749659a591?w=500&auto=format&fit=crop&q=80"],
          quantity: "Medium size (8 inch)",
          price: 399.0,
          discountPercent: 15.0,
          superCategory: "What are you craving?",
          subCategory: "Pizzas",
          subSubCategory: "Non-Veg",
          description: "Fresh hand-tossed dough with rich marinara sauce, mozzarella cheese, and loaded with spicy pepperoni.",
          productDetail: "Contains cheese, pepperoni, wheat flour.",
          returnPolicy: "Non-returnable item.",
          restaurantName: "The urban bite",
          variants: [
            ProductVariant(quantity: "Regular (6 inch)", price: 249.0, discountPercent: 10.0),
            ProductVariant(quantity: "Medium (8 inch)", price: 399.0, discountPercent: 15.0),
            ProductVariant(quantity: "Large (12 inch)", price: 599.0, discountPercent: 20.0),
          ],
          rating: 4.3,
          deliveryTime: 30,
          isVeg: false,
        ),
        ProductModel(
          id: "burger_1",
          name: "Double Cheese Burger",
          images: ["https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500&auto=format&fit=crop&q=80"],
          quantity: "1 piece",
          price: 149.0,
          discountPercent: 0.0,
          superCategory: "What are you craving?",
          subCategory: "Burgers",
          subSubCategory: "Chicken",
          description: "Juicy flame-grilled chicken patties, cheddar cheese slices, tomatoes, onions, and burger sauce.",
          productDetail: "Contains dairy, wheat.",
          returnPolicy: "Non-returnable item.",
          restaurantName: "The urban bite",
          variants: [
            ProductVariant(quantity: "1 piece", price: 149.0, discountPercent: 0.0),
            ProductVariant(quantity: "Combo (2 pieces + Fries)", price: 299.0, discountPercent: 10.0),
          ],
          rating: 4.2,
          deliveryTime: 18,
          isVeg: false,
        ),
        ProductModel(
          id: "cake_1",
          name: "Chocolate Lava Fudge Cake",
          images: ["https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=500&auto=format&fit=crop&q=80"],
          quantity: "500 grams",
          price: 499.0,
          discountPercent: 20.0,
          superCategory: "What are you craving?",
          subCategory: "Cakes",
          subSubCategory: "Chocolate",
          description: "Warm, rich chocolate cake with a molten chocolate center that flows out upon cutting.",
          productDetail: "Contains chocolate, cream, egg, cocoa powder.",
          returnPolicy: "Non-returnable item.",
          restaurantName: "The urban bite",
          variants: [
            ProductVariant(quantity: "250 grams", price: 279.0, discountPercent: 15.0),
            ProductVariant(quantity: "500 grams", price: 499.0, discountPercent: 20.0),
            ProductVariant(quantity: "1 kg", price: 899.0, discountPercent: 25.0),
          ],
          rating: 4.8,
          deliveryTime: 35,
          isVeg: true,
        ),
        ProductModel(
          id: "noodles_1",
          name: "Veg Hakka Noodles",
          images: ["https://images.unsplash.com/photo-1585032226651-759b368d7246?w=500&auto=format&fit=crop&q=80"],
          quantity: "1 bowl",
          price: 179.0,
          discountPercent: 5.0,
          superCategory: "What are you craving?",
          subCategory: "Chinese",
          subSubCategory: "Noodles",
          description: "Stir-fried Chinese noodles tossed with shredded spring onions, carrots, bell peppers, and savory soy sauce.",
          productDetail: "Contains wheat noodles, mixed vegetables, soy sauce, garlic.",
          returnPolicy: "Non-returnable item.",
          restaurantName: "The urban bite",
          variants: [
            ProductVariant(quantity: "Half bowl", price: 99.0, discountPercent: 0.0),
            ProductVariant(quantity: "Full bowl", price: 179.0, discountPercent: 5.0),
          ],
          rating: 4.0,
          deliveryTime: 22,
          isVeg: true,
        ),
        ProductModel(
          id: "roll_1",
          name: "Paneer Tikka Roll",
          images: ["https://images.unsplash.com/photo-1626700051175-6518c4793f4f?w=500&auto=format&fit=crop&q=80"],
          quantity: "1 piece",
          price: 159.0,
          discountPercent: 0.0,
          superCategory: "What are you craving?",
          subCategory: "Rolls",
          subSubCategory: "Paneer",
          description: "Charcoal-grilled paneer cubes, capsicum, onions wrapped in a soft multi-grain paratha with mint mayonnaise.",
          productDetail: "Contains paneer, wheat paratha, mint mayonnaise, spices.",
          returnPolicy: "Non-returnable item.",
          restaurantName: "The urban bite",
          variants: [
            ProductVariant(quantity: "Single", price: 159.0, discountPercent: 0.0),
            ProductVariant(quantity: "Double (2 pieces)", price: 299.0, discountPercent: 10.0),
          ],
          rating: 4.4,
          deliveryTime: 20,
          isVeg: true,
        ),
      ];

      for (var p in foodProducts) {
        await _firestore.collection('products').doc(p.id).set(p.toJson());
      }

      debugPrint('Database seeded successfully.');
    } catch (e) {
      debugPrint('Error seeding database: $e');
    }
  }

  static Future<void> seedVegMenuFromCsv({BuildContext? context}) async {
    try {
      debugPrint('Starting veg menu CSV seeding check...');

      // Check if already seeded to avoid race conditions and redundant writes
      final seedCheck = await _firestore.collection('categories').doc('food_category_veg_v5').get();
      if (seedCheck.exists) {
        debugPrint('Veg menu is already seeded. Skipping seeder.');
        return;
      }

      // 1. Clear existing collections using fast batch deletes
      debugPrint('Clearing existing products, categories, and orders...');
      
      final categoryDocs = await _firestore.collection('categories').get();
      if (categoryDocs.docs.isNotEmpty) {
        final batch = _firestore.batch();
        for (var doc in categoryDocs.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }

      final productDocs = await _firestore.collection('products').get();
      if (productDocs.docs.isNotEmpty) {
        final int batchSize = 200;
        for (int i = 0; i < productDocs.docs.length; i += batchSize) {
          final end = (i + batchSize < productDocs.docs.length) ? i + batchSize : productDocs.docs.length;
          final batch = _firestore.batch();
          for (int j = i; j < end; j++) {
            batch.delete(productDocs.docs[j].reference);
          }
          await batch.commit();
        }
      }

      debugPrint('Existing database collections (products, categories) cleared.');

      // 2. Load and parse CSV
      final csvContent = await rootBundle.loadString('assets/veg-menu.csv');
      final lines = csvContent.split('\n');
      if (lines.isEmpty) {
        debugPrint('CSV file is empty!');
        return;
      }

      final Map<String, Set<String>> categoryStructure = {};
      final List<Map<String, String>> csvProductRows = [];

      // Skip the header row
      for (int i = 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;

        // Custom parser to split by comma, ignoring whitespace
        final List<String> parts = line.split(',').map((e) => e.trim()).toList();
        if (parts.length < 7) {
          debugPrint('Skipping malformed CSV line $i: $line');
          continue;
        }

        final categoryStr = parts[0];
        final subcategoryStr = parts[1];

        if (categoryStr.isEmpty || subcategoryStr.isEmpty) continue;

        categoryStructure.putIfAbsent(categoryStr, () => <String>{}).add(subcategoryStr);

        csvProductRows.add({
          'category': categoryStr,
          'subcategory': subcategoryStr,
          'itemId': parts[2],
          'nameEnglish': parts[3],
          'nameHindi': parts[4],
          'unit': parts[5],
          'price': parts[6],
          'variants': parts.length > 7 ? parts[7] : '',
          'description': parts.length > 8 ? parts[8] : '',
        });
      }

      // 3. Define Image mappings
      final Map<String, String> categoryImages = {
        "Breakfast & South Indian": "assets/categories/breakfast.jpg",
        "Starters & Chinese": "assets/categories/starters.jpg",
        "Indian Main Course": "assets/categories/main_course.jpg",
        "Roti, Rice & Sides": "assets/categories/roti_rice.jpg",
        "Pizza & Fast Food": "assets/categories/pizza_fastfood.jpg",
        "Combo & Thali": "assets/categories/combo_thali.jpg",
        "Beverages": "assets/categories/beverages.jpg",
        "Sweets & Ice Cream": "assets/categories/sweets.jpg",
      };

      final Map<String, String> subcategoryImages = {
        "Paratha": "assets/categories/breakfast.jpg",
        "Chole & Pav Bhaji": "assets/categories/breakfast.jpg",
        "Chaat & Snacks": "assets/categories/starters.jpg",
        "Chai & Coffee": "assets/categories/beverages.jpg",
        "Soup": "assets/categories/starters.jpg",
        "Dosa": "assets/categories/breakfast.jpg",
        "Idli & Uttapam": "assets/categories/breakfast.jpg",
        "Momos": "assets/categories/starters.jpg",
        "Chinese Starters": "assets/categories/starters.jpg",
        "Tandoori Starters": "assets/categories/starters.jpg",
        "Kebabs": "assets/categories/starters.jpg",
        "Manchurian & Chilli": "assets/categories/starters.jpg",
        "Noodles": "assets/categories/roti_rice.jpg",
        "Fried Rice": "assets/categories/roti_rice.jpg",
        "Paneer Sabzi": "assets/categories/main_course.jpg",
        "Veg Sabzi": "assets/categories/main_course.jpg",
        "Mushroom": "assets/categories/main_course.jpg",
        "Dal": "assets/categories/main_course.jpg",
        "Roti & Paratha": "assets/categories/roti_rice.jpg",
        "Naan & Kulcha": "assets/categories/roti_rice.jpg",
        "Rice & Biryani": "assets/categories/roti_rice.jpg",
        "Papad, Salad & Raita": "assets/categories/main_course.jpg",
        "Pizza": "assets/categories/pizza_fastfood.jpg",
        "Burger & Sandwich": "assets/categories/pizza_fastfood.jpg",
        "Fries & Crispy Snacks": "assets/categories/pizza_fastfood.jpg",
        "Pasta": "assets/categories/pizza_fastfood.jpg",
        "Maggi": "assets/categories/pizza_fastfood.jpg",
        "Sizzler": "assets/categories/pizza_fastfood.jpg",
        "Thali": "assets/categories/combo_thali.jpg",
        "Indian Combo": "assets/categories/combo_thali.jpg",
        "Chinese Combo": "assets/categories/combo_thali.jpg",
        "Shakes & Cold Coffee": "assets/categories/beverages.jpg",
        "Mojito & Mocktails": "assets/categories/beverages.jpg",
        "Soda & Lime": "assets/categories/beverages.jpg",
        "Iced Tea": "assets/categories/beverages.jpg",
        "Sundae": "assets/categories/sweets.jpg",
        "Sweets": "assets/categories/sweets.jpg",
        "Ice Cream": "assets/categories/sweets.jpg",
      };

      // 4. Save the craving category structure to Firestore
      final List<Category> categoriesList = [];
      categoryStructure.forEach((catName, subCatsSet) {
        final List<Category> subCategoriesList = [];
        for (var subCatName in subCatsSet) {
          final img = subcategoryImages[subCatName] ?? "assets/categories/combo_thali.jpg";
          subCategoriesList.add(Category(name: subCatName, image: img));
        }
        final catImg = categoryImages[catName] ?? "assets/categories/main_course.jpg";
        categoriesList.add(Category(
          name: catName,
          image: catImg,
          subCategories: subCategoriesList,
        ));
      });

      final supCat = SupCatModel(
        name: "What are you craving?",
        categories: categoriesList,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('categories')
          .doc('food_category_veg')
          .set(supCat.toMap());

      debugPrint('Seeded SupCatModel: What are you craving?');

      // 5. Parse and Batch Upload Products
      final random = Random();
      final List<ProductModel> productsToSeed = [];

      for (var row in csvProductRows) {
        final category = row['category']!;
        final subcategory = row['subcategory']!;
        final itemId = row['itemId']!;
        final nameEnglish = row['nameEnglish']!;
        final nameHindi = row['nameHindi']!;
        final unit = row['unit']!;
        final price = double.tryParse(row['price']!) ?? 0.0;
        final variantsStr = row['variants']!;
        final description = row['description']!;

        final img = categoryImages[category] ?? "assets/categories/combo_thali.jpg";

        // Parse variants
        final List<ProductVariant> variantsList = [];
        double mainPrice = price;
        String mainQuantity = unit;

        if (variantsStr.isNotEmpty) {
          final variantParts = variantsStr.split('|');
          for (var part in variantParts) {
            final splitPart = part.split(':');
            if (splitPart.length == 2) {
              final q = splitPart[0].trim();
              final p = double.tryParse(splitPart[1].trim()) ?? 0.0;
              variantsList.add(ProductVariant(quantity: q, price: p, discountPercent: 0.0));
            }
          }
        }

        if (variantsList.isEmpty) {
          // If no variants specified, use the main unit and price
          variantsList.add(ProductVariant(quantity: unit, price: price, discountPercent: 0.0));
        } else {
          // If there are variants, set the main price and quantity to the first variant
          mainPrice = variantsList.first.price;
          mainQuantity = variantsList.first.quantity;
        }

        final rating = 4.0 + (random.nextDouble() * 0.9); // rating between 4.0 and 4.9
        final deliveryTime = 15 + random.nextInt(21); // delivery time between 15 and 35 minutes

        final product = ProductModel(
          id: itemId,
          name: nameEnglish,
          images: [img],
          quantity: mainQuantity,
          price: mainPrice,
          discountPercent: 0.0,
          superCategory: "What are you craving?",
          subCategory: category,
          subSubCategory: subcategory,
          description: description.isNotEmpty
              ? description
              : "Delicious $nameEnglish, prepared fresh with select ingredients.",
          productDetail: "Freshly prepared vegetarian dish: $nameEnglish ($nameHindi).",
          returnPolicy: "Non-returnable item.",
          restaurantName: "The Urban Bite",
          variants: variantsList,
          rating: double.parse(rating.toStringAsFixed(1)),
          deliveryTime: deliveryTime,
          isVeg: true,
        );

        productsToSeed.add(product);
      }

      // Write in batches of 200 items (Firestore limit is 500 writes per batch)
      final int batchSize = 200;
      for (int i = 0; i < productsToSeed.length; i += batchSize) {
        final end = (i + batchSize < productsToSeed.length) ? i + batchSize : productsToSeed.length;
        final batch = _firestore.batch();
        for (int j = i; j < end; j++) {
          final p = productsToSeed[j];
          final docRef = _firestore.collection('products').doc(p.id);
          batch.set(docRef, p.toJson());
        }
        await batch.commit();
        debugPrint('Seeded batch ${i ~/ batchSize + 1} (${end - i} products)');
      }

      // Write the seed flag document to prevent running seeder again
      await _firestore.collection('categories').doc('food_category_veg_v5').set({
        'seeded': true,
        'timestamp': FieldValue.serverTimestamp(),
      });

      debugPrint('Seeding completed. Total products: ${productsToSeed.length}');

      // Auto-refresh client app state if context is provided and mounted
      if (context != null && context.mounted) {
        try {
          debugPrint('Refreshing category and product state in UI...');
          Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
          Provider.of<ProductProvider>(context, listen: false).fetchProducts();
        } catch (e) {
          debugPrint('Error refreshing state after seeding: $e');
        }
      }
    } catch (e) {
      debugPrint('Error during CSV seeding: $e');
    }
  }

  static Future<void> seedNonVegMenuFromCsv({BuildContext? context}) async {
    try {
      debugPrint('Starting non-veg menu CSV seeding check...');

      // Check if already seeded to avoid race conditions and redundant writes
      final seedCheck = await _firestore.collection('categories').doc('food_category_nonveg_v5').get();
      if (seedCheck.exists) {
        debugPrint('Non-veg menu is already seeded. Skipping seeder.');
        return;
      }

      debugPrint('Seeding non-veg menu...');

      // 2. Load and parse CSV
      final csvContent = await rootBundle.loadString('assets/non-veg-menu.csv');
      final lines = csvContent.split('\n');

      final Map<String, Set<String>> categoryStructure = {};
      final List<Map<String, String>> csvProductRows = [];

      // Skip the header row
      for (int i = 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;

        // Custom parser to split by comma
        final List<String> parts = line.split(',').map((e) => e.trim()).toList();
        if (parts.length < 8) {
          debugPrint('Skipping malformed non-veg CSV line $i: $line');
          continue;
        }

        final categoryStr = parts[0];
        final subcategoryStr = parts[1];

        if (categoryStr.isEmpty || subcategoryStr.isEmpty) continue;

        categoryStructure.putIfAbsent(categoryStr, () => <String>{}).add(subcategoryStr);

        csvProductRows.add({
          'category': categoryStr,
          'subcategory': subcategoryStr,
          'itemId': parts[2],
          'name': parts[3],
          'nameHindi': parts[4],
          'type': parts[5],
          'unit': parts[6],
          'price': parts[7],
          'variants': parts.length > 8 ? parts[8] : '',
          'description': parts.length > 9 ? parts[9] : '',
        });
      }

      // 3. Define Image mappings
      final Map<String, String> categoryImages = {
        "Soup & Momos": "assets/categories/soup_momos.jpg",
        "Chicken Starters": "assets/categories/chicken_starters.jpg",
        "Continental": "assets/categories/continental.jpg",
        "Tandoori Starters": "assets/categories/tandoori_starters_nonveg.jpg",
        "Main Course": "assets/categories/main_course_nonveg.jpg",
        "Biryani & Chinese": "assets/categories/biryani_chinese.jpg",
        "Pizza": "assets/categories/pizza_nonveg.jpg",
        "Roti & Thali": "assets/categories/roti_thali_nonveg.jpg",
      };

      final Map<String, String> subcategoryImages = {
        "Soup": "assets/categories/soup_momos.jpg",
        "Momos": "assets/categories/soup_momos.jpg",
        "Dry Starters": "assets/categories/chicken_starters.jpg",
        "Gravy Starters": "assets/categories/chicken_starters.jpg",
        "Lollipop & Wings": "assets/categories/chicken_starters.jpg",
        "Fried Chicken": "assets/categories/continental.jpg",
        "Chicken & Fish Fry": "assets/categories/continental.jpg",
        "Tikka & Tandoori": "assets/categories/tandoori_starters_nonveg.jpg",
        "Seekh Kabab": "assets/categories/tandoori_starters_nonveg.jpg",
        "Bhuna Gosht": "assets/categories/tandoori_starters_nonveg.jpg",
        "Chicken Curry": "assets/categories/main_course_nonveg.jpg",
        "Mutton Curry": "assets/categories/main_course_nonveg.jpg",
        "Egg & Fish": "assets/categories/main_course_nonveg.jpg",
        "Biryani": "assets/categories/biryani_chinese.jpg",
        "Fried Rice": "assets/categories/biryani_chinese.jpg",
        "Noodles": "assets/categories/biryani_chinese.jpg",
        "Chicken Pizza": "assets/categories/pizza_nonveg.jpg",
        "Roti & Paratha": "assets/categories/roti_thali_nonveg.jpg",
        "Naan": "assets/categories/roti_thali_nonveg.jpg",
        "Thali": "assets/categories/roti_thali_nonveg.jpg",
      };

      // 4. Save the craving category structure to Firestore (under main category "What are you craving for(non-veg)? ")
      final List<Category> categoriesList = [];
      categoryStructure.forEach((catName, subCatsSet) {
        final List<Category> subCategoriesList = [];
        for (var subCatName in subCatsSet) {
          final img = subcategoryImages[subCatName] ?? "assets/categories/roti_thali_nonveg.jpg";
          subCategoriesList.add(Category(name: subCatName, image: img));
        }
        final catImg = categoryImages[catName] ?? "assets/categories/main_course.jpg";
        categoriesList.add(Category(
          name: catName,
          image: catImg,
          subCategories: subCategoriesList,
        ));
      });

      final supCat = SupCatModel(
        name: "What are you craving for(non-veg)? ",
        categories: categoriesList,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('categories')
          .doc('food_category_nonveg')
          .set(supCat.toMap());

      debugPrint('Seeded SupCatModel: What are you craving for(non-veg)? ');

      // 5. Parse and Batch Upload Products
      final random = Random();
      final List<ProductModel> productsToSeed = [];

      for (var row in csvProductRows) {
        final itemId = row['itemId']!;
        final name = row['name']!;
        final nameHindi = row['nameHindi']!;
        final type = row['type']!;
        final unit = row['unit']!;
        final priceStr = row['price']!;
        final variantsStr = row['variants']!;
        final description = row['description']!;

        final subCategory = row['category']!;
        final subSubCategory = row['subcategory']!;

        final double basePrice = double.tryParse(priceStr) ?? 0.0;
        final bool isVegProduct = (type == 'veg');

        // Variants parsing
        final List<ProductVariant> variantsList = [];
        if (variantsStr.isNotEmpty) {
          // Format: Half: 200 | Full: 380
          final parts = variantsStr.split('|');
          for (var p in parts) {
            final vParts = p.split(':');
            if (vParts.length == 2) {
              final vName = vParts[0].trim();
              final vPrice = double.tryParse(vParts[1].trim()) ?? basePrice;
              variantsList.add(ProductVariant(
                quantity: vName,
                price: vPrice,
                discountPercent: 0.0,
              ));
            }
          }
        }

        double mainPrice = basePrice;
        String mainQuantity = unit;

        if (variantsList.isEmpty) {
          // If no variants specified, use the main unit and price
          variantsList.add(ProductVariant(quantity: unit, price: basePrice, discountPercent: 0.0));
        } else {
          // If there are variants, set the main price and quantity to the first variant
          mainPrice = variantsList.first.price;
          mainQuantity = variantsList.first.quantity;
        }

        // Random rating between 4.0 and 4.9
        final rating = 4.0 + random.nextInt(10) / 10.0;

        // Random delivery time between 15 and 35
        final deliveryTime = 15 + random.nextInt(21);

        // Product image mapping
        final imgPath = categoryImages[subCategory] ?? "assets/categories/roti_thali_nonveg.jpg";

        final p = ProductModel(
          id: itemId,
          name: name,
          price: mainPrice,
          quantity: mainQuantity,
          discountPercent: 0.0,
          description: description.isNotEmpty ? description : '$name - Fresh and hot.',
          productDetail: 'Cooked fresh with premium quality ingredients: $name ($nameHindi).',
          returnPolicy: 'Non-returnable. Fresh food items are not eligible for return.',
          restaurantName: 'The Urban Bite',
          isVeg: isVegProduct,
          rating: rating,
          deliveryTime: deliveryTime,
          superCategory: 'What are you craving for(non-veg)? ',
          subCategory: subCategory,
          subSubCategory: subSubCategory,
          images: [imgPath],
          video: '',
          variants: variantsList,
        );

        productsToSeed.add(p);
      }

      // Write products in batches of 200 to Firestore
      final int batchSize = 200;
      for (int i = 0; i < productsToSeed.length; i += batchSize) {
        final end = (i + batchSize < productsToSeed.length) ? i + batchSize : productsToSeed.length;
        final batch = _firestore.batch();
        for (int j = i; j < end; j++) {
          final p = productsToSeed[j];
          final docRef = _firestore.collection('products').doc(p.id);
          batch.set(docRef, p.toJson());
        }
        await batch.commit();
        debugPrint('Seeded batch ${i ~/ batchSize + 1} (${end - i} products)');
      }

      // Write the seed flag document to prevent running seeder again
      await _firestore.collection('categories').doc('food_category_nonveg_v5').set({
        'seeded': true,
        'timestamp': FieldValue.serverTimestamp(),
      });

      debugPrint('Non-veg Seeding completed. Total products: ${productsToSeed.length}');

      // Auto-refresh client app state if context is provided and mounted
      if (context != null && context.mounted) {
        try {
          debugPrint('Refreshing category and product state in UI...');
          Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
          Provider.of<ProductProvider>(context, listen: false).fetchProducts();
        } catch (e) {
          debugPrint('Error refreshing state after seeding: $e');
        }
      }
    } catch (e) {
      debugPrint('Error during Non-veg CSV seeding: $e');
    }
  }
}

