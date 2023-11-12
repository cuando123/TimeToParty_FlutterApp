import 'package:flutter/material.dart';
import 'package:draw_your_image/draw_your_image.dart';

class DrawingScreen extends StatefulWidget {
  @override
  _DrawingScreenState createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {
  var _currentColor = Colors.black;
  var _currentWidth = 4.0;
  final _drawController = DrawController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Draw Your Image'),
        actions: [
          IconButton(
            icon: Icon(Icons.undo),
            onPressed: () {
              if (!_drawController.undo()) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text("No actions to undo"),
                ));
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.redo),
            onPressed: () {
              if (!_drawController.redo()) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text("No actions to redo"),
                ));
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: () => _drawController.clear(),
          ),
        ],
      ),
      body: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Column(
          children: [
            const SizedBox(height: 32),
            const Text('DRAW WHAT YOU WANT!'),
            const SizedBox(height: 50),
            Expanded(
              child: Draw(controller: _drawController,
                  backgroundColor: Colors.blue.shade50,
                  strokeColor: _currentColor,
                  strokeWidth: _currentWidth,
                  isErasing: false,
                  ),  // Upewnij się, że Draw() jest odpowiednim widżetem/widgetem
            ),
            const SizedBox(height: 32),
            buildColorPicker(),
            const SizedBox(height: 32),
            buildBrushSizeSlider(),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget buildColorPicker() {
    return Wrap(
      spacing: 16,
      children: [
        Colors.black,
        Colors.blue,
        Colors.red,
        Colors.green,
        Colors.yellow
      ].map((color) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _currentColor = color;
            });
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 40,
              height: 40,
              color: color,
              child: Center(
                child: _currentColor == color
                    ? Icon(Icons.brush, color: Colors.white)
                    : SizedBox.shrink(),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget buildBrushSizeSlider() {
    return Slider(
      max: 40,
      min: 1,
      value: _currentWidth,
      onChanged: (value) {
        setState(() {
          _currentWidth = value;
        });
      },
    );
  }
}
