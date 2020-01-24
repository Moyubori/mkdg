import 'dart:async';

import 'package:MKDG/camera_overlay.dart';
import 'package:MKDG/image_converter.dart';
import 'package:MKDG/image_filters/canny_filter.dart';
import 'package:MKDG/image_filters/image_filter.dart';
import 'package:MKDG/image_filters/matrix_filter.dart';
import 'package:MKDG/image_filters/no_filter.dart';
import 'package:MKDG/image_filters/roberts_filter.dart';
import 'package:MKDG/rgba_image_stream_painter.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as imglib;
import 'package:wakelock/wakelock.dart';

final List<ImageFilter> filters = [
  NoFilter(),
  MatrixFilter.sobel(),
  MatrixFilter.prewitt(),
  MatrixFilter.log(),
  RobertsFilter(),
  CannyFilter(),
];

void main() {
  runApp(App());
}

class ImageFilterProvider {
  ImageFilter filter;

  ImageFilterProvider(this.filter);
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(title: 'MKDG'),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CameraController _controller;
  int currentOverlayIndex = 0;
  bool firstCanvasFrameDrawn = false;
  bool controllerInitialized = false;

  final ImageFilterProvider filterProvider = ImageFilterProvider(filters[0]);

  List<int> capturedImage;
  StreamController<imglib.Image> imageStreamController =
      StreamController<imglib.Image>.broadcast();

  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    availableCameras().then((List<CameraDescription> cameras) {
      _controller = CameraController(
        cameras.firstWhere(
          (CameraDescription cameraDescription) =>
              cameraDescription.lensDirection == CameraLensDirection.back,
          orElse: () => cameras.last,
        ),
        ResolutionPreset.low,
        enableAudio: false,
      );
      _controller.initialize().then((_) {
        controllerInitialized = true;
        bool finishedPreviousFrame = true;
        _controller.startImageStream((CameraImage image) {
          if (finishedPreviousFrame) {
            finishedPreviousFrame = false;
            compute(convertImageToRGBA, image).then((convertedImage) {
              imageStreamController.add(convertedImage);
              finishedPreviousFrame = true;
            });
          }
        });
        setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Stack(
        children: [
          if (_controller != null &&
              controllerInitialized &&
              (currentOverlayIndex == 0 || !firstCanvasFrameDrawn))
            _buildCameraPreview(context),
          if (currentOverlayIndex > 0)
            RGBAImageStreamPainter(
              imageStreamController.stream,
              filterProvider,
              onFirstFrameDrawn: () {
                firstCanvasFrameDrawn = true;
              },
            ),
          SafeArea(
            child: CameraOverlay(
              filters: filters,
              onPageChanged: (int index) {
                currentOverlayIndex = index;
                filterProvider.filter = filters[currentOverlayIndex];
                if (index == 0) {
                  firstCanvasFrameDrawn = false;
                }
                setState(() {});
              },
            ),
          ),
        ],
      )),
    );
  }

  Widget _buildCameraPreview(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return ClipRect(
      child: Container(
        child: Transform.scale(
          scale: _controller.value.aspectRatio / size.aspectRatio,
          child: Center(
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: CameraPreview(_controller),
            ),
          ),
        ),
      ),
    );
  }
}
