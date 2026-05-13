import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../shimmers/shimmer.dart';

class YCircularImage extends StatelessWidget {
  const YCircularImage({
    super.key,
    this.width = 56,
    this.height = 56,
    this.overlayColor,
    this.backgroundColor,
    required this.image,
    this.fit = BoxFit.cover,
    this.padding = YSizes.sm,
    this.isNetworkImage = false,
  });

  final BoxFit? fit;
  final String image;
  final bool isNetworkImage;
  final Color? overlayColor;
  final Color? backgroundColor;
  final double width, height, padding;

  @override
  Widget build(BuildContext context) {
    // Auto-detect network images by checking if URL starts with http:// or https://
    final fallbackImage = image.isEmpty ? YImage.iconStore : image;
    final bool isNetwork =
        isNetworkImage ||
        fallbackImage.startsWith('http://') ||
        fallbackImage.startsWith('https://');

    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        // If image background color is null then switch it to light and dark mode color design.
        color:
            backgroundColor ??
            (YHelperFunctions.isDarkMode(context)
                ? YColors.black
                : YColors.white),
        borderRadius: BorderRadius.circular(100),
      ),
      // BoxDecoration
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: Center(
          child: isNetwork
              ? CachedNetworkImage(
                  fit: fit,
                  color: overlayColor,
                  imageUrl: fallbackImage,
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      const YShimmerEffect(width: 55, height: 55),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                )
              : Image(
                  fit: fit,
                  image: AssetImage(fallbackImage),
                  color: overlayColor,
                ),
        ),
      ),
    );
  }
}
