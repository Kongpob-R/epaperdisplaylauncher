import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CloudDownloadPage extends StatefulWidget {
  final String shortName;
  const CloudDownloadPage({Key? key, required this.shortName})
      : super(key: key);

  @override
  State<CloudDownloadPage> createState() => _CloudDownloadPageState();
}

class _CloudDownloadPageState extends State<CloudDownloadPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Stack(
            children: <Widget>[
              BarcodeWidget(
                barcode: Barcode.qrCode(
                  errorCorrectLevel: BarcodeQRCorrectionLevel.high,
                ),
                data: '${dotenv.env['HOST_LOGIN']}${widget.shortName}',
                width: 200,
                height: 200,
              ),
              widget.shortName == ''
                  ? Container(
                      decoration: BoxDecoration(
                        border: Border.all(width: 1),
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 64, vertical: 32),
                      child: const Text(
                        'Please Connect to Wi-fi',
                        textScaleFactor: 1.5,
                      ),
                    )
                  : Container(),
            ],
            alignment: Alignment.center,
          ),
          widget.shortName == ''
              ? const Text(
                  '',
                  textScaleFactor: 1.2,
                )
              : Text(
                  '${dotenv.env['HOST_LOGIN']}${widget.shortName}',
                  textScaleFactor: 1.2,
                ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
            child: Column(
              children: [
                const Text(
                  'Please scan QR code to download more e-books! All resources are provided by KMUTNB Central Library.',
                  textScaleFactor: 1.5,
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  width: 150,
                  height: 150,
                  child: Image.asset("assets/images/Logo_lib_2016.png"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
