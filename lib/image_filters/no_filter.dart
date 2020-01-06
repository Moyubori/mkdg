import 'package:MKDG/image_filters/image_filter.dart';
import 'package:image/image.dart';

class NoFilter implements ImageFilter {
  @override
  Image compute(Image image) => image;

  @override
  String get name => 'No filter';
}
