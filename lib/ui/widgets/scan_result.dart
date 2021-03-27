import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ScanResultWidget extends StatelessWidget {
  final data;

  ScanResultWidget({this.data});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      child: SizedBox(
        height: 160,
        child: Column(
          children: [
            Opacity(
                opacity: 0.6,
                child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 48,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 18.0, right: 18.0),
                      child: Text(data == "" ? "No QR code found." : data,
                          style: TextStyle(
                              fontFamily: "Arial Rounded",
                              fontWeight: FontWeight.normal,
                              color: Colors.white)),
                    ))),
            data != ""
                ? CupertinoButton(
              onPressed: () async {
                FlutterClipboard.copy(data);
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(
                  content: Text("Copied to clipboard."),
                  duration: Duration(seconds: 1),
                ));
              },
              child: Text('Copy'),
            )
                : SizedBox(height: 24.0),
            // const SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }
}
