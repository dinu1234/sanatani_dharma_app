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
                  'Live Darshan',
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
  static const List<double> _playerAspectRatios = [
    2.05,
    16 / 9,
    4 / 3,
  ];
  static const List<String> _playerSizeLabels = [
    'Compact',
    'Normal',
    'Expanded',
  ];

  YoutubePlayerController? _youtubeController;
  int _playerSizeIndex = 1;

  LiveDarshanItem get item => widget.item;

  double get _playerAspectRatio => _playerAspectRatios[_playerSizeIndex];

  String get _playerSizeLabel => _playerSizeLabels[_playerSizeIndex];

  void _updatePlayerSize(int nextIndex) {
    if (nextIndex < 0 || nextIndex >= _playerAspectRatios.length) return;
    setState(() => _playerSizeIndex = nextIndex);
  }

  void _handleYoutubeControllerUpdate() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    final videoId = item.youtubeVideoId;
    if (videoId != null && videoId.isNotEmpty) {
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
    }
  }

  @override
  void dispose() {
    _youtubeController?.removeListener(_handleYoutubeControllerUpdate);
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final scale = (mediaQuery.size.width / 390).clamp(0.84, 1.08);
    final imageUrl = _thumbnailUrl(item.thumbnailImagePath);
    final maxPlayerWidth = mediaQuery.size.width > 720 ? 720.0 : double.infinity;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF18110E),
        body: Stack(
          children: [
            Positioned.fill(
              child: imageUrl != null
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const DecoratedBox(
                        decoration: BoxDecoration(color: Colors.black),
                      ),
                    )
                  : const DecoratedBox(
                      decoration: BoxDecoration(color: Colors.black),
                    ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.35),
                      Colors.black.withOpacity(0.62),
                      const Color(0xFF18110E),
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
                          color: Colors.black.withOpacity(0.35),
                        ),
                        child: Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                          size: 22 * scale,
                        ),
                      ),
                    ),
                    SizedBox(height: 18 * scale),
                    Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxPlayerWidth),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (_youtubeController != null)
                              _InAppYoutubePlayer(
                                scale: scale,
                                controller: _youtubeController!,
                                aspectRatio: _playerAspectRatio,
                              )
                            else
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20 * scale),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 220),
                                  curve: Curves.easeOutCubic,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius:
                                        BorderRadius.circular(20 * scale),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.12),
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x33000000),
                                        blurRadius: 18,
                                        offset: Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: AspectRatio(
                                    aspectRatio: _playerAspectRatio,
                                    child: imageUrl != null
                                        ? Image.network(
                                            imageUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                _DarshanImageFallback(
                                                  scale: scale,
                                                ),
                                          )
                                        : _DarshanImageFallback(scale: scale),
                                  ),
                                ),
                              ),
                            if (_youtubeController != null) ...[
                              SizedBox(height: 12 * scale),
                              _YoutubeActionBar(
                                scale: scale,
                                isPlaying: _youtubeController!.value.isPlaying,
                                isFullScreen:
                                    _youtubeController!.value.isFullScreen,
                                sizeLabel: _playerSizeLabel,
                                canShrink: _playerSizeIndex > 0,
                                canExpand: _playerSizeIndex <
                                    _playerAspectRatios.length - 1,
                                onPlayPause: () {
                                  if (_youtubeController!.value.isPlaying) {
                                    _youtubeController!.pause();
                                  } else {
                                    _youtubeController!.play();
                                  }
                                },
                                onShrink: () =>
                                    _updatePlayerSize(_playerSizeIndex - 1),
                                onExpand: () =>
                                    _updatePlayerSize(_playerSizeIndex + 1),
                                onToggleFullscreen:
                                    _youtubeController!.toggleFullScreenMode,
                              ),
                            ],
                          ],
                        ),
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
                        color: Colors.white,
                        height: 1.12,
                      ),
                    ),
                    SizedBox(height: 8 * scale),
                    Text(
                      item.subtitle,
                      style: TextStyle(
                        fontSize: 14 * scale,
                        color: Colors.white.withOpacity(0.88),
                      ),
                    ),
                    if (item.description?.trim().isNotEmpty == true) ...[
                      SizedBox(height: 12 * scale),
                      Text(
                        item.description!.trim(),
                        style: TextStyle(
                          fontSize: 13.5 * scale,
                          height: 1.45,
                          color: Colors.white.withOpacity(0.82),
                        ),
                      ),
                    ],
                    SizedBox(height: 18 * scale),
                    if (_youtubeController == null)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _launchDarshan(item.streamUrl),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFC145),
                            foregroundColor: AppColors.homePrimary,
                            padding: EdgeInsets.symmetric(vertical: 15 * scale),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16 * scale),
                            ),
                          ),
                          icon: Icon(
                            Icons.open_in_new_rounded,
                            size: 22 * scale,
                          ),
                          label: Text(
                            item.isLive
                                ? 'Open Live Darshan'
                                : 'Open Darshan Stream',
                            style: TextStyle(
                              fontSize: 15 * scale,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    if (_youtubeController == null &&
                        item.streamUrl?.trim().isNotEmpty == true) ...[
                      SizedBox(height: 10 * scale),
                      Text(
                        'Youtube player tabhi chalega jab source me valid YouTube video id ya stream url mile.',
                        style: TextStyle(
                          fontSize: 11.5 * scale,
                          color: Colors.white.withOpacity(0.68),
                          height: 1.45,
                        ),
                      ),
                    ],
                    SizedBox(height: 10 * scale),
                    Text(
                      'Source: ${item.source?.trim().isNotEmpty == true ? item.source!.trim() : 'external stream'}',
                      style: TextStyle(
                        fontSize: 11.5 * scale,
                        color: Colors.white.withOpacity(0.68),
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

class _InAppYoutubePlayer extends StatelessWidget {
  const _InAppYoutubePlayer({
    required this.scale,
    required this.controller,
    required this.aspectRatio,
  });

  final double scale;
  final YoutubePlayerController controller;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20 * scale),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20 * scale),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: YoutubePlayerBuilder(
            player: YoutubePlayer(
              controller: controller,
              showVideoProgressIndicator: false,
            ),
            builder: (context, player) {
              return player;
            },
          ),
        ),
      ),
    );
  }
}

class _YoutubeActionBar extends StatelessWidget {
  const _YoutubeActionBar({
    required this.scale,
    required this.isPlaying,
    required this.isFullScreen,
    required this.sizeLabel,
    required this.canShrink,
    required this.canExpand,
    required this.onPlayPause,
    required this.onShrink,
    required this.onExpand,
    required this.onToggleFullscreen,
  });

  final double scale;
  final bool isPlaying;
  final bool isFullScreen;
  final String sizeLabel;
  final bool canShrink;
  final bool canExpand;
  final VoidCallback onPlayPause;
  final VoidCallback onShrink;
  final VoidCallback onExpand;
  final VoidCallback onToggleFullscreen;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 10 * scale),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.38),
        borderRadius: BorderRadius.circular(18 * scale),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        runSpacing: 10 * scale,
        spacing: 10 * scale,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _PlayerPill(
            scale: scale,
            icon: Icons.live_tv_rounded,
            label: sizeLabel,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PlayPauseActionButton(
                scale: scale,
                isPlaying: isPlaying,
                onTap: onPlayPause,
              ),
              SizedBox(width: 8 * scale),
              _PlayerIconButton(
                scale: scale,
                icon: Icons.remove_rounded,
                enabled: canShrink,
                onTap: onShrink,
              ),
              SizedBox(width: 8 * scale),
              _PlayerIconButton(
                scale: scale,
                icon: Icons.add_rounded,
                enabled: canExpand,
                onTap: onExpand,
              ),
              SizedBox(width: 8 * scale),
              _PlayerIconButton(
                scale: scale,
                icon: isFullScreen
                    ? Icons.fullscreen_exit_rounded
                    : Icons.fullscreen_rounded,
                onTap: onToggleFullscreen,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlayerPill extends StatelessWidget {
  const _PlayerPill({
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
      padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 6 * scale),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.54),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 14 * scale,
          ),
          SizedBox(width: 6 * scale),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 11.5 * scale,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayPauseActionButton extends StatelessWidget {
  const _PlayPauseActionButton({
    required this.scale,
    required this.isPlaying,
    required this.onTap,
  });

  final double scale;
  final bool isPlaying;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14 * scale),
        child: Ink(
          padding: EdgeInsets.symmetric(
            horizontal: 14 * scale,
            vertical: 10 * scale,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14 * scale),
            color: Colors.black.withOpacity(0.54),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 20 * scale,
              ),
              SizedBox(width: 6 * scale),
              Text(
                isPlaying ? 'Pause' : 'Play',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13 * scale,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayerIconButton extends StatelessWidget {
  const _PlayerIconButton({
    required this.scale,
    required this.icon,
    required this.onTap,
    this.enabled = true,
  });

  final double scale;
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          width: 36 * scale,
          height: 36 * scale,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: enabled
                ? Colors.black.withOpacity(0.54)
                : Colors.black.withOpacity(0.3),
            border: Border.all(color: Colors.white.withOpacity(0.16)),
          ),
          child: Icon(
            icon,
            color: enabled ? Colors.white : Colors.white38,
            size: 20 * scale,
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
                'Abhi koi live darshan available nahi mila.',
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
            isLive ? 'LIVE' : 'RECORDED',
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
