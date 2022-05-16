import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CloudDownloadPage extends StatefulWidget {
  final String androidId;
  const CloudDownloadPage({Key? key, required this.androidId})
      : super(key: key);

  @override
  State<CloudDownloadPage> createState() => _CloudDownloadPageState();
}

class _CloudDownloadPageState extends State<CloudDownloadPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        BarcodeWidget(
          barcode: Barcode.qrCode(
            errorCorrectLevel: BarcodeQRCorrectionLevel.high,
          ),
          data: '${dotenv.env['HOST_LOGIN']}${widget.androidId}',
          width: 200,
          height: 200,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 24),
          child: Text(
            'Please scan QR code to download more e-books! All resources are provided by KMUTNB Central Library.',
            textScaleFactor: 1.5,
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(
          width: 100,
          height: 100,
          child: Image.asset("assets/images/Logo_lib_2016.png"),
        ),
      ],
    );
  }
}
