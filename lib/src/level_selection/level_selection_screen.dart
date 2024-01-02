import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:game_template/src/Loading_screen/loading_screen_second.dart';
import 'package:game_template/src/level_selection/team_provider.dart';
import 'package:provider/provider.dart';

import '../app_lifecycle/responsive_sizing.dart';
import '../app_lifecycle/translated_text.dart';
import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../customAppBar/customAppBar.dart';
import '../drawer/drawer.dart';
import '../play_session/custom_style_buttons.dart';
import '../style/palette.dart';

class LevelSelectionScreen extends StatefulWidget {
  const LevelSelectionScreen({super.key});

  @override
  _LevelSelectionScreenState createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen> with SingleTickerProviderStateMixin {
  List<TextEditingController> controllers = [];
  bool _duringCelebration = false;
  static final scaffoldKey = GlobalKey<ScaffoldState>();
  late List<Color> teamColors;
  int numberOfTeams = 2;
  List<Color> availableColors = [
    Color(0xFF00A2AC),
    Color(0xFF01B210),
    Color(0xFF9400AC),
    Color(0xFFF50000),
    Color(0xFFFFD335),
    Color(0xFF1C1AAA)
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

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _scaleAnimationPlusButton;
  late Animation<double> _scaleAnimationSelectColorButton;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TeamProvider>(context, listen: false).initializeTeams(context, numberOfTeams);
    });
    teamColors = _initializeColors(numberOfTeams);
    _animationController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    )..repeat(); // Powtarza animację w nieskończoność

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.1), weight: 0.05),
      TweenSequenceItem(tween: ConstantTween<double>(1.1), weight: 0.05),
      TweenSequenceItem(tween: Tween<double>(begin: 1.1, end: 1.0), weight: 0.05),
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 0.85),
    ]).animate(_animationController);

    _scaleAnimationPlusButton = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 0.4),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.1), weight: 0.05),
      TweenSequenceItem(tween: ConstantTween<double>(1.1), weight: 0.05),
      TweenSequenceItem(tween: Tween<double>(begin: 1.1, end: 1.0), weight: 0.05),
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 0.45),
    ]).animate(_animationController);

    _scaleAnimationSelectColorButton = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 0.6),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.1), weight: 0.05),
      TweenSequenceItem(tween: ConstantTween<double>(1.1), weight: 0.05),
      TweenSequenceItem(tween: Tween<double>(begin: 1.1, end: 1.0), weight: 0.05),
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 0.25),
    ]).animate(_animationController);
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<TeamProvider, List<String>>(
      selector: (_, provider) => provider.teamNames,
      builder: (_, teamNames, __) {
        if (controllers.length != teamNames.length) {
          controllers = List.generate(teamNames.length, (_) => TextEditingController());
        }
        for (int i = 0; i < teamNames.length; i++) {
          controllers[i].text = teamNames[i];
        }
        return GestureDetector(
          onTap: () {
            if (!FocusScope.of(context).hasPrimaryFocus) {
              FocusScope.of(context).requestFocus(FocusNode());
            }
            final audioController = context.read<AudioController>();
            audioController.playSfx(SfxType.button_back_exit);
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
                  final audioController = context.read<AudioController>();
                  audioController.playSfx(SfxType.button_back_exit);
                  scaffoldKey.currentState?.openDrawer();
                },
                onBackButtonPressed: () {
                  Navigator.pop(context);
                },
              ),
              body: SafeArea(
                child: Scrollbar(
                  thumbVisibility: true,
                  trackVisibility: true,
                  thickness: -6.0,
                  radius: Radius.circular(10),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Consumer<TeamProvider>(
                      builder: (context, teamProvider, child) {
                        return Column(
                          children: [
                            SizedBox(
                              width: ResponsiveSizing.scaleWidth(context, 290),
                              child: LogoWidget_notitle(),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                SvgPicture.asset('assets/time_to_party_assets/team_icon.svg',
                                    height: ResponsiveSizing.scaleHeight(context, 40)),
                                ResponsiveSizing.responsiveWidthGapWithCondition(context, 5, 10, 300),
                                AnimatedBuilder(
                                  animation: _scaleAnimationPlusButton,
                                  builder: (context, child) => Transform.scale(
                                    scale: _scaleAnimationPlusButton.value,
                                    child: child,
                                  ),
                                  child: CustomElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white, // color
                                      foregroundColor: Color(0xFFCB48EF), // textColor
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      minimumSize: Size(MediaQuery.of(context).size.width * 0.05,
                                          MediaQuery.of(context).size.height * 0.05),
                                    ),
                                    onPressed: numberOfTeams >= availableColors.length
                                        ? null
                                        : () {
                                            setState(() {
                                              numberOfTeams++;
                                              teamColors = _initializeColors(numberOfTeams);
                                              teamProvider.updateTeams(context, numberOfTeams);
                                            });
                                            final audioController = context.read<AudioController>();
                                            audioController.playSfx(SfxType.button_back_exit);
                                          },
                                    child: Icon(Icons.add),
                                  ),
                                ),
                                ResponsiveSizing.responsiveWidthGapWithCondition(context, 5, 10, 300),
                                CustomElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white, // color
                                    foregroundColor: Color(0xFFCB48EF), // textColor
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    minimumSize: Size(MediaQuery.of(context).size.width * 0.05,
                                        MediaQuery.of(context).size.height * 0.05),
                                  ),
                                  onPressed: numberOfTeams <= 2
                                      ? null
                                      : () {
                                          setState(() {
                                            numberOfTeams--;
                                            teamColors = _initializeColors(numberOfTeams);
                                            teamProvider.updateTeams(context, numberOfTeams);
                                          });
                                          final audioController = context.read<AudioController>();
                                          audioController.playSfx(SfxType.button_back_exit);
                                        },
                                  child: Icon(Icons.remove),
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
                                              teamProvider.updateTeamName(index, text);
                                            },
                                            style: TextStyle(
                                              color: Color(0xFFA0A0A0),
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            onTap: () {
                                              final audioController = context.read<AudioController>();
                                              audioController.playSfx(SfxType.button_back_exit);
                                              if (!teamProvider.hasUserInput[index]) {
                                                teamProvider.updateTeamName(index, '');
                                              }
                                            },
                                            decoration: InputDecoration(
                                              hintText: teamProvider.teamNames[index],
                                              hintStyle: TextStyle(
                                                color: Color(0xFFA0A0A0),
                                              ),
                                              filled: true, // Włącz tło
                                              fillColor: Colors.white,
                                              counterText: '',
                                            ),
                                            maxLength: 15,
                                            maxLines: 1,
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
                                            borderRadius: BorderRadius.circular(8.0),
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
                                  AnimatedBuilder(
                                    animation: _scaleAnimation,
                                    builder: (context, child) => Transform.scale(
                                      scale: _scaleAnimation.value,
                                      child: child,
                                    ),
                                    child: CustomStyledButton(
                                      icon: Icons.play_arrow_rounded,
                                      text: getTranslatedString(context, 'play_now'),
                                      onPressed: () {
                                        final audioController = context.read<AudioController>();
                                        audioController.playSfx(SfxType.button_accept);
                                        _toggleCelebration();
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => LoadingScreenSecond(
                                              teamNames: teamProvider.teamNames,
                                              teamColors: teamColors,
                                            ),
                                          ),
                                        );
                                      },
                                      backgroundColor: Palette().pink,
                                      foregroundColor: Palette().white,
                                      width: 190,
                                      height: 45,
                                      fontSize: ResponsiveSizing.scaleHeight(context, 20),
                                    ),
                                  ),
                                  ResponsiveSizing.responsiveWidthGapWithCondition(context, 5, 10, 300),
                                  AnimatedBuilder(
                                    animation: _scaleAnimationSelectColorButton,
                                    builder: (context, child) => Transform.scale(
                                      scale: _scaleAnimationSelectColorButton.value,
                                      child: child,
                                    ),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white, // color
                                        foregroundColor: Color(0xFFCB48EF), // textColor
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        minimumSize: Size(MediaQuery.of(context).size.width * 0.05,
                                            MediaQuery.of(context).size.height * 0.05),
                                      ),
                                      onPressed: () {
                                        final audioController = context.read<AudioController>();
                                        audioController.playSfx(SfxType.button_back_exit);
                                        setState(() {
                                          List<Color> shuffledColors = List.from(availableColors)..shuffle();
                                          teamColors = shuffledColors.sublist(0, numberOfTeams);
                                        });
                                      },
                                      child: Icon(Icons.color_lens),
                                    ),
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
          ),
        );
      },
    );
  }
}
