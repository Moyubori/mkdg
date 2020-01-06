import 'package:MKDG/image_filters/image_filter.dart';
import 'package:image/image.dart';

class MatrixFilter implements ImageFilter {
  final List<List<double>> matrix;
  final String name;

  MatrixFilter(this.name, this.matrix);

  factory MatrixFilter.sobel() => MatrixFilter(
        'Sobel',
        [/*TODO*/],
      );
  factory MatrixFilter.roberts() => MatrixFilter(
        'Roberts',
        [/*TODO*/],
      );
  factory MatrixFilter.prewitt() => MatrixFilter(
        'Prewitt',
        [/*TODO*/],
      );
  factory MatrixFilter.log() => MatrixFilter(
        'LoG',
        [/*TODO*/],
      );

  @override
  Image compute(Image image) {
    // TODO: implement compute
    return image;
  }
}
