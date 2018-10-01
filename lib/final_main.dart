import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
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
  int _selectedIndex = -1;

  bool forward = true;
  Animation<double> animation;
  AnimationController controller;

  Offset _offset = Offset.zero; // changed
  bool _swapped = false;

  List<String> images = [];
  List<String> availableImages = [];
  List<Offset> imageOffsets = [];

  static const TOTAL_IMAGES = 10;
  static const TOTAL_CELLS = 18;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _offset = Offset(0.0, 0.0);

    availableImages = List.generate(TOTAL_IMAGES, (i) {
      return "assets/images/${i + 1}.jpg";
    });

    var r = math.Random();
    images = List.generate(TOTAL_CELLS, (i) {
      return availableImages[r.nextInt(TOTAL_IMAGES)];
    }).toList();

    imageOffsets = List.generate(images.length, (i) => Offset(0.0, 0.0));

    controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    animation = Tween(begin: 0.0, end: 180.0).animate(controller)
      ..addListener(() {
        if (controller.isCompleted) {
          setState(() {
            _swapped = false;
            //_selectedIndex = -1;
            //_offset = Offset(_offset.dx, animation.value);
            var rad = (math.pi / 180.0) * animation.value;
            print("Radian2: ${rad}");
            _offset = Offset(_offset.dx, rad);
            forward = _offset.direction > 0.0;
            imageOffsets[_selectedIndex] = Offset(_offset.dx, _offset.dy);
            images[_selectedIndex] = topImage;
            print("Images: ${images}");
          });
        } else {
          setState(() {
            //_selectedIndex = -1;
            var rad = (math.pi / 180.0) * animation.value;
            print("Radian4: ${rad}");

            print("Top ${topImage} bottom ${bottomImage}");
            String temp = topImage;
            if (rad > 1.55 && !_swapped) {
              _swapped = true;
              topImage = bottomImage;
              bottomImage = temp;

              print("Swapped top ${topImage} bottom ${bottomImage}");
            } else {
              //String temp = bottomImage;

            }

            _offset = Offset(_offset.dx, rad); //animation.value);
            forward = _offset.direction > 0.0;
          });
        }
      });

    Timer.periodic(new Duration(seconds: 3), (t) {
      var r = new math.Random();
      int index = r.nextInt(TOTAL_CELLS);
      String selectedTop = images[index];

      List l = availableImages.where((e) {
        return e != selectedTop;
      }).toList();

      String next = l[r.nextInt(l.length)];

      setState(() {
        //_offset = Offset(0.0, 0.0);
        //topImage = images[index];
        topImage = selectedTop;
        bottomImage = next;
        _selectedIndex = index;
      });

      controller.forward(from: 0.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    //_offset = Offset(0.0, 2.0);
    //_offset = Offset(0.0, -180.0);
    //_offset = Offset(0.0, 105.0);
    var c = new Container(
        alignment: Alignment.center,
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text("Angle ${_offset}"),
            Container(
              child: Slider(
                value: _offset.dy,
                //divisions: 10,
                min: 0.0,
                max: 100.0,
                label: "Angle ${_offset.dy}",
                onChanged: (v) {
                  //print("Angle : ${_offset.dy}");
                  setState(() {
                    //math.pi/180 * v
                    var rad = (math.pi / 180.0) * v;
                    //print("Radian6: ${rad}");
                    _offset = Offset(_offset.dx, rad);
                  });
                },
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            GestureDetector(
              onTap: () {
//                setState(() {
//                  _offset = Offset(0.0, 0.0);
//                  _selectedIndex = 0;
//                });
                controller.forward(from: 0.0);
              },
              child: Padding(
                padding: const EdgeInsets.all(0.3),
                child: new Container(
                  height: 200.0,
                  width: 200.0,
                  color: forward ? Colors.teal : Colors.red,
                  alignment: Alignment.center,
                  child: new Image.asset(topImage),
                ),
              ),
            ),
//            new Container(
//              height: 200.0,
//              width: 200.0,
//              color: forward ? Colors.teal : Colors.red,
//              child: Image.asset('assets/images/badu.jpg'),
//            ),
            SizedBox(
              height: 20.0,
            ),
            //_getFlipStack(),
            Transform(
                // Transform widget
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001) // perspective
                  ..rotateX(_offset.dx) // changed
                  ..rotateY(_offset.dy), // changed
                alignment: FractionalOffset.center,
                child: Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001) // perspective
                    ..rotateX(_offset.dx) // changed
                    ..rotateY(_offset.dy), // changed
                  alignment: FractionalOffset.center,
                  child: Container(
                    height: 200.0,
                    width: 200.0,
                    color: forward ? Colors.teal : Colors.red,
                    child: Image.asset(
                      topImage,
                      fit: BoxFit.cover,
                    ),
                  ),
                )),
          ],
        ));

//    if (1 == 1) {
//      return Scaffold(body: c);
//    }

    var gridView = new GridView.builder(
        itemCount: TOTAL_CELLS,
        gridDelegate:
            new SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
        itemBuilder: (BuildContext context, int index) {
          if (index == _selectedIndex) {
            return _getFlipStack();
          } else {
            return new Padding(
              padding: const EdgeInsets.all(ITEM_PADDING),
              child: new Container(
                height: 200.0,
                width: 200.0,
                color: Colors.black,
                alignment: Alignment.center,
                child: new Image.asset(
                  images[index],
                  fit: BoxFit.cover,
                ),
              ),
            );
          }
        });

    return Container(
      child: Container(color: Colors.black, child: gridView),
    );
  }

  dispose() {
    controller?.dispose();
    super.dispose();
  }

  Widget _lastStackState = null;

  String topImage = ''; // 'assets/images/badu.jpg';
  String bottomImage = ''; // 'assets/images/badu2.jpg';
  static const ITEM_PADDING = 0.3;

  _getFlipStack() {
    String top = topImage;
    String bottom = bottomImage;
//    if (_offset.dy > 1.56) {
//      top = bottomImage;
//      bottom = topImage;
//    }

    if (1 == 1) {
      return Transform(
          // Transform widget
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // perspective
            ..rotateX(_offset.dx) // changed
            ..rotateY(_offset.dy), // changed
          alignment: FractionalOffset.center,
          child: Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // perspective
              ..rotateX(_offset.dx) // changed
              ..rotateY(_offset.dy), // changed
            alignment: FractionalOffset.center,
            child: Padding(
              padding: const EdgeInsets.all(ITEM_PADDING),
              child: Container(
                height: 200.0,
                width: 200.0,
                color: forward ? Colors.teal : Colors.red,
                child: Image.asset(
                  topImage,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ));
    }
    _lastStackState = new Stack(
      children: <Widget>[
        Transform(
            // Transform widget
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // perspective
              ..rotateX(_offset.dx) // changed
              ..rotateY(_offset.dy), // changed
            alignment: FractionalOffset.center,
            child: Padding(
              padding: const EdgeInsets.all(ITEM_PADDING),
              child: Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001) // perspective
                  ..rotateX(_offset.dx) // changed
                  ..rotateY(_offset.dy), // changed
                alignment: FractionalOffset.center,
                child: Container(
                  height: 200.0,
                  width: 200.0,
                  alignment: Alignment.center,
                  color: Colors.black,
                  child: Image.asset(bottom),
                ),
              ),
            )),
        Transform(
            // Transform widget
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // perspective
              ..rotateX(_offset.dx) // changed
              ..rotateY(_offset.dy), // changed
            alignment: FractionalOffset.center,
            child: Padding(
              padding: const EdgeInsets.all(ITEM_PADDING),
              child: Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001) // perspective
                  ..rotateX(_offset.dx) // changed
                  ..rotateY(_offset.dy), // changed
                alignment: FractionalOffset.center,
                child: Container(
                  height: 200.0,
                  width: 200.0,
                  alignment: Alignment.center,
                  color: Colors.black,
                  child: Image.asset(top),
                ),
              ),
            ))
      ],
    );

    return _lastStackState;
  }
}
