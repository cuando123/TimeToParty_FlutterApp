import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';

class PhysicalChallengeCard extends StatefulWidget {
  const PhysicalChallengeCard({super.key});

  @override
  _PhysicalChallengeCardState createState() => _PhysicalChallengeCardState();
}

class _PhysicalChallengeCardState extends State<PhysicalChallengeCard> {
  StreamController<int> selectedController1 = StreamController<int>.broadcast();
  StreamController<int> selectedController2 = StreamController<int>.broadcast();
  StreamController<int> selectedController3 = StreamController<int>.broadcast();

  final List<String> players = ['Gracz 1', 'Gracz 2'];
  final List<String> numbers = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'];
  final List<String> exercises = ['pompki', 'brzuszki', 'przysiady', 'pajacyki'];

  @override
  void dispose() {
    selectedController1.close();
    selectedController2.close();
    selectedController3.close();
    super.dispose();
  }

  void startFling() {
    int playerIndex = Fortune.randomInt(0, players.length);
    int numberIndex = Fortune.randomInt(0, numbers.length);
    int exerciseIndex = Fortune.randomInt(0, exercises.length);

    selectedController1.add(playerIndex);
    selectedController2.add(numberIndex);
    selectedController3.add(exerciseIndex);

    Future.delayed(Duration(seconds: 5), () {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Wynik Losowania'),
              content: Text('${players[playerIndex]} robi ${numbers[numberIndex]} ${exercises[exerciseIndex]}',style: TextStyle(color: Colors.white70)),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ElevatedButton(
          onPressed: startFling,
          child: Text('Rozpocznij Losowanie'),
        ),
        SizedBox(height: 10), // Odstęp
        buildFortuneBar(players, selectedController1),
        SizedBox(height: 10), // Odstęp
        buildFortuneBar(numbers, selectedController2),
        SizedBox(height: 10), // Odstęp
        buildFortuneBar(exercises, selectedController3),
      ],
    );
  }

  Widget buildFortuneBar(List<String> items, StreamController<int> controller) {
    return Expanded(
      child: FortuneBar(
        physics: CircularPanPhysics(
          duration: Duration(seconds: 1),
          curve: Curves.decelerate,
        ),
        onFling: () {
          controller.add(Fortune.randomInt(0, items.length));
        },
        selected: controller.stream,
        styleStrategy: AlternatingStyleStrategy(),
        visibleItemCount: 3, // Zmniejszona ilość widocznych elementów
        items: [
          for (var item in items) FortuneItem(child: Text(item)),
        ],
      ),
    );
  }
}