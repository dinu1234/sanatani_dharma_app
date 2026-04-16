import 'dart:async';
import 'dart:math' as math;

import 'package:dharma_app/Chants/chants_view.dart';
import 'package:dharma_app/GanaMatch/GanaMatch.dart';
import 'package:dharma_app/Notifications/notifications_controller.dart';
import 'package:dharma_app/Notifications/notifications_view.dart';
import 'package:dharma_app/Panchang/panchang_view.dart';
import 'package:dharma_app/Profile/profile_controller.dart';
import 'package:dharma_app/Profile/profile_view.dart';
import 'package:dharma_app/content/content_controller.dart';
import 'package:dharma_app/content/content_model.dart';
import 'package:dharma_app/core/constants/api_constants.dart';
import 'package:dharma_app/core/constants/app_colors.dart';
import 'package:dharma_app/core/widgets/app_svg_asset.dart';
import 'package:dharma_app/core/widgets/shree_svg.dart';
import 'package:dharma_app/widgets/common_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final profileController =
          Get.isRegistered<ProfileController>()
              ? Get.find<ProfileController>()
              : Get.put(ProfileController(), permanent: true);
      final contentController =
          Get.isRegistered<ContentController>()
              ? Get.find<ContentController>()
              : Get.put(ContentController(), permanent: true);
      final notificationsController =
          Get.isRegistered<NotificationsController>()
              ? Get.find<NotificationsController>()
              : Get.put(NotificationsController(), permanent: true);
      profileController.ensureProfileLoaded();
      contentController.ensureContentLoaded();
      notificationsController.loadNotifications();
    });
  }

  Future<bool> _confirmExit(BuildContext context) async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Are you sure you want to go back?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final profileController =
        Get.isRegistered<ProfileController>()
            ? Get.find<ProfileController>()
            : Get.put(ProfileController(), permanent: true);
    final contentController =
        Get.isRegistered<ContentController>()
            ? Get.find<ContentController>()
            : Get.put(ContentController(), permanent: true);
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    final safeBottom = CommonBottomNav.bottomInset(mediaQuery);
    final scale = (width / 390).clamp(0.84, 1.08);
    final navHeight = CommonBottomNav.navHeight(safeBottom);
    final centerNavSize = CommonBottomNav.centerSize(scale);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.homeBackground,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          final shouldExit = await _confirmExit(context);
          if (shouldExit && context.mounted) {
            Navigator.of(context).maybePop();
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.homeBackground,
          body: SafeArea(
            child: RefreshIndicator(
              color: AppColors.homePrimary,
              onRefresh: () async {
                await Future.wait([
                  profileController.loadProfile(silent: true),
                  contentController.loadSponsors(),
                  contentController.loadMantras(),
                ]);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  16 * scale,
                  12 * scale,
                  16 * scale,
                  centerNavSize * 0.1,
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
                      children: [
                        _FeatureCard(
                          title: 'Panchang',
                          assetName: 'assets/images/panchang.svg',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PanchangView(),
                              ),
                            );
                          },
                        ),
                        _FeatureCard(
                          title: 'Chants',
                          assetName: 'assets/images/chants.svg',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ChantsView(),
                              ),
                            );
                          },
                        ),
                        const _FeatureCard(
                          title: 'Darshan',
                          assetName: 'assets/images/darshan.svg',
                        ),
                        _FeatureCard(
                          title: 'Gana Match',
                          assetName: 'assets/images/ganamatch.svg',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const GanaMatchingView(),
                              ),
                            );
                          },
                        ),
                        const _FeatureCard(
                          title: 'Nitya Karma',
                          assetName: 'assets/images/dailyjapa.svg',
                        ),
                      ],
                    ),
                    SizedBox(height: 18 * scale),
                    _SponsoredBanner(scale: scale),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: CommonBottomNav(
            currentItem: AppNavItem.home,
            scale: scale,
            safeBottom: safeBottom,
            centerNavSize: centerNavSize,
            height: navHeight,
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
    final controller =
        Get.isRegistered<ProfileController>()
            ? Get.find<ProfileController>()
            : Get.put(ProfileController(), permanent: true);
    final notificationsController =
        Get.isRegistered<NotificationsController>()
            ? Get.find<NotificationsController>()
            : Get.put(NotificationsController(), permanent: true);

    return Obx(
      () => Row(
        children: [
          Expanded(
            child: Text(
              'Namaste, ${controller.fullName}',
              style: TextStyle(
                fontSize: 25 * scale,
                height: 1,
                fontWeight: FontWeight.w700,
                color: AppColors.homePrimary,
              ),
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 42 * scale,
                width: 42 * scale,
                margin: EdgeInsets.only(right: 10 * scale),
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
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => NotificationsView()),
                    );
                  },
                  icon: Icon(
                    Icons.notifications_none_rounded,
                    color: AppColors.homePrimary,
                    size: 24 * scale,
                  ),
                ),
              ),
              if (notificationsController.unreadCount > 0)
                Positioned(
                  top: -1 * scale,
                  right: 8 * scale,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 5 * scale,
                      vertical: 2 * scale,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE53935),
                      borderRadius: BorderRadius.circular(10 * scale),
                    ),
                    constraints: BoxConstraints(minWidth: 16 * scale),
                    child: Text(
                      notificationsController.unreadCount > 9
                          ? '9+'
                          : '${notificationsController.unreadCount}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10 * scale,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
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
                child: controller.profileImageUrl != null
                    ? Image.network(
                        controller.profileImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const ShreeSvg(fit: BoxFit.cover),
                      )
                    : const ShreeSvg(fit: BoxFit.cover),
              ),
            ),
          ),
        ],
      ),
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
                  ),
                  child: Center(
                    child: SizedBox(
                      width: badgeSize * 0.72,
                      height: badgeSize * 0.72,
                      child: AppSvgAsset(
                        assetName: 'assets/images/verified.svg',
                        fit: BoxFit.contain,
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
                        Text('Get FREE SRC Worth Rs 101'),
                        SizedBox(height: 8),
                        Text('App Launch Special Offer'),
                        SizedBox(height: 8),
                        Text('Get Started at Just Rs 51 Only'),
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
  const _FeatureCard({
    required this.title,
    required this.assetName,
    this.onTap,
  });

  final String title;
  final String assetName;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final scale = (width / 390).clamp(0.84, 1.08);
    final iconWrap = math.min(86.0 * scale, width * 0.2);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12 * scale),
        child: Container(
          padding: EdgeInsets.all(4 * scale),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12 * scale),
            gradient: const LinearGradient(
              colors: [
                AppColors.homeCardTopBorder,
                AppColors.homeCardBottomBorder,
              ],
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
                  child: AppSvgAsset(assetName: assetName, fit: BoxFit.contain),
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
        ),
      ),
    );
  }
}

class _SponsoredBanner extends StatefulWidget {
  const _SponsoredBanner({required this.scale});

  final double scale;

  @override
  State<_SponsoredBanner> createState() => _SponsoredBannerState();
}

class _SponsoredBannerState extends State<_SponsoredBanner> {
  late final PageController _pageController;
  Timer? _autoScrollTimer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.96);
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      final controller =
          Get.isRegistered<ContentController>()
              ? Get.find<ContentController>()
              : Get.put(ContentController(), permanent: true);
      final sponsors = controller.sponsors;
      if (!_pageController.hasClients || sponsors.length <= 1) return;

      final nextIndex = (_currentIndex + 1) % sponsors.length;
      _pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller =
        Get.isRegistered<ContentController>()
            ? Get.find<ContentController>()
            : Get.put(ContentController(), permanent: true);

    return Obx(() {
      final sponsors = controller.sponsors;
      final safeIndex =
          sponsors.isEmpty ? 0 : _currentIndex.clamp(0, sponsors.length - 1);
      final activeSponsor =
          sponsors.isNotEmpty ? sponsors[safeIndex] : null;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: EdgeInsets.only(
              right: 8 * widget.scale,
              bottom: 6 * widget.scale,
            ),
            child: Text(
              activeSponsor?.name?.trim().isNotEmpty == true
                  ? 'Sponsored - ${activeSponsor!.name!}'
                  : 'Sponsored',
              style: TextStyle(
                fontSize: 12 * widget.scale,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(
            height: 200 * widget.scale,
            child: sponsors.isEmpty
                ? _SponsorCard(
                    scale: widget.scale,
                    sponsor: null,
                  )
                : PageView.builder(
                    controller: _pageController,
                    itemCount: sponsors.length,
                    onPageChanged: (index) {
                      setState(() => _currentIndex = index);
                    },
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(
                          right: sponsors.length > 1 ? 8 * widget.scale : 0,
                        ),
                        child: _SponsorCard(
                          scale: widget.scale,
                          sponsor: sponsors[index],
                        ),
                      );
                    },
                  ),
          ),
          if (sponsors.length > 1) SizedBox(height: 10 * widget.scale),
          if (sponsors.length > 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                sponsors.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width:
                      index == safeIndex ? 18 * widget.scale : 8 * widget.scale,
                  height: 8 * widget.scale,
                  margin: EdgeInsets.symmetric(horizontal: 3 * widget.scale),
                  decoration: BoxDecoration(
                    color: index == safeIndex
                        ? AppColors.homePrimary
                        : AppColors.homePrimary.withOpacity(0.24),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }
}

class _SponsorCard extends StatelessWidget {
  const _SponsorCard({
    required this.scale,
    required this.sponsor,
  });

  final double scale;
  final SponsorItem? sponsor;

  @override
  Widget build(BuildContext context) {
    final imagePath = sponsor?.imagePath;
    final imageUrl =
        imagePath != null && imagePath.isNotEmpty
            ? '${ApiConstants.baseUrl}$imagePath'
            : null;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20 * scale),
        color: const Color(0xFFF1F1F1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20 * scale),
        child: imageUrl != null
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _SponsorFallback(
                  scale: scale,
                  title: sponsor?.name,
                ),
              )
            : _SponsorFallback(
                scale: scale,
                title: sponsor?.name,
              ),
      ),
    );
  }
}

class _SponsorFallback extends StatelessWidget {
  const _SponsorFallback({
    required this.scale,
    this.title,
  });

  final double scale;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFECDDBD), Color(0xFFD9B56A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18 * scale),
          child: Text(
            title?.trim().isNotEmpty == true ? title! : 'Sponsor',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22 * scale,
              fontWeight: FontWeight.w700,
              color: AppColors.homePrimary,
            ),
          ),
        ),
      ),
    );
  }
}
