import 'package:MKDG/image_filters/image_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class CameraOverlay extends StatefulWidget {
  final List<ImageFilter> filters;

  final Function(int) onPageChanged;
  final Function onShutterButtonPressed;

  const CameraOverlay({
    Key key,
    @required this.filters,
    this.onPageChanged,
    this.onShutterButtonPressed,
  }) : super(key: key);

  @override
  _CameraOverlayState createState() => _CameraOverlayState();
}

class _CameraOverlayState extends State<CameraOverlay> {
  final PageController backgroundPageController = PageController();
  final PageController labelPageController = PageController();

  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    backgroundPageController.addListener(() {
      labelPageController.jumpTo(backgroundPageController.offset);
      currentPage = backgroundPageController.page.round();
      setState(() {});
    });
  }

  // TODO kontrolki parametrów filtrów

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: MediaQuery.of(context).size,
      child: Stack(
        children: [
          PageView.builder(
            controller: backgroundPageController,
            onPageChanged: (int page) {
              (widget.onPageChanged ?? (_) {})(page);
            },
            itemCount: widget.filters.length,
            itemBuilder: (BuildContext context, int index) {
              return Container();
            },
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: <Widget>[
                    widget.filters[currentPage]
                        .buildControls(context, setState),
                  ],
                ),
              ),
              Spacer(),
              SizedBox(
                height: 30,
                child: PageView.builder(
                  controller: labelPageController,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: widget.filters.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Center(
                      child: Text(
                        widget.filters[index].name,
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
                    Expanded(
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(maxHeight: 100, minHeight: 100),
                        child: RaisedButton(
                          shape: CircleBorder(),
                          color: Colors.white,
                          onPressed: widget.onShutterButtonPressed,
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
