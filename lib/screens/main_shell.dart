import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/app_theme.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _items = [
    (Icons.home_rounded, Icons.home_rounded, 'Home'),
    (Icons.grid_view_outlined, Icons.grid_view_rounded, 'Category'),
    (Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded, 'Message'),
    (Icons.shopping_cart_outlined, Icons.shopping_cart, 'Cart'),
    (Icons.person_outline_rounded, Icons.person_rounded, 'Private'),
  ];

  Widget _body() {
    switch (_index) {
      case 0:
        return const HomeScreen();
      case 4:
        return const _PrivateTab();
      default:
        return Center(
            child: Text('${_items[_index].$3} - coming soon',
                style: AppText.poppins(12, color: AppColors.grey)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: _body(),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.cream,
          border: Border(top: BorderSide(color: Color(0xFFEDE3D2))),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 62.h,
            child: Row(
              children: List.generate(_items.length, (i) {
                final selected = i == _index;
                final item = _items[i];
                return Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _index = i),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(selected ? item.$2 : item.$1,
                            size: 22.r,
                            color: selected ? AppColors.amber : AppColors.grey),
                        SizedBox(height: 4.h),
                        Text(item.$3,
                            style: AppText.poppins(8.5,
                                weight: FontWeight.w500,
                                letterSpacing: 0.6,
                                color: selected
                                    ? AppColors.amber
                                    : AppColors.grey)),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _PrivateTab extends StatelessWidget {
  const _PrivateTab();

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.account_circle_outlined, size: 64.r, color: AppColors.teal),
          SizedBox(height: 12.h),
          Text(user?.email ?? user?.phoneNumber ?? 'Signed in',
              style: AppText.poppins(12, weight: FontWeight.w500)),
          SizedBox(height: 20.h),
          OutlinedButton.icon(
            icon: const Icon(Icons.logout),
            label: const Text('Log out'),
            onPressed: () async {
              await AuthService.instance.signOut();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false);
            },
          ),
        ],
      ),
    );
  }
}
