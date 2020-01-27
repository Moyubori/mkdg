import 'package:MKDG/image_filters/image_filter.dart';
import 'package:flutter/widgets.dart';
import 'package:image/image.dart' as imglib;

class NoFilter implements ImageFilter {
  @override
  imglib.Image compute(imglib.Image image) => image;

  @override
  String get name => 'No filter';

  @override
  Widget buildControls(BuildContext context, Function setState) {
    return Container();
  }
}
