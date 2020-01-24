import 'package:image/image.dart';

abstract class ImageFilter {
  static const int mask = 0x000000FF;
  static const int alpha = 0xFF000000;

  String get name;

  Image compute(Image image);
}
