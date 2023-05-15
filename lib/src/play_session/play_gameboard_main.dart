import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';

import '../settings/settings.dart';

class PlayGameboard extends StatelessWidget {
  late final List<String> teamNames;
  late final List<Color> teamColors;

  PlayGameboard({required this.teamNames, required this.teamColors});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Next Screen'),
      ),
      body: ListView.builder(
        itemCount: teamNames.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
              teamNames[index],
              style: TextStyle(color: Colors.white),
            ),
            trailing: Container(
              width: 20,
              height: 20,
              color: teamColors[index],
            ),
            onTap: () async {
              final settings = Provider.of<SettingsController>(context, listen: false);
              if (settings.vibrationsEnabled.value && await Vibration.hasVibrator() == true) {
                await Vibration.vibrate(duration: 1000); // 1000ms = 1s
              }
            },
          );
        },
      ),
    );
  }
}