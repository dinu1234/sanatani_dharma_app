import 'package:dharma_app/Profile/profile_controller.dart';
import 'package:dharma_app/core/constants/app_colors.dart';
import 'package:dharma_app/core/widgets/app_svg_asset.dart';
import 'package:dharma_app/core/widgets/app_loader.dart';
import 'package:dharma_app/core/widgets/shree_svg.dart';
import 'package:dharma_app/widgets/common_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    final safeBottom = CommonBottomNav.bottomInset(mediaQuery);
    final scale = (width / 390).clamp(0.84, 1.08);
    final navHeight = CommonBottomNav.navHeight(safeBottom);
    final centerNavSize = CommonBottomNav.centerSize(scale);
    final controller =
        Get.isRegistered<ProfileController>()
            ? Get.find<ProfileController>()
            : Get.put(ProfileController(), permanent: true);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.homePrimary,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.homeBackground,
        body: Obx(
          () => Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.only(bottom: centerNavSize * 0.1),
                child: Column(
                  children: [
                    _ProfileHeader(scale: scale, controller: controller),
                    Transform.translate(
                      offset: Offset(0, -28 * scale),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16 * scale),
                        child: Column(
                          children: [
                            _IdCard(scale: scale, controller: controller),
                            SizedBox(height: 18 * scale),
                            _BalanceCard(
                              scale: scale,
                              coinText:
                                  '${controller.user?.coin?.toStringAsFixed(0) ?? '0'} SRC',
                            ),
                            SizedBox(height: 18 * scale),
                            _ActionRow(scale: scale),
                            SizedBox(height: 18 * scale),
                            _TransactionCard(scale: scale),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (controller.isLoading.value || controller.isUpdatingImage.value)
                AppLoader(
                  message:
                      controller.isUpdatingImage.value
                          ? 'Updating profile image'
                          : 'Loading profile',
                ),
            ],
          ),
        ),
        bottomNavigationBar: CommonBottomNav(
          currentItem: AppNavItem.sanathanId,
          scale: scale,
          safeBottom: safeBottom,
          centerNavSize: centerNavSize,
          height: navHeight,
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.scale, required this.controller});

  final double scale;
  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        18 * scale,
        MediaQuery.of(context).padding.top + 10 * scale,
        18 * scale,
        62 * scale,
      ),
      decoration: BoxDecoration(
        color: AppColors.profileHeader,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32 * scale),
          bottomRight: Radius.circular(32 * scale),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Namaste, ${controller.fullName}',
              style: TextStyle(
                fontSize: 28 * scale,
                height: 1,
                fontWeight: FontWeight.w700,
                color: AppColors.profileHeaderText,
              ),
            ),
          ),
          Container(
            width: 50 * scale,
            height: 50 * scale,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.white,
            ),
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
        ],
      ),
    );
  }
}

class _IdCard extends StatelessWidget {
  const _IdCard({required this.scale, required this.controller});

  final double scale;
  final ProfileController controller;

  String _memberSinceText() {
    final date = controller.user?.createdAt;
    if (date == null || date.isEmpty) return '-';
    final parsed = DateTime.tryParse(date);
    if (parsed == null) return date;
    return '${parsed.day.toString().padLeft(2, '0')} - ${parsed.month} - ${parsed.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8 * scale),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28 * scale),
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
            color: AppColors.profileShadow,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Container(
        padding: EdgeInsets.all(18 * scale),
        decoration: BoxDecoration(
          color: AppColors.profileCardBackground,
          borderRadius: BorderRadius.circular(18 * scale),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 18 * scale,
                vertical: 8 * scale,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24 * scale),
                gradient: const LinearGradient(
                  colors: [
                    AppColors.homeGoldDark,
                    AppColors.homeGoldLight,
                    AppColors.homeGoldDark,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: Text(
                'Sanathan ID Card',
                style: TextStyle(
                  fontSize: 16.5 * scale,
                  color: AppColors.homePrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(height: 18 * scale),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 118 * scale,
                      height: 142 * scale,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14 * scale),
                        border: Border.all(
                          color: AppColors.homeGoldDark,
                          width: 2 * scale,
                        ),
                        color: AppColors.white,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12 * scale),
                        child: controller.profileImageUrl != null
                            ? Image.network(
                                controller.profileImageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _ProfilePlaceholder(
                                  scale: scale,
                                ),
                              )
                            : _ProfilePlaceholder(scale: scale),
                      ),
                    ),
                    if (controller.hasActiveSubscription)
                      Positioned(
                        top: -10 * scale,
                        right: -10 * scale,
                        child: SizedBox(
                          width: 34 * scale,
                          height: 34 * scale,
                          child: AppSvgAsset(
                            assetName: 'assets/images/verified.svg',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    Positioned(
                      left: -8 * scale,
                      bottom: -8 * scale,
                      child: GestureDetector(
                        onTap: controller.pickAndUploadProfileImage,
                        child: Container(
                          width: 34 * scale,
                          height: 34 * scale,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.profileHeader,
                            border: Border.all(
                              color: AppColors.white,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.edit_rounded,
                            size: 18 * scale,
                            color: AppColors.profileHeaderText,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 16 * scale),
                Expanded(
                  child: DefaultTextStyle(
                    style: TextStyle(
                      fontSize: 14.5 * scale,
                      color: AppColors.homePrimary,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Name'),
                        SizedBox(height: 2 * scale),
                        Text(
                          controller.fullName,
                          style: TextStyle(
                            fontSize: 14 * scale,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 14 * scale),
                        Text(
                          'Sanathan ID ${controller.user?.sanatanId ?? '-'}',
                          style: TextStyle(
                            fontSize: 14 * scale,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 14 * scale),
                        Text(
                          'Member from ${_memberSinceText()}',
                          style: TextStyle(
                            fontSize: 14 * scale,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 14 * scale),
                        Text(
                          'SRC Holdings\n${controller.user?.coin?.toStringAsFixed(0) ?? '0'}',
                          style: TextStyle(
                            fontSize: 14 * scale,
                            fontWeight: FontWeight.w700,
                            height: 1.1,
                          ),
                        ),
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

class _ProfilePlaceholder extends StatelessWidget {
  const _ProfilePlaceholder({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      alignment: Alignment.center,
      child: Icon(
        Icons.person_rounded,
        size: 54 * scale,
        color: AppColors.profileHeader.withOpacity(0.45),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.scale, required this.coinText});

  final double scale;
  final String coinText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 18 * scale,
        vertical: 16 * scale,
      ),
      decoration: BoxDecoration(
        color: AppColors.profileHeader,
        borderRadius: BorderRadius.circular(28 * scale),
        boxShadow: const [
          BoxShadow(
            color: AppColors.profileShadow,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 72 * scale,
            height: 72 * scale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [
                  AppColors.homeGoldDark,
                  AppColors.homeGoldLight,
                  AppColors.homeGoldDark,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(
              Icons.currency_exchange,
              color: AppColors.homePrimary,
              size: 38 * scale,
            ),
          ),
          SizedBox(width: 14 * scale),
          Expanded(
            child: Text(
              'Sri Ram Coin',
              style: TextStyle(
                fontSize: 17 * scale,
                height: 1.15,
                color: AppColors.profileHeaderText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Total Balance',
                style: TextStyle(
                  fontSize: 16 * scale,
                  color: AppColors.profileHeaderText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8 * scale),
              Text(
                coinText,
                style: TextStyle(
                  fontSize: 16 * scale,
                  color: AppColors.profileHeaderText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionBox(
            scale: scale,
            assetName: 'assets/images/Send.svg',
            title: 'Send',
          ),
        ),
        SizedBox(width: 12 * scale),
        Expanded(
          child: _ActionBox(
            scale: scale,
            assetName: 'assets/images/Recieve.svg',
            title: 'Recieve',
          ),
        ),
        SizedBox(width: 12 * scale),
        Expanded(
          child: _ActionBox(
            scale: scale,
            assetName: 'assets/images/add.svg',
            title: 'Add SRC',
          ),
        ),
      ],
    );
  }
}

class _ActionBox extends StatelessWidget {
  const _ActionBox({
    required this.scale,
    required this.assetName,
    required this.title,
  });

  final double scale;
  final String assetName;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 114 * scale,
      decoration: BoxDecoration(
        color: AppColors.profileCardBackground,
        borderRadius: BorderRadius.circular(24 * scale),
        boxShadow: const [
          BoxShadow(
            color: AppColors.profileShadow,
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 68 * scale,
            height: 68 * scale,
            child: AppSvgAsset(
              assetName: assetName,
              fit: BoxFit.contain,
            ),
          ),
          // SizedBox(height: 12 * scale),
          Text(
            title,
            style: TextStyle(
              fontSize: 15 * scale,
              color: AppColors.profileHeader,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18 * scale),
      decoration: BoxDecoration(
        color: AppColors.profileCardBackground,
        borderRadius: BorderRadius.circular(26 * scale),
        boxShadow: const [
          BoxShadow(
            color: AppColors.profileShadow,
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transaction History',
            style: TextStyle(
              fontSize: 18 * scale,
              color: AppColors.profileHeader,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 18 * scale),
          _TransactionItem(
            scale: scale,
            title: 'Added SRC',
            date: '1 March, 2026',
            amount: '100',
          ),
          Divider(
            height: 26 * scale,
            color: AppColors.profileHeader.withOpacity(0.35),
          ),
          _TransactionItem(
            scale: scale,
            title: 'Donated to Temple',
            date: '10 February, 2026',
            amount: '5',
          ),
        ],
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  const _TransactionItem({
    required this.scale,
    required this.title,
    required this.date,
    required this.amount,
  });

  final double scale;
  final String title;
  final String date;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46 * scale,
          height: 46 * scale,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                AppColors.homeGoldDark,
                AppColors.homeGoldLight,
                AppColors.homeGoldDark,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Icon(
            Icons.currency_rupee,
            color: AppColors.homePrimary,
            size: 24 * scale,
          ),
        ),
        SizedBox(width: 14 * scale),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 17 * scale,
                  color: const Color(0xFF36373C),
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 4 * scale),
              Text(
                date,
                style: TextStyle(
                  fontSize: 15 * scale,
                  color: AppColors.profileTextMuted,
                ),
              ),
            ],
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 20 * scale,
            color: const Color(0xFF2E2F33),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
