import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PhotoScannerScreen extends StatefulWidget {
  @override
  _PhotoScannerScreenState createState() => _PhotoScannerScreenState();
}

class _PhotoScannerScreenState extends State<PhotoScannerScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
                backgroundColor: Colors.black,
                leading: BackButton(
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: Text("Photos")),
            body: Text("photo")));
  }
}
