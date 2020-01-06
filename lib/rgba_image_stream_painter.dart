import 'dart:async';
import 'dart:ui' as ui;

import 'package:MKDG/image_filters/image_filter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:image/image.dart' as imglib;

class _Painter extends ChangeNotifier implements CustomPainter {
  final Function onFirstFrameDrawn;
  final Stream<imglib.Image> imageStream;
  final ImageFilter filter;

  bool onFirstFrameDrawnCalled = false;

  ui.Image _cachedImage;
  bool _paintedCachedImage = true;

  _Painter(this.imageStream, this.filter, {this.onFirstFrameDrawn}) {
    imageStream.listen((imglib.Image image) {
      if (_paintedCachedImage) {
//        Stopwatch stopwatch = new Stopwatch()..start();
        _decodeImage(filter.compute(image)).then((ui.Image decodedImage) {
//          print('conversion executed in ${stopwatch.elapsed.inMilliseconds}ms');
          _cachedImage = decodedImage;
          _paintedCachedImage = false;
          notifyListeners();
        });
      }
    });
  }

  Future<ui.Image> _decodeImage(imglib.Image image) async {
    final Completer<ui.Image> completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      image.getBytes(format: imglib.Format.rgba),
      image.width,
      image.height,
      ui.PixelFormat.rgba8888,
      (ui.Image decodedImage) {
        completer.complete(decodedImage);
      },
    );
    return await completer.future;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (_cachedImage == null) {
      return;
    }
//    Stopwatch stopwatch = new Stopwatch()..start();

    paintImage(
      canvas: canvas,
      rect: Rect.fromLTWH(0, 0, size.width, size.height),
      image: _cachedImage,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.none,
    );
//    print('painting done in ${stopwatch.elapsed.inMilliseconds}ms');

    _paintedCachedImage = true;

    if (!onFirstFrameDrawnCalled && onFirstFrameDrawn != null) {
      onFirstFrameDrawn();
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => !_paintedCachedImage;

  @override
  bool hitTest(ui.Offset position) => null;

  @override
  get semanticsBuilder => null;

  @override
  bool shouldRebuildSemantics(CustomPainter oldDelegate) =>
      !_paintedCachedImage;
}

class RGBAImageStreamPainter extends StatefulWidget {
  final Stream<imglib.Image> imageStream;
  final Function onFirstFrameDrawn;
  final ImageFilter filter;

  RGBAImageStreamPainter(this.imageStream, this.filter,
      {this.onFirstFrameDrawn});

  @override
  _RGBAImageStreamPainterState createState() => _RGBAImageStreamPainterState();
}

class _RGBAImageStreamPainterState extends State<RGBAImageStreamPainter> {
  CustomPainter _painter;

  @override
  void initState() {
    super.initState();
    _painter = _Painter(
      widget.imageStream,
      widget.filter,
      onFirstFrameDrawn: widget.onFirstFrameDrawn,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _painter,
      size: MediaQuery.of(context).size,
    );
  }
}
