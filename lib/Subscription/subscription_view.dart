import 'package:dharma_app/Subscription/subscription_controller.dart';
import 'package:dharma_app/Subscription/subscription_model.dart';
import 'package:dharma_app/core/constants/app_colors.dart';
import 'package:dharma_app/core/widgets/app_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class SubscriptionPlansView extends StatefulWidget {
  const SubscriptionPlansView({
    this.successDestinationBuilder,
    super.key,
  });

  final Widget Function()? successDestinationBuilder;

  @override
  State<SubscriptionPlansView> createState() => _SubscriptionPlansViewState();
}

class _SubscriptionPlansViewState extends State<SubscriptionPlansView> {
  late final SubscriptionController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<SubscriptionController>()
        ? Get.find<SubscriptionController>()
        : Get.put(SubscriptionController(), permanent: true);
    _controller.setPaymentSuccessDestination(widget.successDestinationBuilder);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_controller.plans.isEmpty && !_controller.isLoading.value) {
        _controller.loadPlans();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final scale = (mediaQuery.size.width / 390).clamp(0.84, 1.08);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.homePrimary,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F1E8),
        body: Stack(
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFFFE8CC),
                      Color(0xFFF8F1E8),
                      Color(0xFFEFE2D0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Obx(
                () => RefreshIndicator(
                  color: AppColors.homePrimary,
                  onRefresh: _controller.refreshPlans,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: _SubscriptionHeader(scale: scale),
                      ),
                      if (_controller.isLoading.value &&
                          _controller.plans.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.homePrimary,
                              strokeWidth: 2.4 * scale,
                            ),
                          ),
                        )
                      else if (_controller.plans.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: _EmptyPlansState(
                            scale: scale,
                            message: _controller.errorMessage.value,
                            onRetry: _controller.refreshPlans,
                          ),
                        )
                      else
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                            16 * scale,
                            12 * scale,
                            16 * scale,
                            24 * scale,
                          ),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final plan = _controller.plans[index];
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 14 * scale),
                                  child: _PlanCard(
                                    scale: scale,
                                    plan: plan,
                                    highlighted: index == 0,
                                    isProcessing:
                                        _controller.processingPlanId.value ==
                                            plan.id,
                                    onChoose: () => _controller.choosePlan(plan),
                                  ),
                                );
                              },
                              childCount: _controller.plans.length,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Obx(
              () =>
                  (_controller.isCreatingOrder.value ||
                          _controller.isVerifyingPayment.value)
                      ? AppLoader(
                          message: _controller.isVerifyingPayment.value
                              ? 'Verifying payment'
                              : 'Creating order',
                        )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubscriptionHeader extends StatelessWidget {
  const _SubscriptionHeader({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        18 * scale,
        12 * scale,
        18 * scale,
        22 * scale,
      ),
      decoration: BoxDecoration(
        color: AppColors.homePrimary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28 * scale),
          bottomRight: Radius.circular(28 * scale),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
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
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  width: 40 * scale,
                  height: 40 * scale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.14),
                  ),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: 22 * scale,
                  ),
                ),
              ),
              SizedBox(width: 12 * scale),
              Expanded(
                child: Text(
                  'Subscription',
                  style: TextStyle(
                    fontSize: 24 * scale,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20 * scale),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16 * scale),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22 * scale),
              gradient: const LinearGradient(
                colors: [Color(0xFFFFC145), Color(0xFFFFE8A3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 52 * scale,
                  height: 52 * scale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.homePrimary.withOpacity(0.12),
                  ),
                  child: Icon(
                    Icons.live_tv_rounded,
                    color: AppColors.homePrimary,
                    size: 28 * scale,
                  ),
                ),
                SizedBox(width: 14 * scale),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Unlock Live Darshan',
                        style: TextStyle(
                          fontSize: 18 * scale,
                          fontWeight: FontWeight.w800,
                          color: AppColors.homePrimary,
                        ),
                      ),
                      SizedBox(height: 4 * scale),
                      Text(
                        'Active subscription ke baad Live Darshan access milega.',
                        style: TextStyle(
                          fontSize: 12.5 * scale,
                          height: 1.35,
                          color: const Color(0xFF4E3B21),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.scale,
    required this.plan,
    required this.highlighted,
    required this.isProcessing,
    required this.onChoose,
  });

  final double scale;
  final SubscriptionPlan plan;
  final bool highlighted;
  final bool isProcessing;
  final VoidCallback onChoose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(3 * scale),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22 * scale),
        gradient: highlighted
            ? const LinearGradient(
                colors: [Color(0xFFC48A2C), Color(0xFFFFE38B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: highlighted ? null : Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Container(
        padding: EdgeInsets.all(16 * scale),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20 * scale),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    plan.displayName,
                    style: TextStyle(
                      fontSize: 20 * scale,
                      fontWeight: FontWeight.w800,
                      color: AppColors.homePrimary,
                    ),
                  ),
                ),
                if (highlighted)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10 * scale,
                      vertical: 5 * scale,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3C6),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Best Value',
                      style: TextStyle(
                        fontSize: 11 * scale,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF8A5A05),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 8 * scale),
            Text(
              plan.displayDescription,
              style: TextStyle(
                fontSize: 13 * scale,
                height: 1.4,
                color: const Color(0xFF6B5C52),
              ),
            ),
            SizedBox(height: 14 * scale),
            Wrap(
              spacing: 8 * scale,
              runSpacing: 8 * scale,
              children: [
                _PlanChip(
                  scale: scale,
                  icon: Icons.calendar_month_rounded,
                  label: plan.durationLabel,
                ),
                _PlanChip(
                  scale: scale,
                  icon: Icons.stars_rounded,
                  label: plan.coinRewardLabel,
                ),
              ],
            ),
            SizedBox(height: 16 * scale),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  plan.displayPrice,
                  style: TextStyle(
                    fontSize: 28 * scale,
                    fontWeight: FontWeight.w900,
                    color: AppColors.homePrimary,
                    height: 1,
                  ),
                ),
                if (plan.displayOriginalPrice != null) ...[
                  SizedBox(width: 8 * scale),
                  Padding(
                    padding: EdgeInsets.only(bottom: 2 * scale),
                    child: Text(
                      plan.displayOriginalPrice!,
                      style: TextStyle(
                        fontSize: 13 * scale,
                        color: const Color(0xFF9A8D84),
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                ElevatedButton(
                  onPressed: isProcessing ? null : onChoose,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.homePrimary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16 * scale,
                      vertical: 12 * scale,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14 * scale),
                    ),
                  ),
                  child: isProcessing
                      ? SizedBox(
                          width: 18 * scale,
                          height: 18 * scale,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Choose Plan',
                          style: TextStyle(
                            fontSize: 13 * scale,
                            fontWeight: FontWeight.w800,
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

class _PlanChip extends StatelessWidget {
  const _PlanChip({
    required this.scale,
    required this.icon,
    required this.label,
  });

  final double scale;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 7 * scale),
      decoration: BoxDecoration(
        color: AppColors.homePrimary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15 * scale, color: AppColors.homePrimary),
          SizedBox(width: 6 * scale),
          Text(
            label,
            style: TextStyle(
              fontSize: 12 * scale,
              fontWeight: FontWeight.w700,
              color: AppColors.homePrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyPlansState extends StatelessWidget {
  const _EmptyPlansState({
    required this.scale,
    required this.message,
    required this.onRetry,
  });

  final double scale;
  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24 * scale),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(22 * scale),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24 * scale),
            boxShadow: const [
              BoxShadow(
                color: Color(0x18000000),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.workspace_premium_rounded,
                size: 52 * scale,
                color: AppColors.homePrimary,
              ),
              SizedBox(height: 14 * scale),
              Text(
                'Plans abhi available nahi mile.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18 * scale,
                  fontWeight: FontWeight.w800,
                  color: AppColors.homePrimary,
                ),
              ),
              SizedBox(height: 8 * scale),
              Text(
                message.trim().isNotEmpty
                    ? message.trim()
                    : 'Thodi der baad refresh karke dubara check kijiye.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13 * scale,
                  height: 1.45,
                  color: const Color(0xFF6D625A),
                ),
              ),
              SizedBox(height: 18 * scale),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.homePrimary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14 * scale),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14 * scale),
                    ),
                  ),
                  child: const Text('Refresh'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
