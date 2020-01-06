import 'package:image/image.dart';

abstract class ImageFilter {
  String get name;

  Image compute(Image image);
}
