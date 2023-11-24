import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:roll_slot_machine/roll_slot_machine.dart';

class RollSlotMachine extends StatefulWidget {

  RollSlotMachine({Key? key}) : super(key: key);

  @override
  _RollSlotMachineState createState() => _RollSlotMachineState();
}


class _RollSlotMachineState extends State<RollSlotMachine> with SingleTickerProviderStateMixin{
  final controller = StreamController<int>();
  final _rollSlotController = RollSlotController();
  final _rollSlotController1 = RollSlotController();
  final _rollSlotController2 = RollSlotController();
  final _rollSlotController3 = RollSlotController();
  late AnimationController _pulseAnimationController;
  late Animation<double> _pulseAnimation;
  final random = Random();
  bool isRollSlotVisible = false;
  bool isConfirmButtonVisible = false;
  bool isDrawButtonVisible = true;

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
    'pompki',
    'przysiady',
    'brzuszki',
    'pajacyki',
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
            if (isRollSlotVisible)
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
            Text(getText()),
            if (isDrawButtonVisible)
              Align(
                alignment: Alignment.center,
                child:  FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      isRollSlotVisible = true;
                      isDrawButtonVisible = false;
                    });
                    Future.delayed(Duration(milliseconds: 100), () {
                      _rollSlotController.animateRandomly();
                      if (size.width > 100) _rollSlotController1.animateRandomly();
                      if (size.width > 150) _rollSlotController2.animateRandomly();
                      if (size.width > 200) _rollSlotController3.animateRandomly();
                    });
                    Timer(Duration(seconds: 4), () {
                      setState(() {
                        isConfirmButtonVisible = true;
                      });
                      //Navigator.of(context).pop(getText());
                    });
                  },
                  child: Text('Tap to ROLL!'),
                ),),
            Visibility(
              visible: isConfirmButtonVisible,
              child: Positioned(
                right: 100,
                bottom: 100,
                child: ScaleTransition(
                  scale: _pulseAnimation,
                  child: FloatingActionButton(
                    onPressed: () {
                      Navigator.of(context).pop(getText());
                    },
                    child: Text('Kliknij aby zaczac!'), // Przykładowa ikona
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
    final String x = emojiList1.elementAt(_rollSlotController.currentIndex) +
        emojiList2.elementAt(_rollSlotController1.currentIndex) +
        emojiList3.elementAt(_rollSlotController2.currentIndex);
    return x;
  }
}

class RollSlotWidget extends StatelessWidget {
  List<String> emojiList= [];
  final RollSlotController rollSlotController;

  RollSlotWidget(
      {super.key, required this.emojiList, required this.rollSlotController});

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
    Key? key,
    required this.emoji,
  }) : super(key: key);

  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        boxShadow: [
          BoxShadow(
              color: Colors.deepPurple.withOpacity(.2), offset: Offset(5, 5)),
          BoxShadow(
              color: Colors.deepPurple.withOpacity(.2), offset: Offset(-5, -5)),
        ],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.deepPurple
        ),
      ),
      alignment: Alignment.center,
      child: getImageForCode(emoji),
    );
  }

  Widget getImageForCode(String code) {
    // Mapowanie kodów do ścieżek obrazków
    Map<String, String> codeToImagePath = {
      'pompki': 'assets/time_to_party_assets/activities/pushups.png',
      'przysiady': 'assets/time_to_party_assets/activities/squats.png',
      'brzuszki': 'assets/time_to_party_assets/activities/situps.png',
      'pajacyki': 'assets/time_to_party_assets/activities/jumping_jacks.png',
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
