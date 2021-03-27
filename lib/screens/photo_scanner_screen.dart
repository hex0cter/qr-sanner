import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PhotoScannerScreen extends StatefulWidget {
  @override
  _PhotoScannerScreenState createState() => _PhotoScannerScreenState();
}

class _PhotoScannerScreenState extends State<PhotoScannerScreen> {
  File _image;
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        print(_image);
      } else {
        print('No image selected.');
      }
    });
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
                title: Text("Photos")),
            body: Column(
              children: [
                CupertinoButton(
                  child: Text("Select a photo ..."),
                  onPressed: getImage,
                ),
                _image != null ? Image.file(_image) : Container(),
              ]
            )));
  }
}
