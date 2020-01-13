import 'package:MKDG/image_filters/image_filter.dart';
import 'package:image/image.dart';

class MatrixFilter implements ImageFilter {
  final List<num> matrix;
  final String name;

  MatrixFilter(this.name, this.matrix);

  factory MatrixFilter.sobel() => MatrixFilter(
        'Sobel',
        [-1, 0, 1, -2, 0, 2, -1, 0, 1],
      );
  factory MatrixFilter.roberts() => MatrixFilter(
        'Roberts',
        [0, 0, 0, 0, 1, 0, 0, 0, 0], // TODO
      );
  factory MatrixFilter.prewitt() => MatrixFilter(
        'Prewitt',
        [-1, 0, 1, -1, 0, 1, -1, 0, 1],
      );
  factory MatrixFilter.log() => MatrixFilter(
        'LoG',
        [0, 1, 0, 1, -4, 1, 0, 1, 0],
      );

  @override
  Image compute(Image image) {
    // TODO: implement compute
    return convolution(grayscale(image), matrix);
  }
}
