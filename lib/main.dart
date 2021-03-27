import 'package:flutter/material.dart';
import 'package:qr_scanner/ui/screens/camera_scanner_screen.dart';
import 'package:qr_scanner/ui/screens/photo_scanner_screen.dart';

void main() {
  return runApp(MaterialApp(initialRoute: '/camera', navigatorObservers: [
    routeObserver
  ], routes: {
    "/camera": (context) => CameraScannerScreen(),
    "/photo": (context) => PhotoScannerScreen()
  }));
}
