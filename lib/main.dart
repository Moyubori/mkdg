import 'package:MKDG/camera_overlay.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock/wakelock.dart';

void main() {
  Wakelock.enable();
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
  CameraController controller;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    availableCameras().then((List<CameraDescription> cameras) {
      controller = CameraController(
          cameras.firstWhere(
            (CameraDescription cameraDescription) =>
                cameraDescription.lensDirection == CameraLensDirection.back,
            orElse: () => cameras.last, /**/
          ),
          ResolutionPreset.max);
      controller.initialize().then((_) {
        controller.startImageStream((CameraImage image) {
          print(image.format.toString());
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
          if (controller != null) CameraPreview(controller),
          SafeArea(
            child: CameraOverlay(),
          ),
        ],
      )),
    );
  }
}
