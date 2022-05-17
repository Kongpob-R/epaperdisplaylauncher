import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<String> downloadFile(
  String url,
  String username,
  String token,
  String dir,
) async {
  String proxyHost = dotenv.env['PROXY_HOST'].toString();
  int proxyPort = int.parse(dotenv.env['PROXY_PORT'].toString());
  String proxyUser = dotenv.env['PROXY_USER'].toString();
  String proxyPassword = dotenv.env['PROXY_PASSWORD'].toString();
  HttpClient httpClient = HttpClient();
  File file;
  String filePath = '';
  String fullUrl = '';
  String hostUrl = dotenv.env['HOST_DOWNLOAD'].toString();
  String fileName = url.split('/').last;
  String fileLocation = url.split('name=').last;

  try {
    fullUrl = hostUrl +
        'name=' +
        fileLocation +
        '&user=' +
        username +
        '&token=' +
        token;
    if (proxyHost.isNotEmpty) {
      httpClient.addProxyCredentials(proxyHost, proxyPort, '',
          HttpClientBasicCredentials(proxyUser, proxyPassword));
      // httpClient.findProxy = (url) {
      //   return HttpClient.findProxyFromEnvironment(url, environment: {
      //     "http_proxy": "$proxyUser:$proxyPassword@$proxyHost:$proxyPort"
      //   });
      // };
    }

    log('request: ' + fullUrl);
    var request = await httpClient.getUrl(Uri.parse(fullUrl));
    var response = await request.close();
    if (response.statusCode == 200) {
      var bytes = await consolidateHttpClientResponseBytes(response);
      filePath = '$dir/$fileName';
      file = File(filePath);
      await file.writeAsBytes(bytes);
    } else {
      filePath = 'Error code: ' + response.statusCode.toString();
    }
  } catch (ex) {
    filePath = ex.toString() + ' // Can not fetch url';
  }

  return filePath;
}
