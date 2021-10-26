import 'dart:async';

import 'package:fast_barcode_scanner/fast_barcode_scanner.dart';
import 'package:flutter/material.dart';
import 'detections_counter.dart';

final codeStream = StreamController<String>.broadcast();

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({Key? key}) : super(key: key);

  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final _torchIconState = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          'Fast Barcode Scanner',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: _torchIconState,
            builder: (context, state, _) => IconButton(
              icon: state
                  ? const Icon(Icons.flash_on)
                  : const Icon(Icons.flash_off),
              onPressed: () async {
                await CameraController.instance.toggleTorch();
                _torchIconState.value =
                    CameraController.instance.state.torchState;
              },
            ),
          ),
        ],
      ),
      body: BarcodeCamera(
        types: const [
          BarcodeType.code128,
          BarcodeType.dataMatrix
        ],
        resolution: Resolution.hd4k,
        framerate: Framerate.fps30,
        mode: DetectionMode.pauseDetection,
        position: CameraPosition.back,
        imageInversion: ImageInversion.none,
        onScan: (codes) {
          for (var code in codes) {
            debugPrint("=========== CODE: $code");
            codeStream.add(code);
          }
        },
        children: [
          const MaterialPreviewOverlay(animateDetection: false),
          const BlurPreviewOverlay(),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                ElevatedButton(
                  child: const Text("Resume"),
                  onPressed: () => CameraController.instance.resumeDetector(),
                ),
                const SizedBox(height: 20),
                const DetectionsCounter()
              ],
            ),
          )
        ],
      ),
    );
  }
}
