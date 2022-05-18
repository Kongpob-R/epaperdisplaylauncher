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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              SizedBox(
                width: 450,
                height: 450,
                child: Image.asset("assets/images/Logo_EE.gif"),
              ),
            ],
          ),
        ),
        const Text(
          "This e-book reader belongs to Department of Electrical and \nComputer Engineering, Faculty of Engineering",
          textAlign: TextAlign.center,
          textScaleFactor: 1.2,
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
