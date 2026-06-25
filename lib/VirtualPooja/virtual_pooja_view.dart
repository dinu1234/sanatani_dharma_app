import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:audioplayers/audioplayers.dart';
import 'package:dharma_app/VirtualPooja/virtual_pooja_controller.dart';
import 'package:dharma_app/VirtualPooja/virtual_pooja_model.dart';
import 'package:dharma_app/core/widgets/shree_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class VirtualPoojaView extends StatefulWidget {
  const VirtualPoojaView({super.key});

  @override
  State<VirtualPoojaView> createState() => _VirtualPoojaViewState();
}

class _VirtualPoojaViewState extends State<VirtualPoojaView> {
  late final VirtualPoojaController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<VirtualPoojaController>()
        ? Get.find<VirtualPoojaController>()
        : Get.put(VirtualPoojaController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      controller.resetCurrentPooja();
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final scale = (width / 390).clamp(0.84, 1.08);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFFFFF1DD),
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF1DD),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              18 * scale,
              4 * scale,
              18 * scale,
              16 * scale,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AppBar(scale: scale),
                SizedBox(height: 6 * scale),
                _DeityList(controller: controller, scale: scale),
                SizedBox(height: 2 * scale),
                Obx(
                  () => _StepHeader(
                    scale: scale,
                    deityName:
                        controller.selectedDeity.value?.name ?? 'Ganesha',
                    navaGrahaActive: controller.isNavaGrahaStarted.value,
                  ),
                ),
                SizedBox(height: 6 * scale),
                Obx(() {
                  if (controller.isNavaGrahaStarted.value) {
                    return _NavaGrahaScreen(
                      scale: scale,
                      progress: controller.navaGrahaProgress.value,
                      onReset: controller.resetNavaGraha,
                      onAdvance: controller.advanceNavaGraha,
                      onNewPooja: controller.resetCurrentPooja,
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _AltarCard(
                        scale: scale,
                        deity: controller.selectedDeity.value,
                        isLoading: controller.isLoading.value,
                        diyaLit: controller.diyaProgress.value >= 3,
                        petalsEnabled:
                            controller.diyaProgress.value >= 3 &&
                            controller.petalCount.value < 6,
                        petalEvent: controller.petalEvent.value,
                        onMurtiTap: controller.offerPetal,
                        onBellTap: controller.ringGhanta,
                        bellEnabled:
                            controller.diyaProgress.value >= 3 &&
                            controller.petalCount.value >= 6 &&
                            controller.ghantaRings.value < 3,
                      ),
                      SizedBox(height: 14 * scale),
                      controller.diyaProgress.value < 3
                          ? _DiyaStep(controller: controller, scale: scale)
                          : controller.petalCount.value < 6
                          ? _PetalStep(controller: controller, scale: scale)
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _GhantaStep(
                                  controller: controller,
                                  scale: scale,
                                ),
                                if (controller.ghantaRings.value >= 3) ...[
                                  SizedBox(height: 14 * scale),
                                  _ArchanaCompleteCard(
                                    scale: scale,
                                    deityName:
                                        controller.selectedDeity.value?.name ??
                                        'Deity',
                                    onContinue: controller.startNavaGraha,
                                  ),
                                ],
                              ],
                            ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  const _AppBar({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_rounded,
            color: const Color(0xFF8B0B00),
            size: 24 * scale,
          ),
        ),
        Expanded(
          child: Text(
            'Virtual Pooja',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF8B0B00),
              fontSize: 20 * scale,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        SizedBox(width: 48 * scale),
      ],
    );
  }
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({
    required this.scale,
    required this.deityName,
    required this.navaGrahaActive,
  });

  final double scale;
  final String deityName;
  final bool navaGrahaActive;

  @override
  Widget build(BuildContext context) {
    final titleName = deityName
        .replaceFirst(RegExp(r'^lord\s+', caseSensitive: false), '')
        .trim()
        .toUpperCase();

    return Row(
      children: [
        Text(
          '1 · $titleName ARCHANA',
          style: TextStyle(
            color: navaGrahaActive
                ? const Color(0xFF9C766D)
                : const Color(0xFFBC190A),
            fontSize: 12 * scale,
            fontWeight: navaGrahaActive ? FontWeight.w800 : FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
        SizedBox(width: 9 * scale),
        Expanded(child: Container(height: 1, color: const Color(0xFFC7A08D))),
        SizedBox(width: 9 * scale),
        Text(
          '2 · NAVA GRAHA',
          style: TextStyle(
            color: navaGrahaActive
                ? const Color(0xFFBC190A)
                : const Color(0xFF9C766D),
            fontSize: 12 * scale,
            fontWeight: navaGrahaActive ? FontWeight.w900 : FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _DeityList extends StatelessWidget {
  const _DeityList({required this.controller, required this.scale});

  final VirtualPoojaController controller;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 114 * scale,
      child: Obx(() {
        final selectedId = controller.selectedDeityId.value;
        final deities = controller.deities.toList();

        if (controller.isLoading.value && deities.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFBC190A)),
          );
        }

        if (controller.hasLoadError && deities.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16 * scale),
                  child: Text(
                    controller.loadErrorMessage.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF8B0B00),
                      fontSize: 13 * scale,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(height: 8 * scale),
                TextButton(
                  onPressed: controller.loadActiveDeities,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFBC190A),
                    textStyle: TextStyle(
                      fontSize: 13 * scale,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (deities.isEmpty) {
          return Center(
            child: Text(
              'No active deities',
              style: TextStyle(
                color: const Color(0xFF8B0B00),
                fontSize: 14 * scale,
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        }

        return ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: deities.length,
          separatorBuilder: (_, _) => SizedBox(width: 2 * scale),
          itemBuilder: (context, index) {
            final deity = deities[index];
            final selected = selectedId == deity.id;
            final locked = controller.isDeityLocked(deity);

            return _DeityStory(
              deity: deity,
              imageUrl: deity.fullImageUrl,
              selected: selected,
              locked: locked,
              scale: scale,
              onTap: () => controller.selectDeity(deity),
            );
          },
        );
      }),
    );
  }
}

class _DeityStory extends StatelessWidget {
  const _DeityStory({
    required this.deity,
    required this.imageUrl,
    required this.selected,
    required this.locked,
    required this.scale,
    required this.onTap,
  });

  final VirtualPoojaDeity deity;
  final String? imageUrl;
  final bool selected;
  final bool locked;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final size = 66 * scale;
    final ringColors = selected
        ? const [Color(0xFFFF7A1A), Color(0xFFBC190A)]
        : const [Color(0xFFE7B780), Color(0xFFD8A36D)];

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        width: 88 * scale,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: size,
              height: size,
              padding: EdgeInsets.all(selected ? 3 * scale : 2 * scale),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: ringColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Container(
                padding: EdgeInsets.all(3 * scale),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF1DD),
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: ClipOval(
                        child: imageUrl == null
                            ? _StoryFallback(scale: scale)
                            : Image.network(
                                imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) =>
                                    _StoryFallback(scale: scale),
                              ),
                      ),
                    ),
                    Positioned(
                      right: -2 * scale,
                      bottom: -2 * scale,
                      child: Container(
                        width: 20 * scale,
                        height: 20 * scale,
                        decoration: BoxDecoration(
                          color: locked
                              ? const Color(0xFF760400)
                              : const Color(0xFFFF7A1A),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFFFF1DD),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          locked ? Icons.lock_rounded : Icons.check_rounded,
                          size: 12 * scale,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 7 * scale),
            Text(
              deity.name,
              maxLines: 2,
              overflow: TextOverflow.visible,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected
                    ? const Color(0xFFBC190A)
                    : const Color(0xFF6F3B2D),
                fontSize: 11.5 * scale,
                height: 1.1,
                fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoryFallback extends StatelessWidget {
  const _StoryFallback({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFE7C7),
      padding: EdgeInsets.all(13 * scale),
      child: const ShreeSvg(fit: BoxFit.contain),
    );
  }
}

class _AltarCard extends StatefulWidget {
  const _AltarCard({
    required this.scale,
    required this.deity,
    required this.isLoading,
    required this.diyaLit,
    required this.petalsEnabled,
    required this.petalEvent,
    required this.onMurtiTap,
    required this.onBellTap,
    required this.bellEnabled,
  });

  final double scale;
  final VirtualPoojaDeity? deity;
  final bool isLoading;
  final bool diyaLit;
  final bool petalsEnabled;
  final int petalEvent;
  final VoidCallback onMurtiTap;
  final VoidCallback onBellTap;
  final bool bellEnabled;

  @override
  State<_AltarCard> createState() => _AltarCardState();
}

class _PetalDrop {
  const _PetalDrop({
    required this.id,
    required this.left,
    required this.rotation,
    required this.symbol,
    required this.drift,
    required this.size,
    required this.targetY,
  });

  final int id;
  final double left;
  final double rotation;
  final String symbol;
  final double drift;
  final double size;
  final double targetY;
}

class _FallingPetal extends StatefulWidget {
  const _FallingPetal({required this.petal, required this.scale});

  final _PetalDrop petal;
  final double scale;

  @override
  State<_FallingPetal> createState() => _FallingPetalState();
}

class _FallingPetalState extends State<_FallingPetal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2350),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final raw = _controller.value;
              final t = Curves.easeInOutCubicEmphasized.transform(raw);
              final settleT = Curves.easeOut.transform(
                ((raw - 0.82) / 0.18).clamp(0.0, 1.0),
              );
              final y =
                  (widget.petal.targetY * widget.scale * t) +
                  (10 * widget.scale * settleT);
              final sway =
                  math.sin((raw * math.pi * 1.15) + widget.petal.rotation) *
                  widget.petal.drift *
                  widget.scale;
              final opacity = raw < 0.9
                  ? 1.0
                  : (1 - ((raw - 0.9) / 0.1)).clamp(0.0, 1.0);
              final rotation = widget.petal.rotation + (280 * t);
              final scale = 0.96 + (0.1 * math.sin(raw * math.pi));

              return Stack(
                children: [
                  Positioned(
                    left: constraints.maxWidth * widget.petal.left,
                    top: -10 * widget.scale,
                    child: Opacity(
                      opacity: opacity,
                      child: Transform.translate(
                        offset: Offset((-16 * widget.scale) + (sway * 0.45), y),
                        child: Transform.rotate(
                          angle: rotation * math.pi / 180,
                          child: Transform.scale(scale: scale, child: child),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
            child: Text(
              widget.petal.symbol,
              style: TextStyle(
                fontSize: widget.petal.size * widget.scale,
                height: 1,
                shadows: const [
                  Shadow(color: Color(0x55FFFFFF), blurRadius: 3),
                  Shadow(color: Color(0x33000000), blurRadius: 8),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AltarCardState extends State<_AltarCard> {
  final List<_PetalDrop> _petals = [];
  final math.Random _random = math.Random();
  final List<String> _petalSequence = const [
    '\u{1F33A}',
    '\u{1F3F5}\uFE0F',
    '\u{1F33C}',
    '\u{1F4AE}',
    '\u{1F338}',
    '\u{1F4AE}',
  ];
  int _nextPetalId = 0;
  int _bellWaveEvent = 0;

  @override
  void didUpdateWidget(covariant _AltarCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final missedPetals = widget.petalEvent - oldWidget.petalEvent;
    if (missedPetals > 0) {
      for (var index = 0; index < missedPetals; index++) {
        Future.delayed(Duration(milliseconds: 120 * index), () {
          if (!mounted) return;
          _addPetal();
        });
      }
    }
  }

  void _addPetal() {
    final symbol = _petalSequence[_nextPetalId % _petalSequence.length];
    final petal = _PetalDrop(
      id: _nextPetalId,
      left: 0.5,
      rotation: _random.nextDouble() * 360,
      symbol: symbol,
      drift: 8 + (_random.nextDouble() * 5),
      size: 30 + (_random.nextDouble() * 4),
      targetY: 198 + (_random.nextDouble() * 24),
    );
    _nextPetalId += 1;
    setState(() => _petals.add(petal));
    Future.delayed(const Duration(milliseconds: 2900), () {
      if (!mounted) return;
      setState(() => _petals.removeWhere((item) => item.id == petal.id));
    });
  }

  void _handleBellTap() {
    setState(() => _bellWaveEvent += 1);
    widget.onBellTap();
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;
    final imageUrl = widget.deity?.fullImageUrl;

    return AspectRatio(
      aspectRatio: 1.04,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24 * scale),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/virtual_pooja_altar.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x22000000),
                    Color(0x00000000),
                    Color(0x88000000),
                  ],
                ),
              ),
            ),
            if (widget.diyaLit)
              const Positioned.fill(child: _AltarLightOverlay()),
            Align(
              alignment: const Alignment(0, -0.04),
              child: SizedBox(
                width: 210 * scale,
                height: 292 * scale,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Positioned(
                      top: scale,
                      child: _OmMark(scale: scale),
                    ),
                    Positioned.fill(
                      top: 32 * scale,
                      child: GestureDetector(
                        onTap: widget.petalsEnabled ? widget.onMurtiTap : null,
                        behavior: HitTestBehavior.translucent,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: widget.isLoading
                                  ? const Center(
                                      key: ValueKey('loading'),
                                      child: CircularProgressIndicator(
                                        color: Color(0xFFBC190A),
                                      ),
                                    )
                                  : imageUrl == null
                                  ? const Padding(
                                      key: ValueKey('fallback'),
                                      padding: EdgeInsets.all(42),
                                      child: ShreeSvg(fit: BoxFit.contain),
                                    )
                                  : Image.network(
                                      imageUrl,
                                      key: ValueKey(imageUrl),
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, _, _) => const Padding(
                                        padding: EdgeInsets.all(42),
                                        child: ShreeSvg(fit: BoxFit.contain),
                                      ),
                                    ),
                            ),
                            if (!widget.diyaLit)
                              const Positioned.fill(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: RadialGradient(
                                      center: Alignment(0, -0.08),
                                      radius: 0.92,
                                      colors: [
                                        Color(0x00000000),
                                        Color(0x1A000000),
                                        Color(0x66000000),
                                      ],
                                      stops: [0, 0.58, 1],
                                    ),
                                  ),
                                ),
                              ),
                            Positioned.fill(
                              child: _MurtiBellWave(
                                // key: ValueKey(_bellWaveEvent),
                                scale: scale,
                                event: _bellWaveEvent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            for (final petal in _petals)
              Positioned.fill(
                child: _FallingPetal(petal: petal, scale: scale),
              ),
            if (widget.diyaLit)
              Positioned(
                left: 0,
                right: 0,
                bottom: 12 * scale,
                child: _CenterSmoke(scale: scale),
              ),
            if (widget.diyaLit) ...[
              Positioned(
                left: -16 * scale,
                bottom: -8 * scale,
                child: _LampHalo(scale: scale),
              ),
              Positioned(
                right: -16 * scale,
                bottom: -8 * scale,
                child: _LampHalo(scale: scale),
              ),
            ],
            Positioned(
              left: 25 * scale,
              bottom: 12 * scale,
              child: _Lamp(scale: scale, lit: widget.diyaLit),
            ),
            Positioned(
              right: 25 * scale,
              bottom: 12 * scale,
              child: _Lamp(scale: scale, lit: widget.diyaLit),
            ),
            Positioned(
              top: 12 * scale,
              right: 2 * scale,
              child: _TempleBell(
                scale: scale,
                enabled: widget.bellEnabled,
                onTap: _handleBellTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterSmoke extends StatelessWidget {
  const _CenterSmoke({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 132 * scale,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          _SmokeParticle(
            scale: scale,
            duration: const Duration(milliseconds: 7200),
            delay: Duration.zero,
            drift: -6,
          ),
          _SmokeParticle(
            scale: scale,
            duration: const Duration(milliseconds: 8200),
            delay: const Duration(milliseconds: 1600),
            drift: 3,
          ),
          _SmokeParticle(
            scale: scale,
            duration: const Duration(milliseconds: 9200),
            delay: const Duration(milliseconds: 3200),
            drift: 8,
          ),
        ],
      ),
    );
  }
}

class _LampHalo extends StatelessWidget {
  const _LampHalo({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: 132 * scale,
        height: 94 * scale,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 0.40,
            colors: [Color(0xB3FF8A1F), Color(0x59FFB43C), Color(0x00FFB43C)],
            stops: [0, 0.42, 1],
          ),
        ),
      ),
    );
  }
}

class _SmokeParticle extends StatefulWidget {
  const _SmokeParticle({
    required this.scale,
    required this.duration,
    required this.delay,
    required this.drift,
  });

  final double scale;
  final Duration duration;
  final Duration delay;
  final double drift;

  @override
  State<_SmokeParticle> createState() => _SmokeParticleState();
}

class _SmokeParticleState extends State<_SmokeParticle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.repeat();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final raw = _controller.value;
        final t = Curves.easeInOutSine.transform(raw);
        final opacity = (0.62 * (1 - t)).clamp(0.0, 0.62);
        final y = -108 * widget.scale * t;
        final wave = math.sin(raw * math.pi * 2.4) * 4 * widget.scale;
        final x = (widget.drift * widget.scale * t) + wave;
        final particleScale = 1 + (1.05 * t);

        return Transform.translate(
          offset: Offset(x, y),
          child: Transform.rotate(
            angle:
                ((widget.drift > 0 ? -0.1 : 0.1) * t) +
                (math.sin(raw * math.pi * 1.7) * 0.04),
            child: Transform.scale(
              scale: particleScale,
              child: Opacity(opacity: opacity, child: child),
            ),
          ),
        );
      },
      child: ImageFiltered(
        imageFilter: ui.ImageFilter.blur(
          sigmaX: 4.5 * widget.scale,
          sigmaY: 6.5 * widget.scale,
        ),
        child: Container(
          width: 18 * widget.scale,
          height: 62 * widget.scale,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: const RadialGradient(
              center: Alignment.center,
              radius: 0.95,
              colors: [Color(0xD9FFFFFF), Color(0x73FFFFFF), Color(0x00FFFFFF)],
              stops: [0, 0.48, 1],
            ),
          ),
        ),
      ),
    );
  }
}

class _AltarLightOverlay extends StatefulWidget {
  const _AltarLightOverlay();

  @override
  State<_AltarLightOverlay> createState() => _AltarLightOverlayState();
}

class _AltarLightOverlayState extends State<_AltarLightOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _opacity = Tween<double>(
      begin: 0.36,
      end: 0.76,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _opacity,
        builder: (context, child) {
          return Opacity(opacity: _opacity.value, child: child);
        },
        child: Stack(
          fit: StackFit.expand,
          children: const [
            CustomPaint(painter: _TempleBeamPainter()),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x33FFB43C),
                    Color(0x14FFB43C),
                    Color(0x00FFB43C),
                  ],
                  stops: [0, 0.34, 0.78],
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.04),
                  radius: 0.78,
                  colors: [
                    Color(0x73FFC45A),
                    Color(0x2EFFAA28),
                    Color(0x0FFF7A1A),
                    Color(0x00FFC45A),
                  ],
                  stops: [0, 0.36, 0.58, 0.82],
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, 0.82),
                  radius: 0.68,
                  colors: [
                    Color(0x3DFF8A1F),
                    Color(0x1AFFB43C),
                    Color(0x00FFB43C),
                  ],
                  stops: [0, 0.42, 1],
                ),
              ),
            ),
            Opacity(
              opacity: 0.34,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: SweepGradient(
                    center: Alignment(0, -1),
                    startAngle: 3.49,
                    endAngle: 9.78,
                    colors: [
                      Color(0x00FFD278),
                      Color(0x66FFD278),
                      Color(0x00FFD278),
                      Color(0x45FFD278),
                      Color(0x00FFD278),
                      Color(0x38FFD278),
                      Color(0x00FFD278),
                    ],
                    stops: [0, 0.06, 0.14, 0.28, 0.42, 0.58, 0.74],
                  ),
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.1),
                  radius: 0.88,
                  colors: [
                    Color(0x00000000),
                    Color(0x00000000),
                    Color(0x8C140500),
                  ],
                  stops: [0, 0.52, 1],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TempleBeamPainter extends CustomPainter {
  const _TempleBeamPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final beamPaint = Paint()
      ..blendMode = BlendMode.screen
      ..shader = ui.Gradient.linear(
        Offset(size.width * 0.5, 0),
        Offset(size.width * 0.5, size.height * 0.78),
        const [Color(0x3DFFB42A), Color(0x18FFB42A), Color(0x00FFB42A)],
        const [0, 0.52, 1],
      );

    void drawBeam(
      double topX,
      double topWidth,
      double bottomX,
      double bottomWidth,
    ) {
      final path = Path()
        ..moveTo(topX - topWidth, 0)
        ..lineTo(topX + topWidth, 0)
        ..lineTo(bottomX + bottomWidth, size.height * 0.9)
        ..lineTo(bottomX - bottomWidth, size.height * 0.9)
        ..close();
      canvas.drawPath(path, beamPaint);
    }

    drawBeam(
      size.width * 0.28,
      size.width * 0.045,
      size.width * 0.08,
      size.width * 0.12,
    );
    drawBeam(
      size.width * 0.42,
      size.width * 0.038,
      size.width * 0.28,
      size.width * 0.09,
    );
    drawBeam(
      size.width * 0.58,
      size.width * 0.038,
      size.width * 0.72,
      size.width * 0.09,
    );
    drawBeam(
      size.width * 0.72,
      size.width * 0.045,
      size.width * 0.92,
      size.width * 0.12,
    );

    final centerGlowPaint = Paint()
      ..blendMode = BlendMode.screen
      ..shader = ui.Gradient.radial(
        Offset(size.width * 0.5, size.height * 0.28),
        size.width * 0.44,
        const [Color(0x24FFD36A), Color(0x0FFFB42A), Color(0x00FFB42A)],
        const [0, 0.48, 1],
      );
    canvas.drawRect(rect, centerGlowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _OmMark extends StatelessWidget {
  const _OmMark({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final size = 28 * scale;

    return Opacity(
      opacity: 1,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0x80D8A33A), width: 1.2),
        ),
        child: Center(
          child: Text(
            'ॐ',
            style: TextStyle(
              color: const Color(0xFFD8A33A),
              fontSize: 20 * scale,
              fontFamily: 'serif',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _Lamp extends StatefulWidget {
  const _Lamp({required this.scale, required this.lit});

  final double scale;
  final bool lit;

  @override
  State<_Lamp> createState() => _LampState();
}

class _LampState extends State<_Lamp> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _glow = Tween<double>(
      begin: 0.72,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    if (widget.lit) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _Lamp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lit && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.lit && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;

    return SizedBox(
      width: 58 * scale,
      height: 62 * scale,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          AnimatedBuilder(
            animation: _glow,
            builder: (context, _) {
              return Container(
                width: 60 * scale,
                height: 28 * scale,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4 * scale),
                    topRight: Radius.circular(4 * scale),
                    bottomLeft: Radius.circular(28 * scale),
                    bottomRight: Radius.circular(28 * scale),
                  ),
                  boxShadow: [
                    const BoxShadow(
                      color: Color(0x80000000),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                    if (widget.lit)
                      BoxShadow(
                        color: Color.fromRGBO(
                          255,
                          170,
                          40,
                          0.62 + (0.28 * _glow.value),
                        ),
                        // blurRadius: 12 + (8 * _glow.value),
                        // spreadRadius: 0.5 + (1.5 * _glow.value),
                      ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFC97D1F), Color(0xFF7A3B0E)],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        height: 3 * scale,
                        margin: EdgeInsets.symmetric(horizontal: 3 * scale),
                        decoration: BoxDecoration(
                          color: const Color(0x99F0B34A),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          if (widget.lit)
            Positioned(
              bottom: 26 * scale,
              child: _FlickerFlame(scale: scale),
            ),
        ],
      ),
    );
  }
}

class _FlickerFlame extends StatefulWidget {
  const _FlickerFlame({required this.scale});

  final double scale;

  @override
  State<_FlickerFlame> createState() => _FlickerFlameState();
}

class _FlickerFlameState extends State<_FlickerFlame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final flameScaleY = 1.0 + (math.sin(t * math.pi) * 0.18);
        final flameScaleX = 1.0 - (math.sin(t * math.pi) * 0.08);
        final moveX = math.sin(t * math.pi * 2) * 1.8 * scale;
        final moveY = -math.sin(t * math.pi) * 2.5 * scale;
        final rotate = math.sin(t * math.pi * 2) * 0.08;

        return Transform.translate(
          offset: Offset(moveX, moveY),
          child: Transform.rotate(
            angle: rotate,
            child: Transform.scale(
              scaleX: flameScaleX,
              scaleY: flameScaleY,
              child: child,
            ),
          ),
        );
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            '🔥',
            style: TextStyle(
              fontSize: 30 * scale,
              height: 1,
              shadows: const [
                Shadow(color: Color(0xFFFFF1A8), blurRadius: 10),
                Shadow(color: Color(0xFFFFB43C), blurRadius: 22),
                Shadow(color: Color(0xFFFF5A1F), blurRadius: 36),
              ],
            ),
          ),
          Transform.translate(
            offset: Offset(0, -2 * scale),
            child: Text(
              '🔥',
              style: TextStyle(
                fontSize: 5 * scale,
                color: Colors.white.withValues(alpha: 0.38),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressBars extends StatelessWidget {
  const _ProgressBars({required this.scale, required this.progress});

  final double scale;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (index) {
        final fill = (progress - index).clamp(0.0, 1.0);
        return Expanded(
          child: Container(
            height: 8 * scale,
            margin: EdgeInsets.only(right: index == 2 ? 0 : 6 * scale),
            decoration: BoxDecoration(
              color: const Color(0xFFEBCDBD),
              borderRadius: BorderRadius.circular(999),
            ),
            clipBehavior: Clip.antiAlias,
            child: Align(
              alignment: Alignment.centerLeft,
              child: AnimatedFractionallySizedBox(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                widthFactor: fill,
                heightFactor: 1,
                child: const DecoratedBox(
                  decoration: BoxDecoration(color: Color(0xFFC51B09)),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _DiyaStep extends StatelessWidget {
  const _DiyaStep({required this.controller, required this.scale});

  final VirtualPoojaController controller;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Light the Diya',
          style: TextStyle(
            color: const Color(0xFF8B0B00),
            fontSize: 24 * scale,
            height: 1.05,
            fontWeight: FontWeight.w600,
            fontFamily: 'serif',
          ),
        ),
        SizedBox(height: 4 * scale),
        Text(
          'Deep darshanam punyam',
          style: TextStyle(
            color: const Color(0xFFD83A19),
            fontSize: 15 * scale,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.italic,
          ),
        ),
        SizedBox(height: 10 * scale),
        Text(
          'Press and hold the diya to ignite the sacred flame.',
          style: TextStyle(
            color: const Color(0xFF42140C),
            fontSize: 16 * scale,
            height: 1.25,
          ),
        ),
        SizedBox(height: 10 * scale),
        Obx(
          () => _ProgressBars(
            scale: scale,
            progress: controller.diyaProgress.value >= 3
                ? 1
                : controller.diyaHoldProgress.value,
          ),
        ),
        SizedBox(height: 14 * scale),
        Obx(
          () => _DiyaButton(
            scale: scale,
            progress: controller.diyaProgress.value,
            onLit: controller.lightDiya,
            onHoldProgressChanged: controller.setDiyaHoldProgress,
          ),
        ),
      ],
    );
  }
}

class _PetalStep extends StatelessWidget {
  const _PetalStep({required this.controller, required this.scale});

  final VirtualPoojaController controller;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final count = controller.petalCount.value;
      final completed = count >= 6;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Offer Pushpam',
            style: TextStyle(
              color: const Color(0xFF8B0B00),
              fontSize: 24 * scale,
              height: 1.05,
              fontWeight: FontWeight.w600,
              fontFamily: 'serif',
            ),
          ),
          SizedBox(height: 4 * scale),
          Text(
            'Pushpam samarpayami',
            style: TextStyle(
              color: const Color(0xFFD83A19),
              fontSize: 15 * scale,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
            ),
          ),
          SizedBox(height: 10 * scale),
          Text(
            'Tap the murti to offer flower petals at the lotus feet.',
            style: TextStyle(
              color: const Color(0xFF42140C),
              fontSize: 16 * scale,
              height: 1.25,
            ),
          ),
          SizedBox(height: 10 * scale),
          _ProgressBars(scale: scale, progress: 1 + (count / 6)),
          SizedBox(height: 14 * scale),
          SizedBox(
            width: double.infinity,
            height: 58 * scale,
            child: ElevatedButton.icon(
              onPressed: null,
              icon: Icon(Icons.pan_tool_alt_rounded, size: 20 * scale),
              label: Text(
                completed
                    ? 'Pushpa Arpan Complete'
                    : 'Tap the murti to offer petals · $count/6',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF760400),
                disabledBackgroundColor: const Color(0xFF760400),
                foregroundColor: Colors.white,
                disabledForegroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                textStyle: TextStyle(
                  fontSize: 14.5 * scale,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _GhantaStep extends StatelessWidget {
  const _GhantaStep({required this.controller, required this.scale});

  final VirtualPoojaController controller;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final rings = controller.ghantaRings.value;
      final completed = rings >= 3;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ring the Ghanta',
            style: TextStyle(
              color: const Color(0xFF8B0B00),
              fontSize: 24 * scale,
              height: 1.05,
              fontWeight: FontWeight.w600,
              fontFamily: 'serif',
            ),
          ),
          SizedBox(height: 4 * scale),
          Text(
            'Ghanta nadam samarpayami',
            style: TextStyle(
              color: const Color(0xFFD83A19),
              fontSize: 15 * scale,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
            ),
          ),
          SizedBox(height: 10 * scale),
          Text(
            'Pull the bell-rope thrice to invoke the divine presence.',
            style: TextStyle(
              color: const Color(0xFF42140C),
              fontSize: 16 * scale,
              height: 1.25,
            ),
          ),
          SizedBox(height: 10 * scale),
          _ProgressBars(scale: scale, progress: 2 + (rings / 3)),
          SizedBox(height: 14 * scale),
          SizedBox(
            width: double.infinity,
            height: 58 * scale,
            child: ElevatedButton.icon(
              onPressed: null,
              icon: Icon(Icons.notifications_none_rounded, size: 21 * scale),
              label: Text('Tap the ghanta to ring · $rings/3'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF760400),
                disabledBackgroundColor: const Color(0xFF760400),
                foregroundColor: Colors.white,
                disabledForegroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                textStyle: TextStyle(
                  fontSize: 14.5 * scale,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _DiyaButton extends StatefulWidget {
  const _DiyaButton({
    required this.scale,
    required this.progress,
    required this.onLit,
    required this.onHoldProgressChanged,
  });

  final double scale;
  final int progress;
  final VoidCallback onLit;
  final ValueChanged<double> onHoldProgressChanged;

  @override
  State<_DiyaButton> createState() => _DiyaButtonState();
}

class _DiyaButtonState extends State<_DiyaButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _holdController;

  @override
  void initState() {
    super.initState();
    _holdController =
        AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 1400),
          )
          ..addListener(() {
            widget.onHoldProgressChanged(_holdController.value);
          })
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              widget.onLit();
            }
          });
  }

  @override
  void didUpdateWidget(covariant _DiyaButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.progress >= 3 && _holdController.value != 1) {
      _holdController.value = 1;
      widget.onHoldProgressChanged(1);
    }
  }

  @override
  void dispose() {
    _holdController.dispose();
    super.dispose();
  }

  void _startHold() {
    if (widget.progress >= 3) return;
    _holdController.forward(from: 0);
  }

  void _endHold() {
    if (widget.progress >= 3 || _holdController.isCompleted) return;
    _holdController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;

    return GestureDetector(
      onTapDown: (_) => _startHold(),
      onTapUp: (_) => _endHold(),
      onTapCancel: _endHold,
      child: AnimatedBuilder(
        animation: _holdController,
        builder: (context, _) {
          final percent = (_holdController.value * 100).clamp(0, 100).round();
          final completed = widget.progress >= 3;
          final label = completed
              ? 'Diya Prajwalit'
              : _holdController.isAnimating || _holdController.value > 0
              ? 'Lighting... $percent%'
              : 'Press & hold to light';

          return Container(
            width: double.infinity,
            height: 58 * scale,
            decoration: BoxDecoration(
              color: const Color(0xFFC81405),
              borderRadius: BorderRadius.circular(999),
              boxShadow: completed
                  ? const [
                      BoxShadow(
                        color: Color(0xB3FFB43C),
                        blurRadius: 20,
                        spreadRadius: 1,
                      ),
                    ]
                  : const [],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: completed ? 1 : _holdController.value,
                  child: Container(color: const Color(0x33FFB43C)),
                ),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.local_fire_department_rounded,
                        color: Colors.white,
                        size: 23 * scale,
                      ),
                      SizedBox(width: 10 * scale),
                      Text(
                        label,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15 * scale,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ArchanaCompleteCard extends StatelessWidget {
  const _ArchanaCompleteCard({
    required this.scale,
    required this.deityName,
    required this.onContinue,
  });

  final double scale;
  final String deityName;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E9),
        borderRadius: BorderRadius.circular(24 * scale),
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_rounded,
            color: const Color(0xFF760400),
            size: 28 * scale,
          ),
          SizedBox(height: 8 * scale),
          Text(
            '$deityName Archana Sampanna',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF8B0B00),
              fontSize: 17 * scale,
              fontWeight: FontWeight.w500,
              fontFamily: 'serif',
            ),
          ),
          SizedBox(height: 4 * scale),
          Text(
            'Now perform pradakshina of the Nava Graha.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF42140C),
              fontSize: 13 * scale,
              height: 1.2,
            ),
          ),
          SizedBox(height: 18 * scale),
          SizedBox(
            width: double.infinity,
            height: 50 * scale,
            child: ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7F3D),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: Text(
                'Continue to Nava Graha ->',
                style: TextStyle(
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavaGrahaScreen extends StatefulWidget {
  const _NavaGrahaScreen({
    required this.scale,
    required this.progress,
    required this.onReset,
    required this.onAdvance,
    required this.onNewPooja,
  });

  final double scale;
  final int progress;
  final VoidCallback onReset;
  final VoidCallback onAdvance;
  final VoidCallback onNewPooja;

  @override
  State<_NavaGrahaScreen> createState() => _NavaGrahaScreenState();
}

class _NavaGrahaScreenState extends State<_NavaGrahaScreen>
    with TickerProviderStateMixin {
  late final AnimationController _orbitController;
  late final AnimationController _glowController;
  Timer? _progressTimer;
  bool _paused = false;

  @override
  void initState() {
    super.initState();
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
    _startProgressTimer();
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _orbitController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _NavaGrahaScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.progress >= 9 && oldWidget.progress < 9) {
      _progressTimer?.cancel();
      _orbitController.stop();
      _paused = true;
    }
  }

  void _startProgressTimer() {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted || _paused || widget.progress >= 9) {
        return;
      }
      widget.onAdvance();
    });
  }

  void _togglePause() {
    setState(() {
      _paused = !_paused;
      if (_paused) {
        _orbitController.stop();
        _progressTimer?.cancel();
      } else {
        if (widget.progress < 9) {
          _orbitController.repeat();
          _startProgressTimer();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;
    final planets = <_GrahaPlanet>[
      const _GrahaPlanet('\u2600', 'Surya', '\u0938\u0942\u0930\u094D\u092F', Color(0xFFF5A623), Color(0xFFFFC857), 0.0),
      const _GrahaPlanet('\u263E', 'Chandra', '\u091A\u0902\u0926\u094D\u0930', Color(0xFFC7D2E6), Color(0xFFE8F1FF), 1 / 9),
      const _GrahaPlanet('\u2642\uFE0E', 'Mangal', '\u092E\u0902\u0917\u0932', Color(0xFFD9534F), Color(0xFFFF7B6B), 2 / 9),
      const _GrahaPlanet('\u263F', 'Budh', '\u092C\u0941\u0927', Color(0xFF5CB85C), Color(0xFF8EE08E), 3 / 9),
      const _GrahaPlanet('\u2643', 'Guru', '\u0917\u0941\u0930\u0941', Color(0xFFF0AD4E), Color(0xFFFFD27A), 4 / 9),
      const _GrahaPlanet('\u2640\uFE0E', 'Shukra', '\u0936\u0941\u0915\u094D\u0930', Color(0xFFF8C8DC), Color(0xFFFFE0EE), 5 / 9),
      const _GrahaPlanet('\u2644', 'Shani', '\u0936\u0928\u093F', Color(0xFF3B3F4A), Color(0xFF7A7F8C), 6 / 9),
      const _GrahaPlanet('\u260A', 'Rahu', '\u0930\u093E\u0939\u0941', Color(0xFF6A4C93), Color(0xFF9B7AC5), 7 / 9),
      const _GrahaPlanet('\u260B', 'Ketu', '\u0915\u0947\u0924\u0941', Color(0xFF8B5A2B), Color(0xFFC58A55), 8 / 9),
    ];
    final activeIndex = (widget.progress.clamp(1, 9) - 1).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nava Graha Pradakshina',
          style: TextStyle(
            color: const Color(0xFF3A130F),
            fontSize: 26 * scale,
            fontWeight: FontWeight.w500,
            fontFamily: 'serif',
          ),
        ),
        SizedBox(height: 6 * scale),
        Text(
          'Stand still as the nine planets circle you clockwise · ${widget.progress.clamp(0, 9)}/9',
          style: TextStyle(
            color: const Color(0xFF1F1511),
            fontSize: 14 * scale,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 14 * scale),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(14 * scale),
          decoration: BoxDecoration(
            gradient: const RadialGradient(
              center: Alignment.center,
              radius: 0.85,
              colors: [Color(0xFF2A1810), Color(0xFF0A0512)],
              stops: [0, 0.8],
            ),
            borderRadius: BorderRadius.circular(30 * scale),
          ),
          child: AspectRatio(
            aspectRatio: 1.02,
            child: AnimatedBuilder(
              animation: _orbitController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _StarFieldPainter(),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final size = math.min(
                        constraints.maxWidth,
                        constraints.maxHeight,
                      );
                      final orbitRadius = size * 0.38;
                      final center = size / 2;
                      final activePlanet = planets[activeIndex];
                      final activeAngle =
                          ((_orbitController.value + activePlanet.orbitOffset) *
                                  math.pi *
                                  2) -
                              (math.pi / 2);

                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned.fill(
                            child: IgnorePointer(
                              child: CustomPaint(
                                painter: _OrbitRingPainter(radius: orbitRadius),
                              ),
                            ),
                          ),
                          Positioned(
                            left: center - (52 * scale),
                            top: center - (52 * scale),
                            child: _NavaGrahaCenterOrb(
                              scale: scale,
                              animation: _glowController,
                            ),
                          ),
                          Positioned.fill(
                            child: IgnorePointer(
                              child: widget.progress >= 9
                                  ? const SizedBox.shrink()
                                  : CustomPaint(
                                      painter: _ActiveGrahaBeamPainter(
                                        center: Offset(center, center),
                                        radius: orbitRadius,
                                        angle: activeAngle,
                                        planetRadius: 24 * scale,
                                        color: activePlanet.highlightColor,
                                      ),
                                    ),
                            ),
                          ),
                          Positioned.fill(
                            child: Transform.rotate(
                              angle: _orbitController.value * math.pi * 2,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  for (var index = 0; index < planets.length; index++)
                                    _buildPlanet(
                                      scale: scale,
                                      orbitRadius: orbitRadius,
                                      center: center,
                                      planet: planets[index],
                                      rotationValue: _orbitController.value,
                                      active: index == activeIndex,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
        SizedBox(height: 14 * scale),
        TextButton.icon(
          onPressed: widget.progress >= 9 ? null : _togglePause,
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFFC6A067),
            padding: EdgeInsets.symmetric(horizontal: 2 * scale),
          ),
          icon: Icon(
            _paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
            size: 18 * scale,
          ),
          label: Text(
            widget.progress >= 9
                ? 'Sequence complete'
                : _paused
                ? 'Resume rotation'
                : 'Pause rotation',
            style: TextStyle(
              fontSize: 14 * scale,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(height: 18 * scale),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  widget.onReset();
                  _orbitController.value = 0;
                  setState(() => _paused = false);
                  _orbitController.repeat();
                  _startProgressTimer();
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFE9CFA8)),
                  foregroundColor: const Color(0xFF1F1511),
                  minimumSize: Size(double.infinity, 56 * scale),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                icon: Icon(Icons.replay_rounded, size: 20 * scale),
                label: Text(
                  'Reset',
                  style: TextStyle(
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12 * scale),
            Expanded(
              child: ElevatedButton(
                onPressed: widget.onNewPooja,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE45D2F),
                  foregroundColor: const Color(0xFF150A08),
                  minimumSize: Size(double.infinity, 56 * scale),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: Text(
                  'New pooja',
                  style: TextStyle(
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlanet({
    required double scale,
    required double orbitRadius,
    required double center,
    required _GrahaPlanet planet,
    required double rotationValue,
    required bool active,
  }) {
    final angle = (planet.orbitOffset * math.pi * 2) - (math.pi / 2);
    final x = center + (math.cos(angle) * orbitRadius);
    final y = center + (math.sin(angle) * orbitRadius);
    final planetSize = 48 * scale;
    final labelAbove = math.sin(angle) > 0.2;

    return Positioned(
      left: x - (planetSize / 2),
      top: y - (planetSize / 2),
      child: Transform.rotate(
        angle: -rotationValue * math.pi * 2,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (active && labelAbove) ...[
              Text(
                planet.name,
                style: TextStyle(
                  color: const Color(0xFFD5A94B),
                  fontSize: 10 * scale,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
              Text(
                planet.devName,
                style: TextStyle(
                  color: const Color(0xCCEADDC9),
                  fontSize: 10 * scale,
                ),
              ),
              SizedBox(height: 8 * scale),
            ],
            AnimatedScale(
              scale: active ? 1.4 : 1,
              duration: const Duration(milliseconds: 500),
              child: Container(
                width: planetSize,
                height: planetSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: const Alignment(-0.3, -0.4),
                    colors: [planet.highlightColor, planet.baseColor],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: planet.highlightColor.withValues(
                        alpha: active ? 1 : 0.5,
                      ),
                      blurRadius: active ? 30 * scale : 14 * scale,
                      spreadRadius: active ? 1 : 0,
                    ),
                    if (active)
                      BoxShadow(
                        color: planet.highlightColor.withValues(alpha: 0.85),
                        blurRadius: 60 * scale,
                      ),
                  ],
                ),
                child: Center(
                  child: Text(
                    planet.symbol,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22 * scale,
                      fontWeight: FontWeight.w700,
                      shadows: const [
                        Shadow(color: Color(0x99000000), blurRadius: 2),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (active && !labelAbove) ...[
              SizedBox(height: 8 * scale),
              Text(
                planet.name,
                style: TextStyle(
                  color: const Color(0xFFD5A94B),
                  fontSize: 10 * scale,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
              Text(
                planet.devName,
                style: TextStyle(
                  color: const Color(0xCCEADDC9),
                  fontSize: 10 * scale,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GrahaPlanet {
  const _GrahaPlanet(
    this.symbol,
    this.name,
    this.devName,
    this.baseColor,
    this.highlightColor,
    this.orbitOffset,
  );

  final String symbol;
  final String name;
  final String devName;
  final Color baseColor;
  final Color highlightColor;
  final double orbitOffset;
}

class _OrbitRingPainter extends CustomPainter {
  const _OrbitRingPainter({required this.radius});

  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final dashedPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0x40E8C16C)
      ..strokeWidth = 0.6;
    final solidPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0x66E8C16C)
      ..strokeWidth = 0.4;

    const dash = 2.0;
    const gap = 4.0;
    final circumference = 2 * math.pi * radius;
    final count = (circumference / (dash + gap)).floor();
    for (var i = 0; i < count; i++) {
      final startAngle = (i / count) * math.pi * 2;
      final sweep = dash / radius;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep,
        false,
        dashedPaint,
      );
    }
    canvas.drawCircle(center, radius, solidPaint);
  }

  @override
  bool shouldRepaint(covariant _OrbitRingPainter oldDelegate) {
    return oldDelegate.radius != radius;
  }
}

class _ActiveGrahaBeamPainter extends CustomPainter {
  const _ActiveGrahaBeamPainter({
    required this.center,
    required this.radius,
    required this.angle,
    required this.planetRadius,
    required this.color,
  });

  final Offset center;
  final double radius;
  final double angle;
  final double planetRadius;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final start = center;
    final end = Offset(
      center.dx + (math.cos(angle) * (radius - (planetRadius * 0.52))),
      center.dy + (math.sin(angle) * (radius - (planetRadius * 0.52))),
    );
    final beamGradient = ui.Gradient.linear(
      start,
      end,
      [
        const Color(0xCCFFD278),
        color.withValues(alpha: 0.96),
      ],
      const [0, 1],
    );
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8
      ..shader = beamGradient
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    final corePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2
      ..shader = beamGradient;

    canvas.drawLine(start, end, glowPaint);
    canvas.drawLine(start, end, corePaint);
  }

  @override
  bool shouldRepaint(covariant _ActiveGrahaBeamPainter oldDelegate) {
    return oldDelegate.center != center ||
        oldDelegate.radius != radius ||
        oldDelegate.angle != angle ||
        oldDelegate.planetRadius != planetRadius ||
        oldDelegate.color != color;
  }
}

class _NavaGrahaCenterOrb extends StatelessWidget {
  const _NavaGrahaCenterOrb({
    required this.scale,
    required this.animation,
  });

  final double scale;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value;
        final glowBlur = 32 + (10 * t);
        final glowOpacity = 0.38 + (0.18 * t);
        final omGlow = 8 + (4 * t);

        return Container(
          width: 104 * scale,
          height: 104 * scale,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Color.fromRGBO(255, 210, 120, 0.55 + (0.06 * t)),
                Color.fromRGBO(196, 62, 42, 0.2 + (0.06 * t)),
                Colors.transparent,
              ],
              stops: const [0, 0.7, 1],
            ),
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(255, 180, 80, glowOpacity),
                blurRadius: glowBlur * scale,
                spreadRadius: 1.5 * scale,
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 40 * scale,
              height: 40 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0x80D8A33A),
                  width: 1.2,
                ),
              ),
              child: Center(
                child: Text(
                  '\u0950',
                  style: TextStyle(
                    color: const Color(0xFFD8A33A),
                    fontSize: 30 * scale,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        color: Color.fromRGBO(188, 123, 22, 0.56 + (0.18 * t)),
                        blurRadius: omGlow * scale,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StarFieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stars = [
      const Offset(0.08, 0.14),
      const Offset(0.2, 0.18),
      const Offset(0.35, 0.28),
      const Offset(0.72, 0.12),
      const Offset(0.86, 0.44),
      const Offset(0.18, 0.76),
      const Offset(0.58, 0.82),
      const Offset(0.9, 0.2),
      const Offset(0.62, 0.52),
      const Offset(0.45, 0.15),
      const Offset(0.78, 0.62),
    ];
    final paint = Paint()..color = const Color(0xCCFFFFFF);
    for (final star in stars) {
      canvas.drawCircle(
        Offset(size.width * star.dx, size.height * star.dy),
        star.dx > 0.5 ? 1.1 : 0.8,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TempleBell extends StatefulWidget {
  const _TempleBell({
    required this.scale,
    required this.enabled,
    required this.onTap,
  });

  final double scale;
  final bool enabled;
  final VoidCallback onTap;

  @override
  State<_TempleBell> createState() => _TempleBellState();
}

class _TempleBellState extends State<_TempleBell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final AudioPlayer _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _ringBell() async {
    if (!widget.enabled) {
      return;
    }
    _controller.forward(from: 0);
    widget.onTap();

    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/bell.mp3'));
    } catch (_) {
      // Keep the visual response even if the audio asset cannot play.
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _ringBell,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: widget.enabled ? 1 : 0.8,
        child: SizedBox(
          width: 86 * scale,
          height: 86 * scale,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final swing =
                  math.sin(_controller.value * math.pi * 5) *
                  (1 - _controller.value) *
                  0.42;

              return Transform.rotate(
                angle: swing,
                alignment: Alignment.topCenter,
                child: child,
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 2 * scale,
                  height: 8 * scale,
                  color: const Color(0xFFE6B655),
                ),
                Container(
                  width: 34 * scale,
                  height: 34 * scale,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18 * scale),
                      topRight: Radius.circular(18 * scale),
                      bottomLeft: Radius.circular(6 * scale),
                      bottomRight: Radius.circular(6 * scale),
                    ),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFE6B655),
                        Color(0xFFA67423),
                        Color(0xFF6B4513),
                      ],
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x66000000),
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 12 * scale,
                  height: 7 * scale,
                  decoration: BoxDecoration(
                    color: const Color(0xFF760400),
                    borderRadius: BorderRadius.circular(999),
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

class _MurtiBellWave extends StatefulWidget {
  const _MurtiBellWave({
    required this.scale,
    required this.event,
  });

  final double scale;
  final int event;

  @override
  State<_MurtiBellWave> createState() => _MurtiBellWaveState();
}

class _MurtiBellWaveState extends State<_MurtiBellWave>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1280),
    );
    if (widget.event > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _controller.forward(from: 0);
      });
    }
  }

  @override
  void didUpdateWidget(covariant _MurtiBellWave oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.event > oldWidget.event) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return _MurtiBellWaveRing(
            scale: widget.scale,
            progress: _controller.value,
            delay: 0,
          );
        },
      ),
    );
  }
}

class _MurtiBellWaveRing extends StatelessWidget {
  const _MurtiBellWaveRing({
    required this.scale,
    required this.progress,
    required this.delay,
  });

  final double scale;
  final double progress;
  final double delay;

  @override
  Widget build(BuildContext context) {
    final localProgress = ((progress - delay) / (1 - delay))
        .clamp(0.0, 1.0)
        .toDouble();
    if (localProgress <= 0) {
      return const SizedBox.shrink();
    }

    final eased = Curves.easeOutCubic.transform(localProgress);
    final opacity = (1 - math.pow(localProgress, 1.15)).clamp(0.0, 1.0).toDouble();
    final size = (36 + (344 * eased)) * scale;

    return Opacity(
      opacity: opacity,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Color.fromRGBO(22, 10, 8, 0.42 * opacity),
            width: (1.4 + (1.1 * opacity)) * scale,
          ),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.18 * opacity),
              blurRadius: 28 * scale,
              spreadRadius: 2 * scale,
            ),
          ],
        ),
      ),
    );
  }
}
