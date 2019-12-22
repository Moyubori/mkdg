import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:mkdg/camera_overlay.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
//      title: 'MKDG',
//      theme: ThemeData(
//        primarySwatch: Colors.blue,
//      ),
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
    availableCameras().then((List<CameraDescription> cameras) {
      controller = CameraController(cameras.last, ResolutionPreset.ultraHigh);
      controller.initialize().then((_) {
        setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Stack(
            children: [
              if(controller != null && controller.value.isInitialized) CameraPreview(controller),
              CameraOverlay(),
            ],
          )
        ),
      ),
    );
  }

}
