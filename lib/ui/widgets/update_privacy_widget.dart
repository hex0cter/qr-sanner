import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'information_widget.dart';

class UpdatePrivacyWidget extends StatelessWidget {
  final String data;

  UpdatePrivacyWidget({this.data});

  @override
  Widget build(BuildContext context) {
    return InformationWidget(
      data: data,
      button: CupertinoButton(
        onPressed: () async {
          openAppSettings();
        },
        child: Text('Settings...'),
      )
    );
  }
}
