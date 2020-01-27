import 'dart:core';

import 'package:MKDG/image_filters/image_filter.dart';
import 'package:MKDG/image_filters/matrix_filter.dart';
import 'package:extended_math/extended_math.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as imglib;

//Apply Gaussian filter to smooth the image in order to remove the noise
//Find the intensity gradients of the image
//Apply non-maximum suppression to get rid of spurious response to edge detection
//Apply double threshold to determine potential edges
//Track edge by hysteresis: Finalize the detection of edges by suppressing all the other edges that are weak and not connected to strong edges.

class CannyFilter implements ImageFilter {
  final MatrixFilter verticalSobel = MatrixFilter.sobel()..vertical = true;
  final MatrixFilter horizontalSobel = MatrixFilter.sobel();

  int low = 12;
  int high = 40;

  @override
  imglib.Image compute(imglib.Image image) {
    imglib.grayscale(image);
    imglib.gaussianBlur(image, 3);

    final imglib.Image verticalGradient =
        verticalSobel.compute(imglib.Image.from(image));
    final imglib.Image horizontalGradient =
        horizontalSobel.compute(imglib.Image.from(image));
    final List<num> gradientMagnitude = [];
    final List<num> thetas = [];
    num gradientMax = 0;
    for (int i = 0; i < image.length; i++) {
      final num verticalGradientVal = verticalGradient[i] & ImageFilter.mask;
      final num horizontalGradientVal =
          horizontalGradient[i] & ImageFilter.mask;
      gradientMagnitude.add(hypot(verticalGradientVal, horizontalGradientVal));
      thetas.add(atan2(verticalGradientVal, horizontalGradientVal));
      if (gradientMagnitude.last > gradientMax) {
        gradientMax = gradientMagnitude.last;
      }
    }
    for (int i = 0; i < image.length; i++) {
      gradientMagnitude[i] = gradientMagnitude[i] * 255 ~/ gradientMax;
      final num angle = thetas[i] * 180 / pi;
      thetas[i] = angle >= 0 ? angle : angle + 180;
    }

    final int weak = 50;

    _nonMaxSuppressionAndThreshold(
      image,
      gradientMagnitude,
      thetas,
      low,
      high,
      weak,
    );
    _hysteresis(image, weak);

    return image;
  }

  imglib.Image _nonMaxSuppressionAndThreshold(imglib.Image image,
      List<num> input, List<num> angles, int low, int high, int weak) {
    for (int x = 1; x < image.width - 1; x++) {
      for (int y = 1; y < image.height - 1; y++) {
        num q = 255;
        num r = 255;
        final num angle = angles[x + image.width * y];
        if (angle < 22.5 || (157.5 <= angle && angle < 180)) {
          q = input[x + image.width * (y + 1)];
          r = input[x + image.width * (y - 1)];
        } else if (22.5 <= angle && angle < 67.5) {
          q = input[x + 1 + image.width * (y - 1)];
          r = input[x - 1 + image.width * (y + 1)];
        } else if (67.5 <= angle && angle < 112.5) {
          q = input[x + 1 + image.width * y];
          r = input[x - 1 + image.width * y];
        } else if (112.5 <= angle && angle < 157.5) {
          q = input[x - 1 + image.width * (y - 1)];
          r = input[x + 1 + image.width * (y + 1)];
        }

        if (input[x + image.width * y] >= q &&
            input[x + image.width * y] >= r) {
          final num color = input[x + image.width * y];
          final int outputColor = color >= high ? 255 : color < low ? 0 : weak;
          image.setPixelRgba(x, y, outputColor, outputColor, outputColor);
        } else {
          image.setPixelRgba(x, y, 0, 0, 0);
        }
      }
    }
    return image;
  }

  imglib.Image _hysteresis(imglib.Image image, int weak) {
    final Function checkNeighbors = (imglib.Image _image, int x, int y) =>
        _image.getPixel(x, y + 1) == 0xFFFFFFFF ||
        _image.getPixel(x, y - 1) == 0xFFFFFFFF ||
        _image.getPixel(x + 1, y + 1) == 0xFFFFFFFF ||
        _image.getPixel(x + 1, y - 1) == 0xFFFFFFFF ||
        _image.getPixel(x - 1, y + 1) == 0xFFFFFFFF ||
        _image.getPixel(x - 1, y - 1) == 0xFFFFFFFF ||
        _image.getPixel(x + 1, y) == 0xFFFFFFFF ||
        _image.getPixel(x - 1, y) == 0xFFFFFFFF;
    final imglib.Image topToBottomCopy = imglib.Image.from(image);
    final imglib.Image bottomToTopCopy = imglib.Image.from(image);
    final imglib.Image rightToLeftCopy = imglib.Image.from(image);
    final imglib.Image leftToRightCopy = imglib.Image.from(image);
    final Function performHysteresis = (imglib.Image copy, int startingX,
        int startingY, Function xCondition, Function yCondition, int dx, int dy,
        {bool isLastRun = false}) {
      for (int x = startingX; xCondition(x); x += dx) {
        for (int y = startingY; yCondition(y); y += dy) {
          if (_rgbaToGrayscaleColor(image, x, y) == weak) {
            if (checkNeighbors(copy, x, y)) {
              copy.setPixel(x, y, 0xFFFFFFFF);
              image.setPixel(x, y, 0xFFFFFFFF);
            } else {
              copy.setPixel(x, y, 0xFF000000);
              if (isLastRun) {
                image.setPixel(x, y, 0xFF000000);
              }
            }
          }
        }
      }
    };
    performHysteresis(topToBottomCopy, 0, 0, (x) => x < image.width,
        (y) => y < image.height, 1, 1);
    performHysteresis(bottomToTopCopy, image.width - 1, image.height - 1,
        (x) => x >= 0, (y) => y >= 0, -1, -1);
    performHysteresis(rightToLeftCopy, 0, image.height - 1,
        (x) => x < image.width, (y) => y >= 0, 1, -1);
    performHysteresis(leftToRightCopy, image.width - 1, 0, (x) => x >= 0,
        (y) => y < image.height, -1, 1,
        isLastRun: true);
    return image;
  }

  int _rgbaToGrayscaleColor(imglib.Image image, int x, int y) =>
      image.getPixel(x, y) & ImageFilter.mask;

  @override
  String get name => 'Canny';

  @override
  Widget buildControls(BuildContext context, Function setState) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      child: RangeSlider(
        values: RangeValues(low.toDouble(), high.toDouble()),
        min: 0,
        max: 255,
        divisions: 255,
        onChanged: (RangeValues values) {
          low = values.start.round();
          high = values.end.round();
          print(values);
          setState(() {});
        },
      ),
    );
  }
}
