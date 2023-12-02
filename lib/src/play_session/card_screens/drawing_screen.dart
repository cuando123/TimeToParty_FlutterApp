import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:draw_your_image/draw_your_image.dart';
import 'package:flutter/material.dart';

import '../../style/palette.dart';

class DrawingScreen extends StatefulWidget {
  final String itemToShow;
  final String category;

  DrawingScreen({Key? key, required this.itemToShow, required this.category}) : super(key: key);

  @override
  _DrawingScreenState createState() => _DrawingScreenState();
}


class _DrawingScreenState extends State<DrawingScreen> {
  var _currentColor = Colors.black;
  var _currentWidth = 4.0;
  final _drawController = DrawController();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _convertAndNavigate() async {
    // Wywołaj convertToImage, który uruchomi callback onConvertImage
    _drawController.convertToImage();
  }

  Future<void> onConvertImage(Uint8List imageData) async {
    // Konwersja na ui.Image i zwrócenie jako wynik
    ui.Image image = await convertUint8ListToUiImage(imageData);
    Navigator.of(context).pop(DrawingResult(image: image, category: widget.category));

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rysuj'),
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
    body: Container(
    decoration: BoxDecoration(
    gradient: Palette().backgroundLoadingSessionGradient,
    ),
        child: Column(
          children: [
            const SizedBox(height: 32),
            Text('Draw ${widget.itemToShow}'),
            Text('Category: ${widget.category}'),
            const SizedBox(height: 50),
            Expanded(
              child: Draw(controller: _drawController,
                  backgroundColor: Colors.blue.shade50,
                  strokeColor: _currentColor,
                  strokeWidth: _currentWidth,
                  isErasing: false,
                  onConvertImage: (imageData) async {
                    await onConvertImage(imageData);
                  },
                  ),
            ),
            const SizedBox(height: 32),
            buildColorPicker(),
            const SizedBox(height: 32),
            buildBrushSizeSlider(),
            const SizedBox(height: 60),
            ElevatedButton(
              onPressed: _convertAndNavigate,
              child: Text('Confirm and Continue'),
            )
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

  Future<ui.Image> convertUint8ListToUiImage(Uint8List imageData) async {
    // Tworzenie kodeka obrazu z danych binarnych
    final ui.Codec codec = await ui.instantiateImageCodec(imageData);

    // Dekodowanie pierwszej klatki obrazu (w przypadku obrazów statycznych, będzie to jedyna klatka)
    final ui.FrameInfo frameInfo = await codec.getNextFrame();

    // Zwrócenie obrazu
    return frameInfo.image;
  }

}
class DrawingResult {
  final ui.Image image;
  final String category;

  DrawingResult({required this.image, required this.category});
}

