import 'dart:async';
import 'dart:ui' as ui;

import 'package:MKDG/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:image/image.dart' as imglib;

class _Painter extends ChangeNotifier implements CustomPainter {
  final Function onFirstFrameDrawn;
  final Stream<imglib.Image> imageStream;
  final ImageFilterProvider filterProvider;
  final Function onFilterComputed;

  bool onFirstFrameDrawnCalled = false;

  ui.Image _cachedImage;
  bool _paintedCachedImage = true;

  _Painter(
    this.imageStream,
    this.filterProvider, {
    this.onFirstFrameDrawn,
    this.onFilterComputed,
  }) {
    imageStream.listen((imglib.Image image) {
      if (_paintedCachedImage) {
        final imglib.Image computedImage = filterProvider.filter.compute(image);
        (onFilterComputed ?? () {})(computedImage);
        _decodeImage(computedImage).then((ui.Image decodedImage) {
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
    paintImage(
      canvas: canvas,
      rect: Rect.fromLTWH(0, 0, size.width, size.height),
      image: _cachedImage,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.none,
    );
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
  final ImageFilterProvider filterProvider;
  final Function onFilterComputed;

  RGBAImageStreamPainter(this.imageStream, this.filterProvider,
      {this.onFirstFrameDrawn, this.onFilterComputed});

  @override
  _RGBAImageStreamPainterState createState() => _RGBAImageStreamPainterState();
}

class _RGBAImageStreamPainterState extends State<RGBAImageStreamPainter> {
  _Painter _painter;

  @override
  void initState() {
    super.initState();
    _painter = _Painter(
      widget.imageStream,
      widget.filterProvider,
      onFirstFrameDrawn: widget.onFirstFrameDrawn,
      onFilterComputed: widget.onFilterComputed,
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
