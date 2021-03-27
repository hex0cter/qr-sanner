import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:clipboard/clipboard.dart';
import 'dart:async';

class CameraScannerScreen extends StatefulWidget {
  const CameraScannerScreen({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CameraScannerScreenState();
}

class _CameraScannerScreenState extends State<CameraScannerScreen>
    with WidgetsBindingObserver {
  String textData = "";
  QRViewController controller;
  Timer timer;
  bool flash;

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('state = $state');
    if (state == AppLifecycleState.paused) {
      controller.pauseCamera();
    }
    if (state == AppLifecycleState.resumed) {
      controller.resumeCamera();
    }
  }

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    }
    controller?.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    Future<bool> _future = controller?.getFlashStatus();
    _future?.catchError((err) {
      // do something with err
      print(err);
    });

    String text = textData == "" ? "Please scan a code ..." : textData;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
              child: Stack(
            children: [
              _buildQrView(context),
              Positioned(
                child: IconButton(
                  icon: FutureBuilder(
                    future: _future,
                    builder: (context, snapshot) {
                      print(snapshot?.data);
                      return Icon(
                          snapshot?.data == true
                              ? Icons.flash_on
                              : Icons.flash_off,
                          color: Colors.white70,
                          size: 30);
                    },
                  ),
                  tooltip: 'Flash',
                  onPressed: () {
                    setState(() {
                      controller.toggleFlash();
                    });
                  },
                ),
                top: 60.0,
                left: 10.0,
              ),
              Positioned(
                child: IconButton(
                  icon:
                      Icon(Icons.photo_album, color: Colors.white70, size: 30),
                  tooltip: 'Album',
                  onPressed: () {
                    Navigator.pushNamed(context, "/photo");
                  },
                ),
                top: 60.0,
                right: 10.0,
              )
            ],
          )),
          Positioned(
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
                              child: Text(text,
                                  style: TextStyle(
                                      fontFamily: "Arial Rounded",
                                      fontWeight: FontWeight.normal,
                                      color: Colors.white)),
                            ))),
                    textData != ""
                        ? CupertinoButton(
                            onPressed: () async {
                              FlutterClipboard.copy(textData);
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text("Copied to clipboard."),
                                duration: Duration(seconds: 1),
                              ));
                              setState(() {});
                            },
                            child: Text('Copy'),
                          )
                        : SizedBox(height: 24.0),
                    // const SizedBox(height: 20.0),
                  ],
                ),
              ))
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 300.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.cyan,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        textData = scanData?.code != null ? scanData.code : "";
      });

      timer?.cancel();
      timer = new Timer(new Duration(seconds: 5), () {
        setState(() {
          textData = "";
        });
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
