import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:io';
import 'dart:async';
import 'package:qr_scanner/ui/widgets/scan_result_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_scanner/ui/widgets/update_privacy_widget.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class CameraScannerScreen extends StatefulWidget {
  const CameraScannerScreen({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CameraScannerScreenState();
}

class _CameraScannerScreenState extends State<CameraScannerScreen>
    with WidgetsBindingObserver, RouteAware {
  String data = "";
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void didPush() {
    print("did push");
    // Route was pushed onto navigator and is now topmost route.
  }

  @override
  void didPopNext() {
    print("did pop next");
    print(ModalRoute.of(context).isCurrent);
    print("resume camera");
    controller.resumeCamera();
    setState(() {});
    // Covering route was popped off the navigator.
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    print('state = $state');
    if (state == AppLifecycleState.paused) {
      await controller.pauseCamera();
    }
    if (state == AppLifecycleState.resumed &&
        ModalRoute.of(context).isCurrent) {
      print("resume camera");
      await controller.resumeCamera();
      setState(() {});
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
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
              child: Stack(
            children: [
              _qrScannerWidget(context),
              Positioned(
                child: IconButton(
                  icon: _flashIconWidget(context),
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
                      Icon(Icons.insert_photo, color: Colors.white70, size: 34),
                  tooltip: 'Album',
                  onPressed: _navigateToPhotoScreen,
                ),
                top: 60.0,
                right: 10.0,
              )
            ],
          )),
          _informationPanel()
        ],
      ),
    );
  }

  Widget _flashIconWidget(BuildContext context) {
    Future<bool> _future = controller?.getFlashStatus();
    _future?.catchError((err) {
      // do something with err
      print('_flashIconWidget: $err');
    });

    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        return Icon(snapshot?.data == true ? Icons.flash_on : Icons.flash_off,
            color: Colors.white70, size: 30);
      },
    );
  }

  Widget _informationPanel() {
    Future<bool> _future = Permission.camera.request().isGranted;
    _future?.catchError((err) {
      // do something with err
      print('_informationPanel: $err');
    });

    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot?.data == true) {
          return ScanResultWidget(data: data);
        } else {
          return UpdatePrivacyWidget(
              data: "You have not granted camera permissions to this app.");
        }
      },
    );
  }

  Widget _qrScannerWidget(BuildContext context) {
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

  void _onQRViewCreated(QRViewController _controller) {
    setState(() {
      controller = _controller;
    });
    _controller.scannedDataStream.listen((scanData) {
      print('discovered data ${scanData?.code}');
      setState(() {
        data = scanData?.code != null ? scanData.code : "";
      });

      timer?.cancel();
      timer = new Timer(new Duration(seconds: 1), () {
        print('Reset data');
        setState(() {
          data = "";
        });
      });
    });
  }

  void _navigateToPhotoScreen() async {
    PermissionStatus permissionStatus = await Permission.photos.request();
    if (permissionStatus.isGranted || permissionStatus.isLimited) {
      print("access to photo status: $permissionStatus");

      print("pause camera");
      await controller.pauseCamera();
      Navigator.pushNamed(context, "/photo");
    } else {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text("Access to Photo required"),
          content:
              Text("This app needs to access photos to scan a QR code from it"),
          actions: [
            CupertinoButton(
                child: Text("Cancel"),
                onPressed: () => Navigator.of(context).pop()),
            CupertinoButton(
                child: Text("Setting"),
                onPressed: () {
                  openAppSettings();
                }),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    controller?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
