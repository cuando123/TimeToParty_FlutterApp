import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:roll_slot_machine/roll_slot_machine.dart';

import '../../app_lifecycle/translated_text.dart';
import '../../style/palette.dart';
import '../custom_style_buttons.dart';

class RollSlotMachine extends StatefulWidget {
  const RollSlotMachine({super.key});

  @override
  _RollSlotMachineState createState() => _RollSlotMachineState();
}

class _RollSlotMachineState extends State<RollSlotMachine> with SingleTickerProviderStateMixin {
  final controller = StreamController<int>();
  final _rollSlotController = RollSlotController();
  final _rollSlotController1 = RollSlotController();
  final _rollSlotController2 = RollSlotController();
  final _rollSlotController3 = RollSlotController();
  late AnimationController _pulseAnimationController;
  late Animation<double> _pulseAnimation;
  final random = Random();
  bool isConfirmButtonVisible = false;
  bool isDrawButtonVisible = true;
  double _shadowOpacity = 0.7;

  final List<String> emojiList1 = [
    'man',
    'woman',
  ];
  final List<String> emojiList2 = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
  ];
  final List<String> emojiList3 = [
    'push-ups',
    'squats',
    'sit-ups',
    'jumping_jacks',
  ];

  @override
  void initState() {
    _rollSlotController.addListener(() {
      setState(() {});
    });
    _pulseAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    )..repeat(reverse: true); // Powtarzaj animację w kierunku przeciwnym

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _pulseAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    super.initState();
  }

  @override
  void dispose() {
    controller.close();
    _pulseAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.center,
              child: Row(
                children: [
                  RollSlotWidget(
                    emojiList: emojiList1,
                    rollSlotController: _rollSlotController,
                  ),
                  if (size.width > 100)
                    RollSlotWidget(
                      emojiList: emojiList2,
                      rollSlotController: _rollSlotController1,
                    ),
                  if (size.width > 150)
                    RollSlotWidget(
                      emojiList: emojiList3,
                      rollSlotController: _rollSlotController2,
                    ),
                ],
              ),
            ),
            if (isDrawButtonVisible || isConfirmButtonVisible)
              Positioned.fill(
                child: AnimatedOpacity(
                  opacity: _shadowOpacity,
                  duration: Duration(milliseconds: 300),
                  child: !isDrawButtonVisible && isConfirmButtonVisible // Warunek na wyświetlenie CustomPaint
                      ? CustomPaint(
                    painter: ShadowPainter(),
                    child: Container(),
                  )
                      : Container(
                    color: Colors.black.withOpacity(0.8),
                  ),
                ),
              ),
            if (isDrawButtonVisible)
              Align(
                alignment: Alignment.center,
                child: ScaleTransition(
                  scale: _pulseAnimation,
                  child: CustomStyledButton(
                    icon: Icons.play_arrow_rounded, // Tutaj możesz wybrać odpowiednią ikonę
                    text: getTranslatedString(context, 'randomize'), // Tekst przycisku
                    onPressed: () {
                      setState(() {
                        isDrawButtonVisible = false;
                      });
                      Future.delayed(Duration(milliseconds: 100), () {
                        _rollSlotController.animateRandomly();
                        if (size.width > 100) _rollSlotController1.animateRandomly();
                        if (size.width > 150) _rollSlotController2.animateRandomly();
                        if (size.width > 200) _rollSlotController3.animateRandomly();
                      });
                      Timer(Duration(seconds: 3), () {
                        setState(() {
                          isConfirmButtonVisible = true;
                          _shadowOpacity = 0.7;
                        });
                      });
                    },backgroundColor: Palette().pink, foregroundColor: Palette().white,
                  ),
                ),
              ),
            Visibility(
              visible: isConfirmButtonVisible,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40.0), // Dodaje padding na dole
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: ScaleTransition(
                    scale: _pulseAnimation,
                    child: CustomStyledButton(
                      icon: Icons.play_arrow_rounded,
                      text: getTranslatedString(context, 'start_the_task'),
                      onPressed: () {
                        Navigator.of(context).pop(getText());
                      },backgroundColor: Palette().pink, foregroundColor: Palette().white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getText() {
    final String x = '${emojiList1.elementAt(_rollSlotController.currentIndex)};${emojiList2.elementAt(_rollSlotController1.currentIndex)};${emojiList3.elementAt(_rollSlotController2.currentIndex)}';
    return x;
  }
}

class RollSlotWidget extends StatelessWidget {
  List<String> emojiList = [];
  final RollSlotController rollSlotController;

  RollSlotWidget({super.key, required this.emojiList, required this.rollSlotController});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Flexible(
            child: RollSlot(
                duration: Duration(milliseconds: 4000),
                itemExtend: 150,
                shuffleList: false,
                rollSlotController: rollSlotController,
                children: emojiList.map(
                  (e) {
                    return BuildItem(
                      emoji: e,
                    );
                  },
                ).toList()),
          ),
        ],
      ),
    );
  }
}

class BuildItem extends StatelessWidget {
  const BuildItem({
    super.key,
    required this.emoji,
  });

  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.2), offset: Offset(5, 5)),
          //BoxShadow(color: Colors.deepPurple.withOpacity(.2), offset: Offset(-5, -5)),
        ],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.deepPurple, width: 3),
      ),
      alignment: Alignment.center,
      child: getImageForCode(context, emoji),
    );
  }

  Widget getImageForCode(BuildContext context, String code) {
    // Mapowanie kodów do ścieżek obrazków
    Map<String, String> codeToImagePath = {
      'push-ups': 'assets/time_to_party_assets/activities/pushups.png',
      'squats': 'assets/time_to_party_assets/activities/squats.png',
      'sit-ups': 'assets/time_to_party_assets/activities/situps.png',
      'jumping_jacks': 'assets/time_to_party_assets/activities/jumping_jacks.png',
      'man': 'assets/time_to_party_assets/activities/man.png',
      'woman': 'assets/time_to_party_assets/activities/woman.png',
    };

    // Sprawdź, czy dla danego kodu istnieje obrazek
    if (codeToImagePath.containsKey(code)) {
      String imagePath = codeToImagePath[code]!;
      // Jeśli obrazek istnieje, zwróć go
      return Image.asset(
        imagePath,
        key: Key(code),
      );
    } else {
      // Jeśli obrazek nie istnieje, zwróć Text z kodem
      return Text(
        code,
        key: Key(code),
        style: TextStyle(fontSize: 50),
      );
    }
  }
}

class ShadowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Tło z cieniem
    var rect = Offset.zero & size;
    var shadowPaint = Paint()..color = Colors.black.withOpacity(0.7);
    canvas.drawRect(rect, shadowPaint);

    // Stworzenie przezroczystego paska
    var barHeight = 150.0;
    var barRect = Rect.fromLTWH(0, (size.height - barHeight) / 2, size.width, barHeight);

    var path = Path()..addRect(rect);
    var barPath = Path()..addRect(barRect);
    var difference = Path.combine(PathOperation.difference, path, barPath);

    canvas.drawPath(difference, shadowPaint);

    // Dodanie gradientu
    var gradient = LinearGradient(
      colors: [
        Colors.white.withOpacity(0.8), // Jasny kolor na końcach
        Colors.white.withOpacity(0.4),           // Przezroczystość w środku
        Colors.white.withOpacity(0.8), // Jasny kolor na końcach
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    var gradientPaint = Paint()
      ..shader = gradient.createShader(barRect);

    canvas.drawRect(barRect, gradientPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}







