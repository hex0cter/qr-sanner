import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:clipboard/clipboard.dart';

class QRViewWidget extends StatefulWidget {

  const QRViewWidget({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewWidgetState();
}

class _QRViewWidgetState extends State<QRViewWidget> with WidgetsBindingObserver {
  Barcode result;
  QRViewController controller;
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
    if(state == AppLifecycleState.resumed) {
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

    // double c_width = MediaQuery.of(context).size.width;
    String text = result?.code == null ? "Please scan a code ..." : result.code;
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(flex: 5, child: _buildQrView(context)),
          Expanded(child: Column(
            children: [
              FittedBox(
                fit: BoxFit.contain,
                child: Container (
                  padding: const EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0, bottom: 0.0),
                  width: MediaQuery.of(context).size.width,
                  child: Text(text.length > 120 ? '${text.substring(0, 117)}...' : text.padLeft(120),
                      textAlign: TextAlign.left,
                    style: TextStyle(fontFamily: "Arial Rounded", fontWeight: FontWeight.normal),
                  )
                ),
              ),
              result?.code != null ? ElevatedButton(
                onPressed: () async {
                    FlutterClipboard.copy(result.code);
                    setState(() {});
                },
                child: Text('Copy'),
              ) : SizedBox(height: 24.0),
              // const SizedBox(height: 20.0),
            ],
          ))

          // Spacer(),
          // Expanded(
          //   flex: 1,
          //   child: FittedBox(
          //     fit: BoxFit.contain,
          //     child: Column(
          //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //       children: <Widget>[
          //         if (result?.code != null)
          //           Text(result.code)
          //         else
          //           Text('Please Scan a code...')
          //       ],
          //     ),
          //   ),
          // ),
          // Expanded(
          //     flex: 1,
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       crossAxisAlignment: CrossAxisAlignment.center,
          //       children: <Widget>[
          //         Container(
          //           margin: EdgeInsets.all(8),
          //           child: TextButton(
          //               onPressed: () async {
          //                 await controller?.toggleFlash();
          //                 setState(() {});
          //               },
          //               child: FutureBuilder(
          //                 future: _future,
          //                 builder: (context, snapshot) {
          //                   return snapshot.data == null ? Text("Unknown") : snapshot.data ? Text("On") : Text("Off");
          //                 },
          //               )),
          //         ),
          //         Container(
          //             margin: EdgeInsets.all(8),
          //             child: TextButton(
          //               onPressed: () async {
          //                 if (result != null) {
          //                   FlutterClipboard.copy(result.code);
          //                 }
          //                 setState(() {});
          //               },
          //               child: Text("Copy"),
          //             )
          //         )
          //       ],
          //     ),
          // ),
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
        result = scanData;
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