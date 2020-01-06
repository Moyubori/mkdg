import 'package:MKDG/image_filters/image_filter.dart';
import 'package:image/image.dart';

class CannyFilter implements ImageFilter {
  @override
  Image compute(Image image) {
    // TODO: implement compute
    return image;
  }

  @override
  String get name => 'Canny';
}
