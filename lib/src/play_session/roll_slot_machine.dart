import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:roll_slot_machine/roll_slot_machine.dart';

class RollSlotMachine extends StatefulWidget {
  @override
  _RollSlotMachineState createState() => _RollSlotMachineState();
}

class _RollSlotMachineState extends State<RollSlotMachine> {
  List<int> values = List.generate(100, (index) => index);
  final controller = StreamController<int>();
  final _rollSlotController = RollSlotController();
  final _rollSlotController1 = RollSlotController();
  final _rollSlotController2 = RollSlotController();
  final _rollSlotController3 = RollSlotController();
  final random = Random();
  final List<String> emojiList = [
    '😀',
    '😃',
    '😄',
    '😁',
    '😆',
    '😅',
    '🤣',
    '😂',
    '🙂',
    '🙃',
    '😉',
    '😊',
  ];

  @override
  void initState() {
    _rollSlotController.addListener(() {
      // trigger setState method to reload ui with new index
      // in our case the AppBar title will change
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
      appBar: AppBar(
        title: Text(getText()),
      ),
      body: Center(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    RollSlotWidget(
                      emojiList: emojiList,
                      rollSlotController: _rollSlotController,
                    ),
                    if (size.width > 100)
                      RollSlotWidget(
                        emojiList: emojiList,
                        rollSlotController: _rollSlotController1,
                      ),
                    if (size.width > 150)
                      RollSlotWidget(
                        emojiList: emojiList,
                        rollSlotController: _rollSlotController2,
                      ),
                    if (size.width > 200)
                      RollSlotWidget(
                        emojiList: emojiList,
                        rollSlotController: _rollSlotController3,
                      ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      child: FortuneBar(
                  physics: CircularPanPhysics(
                    duration: Duration(seconds: 1),
                    curve: Curves.decelerate,
                  ),
                  onFling: () {
                    controller.add(1);
                  },
                  selected: controller.stream,
                        styleStrategy: AlternatingStyleStrategy(),
                        visibleItemCount: 7,

                  items: [
                    FortuneItem(child: Text('Han Solo')),
                    FortuneItem(child: Text('Yoda')),
                    FortuneItem(child: Text('Obi-Wan Kenobi')),
                    FortuneItem(child: Text('Han Solo')),
                    FortuneItem(child: Text('Yoda')),
                    FortuneItem(child: Text('Obi-Wan Kenobi')),
                  ],
                ),
              ),
                  ),
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                        border:
                        Border.all(color: Color(0xff2f5d62), width: 5)),
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _rollSlotController.animateRandomly();
          if (size.width > 100) _rollSlotController1.animateRandomly();
          if (size.width > 150) _rollSlotController2.animateRandomly();
          if (size.width > 200) _rollSlotController3.animateRandomly();
        },
        child: Icon(Icons.refresh),
      ),
    );
  }

  String getText() {
    final String x = emojiList.elementAt(_rollSlotController.currentIndex) +
        emojiList.elementAt(_rollSlotController1.currentIndex) +
        emojiList.elementAt(_rollSlotController2.currentIndex) +
        emojiList.elementAt(_rollSlotController3.currentIndex);
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
                  duration: Duration(milliseconds: 6000),
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
