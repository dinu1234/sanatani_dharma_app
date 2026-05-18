import 'package:dharma_app/Profile/profile_controller.dart';
import 'package:dharma_app/Src/src_controller.dart';
import 'package:dharma_app/Src/src_model.dart';
import 'package:dharma_app/core/constants/app_colors.dart';
import 'package:dharma_app/core/utils/toast_utils.dart';
import 'package:dharma_app/core/widgets/app_loader.dart';
import 'package:dharma_app/core/widgets/app_svg_asset.dart';
import 'package:dharma_app/core/widgets/shree_svg.dart';
import 'package:dharma_app/language/language_controller.dart';
import 'package:dharma_app/services/app_info_service.dart';
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
    final controller = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController(), permanent: true);
    final srcController = Get.isRegistered<SrcController>()
        ? Get.find<SrcController>()
        : Get.put(SrcController(), permanent: true);

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
                                  '${srcController.currentBalance.toStringAsFixed(0)} SRC',
                            ),
                            SizedBox(height: 18 * scale),
                            _ActionRow(
                              scale: scale,
                              onSendTap: () =>
                                  ToastUtils.show('send_src_coming_soon'.tr),
                              onReceiveTap: () =>
                                  ToastUtils.show('receive_src_coming_soon'.tr),
                              onAddTap: () => _showAddSrcSheet(
                                context: context,
                                scale: scale,
                                srcController: srcController,
                              ),
                            ),
                            SizedBox(height: 18 * scale),
                            _LanguageCard(scale: scale),
                            SizedBox(height: 18 * scale),
                            _LogoutCard(
                              scale: scale,
                              controller: controller,
                            ),
                            SizedBox(height: 18 * scale),
                            _TransactionCard(
                              scale: scale,
                              srcController: srcController,
                            ),
                            SizedBox(height: 16 * scale),
                            _AppVersionFooter(scale: scale),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (controller.isLoading.value ||
                  controller.isUpdatingImage.value ||
                  controller.isLoggingOut.value ||
                  srcController.isCreatingOrder.value ||
                  srcController.isOpeningCheckout.value ||
                  srcController.isVerifyingPayment.value)
                AppLoader(
                  message: srcController.isOpeningCheckout.value
                      ? 'opening_payment_gateway'.tr
                      : srcController.isVerifyingPayment.value
                      ? 'verifying_src_payment'.tr
                      : srcController.isCreatingOrder.value
                      ? 'creating_src_order'.tr
                      : controller.isLoggingOut.value
                      ? 'logging_out'.tr
                      : controller.isUpdatingImage.value
                      ? 'updating_profile_image'.tr
                      : 'loading_profile'.tr,
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

  Future<void> _showAddSrcSheet({
    required BuildContext context,
    required double scale,
    required SrcController srcController,
  }) async {
    final textController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26 * scale)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            18 * scale,
            18 * scale,
            18 * scale,
            MediaQuery.of(sheetContext).viewInsets.bottom + 20 * scale,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'add_src_title'.tr,
                  style: TextStyle(
                    fontSize: 22 * scale,
                    fontWeight: FontWeight.w800,
                    color: AppColors.profileHeader,
                  ),
                ),
                SizedBox(height: 8 * scale),
                Text(
                  'src_rate_note'.tr,
                  style: TextStyle(
                    fontSize: 13 * scale,
                    height: 1.4,
                    color: const Color(0xFF6A6A6A),
                  ),
                ),
                SizedBox(height: 18 * scale),
                TextFormField(
                  controller: textController,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'src_quantity_label'.tr,
                    hintText: 'src_quantity_hint'.tr,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16 * scale),
                    ),
                  ),
                  validator: (value) {
                    final quantity = int.tryParse((value ?? '').trim());
                    if (quantity == null || quantity <= 0) {
                      return 'src_quantity_invalid'.tr;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12 * scale),
                Text(
                  'src_payment_success_note'.tr,
                  style: TextStyle(
                    fontSize: 12.5 * scale,
                    color: AppColors.profileTextMuted,
                  ),
                ),
                SizedBox(height: 18 * scale),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (srcController.isCreatingOrder.value ||
                          srcController.isVerifyingPayment.value) {
                        return;
                      }
                      if (formKey.currentState?.validate() != true) return;
                      final quantity = int.parse(textController.text.trim());
                      Navigator.of(sheetContext).pop();
                      await srcController.purchaseSrc(quantity);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.profileHeader,
                      foregroundColor: AppColors.profileHeaderText,
                      padding: EdgeInsets.symmetric(vertical: 14 * scale),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16 * scale),
                      ),
                    ),
                    child: Text(
                      'continue_to_payment'.tr,
                      style: TextStyle(
                        fontSize: 15 * scale,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
              'namaste_name'.tr.replaceAll('@name', controller.fullName),
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
                      errorBuilder: (_, _, _) =>
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
    return _formatLongDate(parsed);
  }

  String _subscriptionExpiryText() {
    final date = controller.subscriptionExpiryAt;
    if (date == null || date.isEmpty) return '-';
    final parsed = DateTime.tryParse(date);
    if (parsed == null) return date;
    return _formatLongDate(parsed);
  }

  String _formatLongDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(7 * scale),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30 * scale),
        gradient: const LinearGradient(
          colors: [
            AppColors.homeGoldDark,
            AppColors.homeGoldLight,
            AppColors.homeGoldDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.profileShadow,
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Container(
        padding: EdgeInsets.all(17 * scale),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFCF4),
          borderRadius: BorderRadius.circular(23 * scale),
          border: Border.all(
            color: AppColors.homeGoldLight.withValues(alpha: 0.75),
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16 * scale,
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
                    'sanathan_id_card'.tr,
                    style: TextStyle(
                      fontSize: 15.5 * scale,
                      color: AppColors.homePrimary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16 * scale),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 112 * scale,
                      height: 138 * scale,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18 * scale),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFF8E7), AppColors.white],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        border: Border.all(
                          color: AppColors.homeGoldDark,
                          width: 1.8 * scale,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x12000000),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16 * scale),
                        child: controller.profileImageUrl != null
                            ? Image.network(
                                controller.profileImageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) =>
                                    _ProfilePlaceholder(scale: scale),
                              )
                            : _ProfilePlaceholder(scale: scale),
                      ),
                    ),
                    Positioned(
                      left: -6 * scale,
                      bottom: -6 * scale,
                      child: GestureDetector(
                        onTap: controller.pickAndUploadProfileImage,
                        child: Container(
                          width: 38 * scale,
                          height: 38 * scale,
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
                    if (controller.hasActiveSubscription)
                      Positioned(
                        top: -9 * scale,
                        right: -9 * scale,
                        child: SizedBox(
                          width: 32 * scale,
                          height: 32 * scale,
                          child: AppSvgAsset(
                            assetName: 'assets/images/verified.svg',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(width: 13 * scale),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _IdInfoBlock(
                        scale: scale,
                        label: 'name'.tr,
                        value: controller.fullName,
                        highlighted: true,
                      ),
                      SizedBox(height: 8 * scale),
                      _IdInfoBlock(
                        scale: scale,
                        label: 'sanathan_id'.tr,
                        value: controller.user?.sanatanId ?? '-',
                      ),
                      SizedBox(height: 8 * scale),
                      _IdInfoBlock(
                        scale: scale,
                        label: 'member_from'.tr.replaceAll('@date', ''),
                        value: _memberSinceText(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12 * scale),
            Row(
              children: [
                Expanded(
                  child: _IdStatTile(
                    scale: scale,
                    label: 'sri_ram_coin'.tr,
                    value: '${controller.srcBalance.toStringAsFixed(0)} SRC',
                  ),
                ),
                if (controller.hasActiveSubscription &&
                    controller.subscriptionExpiryAt?.trim().isNotEmpty == true)
                  SizedBox(width: 10 * scale),
                if (controller.hasActiveSubscription &&
                    controller.subscriptionExpiryAt?.trim().isNotEmpty == true)
                  Expanded(
                    child: _IdStatTile(
                      scale: scale,
                      label: 'subscription_valid_till_label'.tr,
                      value: _subscriptionExpiryText(),
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

class _IdInfoBlock extends StatelessWidget {
  const _IdInfoBlock({
    required this.scale,
    required this.label,
    required this.value,
    this.highlighted = false,
  });

  final double scale;
  final String label;
  final String value;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 11 * scale,
        vertical: 9 * scale,
      ),
      decoration: BoxDecoration(
        color: highlighted
            ? const Color(0xFFFFF4D6)
            : const Color(0xFFF8F4EA),
        borderRadius: BorderRadius.circular(14 * scale),
        border: Border.all(
          color: AppColors.homeGoldDark.withValues(alpha: 0.22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.trim(),
            style: TextStyle(
              fontSize: 10.8 * scale,
              color: AppColors.profileTextMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3 * scale),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.2 * scale,
              color: AppColors.homePrimary,
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _IdStatTile extends StatelessWidget {
  const _IdStatTile({
    required this.scale,
    required this.label,
    required this.value,
  });

  final double scale;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 11 * scale,
        vertical: 10 * scale,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF8EFCB), Color(0xFFFFFAEE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(
          color: AppColors.homeGoldDark.withValues(alpha: 0.28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10.8 * scale,
              color: AppColors.profileTextMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4 * scale),
          Text(
            value,
            style: TextStyle(
              fontSize: 13 * scale,
              color: AppColors.homePrimary,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
        ],
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
        color: AppColors.profileHeader.withValues(alpha: 0.45),
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
              'sri_ram_coin'.tr,
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
                'total_balance'.tr,
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
  const _ActionRow({
    required this.scale,
    required this.onSendTap,
    required this.onReceiveTap,
    required this.onAddTap,
  });

  final double scale;
  final VoidCallback onSendTap;
  final VoidCallback onReceiveTap;
  final VoidCallback onAddTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionBox(
            scale: scale,
            assetName: 'assets/images/Send.svg',
            title: 'send'.tr,
            onTap: null,
          ),
        ),
        SizedBox(width: 12 * scale),
        Expanded(
          child: _ActionBox(
            scale: scale,
            assetName: 'assets/images/Recieve.svg',
            title: 'receive'.tr,
            onTap: null,
          ),
        ),
        SizedBox(width: 12 * scale),
        Expanded(
          child: _ActionBox(
            scale: scale,
            assetName: 'assets/images/add.svg',
            title: 'add_src'.tr,
            onTap: onAddTap,
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
    required this.onTap,
  });

  final double scale;
  final String assetName;
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24 * scale),
        child: Ink(
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
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({required this.scale});

  final double scale;

  static const List<Map<String, String>> _languages = [
    {'name': 'English', 'code': 'en'},
    {'name': 'हिंदी', 'code': 'hi'},
    {'name': 'मराठी', 'code': 'mr'},
    {'name': 'বাংলা', 'code': 'bn'},
    {'name': 'ಕನ್ನಡ', 'code': 'kn'},
    {'name': 'తెలుగు', 'code': 'te'},
    {'name': 'தமிழ்', 'code': 'ta'},
    {'name': 'ગુજરાતી', 'code': 'gu'},
  ];

  @override
  Widget build(BuildContext context) {
    final languageController = Get.isRegistered<LanguageController>()
        ? Get.find<LanguageController>()
        : Get.put(LanguageController(), permanent: true);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: AppColors.profileCardBackground,
        borderRadius: BorderRadius.circular(22 * scale),
        boxShadow: const [
          BoxShadow(
            color: AppColors.profileShadow,
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.language_rounded,
            color: AppColors.homePrimary,
            size: 24 * scale,
          ),
          SizedBox(width: 12 * scale),
          Expanded(
            child: Text(
              'change_language'.tr,
              style: TextStyle(
                fontSize: 16 * scale,
                fontWeight: FontWeight.w700,
                color: AppColors.homePrimary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(18 * scale),
                  ),
                ),
                builder: (sheetContext) {
                  return SafeArea(
                    child: FractionallySizedBox(
                      heightFactor: 0.6,
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                              16 * scale,
                              14 * scale,
                              16 * scale,
                              8 * scale,
                            ),
                            child: Text(
                              'select_language'.tr,
                              style: TextStyle(
                                fontSize: 17 * scale,
                                fontWeight: FontWeight.w700,
                                color: AppColors.homePrimary,
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              padding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(sheetContext).padding.bottom +
                                    8 * scale,
                              ),
                              physics: const BouncingScrollPhysics(),
                              itemCount: _languages.length,
                              itemBuilder: (_, index) {
                                final lang = _languages[index];
                                final code = lang['code']!;
                                return ListTile(
                                  leading: Text(
                                    '${index + 1}.',
                                    style: TextStyle(
                                      fontSize: 14 * scale,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.homePrimary,
                                    ),
                                  ),
                                  title: Text(lang['name']!),
                                  trailing:
                                      languageController.selectedLang.value ==
                                              code
                                          ? const Icon(
                                              Icons.check_rounded,
                                              color: AppColors.homePrimary,
                                            )
                                          : null,
                                  onTap: () {
                                    languageController.changeLanguage(code);
                                    Navigator.of(context).pop();
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            child: Text('change'.tr),
          ),
        ],
      ),
    );
  }
}

class _LogoutCard extends StatelessWidget {
  const _LogoutCard({required this.scale, required this.controller});

  final double scale;
  final ProfileController controller;

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('logout'.tr),
          content: Text('logout_confirm'.tr),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text('cancel'.tr),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.profileHeader,
                foregroundColor: AppColors.profileHeaderText,
              ),
              child: Text('logout'.tr),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      await controller.logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.profileCardBackground,
        borderRadius: BorderRadius.circular(22 * scale),
        boxShadow: const [
          BoxShadow(
            color: AppColors.profileShadow,
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16 * scale,
          vertical: 4 * scale,
        ),
        leading: Icon(
          Icons.logout_rounded,
          color: Colors.red.shade700,
          size: 24 * scale,
        ),
        title: Text(
          'logout'.tr,
          style: TextStyle(
            fontSize: 16 * scale,
            fontWeight: FontWeight.w700,
            color: Colors.red.shade700,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: Colors.red.shade700,
          size: 24 * scale,
        ),
        onTap: () => _confirmLogout(context),
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({required this.scale, required this.srcController});

  final double scale;
  final SrcController srcController;

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
          Row(
            children: [
              Expanded(
                child: Text(
                  'transaction_history'.tr,
                  style: TextStyle(
                    fontSize: 18 * scale,
                    color: AppColors.profileHeader,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12 * scale),
          if (srcController.isLoadingHistory.value &&
              srcController.transactions.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 18 * scale),
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.profileHeader,
                  strokeWidth: 2.4 * scale,
                ),
              ),
            )
          else if (srcController.historyError.value.trim().isNotEmpty &&
              srcController.transactions.isEmpty)
            _TransactionEmptyState(
              scale: scale,
              message: srcController.historyError.value,
            )
          else if (srcController.transactions.isEmpty)
            _TransactionEmptyState(
              scale: scale,
              message: 'no_src_transactions_yet'.tr,
            )
          else
            ...List.generate(srcController.transactions.length, (index) {
              final transaction = srcController.transactions[index];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == srcController.transactions.length - 1
                      ? 0
                      : 18 * scale,
                ),
                child: Column(
                  children: [
                    _TransactionItem(
                      scale: scale,
                      transaction: transaction,
                    ),
                    if (index != srcController.transactions.length - 1)
                      Divider(
                        height: 26 * scale,
                        color: AppColors.profileHeader.withValues(alpha: 0.35),
                      ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _AppVersionFooter extends StatelessWidget {
  const _AppVersionFooter({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final version = AppInfoService.versionLabel;
    if (version.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 8 * scale),
      child: Text(
        'app_version'.trParams({'version': version}),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12.5 * scale,
          color: AppColors.profileTextMuted,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _TransactionEmptyState extends StatelessWidget {
  const _TransactionEmptyState({
    required this.scale,
    required this.message,
  });

  final double scale;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 18 * scale),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14 * scale,
            height: 1.45,
            color: AppColors.profileTextMuted,
          ),
        ),
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  const _TransactionItem({
    required this.scale,
    required this.transaction,
  });

  final double scale;
  final SrcHistoryTransaction transaction;

  String _formatDate(String? value) {
    if (value == null || value.trim().isEmpty) return '-';
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final hour = parsed.hour % 12 == 0 ? 12 : parsed.hour % 12;
    final minute = parsed.minute.toString().padLeft(2, '0');
    final suffix = parsed.hour >= 12 ? 'PM' : 'AM';
    return '${parsed.day} ${months[parsed.month - 1]} ${parsed.year}, $hour:$minute $suffix';
  }

  String _formatRs(double? value) {
    if (value == null) return 'Rs 0';
    return value % 1 == 0
        ? 'Rs ${value.toStringAsFixed(0)}'
        : 'Rs ${value.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final quantity = transaction.srcQuantity ?? 0;
    final amountText = transaction.isSuccess ? '+$quantity SRC' : '$quantity SRC';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
            transaction.isSuccess
                ? Icons.add_rounded
                : Icons.error_outline_rounded,
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
                transaction.sourceTitle,
                style: TextStyle(
                  fontSize: 16 * scale,
                  color: const Color(0xFF36373C),
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 4 * scale),
              Text(
                '$quantity SRC • ${_formatRs(transaction.srcUnitPrice)} each',
                style: TextStyle(
                  fontSize: 13.5 * scale,
                  color: AppColors.profileTextMuted,
                ),
              ),
              SizedBox(height: 4 * scale),
              Text(
                _formatDate(transaction.createdAt),
                style: TextStyle(
                  fontSize: 13 * scale,
                  color: AppColors.profileTextMuted,
                ),
              ),
              // SizedBox(height: 4 * scale),
              // Text(
              //   'Status: ${transaction.statusLabel} • ${_formatRs(transaction.amount)}',
              //   style: TextStyle(
              //     fontSize: 13 * scale,
              //     color: transaction.isSuccess
              //         ? const Color(0xFF1F7A46)
              //         : const Color(0xFFB44336),
              //   ),
              // ),
            ],
          ),
        ),
        Text(
          amountText,
          style: TextStyle(
            fontSize: 17 * scale,
            color: transaction.isSuccess
                ? const Color(0xFF1F7A46)
                : const Color(0xFFB44336),
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
