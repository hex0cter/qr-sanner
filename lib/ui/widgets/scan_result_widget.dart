import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'information_widget.dart';

class ScanResultWidget extends StatelessWidget {
  final String data;

  ScanResultWidget({this.data});

  @override
  Widget build(BuildContext context) {
    return InformationWidget(
      data: data != "" ? data: "No QR code found.",
      button: data != "" ? CupertinoButton(
        onPressed: () async {
          FlutterClipboard.copy(data);
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(
            content: Text("Copied to clipboard."),
            duration: Duration(seconds: 1),
          ));
        },
        child: Text('Copy'),
      ) : null
    );
  }
}
