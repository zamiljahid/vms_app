import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen>
    with SingleTickerProviderStateMixin {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
  );

  bool _hasScanned = false;
  bool _permissionGranted = false;

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _checkCameraPermission();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.request();
    if (!mounted) return;

    setState(() {
      _permissionGranted = status.isGranted;
    });

    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Camera permission is required to scan QR codes'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title:  Text('Scan QR Code', style: TextStyle(color: Theme.of(context).primaryColorLight),),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColorDark,
        elevation: 0,
      ),
      body: !_permissionGranted
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) async {
              if (_hasScanned) return;

              final barcode = capture.barcodes.first;
              final String? code = barcode.rawValue;

              if (code == null || code.isEmpty) return;

              // ✅ LOG QR VALUE
              debugPrint('📦 Scanned QR Code: $code');

              _hasScanned = true;
              await _controller.stop();

              if (!mounted) return;
              Navigator.pop(context, code);
            },
          ),

          /// 🔳 Dark overlay
          _ScannerOverlay(),

          /// 🔴 Animated scan line
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Positioned(
                top: 200 + (_animationController.value * 200),
                left: MediaQuery.of(context).size.width * 0.15,
                right: MediaQuery.of(context).size.width * 0.15,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: Colors.greenAccent,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.greenAccent.withOpacity(0.8),
                        blurRadius: 8,
                      )
                    ],
                  ),
                ),
              );
            },
          ),

          /// 📝 Instruction text
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Column(
              children: const [
                Text(
                  'Align the QR code within the frame',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Scanning will happen automatically',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
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

/// 🔲 Custom overlay with cut-out
class _ScannerOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: ColorFilter.mode(
        Colors.black.withOpacity(0.6),
        BlendMode.srcOut,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: Colors.black),
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}