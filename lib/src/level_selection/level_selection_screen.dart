import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:go_router/go_router.dart';
import '../customAppBar/customAppBar.dart';
import '../drawer/drawer.dart';
import '../style/palette.dart';
import 'dart:math';
import '../style/confetti.dart';
import '../app_lifecycle/translated_text.dart';

class LevelSelectionScreen extends StatefulWidget {
  final int numberOfTeams;

  const LevelSelectionScreen({required this.numberOfTeams, Key? key})
      : super(key: key);

  @override
  _LevelSelectionScreenState createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen> {
  List<String> teamNames = [];
  bool _duringCelebration = false;
  late List<Color> teamColors;
  List<Color> availableColors = [
    Colors.yellow,
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.purple,
    Colors.orange,
  ];
  void _toggleCelebration() {
    setState(() {
      _duringCelebration = !_duringCelebration;
    });
  }
  @override
  void initState() {
    super.initState();
    teamNames = List<String>.filled(widget.numberOfTeams, '');
    teamColors = List.generate(
      widget.numberOfTeams,
      (index) => _getRandomColor(index),
    );
  }

  Color _getRandomColor(int index) {
    if (availableColors.isEmpty) {
      return Colors.grey;
    }
    int randomIndex = Random().nextInt(availableColors.length);
    Color randomColor = availableColors[randomIndex];
    availableColors.removeAt(randomIndex);
    return randomColor;
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: Palette().backgroundLoadingSessionGradient,
        ),
        child: Scaffold(
            drawer: CustomAppDrawer(),
            key: scaffoldKey,
            appBar: CustomAppBar(
              title: translatedText('enter_team_names'),
              onMenuButtonPressed: () {
                scaffoldKey.currentState?.openDrawer();
              },
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Container(
                      height: ResponsiveText.scaleHeight(context, 155),
                      child: LogoWidget_notitle(),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: widget.numberOfTeams,
                        itemBuilder: (context, index) {
                          return Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  onChanged: (text) {
                                    setState(() {
                                      teamNames[index] = text;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Team ${index + 1}',
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  await showDialog<Color>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Wybierz kolor'),
                                      content: SingleChildScrollView(
                                        child: BlockPicker(
                                          availableColors: availableColors,
                                          pickerColor: teamColors[index],
                                          onColorChanged: (Color color) {
                                            setState(() {
                                              availableColors
                                                  .add(teamColors[index]);
                                              teamColors[index] = color;
                                              availableColors
                                                  .remove(teamColors[index]);
                                            });
                                          },
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('Anuluj'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(
                                              context, teamColors[index]),
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: teamColors[index],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    Container(
                      height: 200,
                      child: Center(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFCB48EF), // color
                            foregroundColor: Colors.white, // textColor
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            minimumSize: Size(
                                MediaQuery.of(context).size.width * 0.5,
                                MediaQuery.of(context).size.height * 0.05),
                            textStyle: TextStyle(
                                fontFamily: 'HindMadurai', fontSize: 20),
                          ),
                          icon: Icon(Icons.play_arrow_rounded, size: 32),
                          onPressed: () {
                            _toggleCelebration();
                          },
                          label: const Text('Zagraj teraz!'),
                        ),
                      ),
                    ),
                  ],//TODO CONFETTI TEST
                ),
              ),
            )),
      ),
    );
  }
}
