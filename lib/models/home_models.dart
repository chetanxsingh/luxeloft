import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Everything below is read from Cloud Firestore (see README for the schema).

class HomeBanner {
  final String id;
  final String imageUrl; // network image (optional)
  final String asset; // bundled fallback, e.g. assets/images/banner.png (optional)
  HomeBanner({required this.id, this.imageUrl = '', this.asset = ''});

  factory HomeBanner.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? {};
    return HomeBanner(
        id: d.id,
        imageUrl: (m['imageUrl'] ?? '') as String,
        asset: (m['asset'] ?? '') as String);
  }
}

class HomeTab {
  final String id;
  final String title;
  final bool isDefault;
  HomeTab({required this.id, required this.title, this.isDefault = false});

  factory HomeTab.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? {};
    return HomeTab(
        id: d.id,
        title: (m['title'] ?? '') as String,
        isDefault: (m['isDefault'] ?? false) as bool);
  }
}

class HomeCategory {
  final String id;
  final String title;
  final String iconUrl; // network image (optional)
  final String iconAsset; // bundled image, e.g. assets/images/categories/beauty.png (optional)
  final String icon; // key like "beauty" -> assets/images/categories/beauty.png
  HomeCategory(
      {required this.id,
        required this.title,
        this.iconUrl = '',
        this.iconAsset = '',
        this.icon = ''});

  factory HomeCategory.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? {};
    return HomeCategory(
        id: d.id,
        title: (m['title'] ?? '') as String,
        iconUrl: (m['iconUrl'] ?? '') as String,
        iconAsset: (m['iconAsset'] ?? '') as String,
        icon: (m['icon'] ?? '') as String);
  }

  /// Bundled image path. Uses `iconAsset` if set, otherwise builds it from the
  /// `icon` key (or the title), e.g. assets/images/categories/beauty.png
  String get assetPath {
    if (iconAsset.isNotEmpty) return iconAsset;
    final key = icon.isNotEmpty ? icon : title.toLowerCase().replaceAll(' ', '_');
    return 'assets/images/categories/$key.png';
  }

  IconData get iconData => const {
    'beauty': Icons.face_retouching_natural,
    'offers': Icons.local_offer,
    'fashion': Icons.checkroom,
    'home': Icons.chair_alt,
    'shirt': Icons.dry_cleaning,
    'bag': Icons.shopping_bag,
    'dress': Icons.woman,
    'mobiles': Icons.smartphone,
  }[icon] ??
      Icons.category_outlined;
}

class Product {
  final String id;
  final String name;
  final num price;
  final String imageUrl;
  final double rating;
  final int reviews;
  final String tab;
  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.rating,
    required this.reviews,
    required this.tab,
  });

  factory Product.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? {};
    return Product(
      id: d.id,
      name: (m['name'] ?? '') as String,
      price: (m['price'] ?? 0) as num,
      imageUrl: (m['imageUrl'] ?? '') as String,
      rating: ((m['rating'] ?? 0) as num).toDouble(),
      reviews: ((m['reviews'] ?? 0) as num).toInt(),
      tab: (m['tab'] ?? '') as String,
    );
  }

  String get priceLabel =>
      '\$${price % 1 == 0 ? price.toInt() : price.toStringAsFixed(2)}';
}