import 'package:epaperdisplaylauncher/cloud_download_page.dart';
import 'package:epaperdisplaylauncher/home_page.dart';
import 'package:epaperdisplaylauncher/library_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'custom_icon.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Home Page'),
    );
  }
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

class _MyHomePageState extends State<MyHomePage> {
  late int _selectedIndex;
  late PageController _myPage;

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top],
    );
    super.initState();
    _myPage = PageController(
      initialPage: 0,
    );
    _selectedIndex = 0;
  }

  @override
  void dispose() {
    super.dispose();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _myPage,
        children: const <Widget>[
          Center(child: HomePage()),
          Center(child: LibraryPage()),
          Center(child: CloudDownloadPage()),
          Center(child: HomePage()),
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
    );
  }
}
