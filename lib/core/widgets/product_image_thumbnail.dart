import 'package:flutter/material.dart';

class ProductImageThumbnail extends StatelessWidget {
  final dynamic imageData;
  final double size;
  final BorderRadius borderRadius;

  const ProductImageThumbnail({
    super.key,
    this.imageData,
    this.size = 48,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: borderRadius,
      ),
      child: imageData != null
          ? ClipRRect(
              borderRadius: borderRadius,
              child: Image.network(
                imageData.toString(),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.image_outlined,
                  size: size * 0.5,
                  color: Colors.grey,
                ),
              ),
            )
          : Icon(
              Icons.image_outlined,
              size: size * 0.5,
              color: Colors.grey,
            ),
    );
  }
}
