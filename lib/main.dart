// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      theme: ThemeData(
        primaryColor: Colors.blue,
      ),
      home: GameBoard(),
    );
  }
}

class GameBoard extends StatefulWidget {
  @override
  GameBoardState createState() {
    return new GameBoardState();
  }
}

class GameBoardState extends State<GameBoard> {
  final Set<int> selectedIndexes = Set<int>();
  final key = GlobalKey();
  final Set<GameBox> _trackTapped = Set<GameBox>();
  GameBox current;

  _detectTappedItem(PointerEvent event) {
    final RenderBox box = key.currentContext.findRenderObject();
    final result = BoxHitTestResult();
    Offset local = box.globalToLocal(event.position);
    if (box.hitTest(result, position: local)) {
      for (final hit in result.path) {
        /// temporary variable so that the [is] allows access of [index]
        final target = hit.target;

        if ((_trackTapped.contains(target) && current != target)) {
          current = null;
          _clearSelection(event);
        } else if (target is GameBox) {
          _trackTapped.add(target);
          _selectIndex(target.index);
          current = target;
        }
      }
    }
  }

  _selectIndex(int index) {
    setState(() {
      selectedIndexes.add(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _detectTappedItem,
      onPointerMove: _detectTappedItem,
      onPointerUp: _clearSelection,
      child: GridView.builder(
        key: key,
        itemCount: 25,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          childAspectRatio: 1.0,
          crossAxisSpacing: 20.0,
          mainAxisSpacing: 20.0,
        ),
        itemBuilder: (context, index) {
          // TODO: gameboard.letterAtIndex(index)
          final name = index.toString();
          return Foo(
            index: index,
            child: Container(
              color: selectedIndexes.contains(index) ? Colors.teal[400]: Colors.teal[100],
              child: Text(name, style: TextStyle(color: Colors.white, decoration: TextDecoration.none), textAlign: TextAlign.center),
            ),
          );
        },
      ),
    );
  }

  void _clearSelection(PointerEvent event) {
    _trackTapped.clear();
    setState(() {
      selectedIndexes.clear();
    });
  }
}

class Foo extends SingleChildRenderObjectWidget {
  final int index;

  Foo({Widget child, this.index, Key key}) : super(child: child, key: key);

  @override
  GameBox createRenderObject(BuildContext context) {
    return GameBox()..index = index;
  }

  @override
  void updateRenderObject(BuildContext context, GameBox renderObject) {
    renderObject..index = index;
  }
}

class GameBox extends RenderProxyBox {
  int index;
}

