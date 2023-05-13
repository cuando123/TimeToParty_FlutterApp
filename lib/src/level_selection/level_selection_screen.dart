import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../customAppBar/customAppBar.dart';
import '../drawer/drawer.dart';
import '../style/palette.dart';
import 'dart:math';
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
  static final scaffoldKey = GlobalKey<ScaffoldState>();
  late List<Color> teamColors;
  List<Color> availableColors = [
    Colors.yellow,
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.purple,
    Colors.orange,
  ];

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
    teamNames = List<String>.filled(widget.numberOfTeams, '');
    teamColors = _initializeColors(widget.numberOfTeams);
    // Inicjalizacja kontrolerów dla każdego zespołu
    for (int i = 0; i < widget.numberOfTeams; i++) {
      controllers.add(TextEditingController());
    }
  }
  Color _getRandomColor(int index) {
    int randomIndex = Random().nextInt(availableColors.length);
    return availableColors[randomIndex];
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
    final _gap_left = SizedBox(width: MediaQuery.of(context).size.width < 300
        ? ResponsiveText.scaleHeight(context, 5)
        : ResponsiveText.scaleHeight(context, 10));
    return GestureDetector(
      onTap: (){
        if (!FocusScope.of(context).hasPrimaryFocus){
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
              title: translatedText(context, 'enter_team_names', 14, Palette().white),
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
                      height: ResponsiveText.scaleHeight(context, 155),
                      child: LogoWidget_notitle(),
                    ),
                    Column(
                      children: List.generate(widget.numberOfTeams, (index) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 10.0),  // Dodaj odstęp pomiędzy każdym wierszem
                          child: Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 50.0,  // Ustal wysokość pola tekstowego
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
                                    decoration: InputDecoration(
                                      hintText: 'Drużyna ${index + 1}',
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
                                padding: EdgeInsets.only(left: 5.0),  // Dodaj odstęp pomiędzy polem tekstowym a polem koloru
                                child: Container(
                                  width: 50,
                                  height: 50.0,  // Ustal wysokość pola koloru, aby była taka sama jak wysokość pola tekstowego
                                  decoration: BoxDecoration(
                                    color: teamColors[index],
                                    borderRadius: BorderRadius.circular(8.0),  // Zaokrąglenie narożników
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
                        mainAxisAlignment: MainAxisAlignment.center, // Wyśrodkowanie przycisków
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
                              textStyle:
                              TextStyle(fontFamily: 'HindMadurai', fontSize: 20),
                            ),
                            icon: Icon(Icons.play_arrow_rounded, size: 32),
                            onPressed: () {
                              _toggleCelebration();
                            },
                            label: translatedText(
                                context, 'play_now', 20, Palette().white),
                          ),
                          _gap_left,
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
                                List<Color> shuffledColors = List.from(availableColors)..shuffle();
                                teamColors = shuffledColors.sublist(0, widget.numberOfTeams);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
            ],
          ),),),
        ),),);
  }
}
