import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import '../app_lifecycle/translated_text.dart';
import '../settings/settings.dart';
import '../style/palette.dart';

class PlayGameboard extends StatefulWidget {
  final List<String> teamNames;
  final List<Color> teamColors;

  PlayGameboard({required this.teamNames, required this.teamColors});

  @override
  _PlayGameboardState createState() => _PlayGameboardState();
}

class _PlayGameboardState extends State<PlayGameboard>
    with SingleTickerProviderStateMixin {
  late StreamController<int> _selectedController =
      StreamController<int>.broadcast();
  late AnimationController _animationController;
  late Animation<double> _buttonAnimation;
  bool _buttonClicked = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);
    _selectedController = StreamController<int>.broadcast();
    _selectedController.stream.listen((selectedValue) {
      print('Wylosowana wartość: $selectedValue');
    });
  }

  @override
  Widget build(BuildContext context) {
    _buttonAnimation = Tween<double>(
            begin: 0,
            end: MediaQuery.of(context).size.width * 0.5) // Change here
        .animate(CurvedAnimation(
            parent: _animationController, curve: Curves.easeInOut));
    return Container(
      decoration: BoxDecoration(
        gradient: Palette().backgroundLoadingSessionGradient,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Next Screen'),
        ),
        body: Column(
          children: [
            /* Kod pominięty dla czytelności */
            Expanded(
              flex: 1,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 10,
                    left: _buttonClicked ? 0 : _buttonAnimation.value,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _buttonClicked = true;
                          _animationController.stop();
                        });
                      },
                      child: Text('Zakręć kołem'),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.width * 0.5,
                    child: GestureDetector(
                      onTap: () {
                        final randomIndex = Fortune.randomInt(0, 6);
                        _selectedController.add(randomIndex);
                      },
                      child: FortuneWheel(
                        selected: _selectedController.stream,
                        indicators: const <FortuneIndicator>[
                          FortuneIndicator(
                            alignment: Alignment.topCenter,
                            child: TriangleIndicator(
                              color: Colors.green,
                            ),
                          ),
                        ],
                        items: [
                          FortuneItem(
                            child: Transform.rotate(
                              angle: 90 * 3.14 / 180,
                              child: Text(
                                '1',
                                style: TextStyle(
                                    fontFamily: 'HindMadurai', fontSize: 20),
                              ),
                            ),
                            style: FortuneItemStyle(
                              color: Colors.red,
                              borderColor: Colors.green,
                              borderWidth: 3,
                            ),
                          ),
                          FortuneItem(child: Text('2')),
                          FortuneItem(child: Text('3')),
                          FortuneItem(child: Text('1')),
                          FortuneItem(child: Text('2')),
                          FortuneItem(child: Text('3')),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _selectedController.close();
    super.dispose();
  }
}
