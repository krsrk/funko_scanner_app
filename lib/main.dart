import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'funko_service.dart';

Future<void> main() async {
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Funko Scanner',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const FunkoScannerPage(),
    );
  }
}

class FunkoScannerPage extends StatefulWidget {
  const FunkoScannerPage({super.key});

  @override
  State<FunkoScannerPage> createState() => _FunkoScannerPageState();
}

class _FunkoScannerPageState extends State<FunkoScannerPage> {
  final FunkoService _funkoService = FunkoService();
  bool _isSending = false;

  Future<void> _scanCode({bool fromImage = false}) async {
    String? code;
    if (fromImage) {
      // Escaneo desde imagen (mock, implementar con MobileScannerController)
      // Aquí deberías abrir un picker de imagen y pasarla al escáner
      // Por simplicidad, simulamos un código
      code = await _mockScanFromImage();
    } else {
      code = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ScannerScreen(),
        ),
      );
    }
    if (code != null) {
      // Parsear datos desde el código escaneado usando el servicio
      final funko = _funkoService.parseFunkoFromCode(code);
      if (funko != null) {
        setState(() {
          _funkoService.addOrUpdateFunko(funko);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Funko agregado: ${funko.funkoName}'),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al parsear el código escaneado'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendToWebhook() async {
    setState(() => _isSending = true);
    
    final success = await _funkoService.sendToWebhook();
    
    setState(() => _isSending = false);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Datos enviados correctamente'),
          backgroundColor: Colors.green,
        ),
      );
      // Limpiar la lista después del envío exitoso
      setState(() {
        _funkoService.clearFunkos();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al enviar datos'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<String> _mockScanFromImage() async {
    await Future.delayed(const Duration(seconds: 1));
    // Simular diferentes formatos de códigos para testing
    final codes = [
      'FUNKO:12345|Funko Pop Plus|Gamer Stitch|Disney|Lilo & Stitch|Metallic',
      '67890|Funko Pop|Spider-Man|Marvel|Spider-Man|Glow in the Dark',
      '123456789',
    ];
    return codes[DateTime.now().millisecond % codes.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Funko Scanner'),
        actions: [
          if (_funkoService.funkos.isNotEmpty)
            IconButton(
              onPressed: () {
                setState(() {
                  _funkoService.clearFunkos();
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Lista limpiada')),
                );
              },
              icon: const Icon(Icons.clear_all),
              tooltip: 'Limpiar lista',
            ),
        ],
      ),
      body: Column(
        children: [
          // Header con estadísticas
          if (_funkoService.funkos.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[100],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        '${_funkoService.uniqueItems}',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const Text('Tipos únicos'),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        '${_funkoService.totalItems}',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const Text('Total items'),
                    ],
                  ),
                ],
              ),
            ),
          
          // Lista de funkos
          Expanded(
            child: _funkoService.funkos.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.qr_code_scanner, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No hay Funkos escaneados',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Usa los botones de abajo para escanear',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _funkoService.funkos.length,
                    itemBuilder: (context, index) {
                      final funko = _funkoService.funkos[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.deepPurple,
                            child: Text(
                              '${funko.quantity}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            funko.funkoName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ID: ${funko.funkoId}'),
                              Text('${funko.funkoLicense} - ${funko.funkoSeries}'),
                              Text('Sticker: ${funko.funkoSticker}'),
                            ],
                          ),
                          trailing: Chip(
                            label: Text(funko.funkoType),
                            backgroundColor: Colors.deepPurple[100],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          
          // Indicador de carga
          if (_isSending)
            Container(
              padding: const EdgeInsets.all(16),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Text('Enviando datos...'),
                ],
              ),
            ),
          
          // Botones de acción
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _scanCode(fromImage: false),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Cámara'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _scanCode(fromImage: true),
                    icon: const Icon(Icons.image),
                    label: const Text('Imagen'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _funkoService.funkos.isEmpty || _isSending
                        ? null
                        : _sendToWebhook,
                    icon: const Icon(Icons.send),
                    label: const Text('Enviar'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ScannerScreen extends StatelessWidget {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escanear Código')),
      body: MobileScanner(
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          if (barcodes.isNotEmpty) {
            Navigator.pop(context, barcodes.first.rawValue);
          }
        },
      ),
    );
  }
}
