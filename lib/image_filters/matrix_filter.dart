import 'package:MKDG/image_filters/image_filter.dart';
import 'package:image/image.dart';

class MatrixFilter implements ImageFilter {
  final List<List<num>> matrix;
  final String name;

  bool _vertical = false;
  set vertical(bool val) => this._vertical = val;

  MatrixFilter(this.name, this.matrix);

  factory MatrixFilter.sobel() => MatrixFilter(
        'Sobel',
        [
          [-1, 0, 1],
          [-2, 0, 2],
          [-1, 0, 1],
        ],
      );
  factory MatrixFilter.prewitt() => MatrixFilter(
        'Prewitt',
        [
          [-1, 0, 1],
          [-1, 0, 1],
          [-1, 0, 1],
        ],
      );
  factory MatrixFilter.log() => MatrixFilter(
        'LoG',
        [
          [0, 1, 0],
          [1, -4, 1],
          [0, 1, 0],
        ],
      );

  @override
  Image compute(Image image) {
    grayscale(image);
    return convolution(image, _prepareMatrix(matrix, _vertical));
  }

  List<num> _prepareMatrix(List<List<num>> matrix, bool vertical) {
    List<num> outputMatrix = [];
    for (int x = 0; x < 3; x++) {
      for (int y = 0; y < 3; y++) {
        outputMatrix.add(matrix[vertical ? y : x][vertical ? x : y]);
      }
    }
    return outputMatrix;
  }
}
