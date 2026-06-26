import 'dart:async';

import 'package:dharma_app/Profile/profile_controller.dart';
import 'package:dharma_app/SpiritualMedia/spiritual_media_controller.dart';
import 'package:dharma_app/SpiritualMedia/spiritual_media_model.dart';
import 'package:dharma_app/Subscription/subscription_view.dart';
import 'package:dharma_app/core/constants/api_constants.dart';
import 'package:dharma_app/core/constants/app_colors.dart';
import 'package:dharma_app/core/utils/toast_utils.dart';
import 'package:dharma_app/services/spiritual_media_download_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class SpiritualMediaView extends StatefulWidget {
  const SpiritualMediaView({super.key});

  @override
  State<SpiritualMediaView> createState() => _SpiritualMediaViewState();
}

class _SpiritualMediaViewState extends State<SpiritualMediaView> {
  late final SpiritualMediaController _controller;
  late final ProfileController _profileController;
  late final TextEditingController _searchController;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<SpiritualMediaController>()
        ? Get.find<SpiritualMediaController>()
        : Get.put(SpiritualMediaController(), permanent: true);
    _profileController = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController(), permanent: true);
    _searchController = TextEditingController(
      text: _controller.searchQuery.value,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await _profileController.ensureProfileLoaded();
      await _controller.ensureMediaLoaded();
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 320), () {
      _controller.applySearch(value);
    });
  }

  Future<void> _openSubscription() async {
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SubscriptionPlansView(
          featureTitle: 'spiritual_media'.tr,
          featureDescription: 'spiritual_media_subscription_required'.tr,
          featureIcon: Icons.collections_rounded,
        ),
      ),
    );
    if (!mounted) return;
    await _profileController.loadProfile(silent: true);
    await _controller.loadMedia(showLoader: false);
  }

  Future<void> _handleView(SpiritualMediaItem item) async {
    await _profileController.ensureProfileLoaded();
    if (!_profileController.hasActiveSubscription) {
      ToastUtils.show('spiritual_media_subscription_required'.tr);
      await _openSubscription();
      return;
    }

    final detail = await _controller.fetchDetail(item.id ?? 0);
    if (!mounted || detail == null) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SpiritualMediaDetailView(detail: detail),
      ),
    );
  }

  Future<void> _handleDownload(SpiritualMediaItem item) async {
    await _profileController.ensureProfileLoaded();
    if (!_profileController.hasActiveSubscription) {
      ToastUtils.show('spiritual_media_subscription_required'.tr);
      await _openSubscription();
      return;
    }

    final response = await _controller.fetchDetailResponse(item.id ?? 0);
    if (response == null || !response.success) return;

    final path = response.data?.download?.downloadPath ??
        response.data?.media?.imageOriginalPath;
    final url = _mediaUrl(path);
    if (url == null) {
      ToastUtils.show('spiritual_media_download_unavailable'.tr);
      return;
    }
    final detail = response.data?.media;
    if (detail == null) {
      ToastUtils.show('spiritual_media_download_unavailable'.tr);
      return;
    }

    final mimeType = _mimeTypeFromImageType(detail.imageType);
    final extension =
        detail.imageType?.trim().toLowerCase().isNotEmpty == true
        ? detail.imageType!.trim().toLowerCase()
        : SpiritualMediaDownloadService.extensionFromMimeType(mimeType);
    final fileName = SpiritualMediaDownloadService.sanitizeFileName(
      detail.displayTitle,
      extension: extension,
    );

    final savedPath = await SpiritualMediaDownloadService.downloadImage(
      url: url,
      fileName: fileName,
      mimeType: mimeType,
    );
    if (savedPath == null) {
      ToastUtils.show('spiritual_media_download_failed'.tr);
      return;
    }

    if (!mounted) return;
    ToastUtils.show(
      'spiritual_media_download_saved'.tr.replaceAll('@file', fileName),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    final scale = (width / 390).clamp(0.84, 1.08);

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
            Positioned.fill(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFFBE8D4),
                      Color(0xFFF8F1E8),
                      Color(0xFFF1E2D2),
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
                  onRefresh: () => _controller.loadMedia(),
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: _MediaHeader(
                          scale: scale,
                          searchController: _searchController,
                          selectedFilter: _controller.selectedFilter.value,
                          onBack: () => Navigator.of(context).pop(),
                          onSearchChanged: _handleSearchChanged,
                          onSearch: () =>
                              _controller.applySearch(_searchController.text),
                          onClear: () {
                            _searchController.clear();
                            _controller.applySearch('');
                          },
                          onFilterSelected: _controller.applyFilter,
                        ),
                      ),
                      if (_controller.isLoading.value &&
                          _controller.mediaItems.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.homePrimary,
                            ),
                          ),
                        )
                      // else if (_controller.isSubscriptionRequiredForList.value)
                      //   SliverFillRemaining(
                      //     hasScrollBody: false,
                      //     child: _MediaLockedState(
                      //       scale: scale,
                      //       message: _controller.errorMessage.value,
                      //       onSubscribe: _openSubscription,
                      //     ),
                      //   )
                      else if (_controller.mediaItems.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: _MediaEmptyState(
                            scale: scale,
                            message: _controller.errorMessage.value,
                            onRetry: () => _controller.loadMedia(),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                            16 * scale,
                            6 * scale,
                            16 * scale,
                            24 * scale,
                          ),
                          sliver: SliverGrid(
                            delegate: SliverChildBuilderDelegate((context, index) {
                              final item = _controller.mediaItems[index];
                              return _MediaCard(
                                scale: scale,
                                item: item,
                                locked: !_profileController.hasActiveSubscription,
                                onTap: () => _handleView(item),
                                onDownload: () => _handleDownload(item),
                              );
                            }, childCount: _controller.mediaItems.length),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: width < 360 ? 1 : 2,
                              mainAxisSpacing: 14 * scale,
                              crossAxisSpacing: 14 * scale,
                              childAspectRatio: width < 360 ? 0.92 : 0.72,
                            ),
                          ),
                        ),
                    ],
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

class _MediaHeader extends StatelessWidget {
  const _MediaHeader({
    required this.scale,
    required this.searchController,
    required this.selectedFilter,
    required this.onBack,
    required this.onSearchChanged,
    required this.onSearch,
    required this.onClear,
    required this.onFilterSelected,
  });

  final double scale;
  final TextEditingController searchController;
  final String selectedFilter;
  final VoidCallback onBack;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearch;
  final VoidCallback onClear;
  final ValueChanged<String> onFilterSelected;

  @override
  Widget build(BuildContext context) {
    const filters = <Map<String, String>>[
      {'label': 'spiritual_media_all', 'value': ''},
      {'label': 'spiritual_media_wallpaper', 'value': 'wallpaper'},
      {'label': 'spiritual_media_poster', 'value': 'poster'},
      {'label': 'spiritual_media_quote', 'value': 'quote'},
      {'label': 'spiritual_media_teaching', 'value': 'teaching'},
    ];

    return Container(
      padding: EdgeInsets.fromLTRB(
        18 * scale,
        12 * scale,
        18 * scale,
        18 * scale,
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
                onTap: onBack,
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
                  'spiritual_media'.tr,
                  style: TextStyle(
                    fontSize: 24 * scale,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14 * scale),
          Text(
            'spiritual_media_header_desc'.tr,
            style: TextStyle(
              fontSize: 13 * scale,
              color: Colors.white.withOpacity(0.88),
              height: 1.4,
            ),
          ),
          SizedBox(height: 16 * scale),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18 * scale),
            ),
            padding: EdgeInsets.symmetric(horizontal: 12 * scale),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  color: AppColors.homePrimary,
                  size: 22 * scale,
                ),
                SizedBox(width: 8 * scale),
                Expanded(
                  child: TextField(
                    controller: searchController,
                    textInputAction: TextInputAction.search,
                    onChanged: onSearchChanged,
                    onSubmitted: (_) => onSearch(),
                    decoration: InputDecoration(
                      hintText: 'spiritual_media_search_hint'.tr,
                      border: InputBorder.none,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: searchController.text.trim().isEmpty ? onSearch : onClear,
                  child: Icon(
                    searchController.text.trim().isEmpty
                        ? Icons.arrow_forward_rounded
                        : Icons.close_rounded,
                    color: Colors.black54,
                    size: 20 * scale,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14 * scale),
          SizedBox(
            height: 38 * scale,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final filter = filters[index];
                final active = selectedFilter == filter['value'];
                return GestureDetector(
                  onTap: () => onFilterSelected(filter['value']!),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: EdgeInsets.symmetric(
                      horizontal: 14 * scale,
                      vertical: 9 * scale,
                    ),
                    decoration: BoxDecoration(
                      color: active ? Colors.white : Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: active
                            ? Colors.white
                            : Colors.white.withOpacity(0.22),
                      ),
                    ),
                    child: Text(
                      filter['label']!.tr,
                      style: TextStyle(
                        fontSize: 12.5 * scale,
                        fontWeight: FontWeight.w600,
                        color: active ? AppColors.homePrimary : Colors.white,
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (_, __) => SizedBox(width: 8 * scale),
              itemCount: filters.length,
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaCard extends StatelessWidget {
  const _MediaCard({
    required this.scale,
    required this.item,
    required this.locked,
    required this.onTap,
    required this.onDownload,
  });

  final double scale;
  final SpiritualMediaItem item;
  final bool locked;
  final VoidCallback onTap;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final imageUrl = _mediaUrl(item.imageThumbPath ?? item.imageDisplayPath);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24 * scale),
        child: Container(
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24 * scale),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: imageUrl != null
                            ? Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _MediaImageFallback(
                                  scale: scale,
                                  mediaType: item.mediaType,
                                ),
                              )
                            : _MediaImageFallback(
                                scale: scale,
                                mediaType: item.mediaType,
                              ),
                      ),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withOpacity(0.06),
                                Colors.black.withOpacity(0.18),
                                Colors.black.withOpacity(0.52),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12 * scale,
                        left: 12 * scale,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10 * scale,
                            vertical: 5 * scale,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.16),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.24),
                            ),
                          ),
                          child: Text(
                            _mediaTypeLabel(item.mediaType).tr,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11 * scale,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12 * scale,
                        right: 12 * scale,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (locked)
                              Container(
                                margin: EdgeInsets.only(right: 8 * scale),
                                padding: EdgeInsets.all(7 * scale),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.26),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.lock_rounded,
                                  size: 16 * scale,
                                  color: Colors.white,
                                ),
                              ),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: onDownload,
                                borderRadius: BorderRadius.circular(999),
                                child: Ink(
                                  width: 38 * scale,
                                  height: 38 * scale,
                                  decoration: BoxDecoration(
                                    color: AppColors.homePrimary.withOpacity(0.92),
                                    shape: BoxShape.circle,
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x26000000),
                                        blurRadius: 8,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.download_rounded,
                                    color: Colors.white,
                                    size: 20 * scale,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        left: 14 * scale,
                        right: 14 * scale,
                        bottom: 14 * scale,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.displayTitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 18 * scale,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                height: 1.2,
                              ),
                            ),
                            if (item.displaySubtitle.isNotEmpty) ...[
                              SizedBox(height: 6 * scale),
                              Text(
                                item.displaySubtitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12 * scale,
                                  color: Colors.white.withOpacity(0.9),
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Padding(
                //   padding: EdgeInsets.fromLTRB(
                //     14 * scale,
                //     12 * scale,
                //     14 * scale,
                //     14 * scale,
                //   ),
                //   child: Row(
                //     children: [
                //       Expanded(
                //         child: Text(
                //           'spiritual_media_tap_to_view'.tr,
                //           maxLines: 1,
                //           overflow: TextOverflow.ellipsis,
                //           style: TextStyle(
                //             fontSize: 12.5 * scale,
                //             color: const Color(0xFF7B6A5B),
                //             fontWeight: FontWeight.w500,
                //           ),
                //         ),
                //       ),
                //       SizedBox(width: 8 * scale),
                //       Container(
                //         padding: EdgeInsets.symmetric(
                //           horizontal: 10 * scale,
                //           vertical: 7 * scale,
                //         ),
                //         decoration: BoxDecoration(
                //           color: const Color(0xFFF8EEE5),
                //           borderRadius: BorderRadius.circular(999),
                //         ),
                //         child: Row(
                //           mainAxisSize: MainAxisSize.min,
                //           children: [
                //             Icon(
                //               Icons.download_rounded,
                //               size: 15 * scale,
                //               color: AppColors.homePrimary,
                //             ),
                //             SizedBox(width: 5 * scale),
                //             Text(
                //               'spiritual_media_download'.tr,
                //               style: TextStyle(
                //                 fontSize: 11.5 * scale,
                //                 color: AppColors.homePrimary,
                //                 fontWeight: FontWeight.w700,
                //               ),
                //             ),
                //           ],
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SpiritualMediaDetailView extends StatelessWidget {
  const SpiritualMediaDetailView({
    required this.detail,
    super.key,
  });

  final SpiritualMediaDetailItem detail;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final scale = (mediaQuery.size.width / 390).clamp(0.84, 1.08);
    final imageUrl = _mediaUrl(detail.imageDisplayPath ?? detail.imageOriginalPath);

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
            Positioned.fill(
              child: imageUrl != null
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    )
                  : const SizedBox.shrink(),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFF8F1E8).withOpacity(0.72),
                      const Color(0xFFF8F1E8).withOpacity(0.86),
                      const Color(0xFFF8F1E8),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  16 * scale,
                  10 * scale,
                  16 * scale,
                  24 * scale,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        width: 42 * scale,
                        height: 42 * scale,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.homePrimary.withOpacity(0.12),
                        ),
                        child: Icon(
                          Icons.arrow_back_rounded,
                          color: AppColors.homePrimary,
                          size: 22 * scale,
                        ),
                      ),
                    ),
                    SizedBox(height: 18 * scale),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24 * scale),
                      child: AspectRatio(
                        aspectRatio: _detailAspectRatio(detail),
                        child: imageUrl != null
                            ? Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _MediaImageFallback(
                                  scale: scale,
                                  mediaType: detail.mediaType,
                                ),
                              )
                            : _MediaImageFallback(
                                scale: scale,
                                mediaType: detail.mediaType,
                              ),
                      ),
                    ),
                    SizedBox(height: 18 * scale),
                    Container(
                      padding: EdgeInsets.all(18 * scale),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.92),
                        borderRadius: BorderRadius.circular(22 * scale),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x18000000),
                            blurRadius: 18,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            detail.displayTitle,
                            style: TextStyle(
                              fontSize: 24 * scale,
                              fontWeight: FontWeight.w700,
                              color: AppColors.homePrimary,
                              height: 1.15,
                            ),
                          ),
                          SizedBox(height: 10 * scale),
                          if (detail.quoteText?.trim().isNotEmpty == true)
                            Text(
                              detail.quoteText!.trim(),
                              style: TextStyle(
                                fontSize: 16 * scale,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF6F2216),
                                height: 1.4,
                              ),
                            ),
                          if (detail.teachingSource?.trim().isNotEmpty == true) ...[
                            SizedBox(height: 8 * scale),
                            Text(
                              detail.teachingSource!.trim(),
                              style: TextStyle(
                                fontSize: 12.5 * scale,
                                color: const Color(0xFF88654E),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                          if (detail.description?.trim().isNotEmpty == true) ...[
                            SizedBox(height: 12 * scale),
                            Text(
                              detail.description!.trim(),
                              style: TextStyle(
                                fontSize: 14 * scale,
                                color: const Color(0xFF4E4036),
                                height: 1.55,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MediaEmptyState extends StatelessWidget {
  const _MediaEmptyState({
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
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.collections_bookmark_rounded,
                size: 52 * scale,
                color: AppColors.homePrimary,
              ),
              SizedBox(height: 14 * scale),
              Text(
                'spiritual_media_empty'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18 * scale,
                  fontWeight: FontWeight.w700,
                  color: AppColors.homePrimary,
                ),
              ),
              SizedBox(height: 8 * scale),
              Text(
                message.trim().isNotEmpty
                    ? message.trim()
                    : 'retry_later_refresh'.tr,
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
                  child: Text('refresh'.tr),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MediaLockedState extends StatelessWidget {
  const _MediaLockedState({
    required this.scale,
    required this.message,
    required this.onSubscribe,
  });

  final double scale;
  final String message;
  final Future<void> Function() onSubscribe;

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
              Container(
                width: 64 * scale,
                height: 64 * scale,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFF7D48A), Color(0xFFE6782F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(
                  Icons.lock_open_rounded,
                  size: 34 * scale,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 14 * scale),
              Text(
                'spiritual_media_premium_title'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18 * scale,
                  fontWeight: FontWeight.w700,
                  color: AppColors.homePrimary,
                ),
              ),
              SizedBox(height: 8 * scale),
              Text(
                message.trim().isNotEmpty
                    ? message.trim()
                    : 'spiritual_media_subscription_required'.tr,
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
                  onPressed: onSubscribe,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.homePrimary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14 * scale),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14 * scale),
                    ),
                  ),
                  child: Text('take_subscription'.tr),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MediaImageFallback extends StatelessWidget {
  const _MediaImageFallback({
    required this.scale,
    required this.mediaType,
  });

  final double scale;
  final String? mediaType;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF5C1017), Color(0xFFB56B34)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          _mediaTypeIcon(mediaType),
          size: 42 * scale,
          color: Colors.white.withOpacity(0.92),
        ),
      ),
    );
  }
}

double _detailAspectRatio(SpiritualMediaDetailItem detail) {
  final width = detail.originalWidth ?? detail.displayWidth;
  final height = detail.originalHeight ?? detail.displayHeight;
  if (width == null || height == null || width <= 0 || height <= 0) {
    return 4 / 5;
  }
  return width / height;
}

String? _mediaUrl(String? path) {
  final normalized = path?.trim();
  if (normalized == null || normalized.isEmpty) return null;
  if (normalized.startsWith('http://') || normalized.startsWith('https://')) {
    return normalized;
  }
  return '${ApiConstants.baseUrl}$normalized';
}

String _mediaTypeLabel(String? mediaType) {
  switch (mediaType?.trim().toLowerCase()) {
    case 'wallpaper':
      return 'spiritual_media_wallpaper';
    case 'poster':
      return 'spiritual_media_poster';
    case 'quote':
      return 'spiritual_media_quote';
    case 'teaching':
      return 'spiritual_media_teaching';
    default:
      return 'spiritual_media_all';
  }
}

IconData _mediaTypeIcon(String? mediaType) {
  switch (mediaType?.trim().toLowerCase()) {
    case 'wallpaper':
      return Icons.wallpaper_rounded;
    case 'poster':
      return Icons.photo_rounded;
    case 'quote':
      return Icons.format_quote_rounded;
    case 'teaching':
      return Icons.menu_book_rounded;
    default:
      return Icons.collections_rounded;
  }
}

String _mimeTypeFromImageType(String? imageType) {
  switch (imageType?.trim().toLowerCase()) {
    case 'png':
      return 'image/png';
    case 'webp':
      return 'image/webp';
    case 'gif':
      return 'image/gif';
    default:
      return 'image/jpeg';
  }
}
