import 'dart:math' as math;

import 'package:dharma_app/Home/home_view.dart';
import 'package:dharma_app/Profile/profile_view.dart';
import 'package:dharma_app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

enum AppNavItem {
  home,
  panchang,
  sanathanId,
  chants,
  ganaMatch,
}

class CommonBottomNav extends StatelessWidget {
  const CommonBottomNav({
    super.key,
    required this.currentItem,
    required this.scale,
    required this.safeBottom,
    required this.centerNavSize,
    required this.height,
  });

  final AppNavItem currentItem;
  final double scale;
  final double safeBottom;
  final double centerNavSize;
  final double height;

  static double navHeight(double safeBottom) => 84.0 + safeBottom;

  static double centerSize(double scale) => 88.0 * scale;

  @override
  Widget build(BuildContext context) {
    final centerLift = centerNavSize * 0.22;

    return SizedBox(
      height: height + centerLift,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: height,
              padding: EdgeInsets.fromLTRB(
                12 * scale,
                12 * scale,
                12 * scale,
                math.max(10, safeBottom),
              ),
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(22),
                  topRight: Radius.circular(22),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 16,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _NavItem(
                      label: 'Home',
                      icon: Icons.home_filled,
                      selected: currentItem == AppNavItem.home,
                      onTap: () => _handleTap(context, AppNavItem.home),
                    ),
                  ),
                  Expanded(
                    child: _NavItem(
                      label: 'Panchang',
                      icon: Icons.wb_twilight,
                      selected: currentItem == AppNavItem.panchang,
                      onTap: () => _handleTap(context, AppNavItem.panchang),
                    ),
                  ),
                  SizedBox(width: centerNavSize * 0.95),
                  Expanded(
                    child: _NavItem(
                      label: 'Chants',
                      icon: Icons.auto_awesome,
                      selected: currentItem == AppNavItem.chants,
                      onTap: () => _handleTap(context, AppNavItem.chants),
                    ),
                  ),
                  Expanded(
                    child: _NavItem(
                      label: 'Gana Match',
                      icon: Icons.favorite,
                      selected: currentItem == AppNavItem.ganaMatch,
                      onTap: () => _handleTap(context, AppNavItem.ganaMatch),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: height - centerLift - centerNavSize * 0.68,
            child: _CenterNavItem(
              size: centerNavSize,
              selected: currentItem == AppNavItem.sanathanId,
              onTap: () => _handleTap(context, AppNavItem.sanathanId),
            ),
          ),
        ],
      ),
    );
  }

  void _handleTap(BuildContext context, AppNavItem item) {
    if (item == currentItem) return;

    switch (item) {
      case AppNavItem.home:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeView()),
          (route) => false,
        );
        break;
      case AppNavItem.sanathanId:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileView()),
        );
        break;
      case AppNavItem.panchang:
      case AppNavItem.chants:
      case AppNavItem.ganaMatch:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_labelFor(item)} coming soon')),
        );
        break;
    }
  }

  String _labelFor(AppNavItem item) {
    switch (item) {
      case AppNavItem.home:
        return 'Home';
      case AppNavItem.panchang:
        return 'Panchang';
      case AppNavItem.sanathanId:
        return 'Sanathan ID';
      case AppNavItem.chants:
        return 'Chants';
      case AppNavItem.ganaMatch:
        return 'Gana Match';
    }
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scale = (MediaQuery.of(context).size.width / 390).clamp(0.84, 1.08);
    final color = selected ? AppColors.profileHeader : AppColors.homePrimary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(icon, size: 30 * scale, color: color),
          SizedBox(height: 4 * scale),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyle(
              fontSize: label == 'Gana Match' ? 11 * scale : 12.5 * scale,
              color: color,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _CenterNavItem extends StatelessWidget {
  const _CenterNavItem({
    required this.size,
    required this.selected,
    required this.onTap,
  });

  final double size;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scale = (MediaQuery.of(context).size.width / 390).clamp(0.84, 1.08);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [
              AppColors.homeBannerGoldDark,
              AppColors.homeBannerGoldLight,
              AppColors.homeBannerGoldMid,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? const Color(0x330B0A79)
                  : const Color(0x22000000),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: size * 0.38,
              height: size * 0.38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected
                    ? AppColors.profileHeader
                    : AppColors.homePrimary,
              ),
              child: Padding(
                padding: EdgeInsets.all(size * 0.08),
                child: Image.asset(
                  'assets/images/dharma.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(height: 6 * scale),
            Text(
              'Sanathan ID',
              style: TextStyle(
                fontSize: 11.5 * scale,
                color: AppColors.homePrimary,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
