import 'dart:core';

import 'package:MKDG/image_filters/image_filter.dart';
import 'package:image/image.dart';

class RobertsFilter implements ImageFilter {
  static const List<List<num>> _matrices = const [
    const [1, 0, 0, 0, -1, 0, 0, 0, 0, 0],
    const [0, 1, 0, -1, 0, 0, 0, 0, 0, 0],
  ];

  @override
  Image compute(Image image) {
    grayscale(image);
    final Image copy = Image.from(image);
    convolution(image, _matrices[0]);
    convolution(copy, _matrices[1]);
    for (int i = 0; i < image.length; i++) {
      final int pixel1 = image[i] & ImageFilter.mask;
      final int pixel2 = copy[i] & ImageFilter.mask;
      final int val = pixel1.abs() + pixel2.abs();
      image[i] = ImageFilter.alpha + (val << 16) + (val << 8) + val;
    }
    return image;
  }

  @override
  String get name => 'Roberts';
}
