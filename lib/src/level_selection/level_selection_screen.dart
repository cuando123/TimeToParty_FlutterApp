import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Loading_screen/loading_screen.dart';
import '../customAppBar/customAppBar.dart';
import '../drawer/drawer.dart';
import '../style/palette.dart';
import '../app_lifecycle/translated_text.dart';

class LevelSelectionScreen extends StatefulWidget {
  const LevelSelectionScreen({super.key});

  @override
  _LevelSelectionScreenState createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen> {
  List<String> teamNames = [];
  List<bool> touched = [];
  bool _duringCelebration = false;
  static final scaffoldKey = GlobalKey<ScaffoldState>();
  late List<Color> teamColors;
  int numberOfTeams = 2; //Zaczynamy od dwóch drużyn
  List<Color> availableColors = [
    Colors.yellow,
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.purple,
    Colors.orange,
  ];
  String teams = '';

  List<TextEditingController> controllers = [];

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
      setState(() {
        teams = getTranslatedString(context, 'x_teams');
        // Odśwież nazwy drużyn po otrzymaniu tłumaczenia
        teamNames = List<String>.generate(numberOfTeams, (index) => '$teams ${index + 1}');
      });
    });
    // Tymczasowe nazwy drużyn bez tłumaczenia
    teamNames = List<String>.generate(numberOfTeams, (index) => '${index + 1}');
    teamColors = _initializeColors(numberOfTeams);
    // Inicjalizacja kontrolerów dla każdego zespołu
    for (int i = 0; i < numberOfTeams; i++) {
      controllers.add(TextEditingController(text: teamNames[i]));
      touched.add(false); // Dodajemy to
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    teams = getTranslatedString(context, 'x_teams');
    teamNames = List<String>.generate(numberOfTeams, (index) => '$teams ${index + 1}');
    for (int i = 0; i < numberOfTeams; i++) {
      controllers[i].text = teamNames[i]; // aktualizacja kontrolerów
    }
  }

  @override
  void dispose() {
    // Zwolnienie kontrolerów
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              child: Column(
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
                          foregroundColor: Color(0xFFCB48EF), // textColor
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          minimumSize: Size(
                              MediaQuery.of(context).size.width * 0.05,
                              MediaQuery.of(context).size.height * 0.05),
                        ),
                        onPressed: numberOfTeams >= availableColors.length
                            ? null
                            : () {
                          setState(() {
                            numberOfTeams++;
                            teamNames.add('$teams $numberOfTeams');
                            teamColors = _initializeColors(numberOfTeams);
                            controllers.add(TextEditingController(
                                text: teamNames[numberOfTeams - 1]));
                            touched.add(false); // Dodajemy to
                          });
                        },
                      ),
          ResponsiveSizing.responsiveWidthGapWithCondition(context, 5, 10, 300),
                      CustomElevatedButton(
                        child: Icon(Icons.remove),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white, // color
                          foregroundColor: Color(0xFFCB48EF), // textColor
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          minimumSize: Size(
                              MediaQuery.of(context).size.width * 0.05,
                              MediaQuery.of(context).size.height * 0.05),
                        ),
                        onPressed: numberOfTeams <= 2
                            ? null
                            : () {
                          setState(() {
                            numberOfTeams--;
                            teamNames.removeLast();
                            teamColors = _initializeColors(numberOfTeams);
                            controllers.removeLast();
                            touched.removeLast(); // Dodajemy to
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height < 650 ? ResponsiveSizing.scaleHeight(context, 18) : ResponsiveSizing.scaleHeight(context, 10)),
                  Column(
                    children: List.generate(numberOfTeams, (index) {
                      return Padding(
                        padding: EdgeInsets.only(
                            bottom:
                                10.0), // Dodaj odstęp pomiędzy każdym wierszem
                        child: Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 50.0, // Ustal wysokość pola tekstowego
                                child: TextField(
                                  controller: controllers[index],
                                  onChanged: (text) {
                                    teamNames[index] = text;
                                  },
                                  style: TextStyle(
                                    color: Color(0xFFA0A0A0),
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  onEditingComplete: () {
                                    if (!touched[index]) {
                                      controllers[index].clear();
                                      touched[index] = true;
                                    }
                                  },
                                  decoration: InputDecoration(
                                    hintText: '$teams ${index + 1}',
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
                              padding: EdgeInsets.only(
                                  left:
                                      5.0), // Dodaj odstęp pomiędzy polem tekstowym a polem koloru
                              child: Container(
                                width: 50,
                                height:
                                    50.0, // Ustal wysokość pola koloru, aby była taka sama jak wysokość pola tekstowego
                                decoration: BoxDecoration(
                                  color: teamColors[index],
                                  borderRadius: BorderRadius.circular(
                                      8.0), // Zaokrąglenie narożników
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
                      mainAxisAlignment:
                          MainAxisAlignment.center, // Wyśrodkowanie przycisków
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
                                MediaQuery.of(context).size.height * 0.05),
                            textStyle: TextStyle(
                                fontFamily: 'HindMadurai', fontSize: 20),
                          ),
                          icon: Icon(Icons.play_arrow_rounded, size: 32),
                          onPressed: () {
                            _toggleCelebration();
                            // Dodane: przekazanie danych do następnego ekranu
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoadingScreen(
                                  teamNames: teamNames,
                                  teamColors: teamColors,
                                ),
                              ),
                            );
                          },
                          label: translatedText(
                              context, 'play_now', 20, Palette().white),
                        ),
          ResponsiveSizing.responsiveWidthGapWithCondition(context, 5, 10, 300),
                        ElevatedButton(
                          child: Icon(Icons.color_lens),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white, // color
                            foregroundColor: Color(0xFFCB48EF), // textColor
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            minimumSize: Size(
                                MediaQuery.of(context).size.width * 0.05,
                                MediaQuery.of(context).size.height * 0.05),
                          ),
                          onPressed: () {
                            setState(() {
                              List<Color> shuffledColors =
                                  List.from(availableColors)..shuffle();
                              teamColors =
                                  shuffledColors.sublist(0, numberOfTeams);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
