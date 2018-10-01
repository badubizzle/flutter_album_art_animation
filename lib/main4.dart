import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Album Art Screen Saver',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Flutter Animations'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  Animation<double> animation;
  AnimationController controller;

  Offset _offset = Offset.zero; // changed
  Color _backgroundColor = Colors.teal;
  Color _swapColor;

  bool _swapped = false;

  static const TOTAL_CELLS = 21;
  static const ITEM_PADDING = 0.3;

  List<Color> _colors = [];

  List<Color> _availableColors = [];

  int _selectedIndex = -1;

  Color _randomColor() {
    var random = math.Random();

    int r = random.nextInt(200);
    int g = random.nextInt(200);
    int b = random.nextInt(200);

    return Color.fromRGBO(r, g, b, 1.0);
  }

  @override
  void initState() {
    super.initState();

    //set initial offset
    _offset = Offset(0.0, 0.0);

    _colors = List.generate(TOTAL_CELLS, (i) => _randomColor());

    _availableColors = List.generate(20, (_) => _randomColor());

    controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    animation = Tween(begin: 0.0, end: 180.0).animate(controller)
      ..addListener(() {
        if (controller.isCompleted) {
          setState(() {
            var rad = (math.pi / 180.0) * animation.value;
            _offset = Offset(_offset.dx, rad);
            _swapped = false;
            _colors[_selectedIndex] = _backgroundColor;
          });
        } else {
          setState(() {
            var rad = (math.pi / 180.0) * animation.value;

            Color temp = _backgroundColor;

            if (rad >= (math.pi / 2) && !_swapped) {
              _swapped = true;
              _backgroundColor = _swapColor;
              _swapColor = temp;
            }
            _offset = Offset(_offset.dx, rad);
          });
        }
      });

    Timer.periodic(new Duration(seconds: 3), (t) {
      var r = new math.Random();
      int index = r.nextInt(TOTAL_CELLS);

      Color c = _availableColors[r.nextInt(_availableColors.length)];

      setState(() {
        _selectedIndex = index;
        _backgroundColor = _colors[index];
        _swapColor = c;
      });

      controller.forward(from: 0.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    var gridView = new GridView.builder(
        itemCount: TOTAL_CELLS,
        gridDelegate:
            new SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
        itemBuilder: (BuildContext context, int index) {
          if (index == _selectedIndex) {
            return _getFlipWidget();
          } else {
            return new Padding(
              padding: const EdgeInsets.all(ITEM_PADDING),
              child: new Container(
                height: 200.0,
                width: 200.0,
                color: _colors[index],
                alignment: Alignment.center,
              ),
            );
          }
        });

    if (1 == 1) {
      return Scaffold(body: Container(color: Colors.black, child: gridView));
    }
  }

  dispose() {
    controller?.dispose();
    super.dispose();
  }

  Widget _getFlipWidget() {
    return Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(_offset.dx)
          ..rotateY(_offset.dy),
        alignment: FractionalOffset.center,
        child: Padding(
          padding: const EdgeInsets.all(ITEM_PADDING),
          child: Container(
            height: 200.0,
            width: 200.0,
            color: _backgroundColor,
          ),
        ));
  }
}
