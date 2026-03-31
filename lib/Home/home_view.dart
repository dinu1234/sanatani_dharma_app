import 'dart:math' as math;

import 'package:dharma_app/Profile/profile_view.dart';
import 'package:dharma_app/core/constants/app_colors.dart';
import 'package:dharma_app/widgets/common_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    final safeBottom = mediaQuery.padding.bottom;
    final scale = (width / 390).clamp(0.84, 1.08);
    final navHeight = CommonBottomNav.navHeight(safeBottom);
    final centerNavSize = CommonBottomNav.centerSize(scale);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.homeBackground,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.homeBackground,
        bottomNavigationBar: CommonBottomNav(
          currentItem: AppNavItem.home,
          scale: scale,
          safeBottom: safeBottom,
          centerNavSize: centerNavSize,
          height: navHeight,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              16 * scale,
              12 * scale,
              16 * scale,
              navHeight + centerNavSize * 0.45,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(scale: scale),
                SizedBox(height: 20 * scale),
                _MembershipCard(scale: scale),
                SizedBox(height: 18 * scale),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  crossAxisSpacing: 14 * scale,
                  mainAxisSpacing: 14 * scale,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: width < 360 ? 0.9 : 0.98,
                  children: const [
                    _FeatureCard(title: 'Panchang', icon: Icons.wb_twilight),
                    _FeatureCard(title: 'Chants', icon: Icons.auto_awesome),
                    _FeatureCard(title: 'Darshan', icon: Icons.temple_hindu),
                    _FeatureCard(title: 'Gana Match', icon: Icons.favorite),
                  ],
                ),
                SizedBox(height: 18 * scale),
                _SponsoredBanner(scale: scale),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Namaste, Joy',
            style: TextStyle(
              fontSize: 25 * scale,
              height: 1,
              fontWeight: FontWeight.w700,
              color: AppColors.homePrimary,
            ),
          ),
        ),
        Container(
          height: 45 * scale,
          width: 45 * scale,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.white,
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileView()),
              );
            },
            child: ClipOval(
              child: Image.asset(
                'assets/images/dharma.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MembershipCard extends StatelessWidget {
  const _MembershipCard({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final badgeSize = 86.0 * scale;

    return Container(
      padding: EdgeInsets.all(8 * scale),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25 * scale),
        gradient: const LinearGradient(
          colors: [
            AppColors.homeGoldDark,
            AppColors.homeGoldLight,
            AppColors.homeGoldDark,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x24000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Container(
        padding: EdgeInsets.all(15 * scale),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24 * scale),
          border: Border.all(
            color: AppColors.homeGoldBorder,
            width: 2.5 * scale,
          ),
          gradient: const LinearGradient(
            colors: [Color(0xFFD99C42), Color(0xFFF9E889), Color(0xFFC18843)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: 14 * scale,
                vertical: 8 * scale,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22 * scale),
                border: Border.all(
                  color: AppColors.homeGoldAccent,
                  width: 2 * scale,
                ),
              ),
              child: Text(
                'Activate Your Verified Lifetime Sanathan ID',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.w500,
                  color: AppColors.homePrimary,
                ),
              ),
            ),
            SizedBox(height: 16 * scale),
            Row(
              children: [
                Container(
                  width: badgeSize,
                  height: badgeSize,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.homeBlue,
                  ),
                  child: Center(
                    child: Container(
                      width: badgeSize * 0.68,
                      height: badgeSize * 0.68,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.homeBlueInner,
                      ),
                      child: Icon(
                        Icons.verified_rounded,
                        color: AppColors.white,
                        size: 38 * scale,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 14 * scale),
                Expanded(
                  child: DefaultTextStyle(
                    style: TextStyle(
                      fontSize: 14.5 * scale,
                      height: 1.18,
                      color: AppColors.homePrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Get FREE SRC Worth ₹101'),
                        SizedBox(height: 8),
                        Text('App Launch Special Offer'),
                        SizedBox(height: 8),
                        Text('Get Started at Just ₹51 Only'),
                        SizedBox(height: 8),
                        Text('Unlock All Premium Features of the App'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final scale = (width / 390).clamp(0.84, 1.08);
    final iconWrap = math.min(86.0 * scale, width * 0.2);

    return Container(
      padding: EdgeInsets.all(4 * scale),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12 * scale),
        gradient: const LinearGradient(
          colors: [AppColors.homeCardTopBorder, AppColors.homeCardBottomBorder],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.homeCardBackground,
          borderRadius: BorderRadius.circular(12 * scale),
          boxShadow: const [
            BoxShadow(
              color: Color(0x18000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: iconWrap,
              height: iconWrap,
              child: Icon(
                icon,
                color: AppColors.homePrimary,
                size: iconWrap,
              ),
            ),
            SizedBox(height: 8 * scale),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10 * scale),
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: title == 'Gana Match' ? 20 * scale : 21 * scale,
                  height: 1.05,
                  color: AppColors.homePrimary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SponsoredBanner extends StatelessWidget {
  const _SponsoredBanner({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: EdgeInsets.only(right: 8 * scale, bottom: 6 * scale),
          child: Text(
            'Sponsored',
            style: TextStyle(fontSize: 12 * scale, color: Colors.black87),
          ),
        ),
        Container(
          height: 200 * scale,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20 * scale),
            image: const DecorationImage(
              image: NetworkImage(
                'https://images.unsplash.com/photo-1528715471579-d1bcf0ba5e83?auto=format&fit=crop&w=1200&q=80',
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }
}
