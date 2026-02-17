import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/api_service.dart';
import '../models/tote.dart';
import 'tote_view_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final ApiService _apiService = ApiService();
  MobileScannerController cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    torchEnabled: false,
  );
  bool _isProcessing = false;
  bool _torchOn = false;
  String? _detectedCode;

  @override
  void initState() {
    super.initState();
    cameraController.start();
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  Future<void> _handleQRCode(String qrCode) async {
    if (_isProcessing) return;
    
    setState(() {
      _isProcessing = true;
      _detectedCode = qrCode;
    });

    try {
      // Show loading indicator
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('Looking up: $qrCode'),
            ],
          ),
        ),
      );

      // Look up tote by QR code
      final Tote tote = await _apiService.getToteByQRCode(qrCode);

      // Close loading dialog
      if (!mounted) return;
      Navigator.of(context).pop();

      // Navigate to tote view screen
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ToteViewScreen(tote: tote),
        ),
      );
    } catch (e) {
      // Close loading dialog
      if (!mounted) return;
      Navigator.of(context).pop();

      // Show error message
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Tote Not Found'),
          content: Text('QR Code: $qrCode\n\nNo tote found with this QR code.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _isProcessing = false;
                  _detectedCode = null;
                });
              },
              child: const Text('Try Again'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Go back to home
              },
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scanArea = MediaQuery.of(context).size.width * 0.7;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(_torchOn ? Icons.flash_on : Icons.flash_off),
            onPressed: () {
              cameraController.toggleTorch();
              setState(() {
                _torchOn = !_torchOn;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              if (_isProcessing) return;
              
              final List<Barcode> barcodes = capture.barcodes;
              
              if (barcodes.isEmpty) return;
              
              for (final barcode in barcodes) {
                if (barcode.rawValue != null && barcode.rawValue!.isNotEmpty) {
                  _handleQRCode(barcode.rawValue!);
                  break;
                }
              }
            },
          ),
          // Scanning frame overlay
          Center(
            child: Container(
              width: scanArea,
              height: scanArea,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _detectedCode != null ? Colors.green : Colors.white,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  // Corner decorations
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: _detectedCode != null ? Colors.green : Colors.blue,
                            width: 5,
                          ),
                          left: BorderSide(
                            color: _detectedCode != null ? Colors.green : Colors.blue,
                            width: 5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: _detectedCode != null ? Colors.green : Colors.blue,
                            width: 5,
                          ),
                          right: BorderSide(
                            color: _detectedCode != null ? Colors.green : Colors.blue,
                            width: 5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _detectedCode != null ? Colors.green : Colors.blue,
                            width: 5,
                          ),
                          left: BorderSide(
                            color: _detectedCode != null ? Colors.green : Colors.blue,
                            width: 5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _detectedCode != null ? Colors.green : Colors.blue,
                            width: 5,
                          ),
                          right: BorderSide(
                            color: _detectedCode != null ? Colors.green : Colors.blue,
                            width: 5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Instruction text at top
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Position QR code within the frame',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Detection indicator at bottom
          if (_detectedCode != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Detected: $_detectedCode',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
