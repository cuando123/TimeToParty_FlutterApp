import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_slot_machine/slot_machine.dart';

class SlotMachinePage extends StatefulWidget {
  final String title;

  const SlotMachinePage({super.key, required this.title});

  @override
  _SlotMachinePageState createState() => _SlotMachinePageState();
}

class _SlotMachinePageState extends State<SlotMachinePage> {
  late SlotMachineController _controller;

  @override
  void initState() {
    super.initState();
  }

  void onButtonTap({required int index}) {
    _controller.stop(reelIndex: index);
  }

  void onStart() {
    final index = Random().nextInt(20);
    _controller.start(hitRollItemIndex: index < 5 ? index : null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SlotMachine(
              rollItems: const [
                RollItem(
                    index: 0,
                    child: Text('asd')),
                RollItem(
                    index: 1,
                    child: Text('asd')),
                RollItem(
                    index: 2,
                    child: Text('asd')),
                RollItem(
                    index: 3,
                    child: Text('asd')),
                RollItem(
                    index: 4,
                    child: Text('asd')),
              ],
              onCreated: (controller) {
                _controller = controller;
              },
              onFinished: (resultIndexes) {
                print('Result: $resultIndexes');
              },
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 72,
                    height: 44,
                    child: TextButton(
                        child: Text('STOP'),
                        onPressed: () => onButtonTap(index: 0)),
                  ),
                  SizedBox(width: 8),
                  SizedBox(
                    width: 72,
                    height: 44,
                    child: TextButton(
                        child: Text('STOP'),
                        onPressed: () => onButtonTap(index: 1)),
                  ),
                  SizedBox(width: 8),
                  SizedBox(
                    width: 72,
                    height: 44,
                    child: TextButton(
                        child: Text('STOP'),
                        onPressed: () => onButtonTap(index: 2)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: TextButton(
                child: Text('START'),
                onPressed: () => onStart(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
