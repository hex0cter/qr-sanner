import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:qr_code_tools/qr_code_tools.dart';
import 'package:qr_scanner/ui/widgets/scan_result_widget.dart';

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
  void didChangeDependencies() async {
    await getImage();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.black,
          leading: BackButton(
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: <Widget>[
            IconButton(
                icon: const Icon(Icons.add_photo_alternate, size: 28),
                tooltip: 'Select a photo',
                onPressed: getImage,
            ),
          ],
          title: Text("Photos")),
      body: _image != null
          ? Stack(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      image: FileImage(_image),
                    ),
                  ),
                ),
                // FittedBox(child: Image.file(_image), fit: BoxFit.fill),
                ScanResultWidget(data: _data)
              ],
            )
          : Center(
              child: Text("Please select a photo.",
                  style: TextStyle(color: Colors.white, fontSize: 20.0))),
      backgroundColor: Colors.black,
    );
  }
}
