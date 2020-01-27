import 'package:flutter/cupertino.dart';
import 'package:image/image.dart' as imglib;

abstract class ImageFilter {
  static const int mask = 0x000000FF;
  static const int alpha = 0xFF000000;

  String get name;

  imglib.Image compute(imglib.Image image);

  Widget buildControls(BuildContext context, Function setState);
}
