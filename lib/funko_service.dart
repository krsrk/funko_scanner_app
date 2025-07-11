import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'funko.dart';
import 'dart:io'; // Added for File
import 'package:uuid/uuid.dart';
import 'package:http_parser/http_parser.dart';

class FunkoService {
  final List<Funko> _funkos = [];

  List<Funko> get funkos => List.unmodifiable(_funkos);

  /// Agrega un nuevo funko o suma la cantidad si ya existe
  void addOrUpdateFunko(Funko newFunko) {
    final index = _funkos.indexWhere((f) => f.funkoId == newFunko.funkoId);
    if (index != -1) {
      _funkos[index].quantity += newFunko.quantity;
    } else {
      _funkos.add(newFunko);
    }
  }

  /// Parsea un código escaneado y retorna un objeto Funko
  Funko? parseFunkoFromCode(String code) {
    try {
      // Simulación de parseo de diferentes formatos de códigos
      if (code.startsWith('FUNKO:')) {
        return _parseFunkoFormat(code);
      } else if (code.contains('|')) {
        return _parsePipeSeparatedFormat(code);
      } else {
        // Mostrar el valor leído y 'Funko desconocido'
        return Funko(
          funkoId: int.tryParse(code.replaceAll(RegExp(r'\D'), '')) ?? 0,
          funkoType: 'Desconocido',
          funkoName: 'Funko desconocido',
          funkoLicense: '',
          funkoSeries: '',
          funkoSticker: code,
          quantity: 1,
          imagesPath: '',
        );
      }
    } catch (e) {
      print('Error parsing code: $e');
      return null;
    }
  }

  /// Parsea formato: FUNKO:ID|TYPE|NAME|LICENSE|SERIES|STICKER
  Funko _parseFunkoFormat(String code) {
    final parts = code.replaceFirst('FUNKO:', '').split('|');
    if (parts.length >= 6) {
      return Funko(
        funkoId: int.parse(parts[0]),
        funkoType: parts[1],
        funkoName: parts[2],
        funkoLicense: parts[3],
        funkoSeries: parts[4],
        funkoSticker: parts[5],
        quantity: 1,
        imagesPath: 'funko_${parts[0]}.jpg',
      );
    }
    throw FormatException('Invalid FUNKO format');
  }

  /// Parsea formato separado por pipes: ID|TYPE|NAME|LICENSE|SERIES|STICKER
  Funko _parsePipeSeparatedFormat(String code) {
    final parts = code.split('|');
    if (parts.length >= 6) {
      return Funko(
        funkoId: int.parse(parts[0]),
        funkoType: parts[1],
        funkoName: parts[2],
        funkoLicense: parts[3],
        funkoSeries: parts[4],
        funkoSticker: parts[5],
        quantity: 1,
        imagesPath: 'funko_${parts[0]}.jpg',
      );
    }
    throw FormatException('Invalid pipe-separated format');
  }

  /// Parsea formato numérico: genera datos basados en el ID
  Funko _parseNumericFormat(String code) {
    final id =
        int.tryParse(code.replaceAll(RegExp(r'\D'), '')) ??
        DateTime.now().millisecondsSinceEpoch;

    // Genera datos dummy basados en el ID
    final dummyData = _getDummyDataById(id);

    return Funko(
      funkoId: id,
      funkoType: dummyData['type']!,
      funkoName: dummyData['name']!,
      funkoLicense: dummyData['license']!,
      funkoSeries: dummyData['series']!,
      funkoSticker: dummyData['sticker']!,
      quantity: 1,
      imagesPath: 'funko_$id.jpg',
    );
  }

  /// Parsea formato por defecto
  Funko _parseDefaultFormat(String code) {
    final id = DateTime.now().millisecondsSinceEpoch;
    final dummyData = _getDummyDataById(id);

    return Funko(
      funkoId: id,
      funkoType: dummyData['type']!,
      funkoName: dummyData['name']!,
      funkoLicense: dummyData['license']!,
      funkoSeries: dummyData['series']!,
      funkoSticker: dummyData['sticker']!,
      quantity: 1,
      imagesPath: 'funko_$id.jpg',
    );
  }

  /// Obtiene datos dummy basados en el ID
  Map<String, String> _getDummyDataById(int id) {
    final dummyFunkos = [
      {
        'type': 'Funko Pop Plus',
        'name': 'Gamer Stitch',
        'license': 'Disney',
        'series': 'Lilo & Stitch',
        'sticker': 'Metallic',
      },
      {
        'type': 'Funko Pop',
        'name': 'Spider-Man',
        'license': 'Marvel',
        'series': 'Spider-Man',
        'sticker': 'Glow in the Dark',
      },
      {
        'type': 'Funko Pop Deluxe',
        'name': 'Batman',
        'license': 'DC Comics',
        'series': 'Batman',
        'sticker': 'Chase',
      },
      {
        'type': 'Funko Pop',
        'name': 'Mickey Mouse',
        'license': 'Disney',
        'series': 'Classic',
        'sticker': 'Common',
      },
      {
        'type': 'Funko Pop Plus',
        'name': 'Iron Man',
        'license': 'Marvel',
        'series': 'Avengers',
        'sticker': 'Metallic',
      },
    ];

    final data = dummyFunkos[id % dummyFunkos.length];
    return {
      'type': data['type']!,
      'name': data['name']!,
      'license': data['license']!,
      'series': data['series']!,
      'sticker': data['sticker']!,
    };
  }

  /// Envía los datos al webhook
  Future<bool> sendToWebhook() async {
    try {
      final url = dotenv.env['WEBHOOK_URL'] ?? '';
      print('Webhook URL: ${url.isEmpty ? 'NOT CONFIGURED' : url}');
      
      if (url.isEmpty || url == '[your_webhook_url]') {
        throw Exception('WEBHOOK_URL not configured. Please update your .env file with a valid webhook URL.');
      }

      final body = jsonEncode(_funkos.map((f) => f.toJson()).toList());
      print('Sending ${_funkos.length} funkos to webhook...');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print('Webhook response status: ${response.statusCode}');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error sending to webhook: $e');
      return false;
    }
  }

  // Agregar función para enviar imagen al webhook
  Future<bool> sendImageToWebhook(File imageFile) async {
    try {
      final url = dotenv.env['WEBHOOK_URL'] ?? '';
      if (url.isEmpty || url == '[your_webhook_url]') {
        throw Exception('WEBHOOK_URL not configured. Please update your .env file with a valid webhook URL.');
      }
      final uuid = Uuid().v4();
      final filename = '$uuid.jpg';
      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.fields['id'] = uuid;
      request.fields['filename'] = filename;
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          filename: filename,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
      final response = await request.send();
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error sending image to webhook: $e');
      return false;
    }
  }

  /// Limpia la lista de funkos
  void clearFunkos() {
    _funkos.clear();
  }

  /// Obtiene el total de items
  int get totalItems {
    return _funkos.fold(0, (sum, funko) => sum + funko.quantity);
  }

  /// Obtiene el número de tipos únicos
  int get uniqueItems => _funkos.length;
}
