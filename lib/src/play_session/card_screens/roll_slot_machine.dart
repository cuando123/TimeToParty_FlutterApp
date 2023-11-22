import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:roll_slot_machine/roll_slot_machine.dart';

class RollSlotMachine extends StatefulWidget {

  RollSlotMachine({Key? key}) : super(key: key);

  @override
  _RollSlotMachineState createState() => _RollSlotMachineState();
}


class _RollSlotMachineState extends State<RollSlotMachine> {
  final controller = StreamController<int>();
  final _rollSlotController = RollSlotController();
  final _rollSlotController1 = RollSlotController();
  final _rollSlotController2 = RollSlotController();
  final _rollSlotController3 = RollSlotController();
  final random = Random();
  final List<String> emojiList1 = [
    'Gracz 1',
    'Gracz 2',
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
    super.initState();
  }

  @override
  void dispose() {
    controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
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
            ),
            Text(getText())
          ],

        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _rollSlotController.animateRandomly();
          if (size.width > 100) _rollSlotController1.animateRandomly();
          if (size.width > 150) _rollSlotController2.animateRandomly();
          if (size.width > 200) _rollSlotController3.animateRandomly();
          Timer(Duration(seconds: 4), () { // Załóżmy, że animacja trwa 4 sekundy
            Navigator.of(context).pop(getText()); // Zamknięcie RollSlotMachine
          });
        },
        child: Icon(Icons.refresh),
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
            child: Padding(
              padding: const EdgeInsets.all(1.0),
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
      child: Text(
        emoji,
        key: Key(emoji),
        style: const TextStyle(fontSize: 50),
      ),
    );
  }
}
