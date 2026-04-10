import 'package:dharma_app/Chants/chants_view.dart';
import 'package:dharma_app/GanaMatch/GanaMatch.dart';
import 'dart:math' as math;

import 'package:dharma_app/Home/home_view.dart';
import 'package:dharma_app/Panchang/panchang_view.dart';
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

  static double navHeight(double safeBottom) => 72.0 + safeBottom;

  static double centerSize(double scale) => 72.0 * scale;

  @override
  Widget build(BuildContext context) {
    final notchSize = centerNavSize * 1.72;

    return SizedBox(
      height: height,
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
              decoration: const BoxDecoration(
                color: Colors.transparent,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x18000000),
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Positioned.fill(
                    child: ClipPath(
                      clipper: _BottomNavClipper(
                        notchRadius: notchSize / 2,
                        topRadius: 0,
                      ),
                      child: Container(
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      14 * scale,
                      8 * scale,
                      14 * scale,
                      math.max(14, safeBottom + 4),
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
                            onTap: () =>
                                _handleTap(context, AppNavItem.panchang),
                          ),
                        ),
                        SizedBox(width: centerNavSize * 1.42),
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
                            onTap: () =>
                                _handleTap(context, AppNavItem.ganaMatch),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: -centerNavSize * 0.18,
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
      case AppNavItem.ganaMatch:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const GanaMatchingView()),
        );
        break;
      case AppNavItem.panchang:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PanchangView()),
        );
        break;
      case AppNavItem.chants:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChantsView()),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24 * scale, color: color),
          SizedBox(height: 3 * scale),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyle(
              fontSize: label == 'Gana Match' ? 9.2 * scale : 10 * scale,
              color: color,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              height: 1.05,
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
      child: SizedBox(
        width: size * 1.16,
        height: size * 1.18,
        child: Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: size * 0.2,
              child: Container(
                width: size * 1.02,
                height: size * 0.76,
               
                child: Column(
                  children: [
                    Container(
                      width: size * 0.42,
                      height: 1.3,
                      margin: EdgeInsets.only(top: size * 0.12),
                      color: AppColors.homePrimary.withOpacity(0.14),
                    ),
                    SizedBox(height: size * 0.18),
                    Text(
                      'Sanathan ID',
                      style: TextStyle(
                        fontSize: 11 * scale,
                        color: AppColors.homePrimary,
                        fontWeight: FontWeight.w800,
                        // height: 1.05,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
               top: size * -0.4,
              child: Container(
                width: size * 0.80,
                height: size * 0.80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      selected ? AppColors.profileHeader : AppColors.homePrimary,
                  border: Border.all(
                    color: AppColors.white,
                    width: 2.4 * scale,
                  ),
                 
                ),
                child: Padding(
                  padding: EdgeInsets.all(size * 0.075),
                  child: Image.asset(
                    'assets/images/dharma.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavClipper extends CustomClipper<Path> {
  _BottomNavClipper({
    required this.notchRadius,
    required this.topRadius,
  });

  final double notchRadius;
  final double topRadius;

  @override
  Path getClip(Size size) {
    final centerX = size.width / 2;
    final notchHalfWidth = notchRadius * 0.80;
    final notchDepth = notchRadius * 0.8;
    final shoulderRadius = notchRadius * 0.18;
    final shoulderDepth = notchRadius * 0.10;
    final leftNotchStart = centerX - notchHalfWidth;
    final rightNotchEnd = centerX + notchHalfWidth;

    final path = Path()
      ..moveTo(0, topRadius)
      ..quadraticBezierTo(0, 0, topRadius, 0)
      ..lineTo(leftNotchStart - shoulderRadius, 0)
      ..quadraticBezierTo(
        leftNotchStart,
        0,
        leftNotchStart,
        shoulderDepth,
      )
      ..arcToPoint(
        Offset(rightNotchEnd, shoulderDepth),
        radius: Radius.elliptical(notchHalfWidth, notchDepth),
        clockwise: false,
      )
      ..quadraticBezierTo(
        rightNotchEnd,
        0,
        rightNotchEnd + shoulderRadius,
        0,
      )
      ..lineTo(size.width - topRadius, 0)
      ..quadraticBezierTo(size.width, 0, size.width, topRadius)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(covariant _BottomNavClipper oldClipper) {
    return oldClipper.notchRadius != notchRadius ||
        oldClipper.topRadius != topRadius;
  }
}
