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
  bool _swapped = false;

  static const TOTAL_CELLS = 21;
  static const ITEM_PADDING = 0.3;

  int _selectedIndex = -1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _offset = Offset(0.0, 0.0);

    controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    animation = Tween(begin: 0.0, end: 180.0).animate(controller)
      ..addListener(() {
        if (controller.isCompleted) {
          setState(() {
            var rad = (math.pi / 180.0) * animation.value;
            _offset = Offset(_offset.dx, rad);
            _swapped = false;
          });
        } else {
          setState(() {
            var rad = (math.pi / 180.0) * animation.value;
            if (rad >= (math.pi / 2) && !_swapped) {
              _swapped = true;
              if (_backgroundColor == Colors.teal) {
                _backgroundColor = Colors.deepOrange;
              } else {
                _backgroundColor = Colors.teal;
              }
            }
            _offset = Offset(_offset.dx, rad);
          });
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    var c = new Container(
        alignment: Alignment.center,
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text("${_offset}"),
            SizedBox(
              height: 20.0,
            ),
            FlatButton(
              child: Text("Run"),
              onPressed: () {
                controller.forward(from: 0.0);
              },
            ),
            SizedBox(
              height: 20.0,
            ),
            Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateX(_offset.dx)
                  ..rotateY(_offset.dy),
                alignment: FractionalOffset.center,
                child: Container(
                  height: 200.0,
                  width: 200.0,
                  color: _backgroundColor,
                )),
          ],
        ));

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
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                  });
                  controller.forward(from: 0.0);
                },
                child: new Container(
                  height: 200.0,
                  width: 200.0,
                  child: Text("Tap Me!"),
                  color: Colors.black12,
                  alignment: Alignment.center,
                ),
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
