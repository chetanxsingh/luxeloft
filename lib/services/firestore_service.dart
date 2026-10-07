import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/home_models.dart';

class FirestoreService {
  FirestoreService._();
  static final instance = FirestoreService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---------- users ----------
  /// Saves / updates `users/{uid}`. Returns true when the document was newly created.
  Future<bool> saveUser(User user, {String? phone, String? name}) async {
    final ref = _db.collection('users').doc(user.uid);
    final existing = await ref.get();

    final data = <String, Object?>{
      'uid': user.uid,
      'email': user.email,
      'phone': phone ?? user.phoneNumber,
      'name': name ?? user.displayName,
      'photoUrl': user.photoURL,
      'provider': user.providerData.isNotEmpty
          ? user.providerData.first.providerId
          : 'password',
      'lastLoginAt': FieldValue.serverTimestamp(),
      if (!existing.exists) 'createdAt': FieldValue.serverTimestamp(),
    }..removeWhere((_, v) => v == null);

    await ref.set(data, SetOptions(merge: true));
    return !existing.exists;
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> userStream(String uid) =>
      _db.collection('users').doc(uid).snapshots();

  // ---------- home screen content ----------
  Stream<String> headline() => _db
      .collection('app_config')
      .doc('home')
      .snapshots()
      .map((d) => (d.data()?['headline'] ?? 'What are you looking for today?') as String);

  Stream<List<HomeBanner>> banners() => _db
      .collection('banners')
      .orderBy('order')
      .snapshots()
      .map((s) => s.docs.map(HomeBanner.fromDoc).toList());

  Stream<List<HomeTab>> tabs() => _db
      .collection('tabs')
      .orderBy('order')
      .snapshots()
      .map((s) => s.docs.map(HomeTab.fromDoc).toList());

  Stream<List<HomeCategory>> categories() => _db
      .collection('categories')
      .orderBy('order')
      .snapshots()
      .map((s) => s.docs.map(HomeCategory.fromDoc).toList());

  Stream<List<Product>> products() => _db
      .collection('products')
      .orderBy('order')
      .snapshots()
      .map((s) => s.docs.map(Product.fromDoc).toList());
}
