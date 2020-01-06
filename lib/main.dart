import 'dart:async';

import 'package:MKDG/camera_overlay.dart';
import 'package:MKDG/image_converter.dart';
import 'package:MKDG/rgba_image_stream_painter.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as imglib;
import 'package:wakelock/wakelock.dart';

void main() {
  runApp(App());
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
        bool finishedPreviousFrame = true;
        _controller.startImageStream((CameraImage image) {
          if (finishedPreviousFrame) {
            finishedPreviousFrame = false;
//            compute(convertImage, image).then((convertedImage) {
//              capturedImage = convertedImage;
//              finishedPreviousFrame = true;
////              setState(() {});
//            });
            compute(convertImageToRGBA, image).then((convertedImage) {
              imageStreamController.add(convertedImage);
              finishedPreviousFrame = true;
//              setState(() {});
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
//          if (_controller != null) _buildCameraPreview(context),
          RGBAImageStreamPainter(
            imageStreamController.stream.asBroadcastStream(),
          ),
          SafeArea(
            child: CameraOverlay(),
          ),
//          if (capturedImage != null)
//            SizedBox(
//              width: 500,
//              height: 500,
//              child: Transform.rotate(
//                angle: pi / 2,
//                child: Image.memory(capturedImage),
//              ),
//            ),
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
