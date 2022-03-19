import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class CloudDownloadPage extends StatefulWidget {
  const CloudDownloadPage({Key? key}) : super(key: key);

  @override
  State<CloudDownloadPage> createState() => _CloudDownloadPageState();
}

class _CloudDownloadPageState extends State<CloudDownloadPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        QrImage(
          data: "1234567890",
          version: QrVersions.auto,
          size: 200.0,
        ),
        const Padding(
          padding: EdgeInsets.all(12.0),
          child: Text(
            'Please scan QR code to download more books from KMUTNB library',
            textScaleFactor: 2.5,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
