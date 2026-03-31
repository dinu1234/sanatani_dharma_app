import 'package:dharma_app/core/constants/app_colors.dart';
import 'package:dharma_app/widgets/common_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

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
        statusBarColor: AppColors.profileHeader,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.homeBackground,
        bottomNavigationBar: CommonBottomNav(
          currentItem: AppNavItem.sanathanId,
          scale: scale,
          safeBottom: safeBottom,
          centerNavSize: centerNavSize,
          height: navHeight,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: navHeight + centerNavSize * 0.45),
          child: Column(
            children: [
              _ProfileHeader(scale: scale),
              Transform.translate(
                offset: Offset(0, -28 * scale),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16 * scale),
                  child: Column(
                    children: [
                      _IdCard(scale: scale),
                      SizedBox(height: 18 * scale),
                      _BalanceCard(scale: scale),
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
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.scale});

  final double scale;

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
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Namaste, Joy',
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
                  child: Image.asset(
                    'assets/images/dharma.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IdCard extends StatelessWidget {
  const _IdCard({required this.scale});

  final double scale;

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
                        borderRadius: BorderRadius.circular(4 * scale),
                        border: Border.all(
                          color: AppColors.homeGoldDark,
                          width: 2 * scale,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14 * scale),
                        child: Image.asset(
                          'assets/images/dharma.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: -10 * scale,
                      right: -10 * scale,
                      child: Container(
                        width: 32 * scale,
                        height: 32 * scale,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.homeBlue,
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          size: 18 * scale,
                          color: AppColors.white,
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
                          'Joyappa Achaiah',
                          style: TextStyle(
                            fontSize: 14 * scale,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 14 * scale),
                        Text(
                          'Sanathan ID 2306160',
                          style: TextStyle(
                            fontSize: 14 * scale,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 14 * scale),
                        Text(
                          'Member from 07 - 3 - 2024',
                          style: TextStyle(
                            fontSize: 14 * scale,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 14 * scale),
                        Text(
                          'SRC Holdings\n11036',
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

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.scale});

  final double scale;

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
              'श्रीराम कॉइन\nSri Ram Coin',
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
                '11036 SRC',
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
            icon: Icons.send_outlined,
            title: 'Send',
          ),
        ),
        SizedBox(width: 12 * scale),
        Expanded(
          child: _ActionBox(
            scale: scale,
            icon: Icons.download_for_offline_outlined,
            title: 'Recieve',
          ),
        ),
        SizedBox(width: 12 * scale),
        Expanded(
          child: _ActionBox(
            scale: scale,
            icon: Icons.add_box_outlined,
            title: 'Add SRC',
            highlight: true,
          ),
        ),
      ],
    );
  }
}

class _ActionBox extends StatelessWidget {
  const _ActionBox({
    required this.scale,
    required this.icon,
    required this.title,
    this.highlight = false,
  });

  final double scale;
  final IconData icon;
  final String title;
  final bool highlight;

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
          Stack(
            alignment: Alignment.center,
            children: [
              if (highlight)
                Container(
                  width: 40 * scale,
                  height: 40 * scale,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.profileHeaderText,
                  ),
                ),
              Icon(
                icon,
                size: 38 * scale,
                color: AppColors.profileHeader,
              ),
            ],
          ),
          SizedBox(height: 12 * scale),
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
