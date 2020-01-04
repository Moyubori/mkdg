import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class CameraOverlay extends StatefulWidget {
  @override
  _CameraOverlayState createState() => _CameraOverlayState();
}

class _CameraOverlayState extends State<CameraOverlay> {
  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: MediaQuery.of(context).size,
      child: Stack(
        children: [
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
              SizedBox(
                height: 30,
                child: PageView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    return Center(
                      child: Text(
                        '$index',
                        style: GoogleFonts.robotoMono(
                          textStyle: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0, top: 2.0),
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
        ],
      ),
    );
  }
}
