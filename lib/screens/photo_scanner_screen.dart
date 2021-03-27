import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:qr_code_tools/qr_code_tools.dart';
import 'package:qr_scanner/ui/scan_result.dart';

class PhotoScannerScreen extends StatefulWidget {
  @override
  _PhotoScannerScreenState createState() => _PhotoScannerScreenState();
}

class _PhotoScannerScreenState extends State<PhotoScannerScreen> {
  File _image;
  final picker = ImagePicker();

  String _data = "";

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      return;
    }

    String data = await QrCodeToolsPlugin.decodeFrom(pickedFile.path);

    if (pickedFile?.path != null) {
      setState(() {
        _image = File(pickedFile.path);
        _data = data == null ? "" : data;
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
                backgroundColor: Colors.black,
                leading: BackButton(
                  onPressed: () => Navigator.of(context).pop(),
                ),
                actions: <Widget>[
                  IconButton(
                      icon: const Icon(Icons.add_photo_alternate),
                      tooltip: 'Show Snackbar',
                      onPressed: getImage
                  ),
                ],
                title: Text("Photos")),
            body: _image != null ? Stack(
              children: [
                Center(child: Image.file(_image)),
                ScanResultWidget(data: _data)
              ],
            ) :  Center(child: Text("Please select a photo.", style: TextStyle(color: Colors.white))),
            backgroundColor: Colors.black,
        )
    );
  }
}
