import 'package:flutter_test/flutter_test.dart';
import 'package:funko_scanner_app/funko.dart';

void main() {
  group('Funko Model Tests', () {
    test('should create Funko with all required fields', () {
      final funko = Funko(
        funkoId: 12345,
        funkoType: 'Funko Pop Plus',
        funkoName: 'Gamer Stitch',
        funkoLicense: 'Disney',
        funkoSeries: 'Lilo & Stitch',
        funkoSticker: 'Metallic',
        quantity: 1,
        imagesPath: 'path/to/image.jpg',
      );

      expect(funko.funkoId, equals(12345));
      expect(funko.funkoType, equals('Funko Pop Plus'));
      expect(funko.funkoName, equals('Gamer Stitch'));
      expect(funko.funkoLicense, equals('Disney'));
      expect(funko.funkoSeries, equals('Lilo & Stitch'));
      expect(funko.funkoSticker, equals('Metallic'));
      expect(funko.quantity, equals(1));
      expect(funko.imagesPath, equals('path/to/image.jpg'));
    });

    test('should convert Funko to JSON correctly', () {
      final funko = Funko(
        funkoId: 12345,
        funkoType: 'Funko Pop Plus',
        funkoName: 'Gamer Stitch',
        funkoLicense: 'Disney',
        funkoSeries: 'Lilo & Stitch',
        funkoSticker: 'Metallic',
        quantity: 1,
        imagesPath: 'path/to/image.jpg',
      );

      final json = funko.toJson();

      expect(json['funko_id'], equals(12345));
      expect(json['funko_type'], equals('Funko Pop Plus'));
      expect(json['funko_name'], equals('Gamer Stitch'));
      expect(json['funko_license'], equals('Disney'));
      expect(json['funko_series'], equals('Lilo & Stitch'));
      expect(json['funko_sticker'], equals('Metallic'));
      expect(json['quantity'], equals(1));
      expect(json['images_path'], equals('path/to/image.jpg'));
    });

    test('should create Funko from JSON correctly', () {
      final json = {
        'funko_id': 12345,
        'funko_type': 'Funko Pop Plus',
        'funko_name': 'Gamer Stitch',
        'funko_license': 'Disney',
        'funko_series': 'Lilo & Stitch',
        'funko_sticker': 'Metallic',
        'quantity': 1,
        'images_path': 'path/to/image.jpg',
      };

      final funko = Funko.fromJson(json);

      expect(funko.funkoId, equals(12345));
      expect(funko.funkoType, equals('Funko Pop Plus'));
      expect(funko.funkoName, equals('Gamer Stitch'));
      expect(funko.funkoLicense, equals('Disney'));
      expect(funko.funkoSeries, equals('Lilo & Stitch'));
      expect(funko.funkoSticker, equals('Metallic'));
      expect(funko.quantity, equals(1));
      expect(funko.imagesPath, equals('path/to/image.jpg'));
    });

    test('should allow quantity modification', () {
      final funko = Funko(
        funkoId: 12345,
        funkoType: 'Funko Pop Plus',
        funkoName: 'Gamer Stitch',
        funkoLicense: 'Disney',
        funkoSeries: 'Lilo & Stitch',
        funkoSticker: 'Metallic',
        quantity: 1,
        imagesPath: 'path/to/image.jpg',
      );

      funko.quantity = 5;
      expect(funko.quantity, equals(5));

      funko.quantity += 3;
      expect(funko.quantity, equals(8));
    });
  });
} 