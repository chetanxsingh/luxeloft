import 'package:cloud_firestore/cloud_firestore.dart';

/// OPTIONAL helper (debug builds only): long-press the logo on Home to write the
/// same sample documents you would otherwise type into the Firebase console.
class SeedService {
  static Future<void> run() async {
    final db = FirebaseFirestore.instance;
    final batch = db.batch();

    batch.set(db.doc('app_config/home'),
        {'headline': 'What are you looking for today?'});

    batch.set(db.doc('banners/b1'),
        {'order': 1, 'imageUrl': '', 'asset': 'assets/images/banner.png'});
    batch.set(db.doc('banners/b2'),
        {'order': 2, 'imageUrl': '', 'asset': 'assets/images/banner.png'});
    batch.set(db.doc('banners/b3'),
        {'order': 3, 'imageUrl': '', 'asset': 'assets/images/banner.png'});
    batch.set(db.doc('banners/b4'),
        {'order': 4, 'imageUrl': '', 'asset': 'assets/images/banner.png'});

    const tabs = ['Recommend', 'Cell Phone', 'Car Products', 'Department Store', 'Computer'];
    for (var i = 0; i < tabs.length; i++) {
      batch.set(db.doc('tabs/t${i + 1}'),
          {'title': tabs[i], 'order': i + 1, 'isDefault': tabs[i] == 'Cell Phone'});
    }

    const cats = [
      ['Beauty', 'beauty'], ['Offers', 'offers'], ['Fashion', 'fashion'], ['Home', 'home'],
      ['Shirt', 'shirt'], ['Woman Bag', 'bag'], ['Dress', 'dress'], ['Mobiles', 'mobiles'],
    ];
    for (var i = 0; i < cats.length; i++) {
      batch.set(db.doc('categories/c${i + 1}'),
          {
            'title': cats[i][0],
            'icon': cats[i][1],
            'iconUrl': '',
            'iconAsset': 'assets/images/categories/${cats[i][1]}.png',
            'order': i + 1,
          });
    }

    batch.set(db.doc('products/p1'), {
      'name': 'Multi Kit', 'price': 500, 'rating': 4.6, 'reviews': 86,
      'tab': 'Cell Phone', 'order': 1,
      'imageUrl': 'https://picsum.photos/seed/multikit/300/300',
    });
    batch.set(db.doc('products/p2'), {
      'name': 'Lipstick', 'price': 400, 'rating': 4.6, 'reviews': 86,
      'tab': 'Cell Phone', 'order': 2,
      'imageUrl': 'https://picsum.photos/seed/lipstick/300/300',
    });

    await batch.commit();
  }
}