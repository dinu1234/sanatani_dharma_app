import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppSvgAsset extends StatelessWidget {
  AppSvgAsset({
    super.key,
    required this.assetName,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  }) : _svgFuture = _pendingLoads.putIfAbsent(
         assetName,
         () => rootBundle.loadString(assetName).then(_inlineSvgStyles),
       );

  final String assetName;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Future<String> _svgFuture;

  static final Map<String, String> _svgCache = {};
  static final Map<String, Future<String>> _pendingLoads = {};

  static String _inlineSvgStyles(String svg) {
    final styleBlockRegex = RegExp(
      r'<style[^>]*>([\s\S]*?)</style>',
      caseSensitive: false,
    );
    final classRuleRegex = RegExp(r'\.(?<name>[\w-]+)\s*\{(?<body>[^}]*)\}');
    final classStyles = <String, String>{};

    for (final styleMatch in styleBlockRegex.allMatches(svg)) {
      final css = styleMatch.group(1) ?? '';
      for (final ruleMatch in classRuleRegex.allMatches(css)) {
        final name = ruleMatch.namedGroup('name');
        final body = ruleMatch.namedGroup('body')?.trim();
        if (name == null || body == null || body.isEmpty) {
          continue;
        }
        classStyles[name] = body.endsWith(';') ? body : '$body;';
      }
    }

    if (classStyles.isEmpty) {
      return svg;
    }

    var inlined = svg.replaceAll(styleBlockRegex, '');
    final classAttrRegex = RegExp(r'class="([^"]+)"');

    inlined = inlined.replaceAllMapped(classAttrRegex, (match) {
      final classNames = match.group(1)?.split(RegExp(r'\s+')) ?? const [];
      final mergedStyle = classNames
          .map((name) => classStyles[name])
          .whereType<String>()
          .join(' ');

      if (mergedStyle.isEmpty) {
        return '';
      }

      return 'style="$mergedStyle"';
    });

    return inlined;
  }

  @override
  Widget build(BuildContext context) {
    final cachedSvg = _svgCache[assetName];
    if (cachedSvg != null) {
      return SvgPicture.string(
        cachedSvg,
        width: width,
        height: height,
        fit: fit,
      );
    }

    return FutureBuilder<String>(
      future: _svgFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox(width: width, height: height);
        }

        final svg = snapshot.data!;
        _svgCache[assetName] = svg;

        return SvgPicture.string(
          svg,
          width: width,
          height: height,
          fit: fit,
        );
      },
    );
  }
}
