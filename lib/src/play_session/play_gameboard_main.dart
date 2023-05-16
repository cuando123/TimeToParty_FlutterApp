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
  StreamController<int> selected = StreamController<int>();
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
  }

  @override
  void dispose() {
    selected.close();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _buttonAnimation = Tween<double>(
            begin: 0,
            end: MediaQuery.of(context).size.width * 0.5) // Change here
        .animate(CurvedAnimation(
            parent: _animationController, curve: Curves.easeInOut));
    final items = <String>[
      'Grogu',
      'Mace Windu',
      'Obi-Wan Kenobi',
      'Han Solo',
      'Luke Skywalker',
      'Darth Vader',
      'Yoda',
      'Ahsoka Tano',
    ];
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
            /*         Container(
            height: MediaQuery.of(context).size.height*0.1,
            child: ListView.builder(
              itemCount: widget.teamNames.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    widget.teamNames[index],
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing: Container(
                    width: 20,
                    height: 20,
                    color: widget.teamColors[index],
                  ),
                  onTap: () async {
                    final settings =
                    Provider.of<SettingsController>(context, listen: false);
                    if (settings.vibrationsEnabled.value &&
                        await Vibration.hasVibrator() == true) {
                      await Vibration.vibrate(duration: 1000); // 1000ms = 1s
                    }
                  },
                );
              },
            ),
          ),*/
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    15.0, 10.0, 15.0, 2.0), // left, top, right, bottom
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      left: 0,
                      top: 0,
                      child: Column(
                        children: [
                          SvgPicture.asset(
                              'assets/time_to_party_assets/field_sheet.svg',
                              width: ResponsiveSizing.scaleHeight(context, 50)),
                          ResponsiveSizing.responsiveHeightGap(context, 6),
                          SvgPicture.asset(
                              'assets/time_to_party_assets/field_pantomime.svg',
                              width: ResponsiveSizing.scaleHeight(context, 50)),
                          ResponsiveSizing.responsiveHeightGap(context, 6),
                          SvgPicture.asset(
                              'assets/time_to_party_assets/field_letters.svg',
                              width: ResponsiveSizing.scaleHeight(context, 50)),
                          ResponsiveSizing.responsiveHeightGap(context, 6),
                          SvgPicture.asset(
                              'assets/time_to_party_assets/field_arrows.svg',
                              width: ResponsiveSizing.scaleHeight(context, 50)),
                          ResponsiveSizing.responsiveHeightGap(context, 6),
                          SvgPicture.asset(
                              'assets/time_to_party_assets/field_sheet.svg',
                              width: ResponsiveSizing.scaleHeight(context, 50)),
                          ResponsiveSizing.responsiveHeightGap(context, 6),
                          SvgPicture.asset(
                              'assets/time_to_party_assets/field_microphone.svg',
                              width: ResponsiveSizing.scaleHeight(context, 50)),
                          ResponsiveSizing.responsiveHeightGap(context, 6),
                          SvgPicture.asset(
                              'assets/time_to_party_assets/field_letters.svg',
                              width: ResponsiveSizing.scaleHeight(context, 50)),
                          ResponsiveSizing.responsiveHeightGap(context, 6),
                          SvgPicture.asset(
                              'assets/time_to_party_assets/field_star_blue.svg',
                              width: ResponsiveSizing.scaleHeight(context, 50)),
                          ResponsiveSizing.responsiveHeightGap(context, 6),
                          SvgPicture.asset(
                              'assets/time_to_party_assets/field_star_blue.svg',
                              width: ResponsiveSizing.scaleHeight(
                                  context, 50)), // replace with actual svg file
                        ],
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Column(
                        children: List.generate(
                          9,
                          (index) => Column(
                            children: [
                              SvgPicture.asset(
                                'assets/time_to_party_assets/field_sheet.svg',
                                width: 50,
                                height: 50,
                              ),
                              ResponsiveSizing.responsiveHeightGap(context, 6),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(4, (index) {
                          return Row(
                            children: [
                              SvgPicture.asset(
                                'assets/time_to_party_assets/field_sheet.svg',
                                width: 50,
                                height: 50,
                              ),
                              ResponsiveSizing.responsiveWidthGap(context, 6),
                            ],
                          );
                        }),
                      ),
                    ),
                    Positioned(
                      bottom: 0, // adjust this value as needed
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(4, (index) {
                          return Row(
                            children: [
                              SvgPicture.asset(
                                'assets/time_to_party_assets/field_sheet.svg',
                                width: 50,
                                height: 50,
                              ),
                              ResponsiveSizing.responsiveWidthGap(context, 6),
                            ],
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // First, the FortuneWheel
                  // Then, the button
                  Positioned(
                    top: 10, // 90% of the height of the wheel
                    left: _buttonClicked ? 0 : _buttonAnimation.value,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _buttonClicked = true;
                          _animationController.stop();
                          selected.add(
                            Fortune.randomInt(0, items.length),
                          );
                        });
                      },
                      child: Text('Zakręć kołem'),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context)
                        .size
                        .width, // 20% of screen width
                    height: MediaQuery.of(context).size.width *
                        0.5, // same as width for a circle
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selected.add(
                            Fortune.randomInt(0, items.length),
                          );
                        });
                      },
                      child: FortuneWheel(
                        selected: selected.stream,
                        items: [
                          for (var it in items) FortuneItem(child: Text(it)),
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
}
