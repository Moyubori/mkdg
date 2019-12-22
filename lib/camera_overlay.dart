import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CameraOverlay extends StatefulWidget {
  @override
  _CameraOverlayState createState() => _CameraOverlayState();
}

class _CameraOverlayState extends State<CameraOverlay> {
  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
        size: MediaQuery.of(context).size,
        child: Stack(children: [
          PageView.builder(
            itemBuilder: (BuildContext context, int index) {
              return Placeholder();
            },
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: <Widget>[],
                ),
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      child: IconButton(
                        color: Colors.white,
                        icon: Icon(Icons.photo),
                        onPressed: () {
                          print('gallery button pressed');
                        },
                      ),
                    ),
                    Expanded(
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(maxHeight: 100, minHeight: 100),
                        child: RaisedButton(
                          shape: CircleBorder(),
                          color: Colors.white,
                          onPressed: () {},
                        ),
                      ),
                    ),
                    Flexible(
                      child: Opacity(
                        opacity: 0,
                        child: IgnorePointer(
                          child: IconButton(
                            icon: Icon(Icons.photo),
                            onPressed: () {},
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ]));
  }
}
