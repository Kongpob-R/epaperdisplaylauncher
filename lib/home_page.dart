import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  //  assets/images/Logo_central_library.jpg
  //  assets/images/Logo_EE.gif
  //  assets/images/Logo_ENG_small.png
  //  assets/images/Logo_icit_account.png
  //  assets/images/Logo_kmutnb.png
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            SizedBox(
              width: 150,
              height: 150,
              child: Image.asset("assets/images/Logo_kmutnb.png"),
            ),
            SizedBox(
              width: 150,
              height: 150,
              child: Image.asset("assets/images/Logo_ENG_small.png"),
            ),
            SizedBox(
              width: 150,
              height: 150,
              child: Image.asset("assets/images/Logo_EE.gif"),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 32.0, 0, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              SizedBox(
                width: 150,
                height: 150,
                child: Image.asset("assets/images/Logo_central_library.jpg"),
              ),
              SizedBox(
                width: 150,
                height: 150,
                child: Image.asset("assets/images/Logo_icit_account.png"),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(4, 128, 4, 4),
          child: Text(
            "This e-book reader belongs to Faculty of Engineering",
            textAlign: TextAlign.center,
            textScaleFactor: 1.2,
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(4, 4, 4, 32),
          child: Text(
            " King Mongkut's University of Technology North Bangkok ",
            textAlign: TextAlign.center,
            textScaleFactor: 1.2,
          ),
        ),
      ],
    );
  }
}
