// imgLib -> Image package from https://pub.dartlang.org/packages/image
import 'package:camera/camera.dart';
import 'package:image/image.dart' as imglib;

Future<List<int>> convertImage(CameraImage image) async {
//  Stopwatch stopwatch = new Stopwatch()..start();
  try {
    imglib.Image img;
    if (image.format.group == ImageFormatGroup.yuv420) {
      img = _convertYUV420(image);
    } else if (image.format.group == ImageFormatGroup.bgra8888) {
      img = _convertBGRA8888(image);
    }
//    print('conversion executed in ${stopwatch.elapsed.inMilliseconds}ms');
    imglib.JpegEncoder encoder = imglib.JpegEncoder(quality: 75);
    List<int> png = encoder.encodeImage(img);
//    print('encoding executed in ${stopwatch.elapsed.inMilliseconds}ms');
    return png;
  } catch (e) {
    print(">>>>>>>>>>>> ERROR:" + e.toString());
  }
  return null;
}

Future<imglib.Image> convertImageToRGBA(CameraImage image) async {
  try {
    imglib.Image img;
    if (image.format.group == ImageFormatGroup.yuv420) {
      img = _convertYUV420(image);
    } else if (image.format.group == ImageFormatGroup.bgra8888) {
      img = _convertBGRA8888(image);
    }
    return img;
  } catch (e) {
    print(">>>>>>>>>>>> ERROR:" + e.toString());
  }
  return null;
}

imglib.Image _convertBGRA8888(CameraImage image) {
  return imglib.Image.fromBytes(
    image.width,
    image.height,
    image.planes[0].bytes,
    format: imglib.Format.bgra,
  );
}

imglib.Image _convertYUV420(CameraImage image) {
  final imglib.Image img = imglib.Image(image.width, image.height);
  final Plane plane = image.planes[0];
  const int shift = (0xFF << 24);
  for (int x = 0; x < image.width; x++) {
    for (int planeOffset = 0;
        planeOffset < image.height * image.width;
        planeOffset += image.width) {
      final int pixelColor = plane.bytes[planeOffset + x];
      final int calculatedValue =
          shift | (pixelColor << 16) | (pixelColor << 8) | pixelColor;
      img.data[planeOffset + x] = calculatedValue;
    }
  }
  return img;
}
