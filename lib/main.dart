import 'dart:developer';
import 'dart:io';

import 'package:epaperdisplaylauncher/cloud_download_page.dart';
import 'package:epaperdisplaylauncher/home_page.dart';
import 'package:epaperdisplaylauncher/library_page.dart';
import 'package:epaperdisplaylauncher/pre_download_controller.dart';
import 'package:epaperdisplaylauncher/setting_page.dart';
import 'download_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'custom_icon.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'dart:async';
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
  late WebSocketChannel _channel;
  String _newBook = '';
  String _androidId = '';
  String _shortName = '';
  String _availability = '';
  bool _preDownloadReqCooldown = false;
  late Timer _timer;
  late int _timeCounter;
  List<dynamic> _preDownloadList = [];

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

  void downloadRes(
    WebSocketChannel channel,
    bool isShowDialog,
    String title,
    String url,
    String isbn,
    String username,
    String token,
  ) async {
    var res = {
      'event': 'download_res',
      'ereaderuid': _androidId,
      'username': username,
      'title': title,
    };
    isShowDialog ? showDownloadDialog(title.toString(), 'start') : false;
    channel.sink.add(jsonEncode(res));
    log('Downloaded: ' + await downloadFile(title, url, isbn, username, token));
    isShowDialog ? showDownloadDialog(title.toString(), 'finish') : false;
  }

  void showDownloadDialog(String bookName, String action) {
    showDialog(
        context: navigatorKey.currentContext!,
        builder: (context) => action == 'finish'
            ? AlertDialog(
                shape: Border.all(
                  color: Colors.black,
                ),
                title: Text(bookName),
                content: const Text('Download Complete'),
                actions: <Widget>[
                  TextButton(
                    style: ButtonStyle(
                      side: MaterialStateProperty.all(
                          const BorderSide(width: 1, color: Colors.black)),
                      foregroundColor: MaterialStateProperty.all(Colors.black),
                      padding: MaterialStateProperty.all(
                          const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 40)),
                      textStyle: MaterialStateProperty.all(
                          const TextStyle(fontSize: 20)),
                    ),
                    onPressed: () {
                      Navigator.pop(context, 'Launch library');
                      _myPage.jumpToPage(1);
                      setState(() {
                        _selectedIndex = 1;
                        _newBook = 'found';
                      });
                    },
                    child: const Text('Launch library'),
                  ),
                ],
                actionsAlignment: MainAxisAlignment.center,
              )
            : SimpleDialog(
                shape: Border.all(
                  color: Colors.black,
                ),
                title: Text(bookName),
                contentPadding: const EdgeInsets.all(8),
                children: const <Widget>[Text('Downloading')],
              ));
  }

  void wserror(err) async {
    log(DateTime.now().toString() + " Connection error: $err");
    setState(() {
      _shortName = '';
    });
    reconnect();
  }

  void reconnect() async {
    await Future.delayed(const Duration(seconds: 4));
    setState(() {
      log(DateTime.now().toString() + " Starting connection attempt...");
      _channel = WebSocketChannel.connect(
        Uri.parse(dotenv.env['HOST'].toString()),
      );
      log(DateTime.now().toString() + " Connection attempt completed.");
    });
    _channel.stream.listen(
      (data) {
        data = jsonDecode(data);
        log('from stream: ' + data.toString());
        switch (data['event']) {
          case 'status_req':
            statusRes(_channel);
            break;
          case 'download':
            downloadRes(
              _channel,
              true,
              data['title'],
              data['url'],
              data['isbn'],
              data['user'],
              data['token'],
            );
            break;
          case 'short_name_res':
            setState(() {
              _shortName = data[_androidId];
              log(_shortName);
            });
            break;
          case 'pre_download_res':
            setState(() {
              _preDownloadList = data['pre_download_list'];
            });
            List bookToDownloads = resetToDefault(_preDownloadList);
            for (var book in bookToDownloads) {
              log(book.toString());
              downloadRes(
                _channel,
                false,
                book['title']!,
                book['url']!,
                book['isbn'] ?? '',
                data['user'] ?? 'adminEreader',
                data['token'] ?? dotenv.env['TOKEN'].toString(),
              );
            }
            break;
          default:
        }
      },
      onDone: reconnect,
      onError: wserror,
      cancelOnError: true,
    );
    _channel.sink.add(json.encode({'event': 'short_name_req'}));
    // _channel.sink.add(json.encode({'event': 'pre_download_req'}));
  }

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    WidgetsBinding.instance?.addObserver(this);
    super.initState();
    reconnect();
    initPlatformState();
    _myPage = PageController(
      initialPage: 0,
    );
    _selectedIndex = 0;
    _battery.onBatteryStateChanged.listen((BatteryState state) {
      log('$state');
      String previousState = _availability;
      setState(() {
        switch ('$state') {
          case 'BatteryState.charging':
            _availability = 'Available';
            break;
          case 'BatteryState.full':
            _availability = 'Available';
            break;
          default:
            _availability = 'In use';
            break;
        }
      });
      statusRes(_channel);
      if (previousState == 'In use' &&
          _availability == 'Available' &&
          _preDownloadReqCooldown == false) {
        _channel.sink.add(json.encode({'event': 'pre_download_req'}));
        log('emit pre_download_req');
        startTimer(5);
      }
    });
  }

  void startTimer(int start) {
    const oneSec = Duration(seconds: 1);
    setState(() {
      _timeCounter = start;
      _preDownloadReqCooldown = true;
    });
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_timeCounter == 0) {
          setState(() {
            timer.cancel();
            _preDownloadReqCooldown = false;
          });
        } else {
          setState(() {
            _timeCounter--;
          });
        }
      },
    );
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
            Center(child: LibraryPage(newBook: _newBook)),
            Center(child: CloudDownloadPage(shortName: _shortName)),
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
}
