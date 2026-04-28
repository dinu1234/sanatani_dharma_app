import 'package:dharma_app/LiveDarshan/live_darshan_controller.dart';
import 'package:dharma_app/LiveDarshan/live_darshan_model.dart';
import 'package:dharma_app/core/constants/api_constants.dart';
import 'package:dharma_app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class LiveDarshanView extends StatefulWidget {
  const LiveDarshanView({super.key});

  @override
  State<LiveDarshanView> createState() => _LiveDarshanViewState();
}

class _LiveDarshanViewState extends State<LiveDarshanView> {
  late final LiveDarshanController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<LiveDarshanController>()
        ? Get.find<LiveDarshanController>()
        : Get.put(LiveDarshanController(), permanent: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _controller.ensureDarshanLoaded();
    });
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
                      Color(0xFFFBE9D7),
                      Color(0xFFF7F3EE),
                      Color(0xFFEDE4D7),
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
                  onRefresh: _controller.refreshDarshan,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: _DarshanHeader(
                          scale: scale,
                          controller: _controller,
                        ),
                      ),
                      if (_controller.isLoading.value &&
                          _controller.darshanItems.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.homePrimary,
                              strokeWidth: 2.4 * scale,
                            ),
                          ),
                        )
                      else if (_controller.darshanItems.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: _EmptyDarshanState(
                            scale: scale,
                            message: _controller.errorMessage.value,
                            onRetry: _controller.refreshDarshan,
                          ),
                        )
                      else
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                            16 * scale,
                            10 * scale,
                            16 * scale,
                            24 * scale,
                          ),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final item = _controller.darshanItems[index];
                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom: index ==
                                            _controller.darshanItems.length - 1
                                        ? 0
                                        : 14 * scale,
                                  ),
                                  child: _DarshanCard(
                                    scale: scale,
                                    item: item,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              LiveDarshanDetailView(item: item),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                              childCount: _controller.darshanItems.length,
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

class _DarshanHeader extends StatelessWidget {
  const _DarshanHeader({
    required this.scale,
    required this.controller,
  });

  final double scale;
  final LiveDarshanController controller;

  @override
  Widget build(BuildContext context) {
    final count = controller.darshanItems.length;

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
                  'live_darshan'.tr,
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
         
          SizedBox(height: 16 * scale),
      ],
      ),
    );
  }
}

class _DarshanCard extends StatelessWidget {
  const _DarshanCard({
    required this.scale,
    required this.item,
    required this.onTap,
  });

  final double scale;
  final LiveDarshanItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final imageUrl = _thumbnailUrl(item.thumbnailImagePath);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22 * scale),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22 * scale),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(22 * scale),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: imageUrl != null
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _DarshanImageFallback(scale: scale),
                        )
                      : _DarshanImageFallback(scale: scale),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(14 * scale),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _LiveBadge(scale: scale, isLive: item.isLive),
                        const Spacer(),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.homePrimary,
                          size: 22 * scale,
                        ),
                      ],
                    ),
                    SizedBox(height: 10 * scale),
                    Text(
                      item.displayTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18 * scale,
                        fontWeight: FontWeight.w700,
                        color: AppColors.homePrimary,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 6 * scale),
                    Text(
                      item.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13 * scale,
                        color: const Color(0xFF69594F),
                        height: 1.35,
                      ),
                    ),
                    if (item.description?.trim().isNotEmpty == true) ...[
                      SizedBox(height: 8 * scale),
                      Text(
                        item.description!.trim(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5 * scale,
                          color: const Color(0xFF7D7067),
                          height: 1.4,
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
    );
  }
}

class LiveDarshanDetailView extends StatefulWidget {
  const LiveDarshanDetailView({
    required this.item,
    super.key,
  });

  final LiveDarshanItem item;

  @override
  State<LiveDarshanDetailView> createState() => _LiveDarshanDetailViewState();
}

class _LiveDarshanDetailViewState extends State<LiveDarshanDetailView> {
  LiveDarshanItem get item => widget.item;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final scale = (mediaQuery.size.width / 390).clamp(0.84, 1.08);
    final imageUrl = _thumbnailUrl(item.thumbnailImagePath);
    final hasYoutubeVideo = item.youtubeVideoId?.trim().isNotEmpty == true;

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
                      errorBuilder: (_, __, ___) => const DecoratedBox(
                        decoration: BoxDecoration(color: Color(0xFFF8F1E8)),
                      ),
                    )
                  : const DecoratedBox(
                      decoration: BoxDecoration(color: Color(0xFFF8F1E8)),
                    ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFF8F1E8).withOpacity(0.90),
                      const Color(0xFFF8F1E8).withOpacity(0.84),
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
                  20 * scale,
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
                      borderRadius: BorderRadius.circular(20 * scale),
                      child: Stack(
                        children: [
                          AspectRatio(
                            aspectRatio: 16 / 9,
                            child: imageUrl != null
                                ? Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _DarshanImageFallback(scale: scale),
                                  )
                                : _DarshanImageFallback(scale: scale),
                          ),
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withOpacity(0.1),
                                    Colors.black.withOpacity(0.45),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: _FullscreenPlayButton(
                                scale: scale,
                                onTap: () {
                                  if (hasYoutubeVideo) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            _FullscreenDarshanVideoView(
                                              item: item,
                                            ),
                                      ),
                                    );
                                    return;
                                  }
                                  _launchDarshan(item.streamUrl);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20 * scale),
                    _LiveBadge(scale: scale, isLive: item.isLive),
                    SizedBox(height: 12 * scale),
                    Text(
                      item.displayTitle,
                      style: TextStyle(
                        fontSize: 28 * scale,
                        fontWeight: FontWeight.w700,
                        color: AppColors.homePrimary,
                        height: 1.12,
                      ),
                    ),
                    SizedBox(height: 8 * scale),
                    Text(
                      item.subtitle,
                      style: TextStyle(
                        fontSize: 14 * scale,
                        color: const Color(0xFF69594F),
                      ),
                    ),
                    if (item.description?.trim().isNotEmpty == true) ...[
                      SizedBox(height: 12 * scale),
                      Text(
                        item.description!.trim(),
                        style: TextStyle(
                          fontSize: 13.5 * scale,
                          height: 1.45,
                          color: const Color(0xFF7D7067),
                        ),
                      ),
                    ],
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

class _FullscreenDarshanVideoView extends StatefulWidget {
  const _FullscreenDarshanVideoView({required this.item});

  final LiveDarshanItem item;

  @override
  State<_FullscreenDarshanVideoView> createState() =>
      _FullscreenDarshanVideoViewState();
}

class _FullscreenDarshanVideoViewState extends State<_FullscreenDarshanVideoView> {
  YoutubePlayerController? _youtubeController;

  LiveDarshanItem get item => widget.item;

  void _handleYoutubeControllerUpdate() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    final videoId = item.youtubeVideoId;
    if (videoId == null || videoId.isEmpty) return;
    _youtubeController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        isLive: item.isLive,
        hideControls: true,
        enableCaption: false,
      ),
    );
    _youtubeController!.addListener(_handleYoutubeControllerUpdate);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _youtubeController?.toggleFullScreenMode();
    });
  }

  @override
  void dispose() {
    _youtubeController?.removeListener(_handleYoutubeControllerUpdate);
    _youtubeController?.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: AppColors.homePrimary,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final scale = (mediaQuery.size.width / 390).clamp(0.84, 1.08);
    final imageUrl = _thumbnailUrl(item.thumbnailImagePath);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Positioned.fill(
              child: _youtubeController != null
                  ? YoutubePlayerBuilder(
                      player: YoutubePlayer(
                        controller: _youtubeController!,
                        showVideoProgressIndicator: false,
                      ),
                      builder: (context, player) => player,
                    )
                  : (imageUrl != null
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _DarshanImageFallback(scale: scale),
                        )
                      : _DarshanImageFallback(scale: scale)),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.28),
                        Colors.transparent,
                        Colors.black.withOpacity(0.42),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 12 * scale,
                  vertical: 10 * scale,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _RoundOverlayButton(
                          scale: scale,
                          icon: Icons.arrow_back_rounded,
                          onTap: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _RoundOverlayButton(
                          scale: scale,
                          icon: _youtubeController?.value.isPlaying == true
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          onTap: () {
                            final controller = _youtubeController;
                            if (controller == null) return;
                            if (controller.value.isPlaying) {
                              controller.pause();
                            } else {
                              controller.play();
                            }
                          },
                        ),
                        _RoundOverlayButton(
                          scale: scale,
                          icon: _youtubeController?.value.isFullScreen == true
                              ? Icons.fullscreen_exit_rounded
                              : Icons.fullscreen_rounded,
                          onTap: () => _youtubeController?.toggleFullScreenMode(),
                        ),
                      ],
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

class _FullscreenPlayButton extends StatelessWidget {
  const _FullscreenPlayButton({
    required this.scale,
    required this.onTap,
  });

  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          width: 72 * scale,
          height: 72 * scale,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withOpacity(0.52),
            border: Border.all(color: Colors.white.withOpacity(0.38)),
          ),
          child: Icon(
            Icons.play_arrow_rounded,
            color: Colors.white,
            size: 40 * scale,
          ),
        ),
      ),
    );
  }
}

class _RoundOverlayButton extends StatelessWidget {
  const _RoundOverlayButton({
    required this.scale,
    required this.icon,
    required this.onTap,
  });

  final double scale;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          width: 42 * scale,
          height: 42 * scale,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withOpacity(0.44),
            border: Border.all(color: Colors.white.withOpacity(0.22)),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 22 * scale,
          ),
        ),
      ),
    );
  }
}

class _EmptyDarshanState extends StatelessWidget {
  const _EmptyDarshanState({
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
                Icons.live_tv_rounded,
                size: 52 * scale,
                color: AppColors.homePrimary,
              ),
              SizedBox(height: 14 * scale),
              Text(
                'live_unavailable'.tr,
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

class _DarshanImageFallback extends StatelessWidget {
  const _DarshanImageFallback({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF5C1017), Color(0xFFAA6230)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.live_tv_rounded,
          size: 48 * scale,
          color: Colors.white.withOpacity(0.92),
        ),
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge({
    required this.scale,
    required this.isLive,
  });

  final double scale;
  final bool isLive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10 * scale,
        vertical: 6 * scale,
      ),
      decoration: BoxDecoration(
        color: isLive ? const Color(0xFFE53935) : const Color(0xFF7A6A61),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7 * scale,
            height: 7 * scale,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 6 * scale),
          Text(
            isLive ? 'live'.tr : 'recorded'.tr,
            style: TextStyle(
              fontSize: 11 * scale,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

String? _thumbnailUrl(String? path) {
  if (path == null || path.trim().isEmpty) return null;
  final normalized = path.trim();
  if (normalized.startsWith('http://') || normalized.startsWith('https://')) {
    return normalized;
  }
  return '${ApiConstants.baseUrl}$normalized';
}

Future<void> _launchDarshan(String? url) async {
  final streamUrl = url?.trim();
  if (streamUrl == null || streamUrl.isEmpty) return;

  final uri = Uri.tryParse(streamUrl);
  if (uri == null) return;

  await launchUrl(uri, mode: LaunchMode.externalApplication);
}
