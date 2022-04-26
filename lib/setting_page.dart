import 'package:flutter/material.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({Key? key}) : super(key: key);

  void launchPage(BuildContext context) {
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
    //   action: 'action_application_details_settings',
    //   data: 'package:com.happysoft.epaperdisplaylauncher',
    // );
    // intent.launch();
    // const intent = AndroidIntent(
    //   action: 'onyx_epdc_update_to_display()',
    // );
    // intent.sendBroadcast();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ElevatedButton(
            onPressed: () {
              launchPage(context);
            },
            child: const Text('push'),
          ),
          const Center(
            child: Text('this is setting page'),
          ),
        ],
      ),
    );
  }
}
