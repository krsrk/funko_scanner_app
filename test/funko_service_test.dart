import 'package:flutter_test/flutter_test.dart';
import 'package:funko_scanner_app/funko_service.dart';
import 'package:funko_scanner_app/funko.dart';

void main() {
  group('FunkoService Tests', () {
    late FunkoService service;

    setUp(() {
      service = FunkoService();
    });

    group('addOrUpdateFunko', () {
      test('should add new funko when it does not exist', () {
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

        service.addOrUpdateFunko(funko);

        expect(service.funkos.length, equals(1));
        expect(service.funkos.first.funkoId, equals(12345));
        expect(service.funkos.first.quantity, equals(1));
      });

      test('should update quantity when funko already exists', () {
        final funko1 = Funko(
          funkoId: 12345,
          funkoType: 'Funko Pop Plus',
          funkoName: 'Gamer Stitch',
          funkoLicense: 'Disney',
          funkoSeries: 'Lilo & Stitch',
          funkoSticker: 'Metallic',
          quantity: 1,
          imagesPath: 'path/to/image.jpg',
        );

        final funko2 = Funko(
          funkoId: 12345,
          funkoType: 'Funko Pop Plus',
          funkoName: 'Gamer Stitch',
          funkoLicense: 'Disney',
          funkoSeries: 'Lilo & Stitch',
          funkoSticker: 'Metallic',
          quantity: 3,
          imagesPath: 'path/to/image.jpg',
        );

        service.addOrUpdateFunko(funko1);
        service.addOrUpdateFunko(funko2);

        expect(service.funkos.length, equals(1));
        expect(service.funkos.first.quantity, equals(4));
      });

      test('should handle multiple different funkos', () {
        final funko1 = Funko(
          funkoId: 12345,
          funkoType: 'Funko Pop Plus',
          funkoName: 'Gamer Stitch',
          funkoLicense: 'Disney',
          funkoSeries: 'Lilo & Stitch',
          funkoSticker: 'Metallic',
          quantity: 1,
          imagesPath: 'path/to/image.jpg',
        );

        final funko2 = Funko(
          funkoId: 67890,
          funkoType: 'Funko Pop',
          funkoName: 'Spider-Man',
          funkoLicense: 'Marvel',
          funkoSeries: 'Spider-Man',
          funkoSticker: 'Glow in the Dark',
          quantity: 2,
          imagesPath: 'path/to/image2.jpg',
        );

        service.addOrUpdateFunko(funko1);
        service.addOrUpdateFunko(funko2);

        expect(service.funkos.length, equals(2));
        expect(service.totalItems, equals(3));
        expect(service.uniqueItems, equals(2));
      });
    });

    group('parseFunkoFromCode', () {
      test('should parse FUNKO format correctly', () {
        const code = 'FUNKO:12345|Funko Pop Plus|Gamer Stitch|Disney|Lilo & Stitch|Metallic';
        
        final funko = service.parseFunkoFromCode(code);
        
        expect(funko, isNotNull);
        expect(funko!.funkoId, equals(12345));
        expect(funko.funkoType, equals('Funko Pop Plus'));
        expect(funko.funkoName, equals('Gamer Stitch'));
        expect(funko.funkoLicense, equals('Disney'));
        expect(funko.funkoSeries, equals('Lilo & Stitch'));
        expect(funko.funkoSticker, equals('Metallic'));
        expect(funko.quantity, equals(1));
        expect(funko.imagesPath, equals('funko_12345.jpg'));
      });

      test('should parse pipe-separated format correctly', () {
        const code = '67890|Funko Pop|Spider-Man|Marvel|Spider-Man|Glow in the Dark';
        
        final funko = service.parseFunkoFromCode(code);
        
        expect(funko, isNotNull);
        expect(funko!.funkoId, equals(67890));
        expect(funko.funkoType, equals('Funko Pop'));
        expect(funko.funkoName, equals('Spider-Man'));
        expect(funko.funkoLicense, equals('Marvel'));
        expect(funko.funkoSeries, equals('Spider-Man'));
        expect(funko.funkoSticker, equals('Glow in the Dark'));
        expect(funko.quantity, equals(1));
        expect(funko.imagesPath, equals('funko_67890.jpg'));
      });

      test('should parse numeric format and generate dummy data', () {
        const code = '123456789';
        
        final funko = service.parseFunkoFromCode(code);
        
        expect(funko, isNotNull);
        expect(funko!.funkoId, equals(123456789));
        expect(funko.funkoType, isNotEmpty);
        expect(funko.funkoName, isNotEmpty);
        expect(funko.funkoLicense, isNotEmpty);
        expect(funko.funkoSeries, isNotEmpty);
        expect(funko.funkoSticker, isNotEmpty);
        expect(funko.quantity, equals(1));
        expect(funko.imagesPath, equals('funko_123456789.jpg'));
      });

      test('should handle invalid FUNKO format', () {
        const code = 'FUNKO:invalid|format';
        
        final funko = service.parseFunkoFromCode(code);
        
        expect(funko, isNull);
      });

      test('should handle invalid pipe-separated format', () {
        const code = '123|incomplete';
        
        final funko = service.parseFunkoFromCode(code);
        
        expect(funko, isNull);
      });

      test('should handle empty or short codes', () {
        const code = '123';
        
        final funko = service.parseFunkoFromCode(code);
        
        expect(funko, isNotNull);
        expect(funko!.funkoId, isPositive);
        expect(funko.funkoType, isNotEmpty);
        expect(funko.funkoName, isNotEmpty);
      });
    });

    group('clearFunkos', () {
      test('should clear all funkos', () {
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

        service.addOrUpdateFunko(funko);
        expect(service.funkos.length, equals(1));

        service.clearFunkos();
        expect(service.funkos.length, equals(0));
        expect(service.totalItems, equals(0));
        expect(service.uniqueItems, equals(0));
      });
    });

    group('totalItems and uniqueItems', () {
      test('should calculate totals correctly', () {
        final funko1 = Funko(
          funkoId: 12345,
          funkoType: 'Funko Pop Plus',
          funkoName: 'Gamer Stitch',
          funkoLicense: 'Disney',
          funkoSeries: 'Lilo & Stitch',
          funkoSticker: 'Metallic',
          quantity: 2,
          imagesPath: 'path/to/image.jpg',
        );

        final funko2 = Funko(
          funkoId: 67890,
          funkoType: 'Funko Pop',
          funkoName: 'Spider-Man',
          funkoLicense: 'Marvel',
          funkoSeries: 'Spider-Man',
          funkoSticker: 'Glow in the Dark',
          quantity: 3,
          imagesPath: 'path/to/image2.jpg',
        );

        service.addOrUpdateFunko(funko1);
        service.addOrUpdateFunko(funko2);

        expect(service.totalItems, equals(5));
        expect(service.uniqueItems, equals(2));
      });

      test('should handle quantity updates in totals', () {
        final funko1 = Funko(
          funkoId: 12345,
          funkoType: 'Funko Pop Plus',
          funkoName: 'Gamer Stitch',
          funkoLicense: 'Disney',
          funkoSeries: 'Lilo & Stitch',
          funkoSticker: 'Metallic',
          quantity: 1,
          imagesPath: 'path/to/image.jpg',
        );

        final funko2 = Funko(
          funkoId: 12345,
          funkoType: 'Funko Pop Plus',
          funkoName: 'Gamer Stitch',
          funkoLicense: 'Disney',
          funkoSeries: 'Lilo & Stitch',
          funkoSticker: 'Metallic',
          quantity: 2,
          imagesPath: 'path/to/image.jpg',
        );

        service.addOrUpdateFunko(funko1);
        service.addOrUpdateFunko(funko2);

        expect(service.totalItems, equals(3));
        expect(service.uniqueItems, equals(1));
      });
    });
  });
} 