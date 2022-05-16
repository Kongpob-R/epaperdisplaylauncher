import 'dart:developer';
import 'dart:io';

import 'package:epaperdisplaylauncher/cloud_download_page.dart';
import 'package:epaperdisplaylauncher/home_page.dart';
import 'package:epaperdisplaylauncher/library_page.dart';
import 'package:epaperdisplaylauncher/setting_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'custom_icon.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'dart:async';
import 'package:html/parser.dart' as html;
import 'package:html/dom.dart' as html;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:battery_plus/battery_plus.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  await dotenv.load(fileName: '.env');
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyHomePage(
    title: '',
  ));
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  final navigatorKey = GlobalKey<NavigatorState>();
  late int _selectedIndex;
  late PageController _myPage;
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  final Battery _battery = Battery();
  final _channel = WebSocketChannel.connect(
    Uri.parse(dotenv.env['HOST'].toString()),
  );
  String _androidId = '';
  String _availability = '';
  String targetPath = '/storage/emulated/0/Books';

  Future<void> initPlatformState() async {
    final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    if (!mounted) return;

    setState(() {
      _androidId = androidInfo.id.toString();
      log(_androidId);
    });
  }

  void statusRes(WebSocketChannel channel) async {
    var deviceStatus = {
      'event': 'status_res',
      'ereaderuid': _androidId,
      'availability': _availability,
      'connection': 'Online',
      'battery': ((await _battery.batteryLevel).toString()) + '%',
    };
    channel.sink.add(jsonEncode(deviceStatus));
  }

  void downloadRes(WebSocketChannel channel, String url) async {
    var res = {
      'event': 'download_res',
      'ereaderuid': _androidId,
      'url': url,
    };
    channel.sink.add(jsonEncode(res));
    log(await downloadFile(url, targetPath));
    // showDownloadResDialog();
  }

  void showDownloadResDialog() {
    showDialog(
      context: navigatorKey.currentContext!,
      builder: (context) => AlertDialog(
        shape: Border.all(
          color: Colors.black,
        ),
        title: const Text('Book Name'),
        content: const Text('Download Complete'),
        actions: <Widget>[
          TextButton(
            style: ButtonStyle(
              side: MaterialStateProperty.all(
                  const BorderSide(width: 1, color: Colors.black)),
              foregroundColor: MaterialStateProperty.all(Colors.black),
              padding: MaterialStateProperty.all(
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 40)),
              textStyle:
                  MaterialStateProperty.all(const TextStyle(fontSize: 20)),
            ),
            onPressed: () {
              Navigator.pop(context, 'Launch library');
              _myPage.jumpToPage(1);
              setState(() {
                _selectedIndex = 1;
              });
            },
            child: const Text('Launch library'),
          ),
        ],
        actionsAlignment: MainAxisAlignment.center,
      ),
    );
  }

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    WidgetsBinding.instance?.addObserver(this);
    super.initState();
    initPlatformState();
    _myPage = PageController(
      initialPage: 0,
    );
    _selectedIndex = 0;

    _channel.stream.listen(
      (data) {
        data = jsonDecode(data);
        log('from stream: ' + data.toString());
        switch (data['event']) {
          case 'status_req':
            statusRes(_channel);
            break;
          case 'download':
            downloadRes(_channel, data['url']);
            break;
          default:
        }
      },
      onError: (error) => log(error.toString()),
    );

    _battery.onBatteryStateChanged.listen((BatteryState state) {
      setState(() {
        switch (state.toString()) {
          case 'discharging':
            _availability = 'In use';
            break;
          default:
            _availability = 'Available';
            break;
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance?.removeObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.inactive:
        log('appLifeCycleState inactive');
        break;
      case AppLifecycleState.resumed:
        log('appLifeCycleState resumed');
        break;
      case AppLifecycleState.paused:
        log('appLifeCycleState paused');
        break;
      case AppLifecycleState.detached:
        log('appLifeCycleState detached');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    log('build MyhomePage');
    return MaterialApp(
      navigatorKey: navigatorKey,
      home: Scaffold(
        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _myPage,
          children: <Widget>[
            const Center(child: HomePage()),
            const Center(child: LibraryPage()),
            Center(child: CloudDownloadPage(androidId: _androidId)),
            const Center(child: SettingPage()),
          ],
        ),
        bottomNavigationBar: Container(
          height: 60,
          padding: EdgeInsets.zero,
          decoration: const BoxDecoration(
              border: Border(top: BorderSide(width: 1, color: Colors.black))),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              customIcon(
                0,
                _selectedIndex,
                const Icon(
                  Icons.home,
                  color: Colors.black,
                ),
                'Home',
                () {
                  _myPage.jumpToPage(0);
                  setState(() {
                    _selectedIndex = 0;
                  });
                },
              ),
              customIcon(
                1,
                _selectedIndex,
                const Icon(
                  Icons.collections_bookmark,
                  color: Colors.black,
                ),
                'Library',
                () {
                  _myPage.jumpToPage(1);
                  setState(() {
                    _selectedIndex = 1;
                  });
                },
              ),
              customIcon(
                2,
                _selectedIndex,
                const Icon(
                  Icons.cloud_download,
                  color: Colors.black,
                ),
                'Cloud Download',
                () {
                  _myPage.jumpToPage(2);
                  setState(() {
                    _selectedIndex = 2;
                  });
                },
              ),
              customIcon(
                3,
                _selectedIndex,
                const Icon(
                  Icons.settings,
                  color: Colors.black,
                ),
                'Setting',
                () {
                  _myPage.jumpToPage(3);
                  setState(() {
                    _selectedIndex = 3;
                  });
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<String> downloadFile(String url, String dir) async {
    String proxyHost = dotenv.env['PROXY_HOST'].toString();
    int proxyPort = int.parse(dotenv.env['PROXY_PORT'].toString());
    String proxyUser = dotenv.env['PROXY_USER'].toString();
    String proxyPassword = dotenv.env['PROXY_PASSWORD'].toString();
    HttpClient httpClient = HttpClient();
    File file;
    String filePath = '';
    String fullUrl = '';
    List<String> splitedHostUrl = url.split('/');
    splitedHostUrl.removeLast();
    String hostUrl = splitedHostUrl.join('/');
    String fileName = url.split('/').last;

    try {
      fullUrl = hostUrl + '/' + fileName;
      if (proxyHost.isNotEmpty) {
        httpClient.addProxyCredentials(proxyHost, proxyPort, '',
            HttpClientBasicCredentials(proxyUser, proxyPassword));
        // httpClient.findProxy = (url) {
        //   return HttpClient.findProxyFromEnvironment(url, environment: {
        //     "http_proxy": "$proxyUser:$proxyPassword@$proxyHost:$proxyPort"
        //   });
        // };
      }

      var request = await httpClient.getUrl(Uri.parse(fullUrl));
      var response = await request.close();
      var document = html.parse(await readResponse(response));
      html.Element redirect =
          document.querySelector('meta[HTTP-EQUIV="Refresh"]')!;
      String bookDownloaderUrl = redirect.attributes['content'].toString();
      bookDownloaderUrl = bookDownloaderUrl.substring(8);
      bookDownloaderUrl = 'http' + bookDownloaderUrl.substring(5);
      log(bookDownloaderUrl);

      request = await httpClient.getUrl(Uri.parse(bookDownloaderUrl));
      response = await request.close();
      document = html.parse(await readResponse(response));
      List<html.Element> formInputs = document.querySelectorAll('input');
      List<Map<String, dynamic>> formMap = [];
      for (var parameter in formInputs) {
        formMap.add({
          'name': parameter.attributes['name'],
          'value': parameter.attributes['value']
        });
      }
      log(formMap.toString());

      // Download=Open+from+Central+Library
      // &bibid=B15376187
      // &num_access=
      // &fname=%2Febook%2FB15376187.pdf
      // &id_code=%2Febook%2FB15376187.pdf
      // &porpose=0
      // &other=
      // &xserver= http%3A%2F%2Flibrary.kmutnb.ac.th%2F
      // &option=com_search

      // if (response.statusCode == 200) {
      //   var bytes = await consolidateHttpClientResponseBytes(response);
      //   filePath = '$dir/$fileName';
      //   file = File(filePath);
      //   await file.writeAsBytes(bytes);
      // } else {
      //   filePath = 'Error code: ' + response.statusCode.toString();
      // }
    } catch (ex) {
      filePath = ex.toString() + ' // Can not fetch url';
    }

    return filePath;
  }

  Future<String> readResponse(HttpClientResponse response) {
    final completer = Completer<String>();
    final contents = StringBuffer();
    response.transform(utf8.decoder).listen((data) {
      contents.write(data);
      log(data);
    }, onDone: () => completer.complete(contents.toString()));
    return completer.future;
  }
}
