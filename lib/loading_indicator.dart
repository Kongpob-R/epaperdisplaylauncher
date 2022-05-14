import 'package:flutter/material.dart';

class LoadingIndicator extends StatefulWidget {
  const LoadingIndicator({Key? key}) : super(key: key);

  @override
  State<LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        children: const <Widget>[
          BlinkWidget(
            children: <Widget>[
              Icon(Icons.square),
              Icon(Icons.crop_square),
            ],
            interval: 1200,
            offset: 0,
          ),
          BlinkWidget(
            children: <Widget>[
              Icon(Icons.square),
              Icon(Icons.crop_square),
            ],
            interval: 1200,
            offset: 400,
          ),
          BlinkWidget(
            children: <Widget>[
              Icon(Icons.square),
              Icon(Icons.crop_square),
            ],
            interval: 1200,
            offset: 800,
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
      ),
    );
  }
}

class BlinkWidget extends StatefulWidget {
  final List<Widget> children;
  final int interval;
  final int offset;

  const BlinkWidget(
      {Key? key,
      required this.children,
      required this.interval,
      required this.offset})
      : super(key: key);

  @override
  _BlinkWidgetState createState() => _BlinkWidgetState();
}

class _BlinkWidgetState extends State<BlinkWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentWidget = 0;

  @override
  initState() {
    super.initState();

    _controller = AnimationController(
        duration: Duration(milliseconds: widget.interval), vsync: this);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          if (++_currentWidget == widget.children.length) {
            _currentWidget = 0;
          }
        });

        _controller.forward(from: 0.0);
      }
    });
    Future.delayed(
        Duration(milliseconds: widget.offset), () => _controller.forward());
  }

  @override
  dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: widget.children[_currentWidget],
    );
  }
}
