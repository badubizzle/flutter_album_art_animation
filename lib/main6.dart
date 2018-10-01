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
  String _backgroundImage;
  String _swapImage;

  bool _swapped = false;

  static const TOTAL_CELLS = 21;
  static const ITEM_PADDING = 0.15;

  static const TOTAL_IMAGES = 29;

  List<String> _images = [];

  List<String> _availableImages = [];

  int _selectedIndex = -1;

  @override
  void initState() {
    super.initState();

    //set initial offset
    _offset = Offset(0.0, 0.0);

    _availableImages = List.generate(TOTAL_IMAGES, (i) {
      return "assets/images/${i + 1}.jpg";
    }).toList();

    var r = math.Random();
    _images = List.generate(TOTAL_CELLS, (_) {
      return _availableImages[r.nextInt(_availableImages.length)];
    });

    controller = AnimationController(
        duration: const Duration(milliseconds: 900), vsync: this);
    animation = Tween(begin: 0.0, end: 180.0).animate(controller)
      ..addListener(() {
        if (controller.isCompleted) {
          setState(() {
            var rad = (math.pi / 180.0) * animation.value;
            _offset = Offset(_offset.dx, rad);
            _swapped = false;
            _images[_selectedIndex] = _backgroundImage;
          });
        } else {
          setState(() {
            var rad = (math.pi / 180.0) * animation.value;

            String temp = _backgroundImage;

            if (rad >= (math.pi / 2) && !_swapped) {
              _swapped = true;
              _backgroundImage = _swapImage;
              _swapImage = temp;
            }
            _offset = Offset(_offset.dx, rad);
          });
        }
      });

    Timer.periodic(new Duration(seconds: 2), (t) {
      var r = new math.Random();
      int index = r.nextInt(TOTAL_CELLS);

      String randomImage = _availableImages[r.nextInt(_availableImages.length)];

      setState(() {
        _selectedIndex = index;
        _backgroundImage = _images[index];
        _swapImage = randomImage;
      });

      controller.forward(from: 0.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    var gridView = new GridView.builder(
        itemCount: TOTAL_CELLS,
        gridDelegate: new SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 150.0),
        itemBuilder: (BuildContext context, int index) {
          if (index == _selectedIndex) {
            return _getFlipWidget();
          } else {
            return new Padding(
              padding: const EdgeInsets.all(ITEM_PADDING),
              child: new Container(
                //height: 200.0,
                //width: 200.0,
                child: Image.asset(_images[index], fit: BoxFit.cover),
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
        ..rotateX(0.01 * _offset.dx)
        ..rotateY(-0.01 * _offset.dy),
      alignment: FractionalOffset.center,
      child: Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(_offset.dx)
            ..rotateY(_offset.dy),
          alignment: FractionalOffset.center,
          child: Padding(
            padding: const EdgeInsets.all(ITEM_PADDING),
            child: Container(
              //height: 200.0,
              //width: 200.0,
              //color: _backgroundColor,
              child: Image.asset(
                _backgroundImage,
                fit: BoxFit.cover,
              ),
            ),
          )),
    );
  }
}
