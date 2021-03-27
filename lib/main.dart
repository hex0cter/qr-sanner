import 'package:flutter/material.dart';
import 'package:qr_scanner/ui/camera_scanner_screen.dart';
import 'package:qr_scanner/ui/photo_scanner_screen.dart';

void main() => runApp(MaterialApp(initialRoute: '/camera', routes: {
      "/camera": (context) => CameraScannerScreen(),
      "/photo": (context) => PhotoScannerScreen()
    }));
