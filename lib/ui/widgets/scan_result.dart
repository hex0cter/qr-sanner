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
        child: Container(
          decoration: new BoxDecoration(
              // border: new Border.all(width: borderWidth ,color: Colors.transparent), //color is transparent so that it does not blend with the actual color specified
              // borderRadius: const BorderRadius.all(const Radius.circular(30.0)),
              color: new Color.fromRGBO(55, 55, 55, 0.5) // Specifies the background color and the opacity
          ),
          child: Column(
            children: [
              Opacity(
                  opacity: 1,
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
      ),
    );
  }
}
