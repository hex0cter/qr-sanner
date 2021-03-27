
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PhotoScannerScreen extends StatefulWidget {
  @override
  _PhotoScannerScreenState createState() => _PhotoScannerScreenState();
}

class _PhotoScannerScreenState extends State<PhotoScannerScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(body: Text("photo")));
  }
}
