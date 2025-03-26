import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppIcon extends StatelessWidget {
  final String source;
  final BoxFit fit;
  final Color? color;
  final double size;
  final void Function()? onTap;

  const AppIcon({
    super.key,
    required this.source,
    this.fit = BoxFit.cover,
    this.color,
    this.size = 24,
    this.onTap,
  });

  bool get _isSvg => source.toLowerCase().endsWith('.svg');

  @override
  Widget build(BuildContext context) {
    assert(
      _isSvg,
      'Implemented only for svg',
    );

    return InkWell(
      onTap: onTap,
      child: SvgPicture.asset(
        source,
        package: 'core_ui',
        colorFilter: color != null
            ? ColorFilter.mode(
                color!,
                BlendMode.srcIn,
              )
            : null,
        fit: fit,
        height: size,
        width: size,
      ),
    );
  }
}
