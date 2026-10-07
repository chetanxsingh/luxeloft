import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/app_assets.dart';
import '../core/app_theme.dart';
import '../models/home_models.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/seed_service.dart';

/// Every piece of content on this screen is streamed from Cloud Firestore.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _db = FirestoreService.instance;
  final _bannerController = PageController();
  int _bannerIndex = 0;
  String? _selectedTab;

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = AuthService.instance.currentUser?.uid;
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _header(),
          SizedBox(height: 14.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (uid != null)
                  StreamBuilder(
                    stream: _db.userStream(uid),
                    builder: (_, snap) {
                      final user = AuthService.instance.currentUser;
                      final data = snap.data?.data();
                      final name = (data?['name'] as String?)?.trim().isNotEmpty == true
                          ? data!['name'] as String
                          : (user?.displayName ??
                          user?.email?.split('@').first ??
                          user?.phoneNumber ??
                          'there');
                      return Text('Hi, $name',
                          style: AppText.dmSans(11, weight: FontWeight.w500));
                    },
                  ),
                SizedBox(height: 4.h),
                StreamBuilder<String>(
                  stream: _db.headline(),
                  builder: (_, snap) => Text(
                    snap.data ?? 'What are you looking for today?',
                    style: AppText.dmSans(20),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          _banners(),
          SizedBox(height: 16.h),
          _tabsAndProducts(),
        ],
      ),
    );
  }

  // ---------------- header ----------------
  Widget _header() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: 16.w, height: 1.6, color: AppColors.ink),
              SizedBox(height: 4.h),
              Container(width: 10.w, height: 1.6, color: AppColors.ink),
            ],
          ),
          GestureDetector(
            // Debug-only helper: long-press the logo to seed Firestore sample data.
            onLongPress: kDebugMode
                ? () async {
              try {
                await SeedService.run();
                if (mounted) showAppSnack(context, 'Sample data written to Firestore');
              } catch (e) {
                if (mounted) showAppSnack(context, 'Seed failed: $e', error: true);
              }
            }
                : null,
            child: Image.asset(AppAssets.logo, height: 38.h),
          ),
          Row(
            children: [
              Icon(Icons.search, size: 22.r),
              SizedBox(width: 10.w),
              Icon(Icons.crop_free, size: 20.r),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- banner ----------------
  Widget _banners() {
    return StreamBuilder<List<HomeBanner>>(
      stream: _db.banners(),
      builder: (_, snap) {
        final banners = snap.data ?? [];
        if (snap.connectionState == ConnectionState.waiting) {
          return SizedBox(
              height: 0.58.sw,
              child: const Center(child: CircularProgressIndicator()));
        }
        if (banners.isEmpty) return const SizedBox.shrink();
        return Column(
          children: [
            AspectRatio(
              aspectRatio: 1499 / 844,
              child: PageView.builder(
                controller: _bannerController,
                itemCount: banners.length,
                onPageChanged: (i) => setState(() => _bannerIndex = i),
                itemBuilder: (_, i) {
                  final b = banners[i];
                  if (b.imageUrl.isNotEmpty) {
                    return Image.network(b.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                        const ColoredBox(color: Color(0xFFFDD35C)));
                  }
                  return Image.asset(
                      b.asset.isNotEmpty ? b.asset : AppAssets.banner,
                      fit: BoxFit.cover);
                },
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                banners.length,
                    (i) => Container(
                  width: 5.r,
                  height: 5.r,
                  margin: EdgeInsets.symmetric(horizontal: 2.5.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == _bannerIndex
                        ? AppColors.orange
                        : const Color(0xFFE2D6C0),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ---------------- tabs + categories + products ----------------
  Widget _tabsAndProducts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StreamBuilder<List<HomeTab>>(
          stream: _db.tabs(),
          builder: (_, snap) {
            final tabs = snap.data ?? [];
            if (tabs.isEmpty) return const SizedBox(height: 24);
            _selectedTab ??=
                (tabs.where((t) => t.isDefault).firstOrNull ?? tabs.first).title;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: tabs.map((t) {
                  final selected = t.title == _selectedTab;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedTab = t.title),
                    child: Padding(
                      padding: EdgeInsets.only(right: 18.w),
                      child: Column(
                        children: [
                          Text(t.title,
                              style: AppText.poppins(8.5, weight: FontWeight.w700)),
                          SizedBox(height: 4.h),
                          Container(
                            height: 2,
                            width: 26.w,
                            color: selected ? AppColors.amber : Colors.transparent,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 6.h),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text('See More',
                style: AppText.poppins(7.5,
                    weight: FontWeight.w600, color: AppColors.amber)),
          ),
        ),
        _categories(),
        SizedBox(height: 12.h),
        _products(),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _categories() {
    return StreamBuilder<List<HomeCategory>>(
      stream: _db.categories(),
      builder: (_, snap) {
        final cats = snap.data ?? [];
        if (cats.isEmpty) return const SizedBox.shrink();
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          itemCount: cats.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 10.h,
            crossAxisSpacing: 10.w,
            childAspectRatio: 0.85,
          ),
          itemBuilder: (_, i) {
            final c = cats[i];
            return Column(
              children: [
                Container(
                  width: 52.r,
                  height: 52.r,
                  decoration: BoxDecoration(
                    color: AppColors.fieldFill.withAlpha(90),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.fieldBorder),
                  ),
                  padding: EdgeInsets.all(5.r),
                  child: _categoryImage(c),
                ),
                SizedBox(height: 6.h),
                Text(c.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.poppins(8, color: AppColors.grey, height: 1.3)),
              ],
            );
          },
        );
      },
    );
  }

  /// Priority: network image (iconUrl) -> bundled image (assetPath) -> Material icon.
  Widget _categoryImage(HomeCategory c) {
    final fallback = Icon(c.iconData, color: AppColors.amber, size: 24.r);
    if (c.iconUrl.isNotEmpty) {
      return Image.network(c.iconUrl,
          fit: BoxFit.contain, errorBuilder: (_, __, ___) => fallback);
    }
    return Image.asset(
      c.assetPath,
      fit: BoxFit.contain,
      errorBuilder: (_, error, __) {
        debugPrint('Category image failed: ${c.assetPath} -> $error');
        return fallback;
      },
    );
  }

  Widget _products() {
    return StreamBuilder<List<Product>>(
      stream: _db.products(),
      builder: (_, snap) {
        if (snap.hasError) {
          return Padding(
            padding: EdgeInsets.all(16.r),
            child: Text('Could not load products: ${snap.error}',
                style: AppText.poppins(10, color: Colors.red)),
          );
        }
        if (!snap.hasData) {
          return const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()));
        }
        final all = snap.data!;
        final list = (_selectedTab == null || _selectedTab == 'Recommend')
            ? all
            : all.where((p) => p.tab == _selectedTab).toList();
        if (list.isEmpty) {
          return Padding(
            padding: EdgeInsets.all(24.r),
            child: Center(
                child: Text('No products in this tab yet.',
                    style: AppText.poppins(10, color: AppColors.grey))),
          );
        }
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          itemCount: list.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14.h,
            crossAxisSpacing: 14.w,
            childAspectRatio: 0.72,
          ),
          itemBuilder: (_, i) => _ProductCard(product: list[i]),
        );
      },
    );
  }
}

class _ProductCard extends StatefulWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _fav = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    return Container(
      padding: EdgeInsets.fromLTRB(10.w, 8.h, 10.w, 8.h),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 10, offset: Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _fav = !_fav),
            child: Icon(_fav ? Icons.favorite : Icons.favorite_border,
                size: 14.r, color: _fav ? Colors.red : AppColors.ink),
          ),
          Expanded(
            child: Center(
              child: p.imageUrl.isEmpty
                  ? Icon(Icons.image_outlined, size: 40.r, color: AppColors.grey)
                  : Image.network(p.imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(
                      Icons.broken_image_outlined,
                      color: AppColors.grey,
                      size: 36.r)),
            ),
          ),
          SizedBox(height: 6.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.poppins(10, weight: FontWeight.w500)),
                    SizedBox(height: 2.h),
                    Text(p.priceLabel,
                        style: AppText.poppins(10.5, weight: FontWeight.w600)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => showAppSnack(context, '${p.name} added to cart'),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 4.h),
                  decoration: BoxDecoration(
                      color: AppColors.orange,
                      borderRadius: BorderRadius.circular(3.r)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shopping_cart_outlined,
                          size: 9.r, color: Colors.white),
                      SizedBox(width: 3.w),
                      Text('Add',
                          style: AppText.poppins(8,
                              weight: FontWeight.w600, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Icon(Icons.star_rounded, size: 11.r, color: AppColors.amber),
              SizedBox(width: 3.w),
              Text('${p.rating}', style: AppText.poppins(7.5)),
              SizedBox(width: 8.w),
              Text('${p.reviews} Reviews', style: AppText.poppins(7.5)),
              const Spacer(),
              Icon(Icons.more_vert, size: 13.r, color: AppColors.grey),
            ],
          ),
        ],
      ),
    );
  }
}