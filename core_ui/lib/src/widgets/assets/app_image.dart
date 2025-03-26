import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppImage extends StatelessWidget {
  final String source;
  final BoxFit fit;
  final Color? color;
  final double? width;
  final double? height;
  final void Function()? onTap;

  const AppImage({
    super.key,
    required this.source,
    this.fit = BoxFit.cover,
    this.color,
    this.width,
    this.height,
    this.onTap,
  });

  bool get _isNetwork => source.toLowerCase().startsWith('http');

  bool get _isSvg => source.toLowerCase().endsWith('.svg');

  ImageProvider get _imageProvider {
    return _isNetwork ? NetworkImage(source) : AssetImage(source) as ImageProvider;
  }

  BytesLoader get _svgLoader {
    return _isNetwork ? SvgNetworkLoader(source) : SvgAssetLoader(source);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: _isSvg
          ? SvgPicture(
              _svgLoader,
              fit: fit,
              colorFilter: color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
              width: width,
              height: height,
              placeholderBuilder: _placeholderBuilder,
              errorBuilder: _errorBuilder,
            )
          : Image(
              image: _imageProvider,
              fit: fit,
              color: color,
              width: width,
              height: height,
              loadingBuilder: _loadingBuilder,
              errorBuilder: _errorBuilder,
            ),
    );
  }

  static Widget _placeholderBuilder(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }

  static Widget _errorBuilder(BuildContext context, Object error, StackTrace? stackTrace) {
    return const Center(
      child: Icon(Icons.broken_image),
    );
  }

  static Widget _loadingBuilder(
    BuildContext context,
    Widget child,
    ImageChunkEvent? loadingProgress,
  ) {
    if (loadingProgress != null) {
      final int current = loadingProgress.cumulativeBytesLoaded;
      final int total = loadingProgress.expectedTotalBytes ?? 1;

      return Center(
        child: CircularProgressIndicator(value: current / total),
      );
    }

    return child;
  }
}
