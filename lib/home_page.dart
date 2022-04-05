import 'package:flutter/material.dart';
import 'package:device_apps/device_apps.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Application> apps = [];

  void getApp() async {
    apps = await DeviceApps.getInstalledApplications(
      includeAppIcons: true,
      includeSystemApps: true,
      onlyAppsWithLaunchIntent: false,
    );
  }

  @override
  void initState() {
    getApp();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: apps.length,
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTap: () => DeviceApps.openApp(apps[index].packageName),
          child: SizedBox(
            height: 50,
            child: Column(
              children: <Widget>[
                Center(child: Text('Entry ${apps[index].appName}')),
                Center(child: Text('packageName ${apps[index].packageName}')),
              ],
            ),
          ),
        );
      },
    );
  }
}
