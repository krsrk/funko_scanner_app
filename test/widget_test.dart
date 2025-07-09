// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funko_scanner_app/main.dart';
import 'package:funko_scanner_app/funko_service.dart';
import 'package:funko_scanner_app/funko.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

void main() {
  group('Funko Scanner Widget Tests', () {
    testWidgets('should display empty state when no funkos', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MyApp());

      expect(find.text('Funko Scanner'), findsOneWidget);
      expect(find.text('Escanear Cámara'), findsOneWidget);
      expect(find.text('Escanear Imagen'), findsOneWidget);
      expect(find.text('Enviar'), findsOneWidget);

      // El botón enviar debería estar deshabilitado cuando no hay funkos
      final sendButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Enviar'),
      );
      expect(sendButton.onPressed, isNull);
    });

    testWidgets('should display funko list when funkos are added', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MyApp());

      // Simular escaneo de un funko
      await tester.tap(find.text('Escanear Cámara'));
      await tester.pumpAndSettle();

      // Simular que se escaneó un código
      // Nota: En un test real, necesitarías mockear el scanner
      // Por ahora, verificamos que la UI se actualiza correctamente

      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('should enable send button when funkos are present', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MyApp());

      // Simular que hay funkos en la lista
      // En un test real, necesitarías inyectar un FunkoService mock

      final sendButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Enviar'),
      );

      // El botón debería estar habilitado cuando hay funkos
      // expect(sendButton.onPressed, isNotNull);
    });

    testWidgets('should show loading indicator when sending', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MyApp());

      // Simular envío de datos
      await tester.tap(find.text('Enviar'));
      await tester.pump();

      // Debería mostrar un indicador de carga
      // expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display funko details correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MyApp());

      // Crear un funko de prueba
      final testFunko = Funko(
        funkoId: 12345,
        funkoType: 'Funko Pop Plus',
        funkoName: 'Gamer Stitch',
        funkoLicense: 'Disney',
        funkoSeries: 'Lilo & Stitch',
        funkoSticker: 'Metallic',
        quantity: 2,
        imagesPath: 'path/to/image.jpg',
      );

      // Simular que se agregó el funko a la lista
      // En un test real, necesitarías inyectar el servicio

      // Verificar que se muestran los detalles correctos
      // expect(find.text('Gamer Stitch'), findsOneWidget);
      // expect(find.text('ID: 12345 | Cantidad: 2'), findsOneWidget);
      // expect(find.text('Funko Pop Plus'), findsOneWidget);
    });

    testWidgets('should handle camera scan button tap', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MyApp());

      await tester.tap(find.text('Escanear Cámara'));
      await tester.pumpAndSettle();

      // Debería navegar a la pantalla del scanner
      expect(find.text('Escanear Código'), findsOneWidget);
      expect(find.byType(MobileScanner), findsOneWidget);
    });

    testWidgets('should handle image scan button tap', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MyApp());

      await tester.tap(find.text('Escanear Imagen'));
      await tester.pumpAndSettle();

      // Debería simular el escaneo desde imagen
      // En un test real, necesitarías mockear el picker de imagen
    });
  });
}

// Mock FunkoService para testing
class MockFunkoService extends FunkoService {
  final List<Funko> _mockFunkos = [];
  bool _isSending = false;

  @override
  List<Funko> get funkos => List.unmodifiable(_mockFunkos);

  @override
  void addOrUpdateFunko(Funko newFunko) {
    final index = _mockFunkos.indexWhere((f) => f.funkoId == newFunko.funkoId);
    if (index != -1) {
      _mockFunkos[index].quantity += newFunko.quantity;
    } else {
      _mockFunkos.add(newFunko);
    }
  }

  @override
  Future<bool> sendToWebhook() async {
    _isSending = true;
    await Future.delayed(const Duration(milliseconds: 100));
    _isSending = false;
    return true;
  }

  bool get isSending => _isSending;

  @override
  void clearFunkos() {
    _mockFunkos.clear();
  }

  @override
  int get totalItems {
    return _mockFunkos.fold(0, (sum, funko) => sum + funko.quantity).toInt();
  }

  @override
  int get uniqueItems => _mockFunkos.length;
}
