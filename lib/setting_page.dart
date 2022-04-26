import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  late final List settings;

  @override
  void initState() {
    super.initState();
    settings = [
      'WiFi connection',
      'Date and time',
      'Display',
      'About this device',
    ];
  }

  void launchPage(String page) {
    switch (page) {
      case 'WiFi connection':
        const intent = AndroidIntent(
          action: 'onyx.settings.action.wifi',
        );
        intent.launch();
        break;
      case 'Date and time':
        const intent = AndroidIntent(
          action: 'onyx.settings.action.datetime',
        );
        intent.launch();
        break;
      case 'Display':
        const intent = AndroidIntent(
          action: 'android.settings.DISPLAY_SETTINGS',
        );
        intent.launch();
        break;
      case 'Test':
        const intent = AndroidIntent(
          action: 'android.intent.action.MAIN',
          package: 'com.onyx.android.onyxotaservice',
          flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
        );
        intent.launch();
        break;
      default:
    }
    // Navigator.push(
    //   context,
    //   PageRouteBuilder(
    //     pageBuilder: (context, animation1, animation2) => const Scaffold(
    //       body: Center(child: Text("hi")),
    //     ),
    //     transitionDuration: Duration.zero,
    //     reverseTransitionDuration: Duration.zero,
    //   ),
    // );
    // const intent = AndroidIntent(
    //   action: 'onyx_epdc_update_to_display()',
    // );
    // intent.sendBroadcast();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 30),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(width: 1),
              ),
            ),
            child: const Text(
              'Setting',
              textScaleFactor: 3,
            ),
          ),
          Expanded(
            child: ScrollablePositionedList.builder(
              itemCount: settings.length,
              itemScrollController: itemScrollController,
              itemPositionsListener: itemPositionsListener,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    launchPage(settings[index]);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 30,
                    ),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(width: 1)),
                    ),
                    child: Text(
                      settings[index],
                      textScaleFactor: 2,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
