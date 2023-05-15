import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Loading_screen/loading_screen.dart';
import '../app_lifecycle/translated_text.dart';
import '../customAppBar/customAppBar.dart';
import '../drawer/drawer.dart';
import '../style/palette.dart';

class TeamProvider with ChangeNotifier {
  String teams = '';
  List<String> teamNames = [];
  List<bool> hasUserInput = [];

  void initializeTeams(BuildContext context, int numberOfTeams) {
    teams = getTranslatedString(context, 'x_teams');
    teamNames =
        List<String>.generate(numberOfTeams, (index) => '$teams ${index + 1}');
    hasUserInput = List<bool>.generate(numberOfTeams, (index) => false);
    notifyListeners();
  }

  void updateTeams(BuildContext context, int numberOfTeams) {
    teams = getTranslatedString(context, 'x_teams');
    teamNames =
        List<String>.generate(numberOfTeams, (index) => '$teams ${index + 1}');
    hasUserInput = List<bool>.generate(numberOfTeams, (index) => false);
    notifyListeners();
  }

  void updateTeamName(int index, String newName) {
    teamNames[index] = newName;
    hasUserInput[index] = true;
    notifyListeners();
  }
}

class LevelSelectionScreen extends StatefulWidget {
  const LevelSelectionScreen({super.key});

  @override
  _LevelSelectionScreenState createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen> {
  List<TextEditingController> controllers = [];
  bool _duringCelebration = false;
  static final scaffoldKey = GlobalKey<ScaffoldState>();
  late List<Color> teamColors;
  int numberOfTeams = 2;
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

  List<Color> _initializeColors(int numberOfTeams) {
    List<Color> shuffledColors = List.from(availableColors)..shuffle();
    return shuffledColors.sublist(0, numberOfTeams);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TeamProvider>(context, listen: false)
          .initializeTeams(context, numberOfTeams);
    });
    teamColors = _initializeColors(numberOfTeams);
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<TeamProvider, List<String>>(
      selector: (_, provider) => provider.teamNames,
      builder: (_, teamNames, __) {
        if (controllers.length != teamNames.length) {
          controllers =
              List.generate(teamNames.length, (_) => TextEditingController());
        }
        for (int i = 0; i < teamNames.length; i++) {
          controllers[i].text = teamNames[i];
        }
        return GestureDetector(
          onTap: () {
            if (!FocusScope.of(context).hasPrimaryFocus) {
              FocusScope.of(context).requestFocus(FocusNode());
            }
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: Palette().backgroundLoadingSessionGradient,
            ),
            child: Scaffold(
              drawer: CustomAppDrawer(),
              key: scaffoldKey,
              appBar: CustomAppBar(
                title: translatedText(
                    context, 'enter_team_names', 14, Palette().white),
                onMenuButtonPressed: () {
                  scaffoldKey.currentState?.openDrawer();
                },
                onBackButtonPressed: () {
                  Navigator.pop(context);
                },
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Consumer<TeamProvider>(
                    builder: (context, teamProvider, child) {
                      return Column(
                        children: [
                          Container(
                            height: ResponsiveSizing.scaleHeight(context, 155),
                            child: LogoWidget_notitle(),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              CustomElevatedButton(
                                child: Icon(Icons.add),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white, // color
                                  foregroundColor:
                                      Color(0xFFCB48EF), // textColor
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  minimumSize: Size(
                                      MediaQuery.of(context).size.width * 0.05,
                                      MediaQuery.of(context).size.height *
                                          0.05),
                                ),
                                onPressed: numberOfTeams >=
                                        availableColors.length
                                    ? null
                                    : () {
                                        setState(() {
                                          numberOfTeams++;
                                          teamColors =
                                              _initializeColors(numberOfTeams);
                                          teamProvider.updateTeams(
                                              context, numberOfTeams);
                                        });
                                      },
                              ),
                              ResponsiveSizing.responsiveWidthGapWithCondition(
                                  context, 5, 10, 300),
                              CustomElevatedButton(
                                child: Icon(Icons.remove),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white, // color
                                  foregroundColor:
                                      Color(0xFFCB48EF), // textColor
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  minimumSize: Size(
                                      MediaQuery.of(context).size.width * 0.05,
                                      MediaQuery.of(context).size.height *
                                          0.05),
                                ),
                                onPressed: numberOfTeams <= 2
                                    ? null
                                    : () {
                                        setState(() {
                                          numberOfTeams--;
                                          teamColors =
                                              _initializeColors(numberOfTeams);
                                          teamProvider.updateTeams(
                                              context, numberOfTeams);
                                        });
                                      },
                              ),
                            ],
                          ),
                          SizedBox(
                              height: MediaQuery.of(context).size.height < 650
                                  ? ResponsiveSizing.scaleHeight(context, 18)
                                  : ResponsiveSizing.scaleHeight(context, 10)),
                          Column(
                            children: List.generate(numberOfTeams, (index) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: 10.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        height: 50.0,
                                        child: TextField(
                                          onChanged: (text) {
                                            teamProvider.updateTeamName(
                                                index, text);
                                          },
                                          style: TextStyle(
                                            color: Color(0xFFA0A0A0),
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          onTap: () {
                                            if (!teamProvider
                                                .hasUserInput[index]) {
                                              teamProvider.updateTeamName(
                                                  index, '');
                                            }
                                          },
                                          decoration: InputDecoration(
                                            hintText:
                                                '${teamProvider.teamNames[index]}',
                                            hintStyle: TextStyle(
                                              color: Color(0xFFA0A0A0),
                                            ),
                                            filled: true, // Włącz tło
                                            fillColor: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 5.0),
                                      child: Container(
                                        width: 50,
                                        height: 50.0,
                                        decoration: BoxDecoration(
                                          color: teamColors[index],
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFFCB48EF), // color
                                    foregroundColor: Colors.white, // textColor
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    minimumSize: Size(
                                        MediaQuery.of(context).size.width * 0.5,
                                        MediaQuery.of(context).size.height *
                                            0.05),
                                    textStyle: TextStyle(
                                        fontFamily: 'HindMadurai',
                                        fontSize: 20),
                                  ),
                                  icon:
                                      Icon(Icons.play_arrow_rounded, size: 32),
                                  onPressed: () {
                                    _toggleCelebration();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LoadingScreen(
                                          teamNames: teamProvider.teamNames,
                                          teamColors: teamColors,
                                        ),
                                      ),
                                    );
                                  },
                                  label: translatedText(
                                      context, 'play_now', 20, Palette().white),
                                ),
                                ResponsiveSizing
                                    .responsiveWidthGapWithCondition(
                                        context, 5, 10, 300),
                                ElevatedButton(
                                  child: Icon(Icons.color_lens),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white, // color
                                    foregroundColor:
                                        Color(0xFFCB48EF), // textColor
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    minimumSize: Size(
                                        MediaQuery.of(context).size.width *
                                            0.05,
                                        MediaQuery.of(context).size.height *
                                            0.05),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      List<Color> shuffledColors =
                                          List.from(availableColors)..shuffle();
                                      teamColors = shuffledColors.sublist(
                                          0, numberOfTeams);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
