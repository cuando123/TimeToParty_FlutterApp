import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../customAppBar/customAppBar_notitle.dart';
import '../drawer/drawer.dart';
import '../instruction_dialog/instruction_dialog.dart';
import '../level_selection/level_selection_screen.dart';
import '../style/palette.dart';
import '../app_lifecycle/translated_text.dart';
import '../style/stars_animation.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  _MainMenuScreenState createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    )..repeat();  // Powtarza animację w nieskończoność

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 1.1),
          weight: 0.05
      ),
      TweenSequenceItem(
          tween: ConstantTween<double>(1.1),
          weight: 0.05
      ),
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.1, end: 1.0),
          weight: 0.05
      ),
      TweenSequenceItem(
          tween: ConstantTween<double>(1.0),
          weight: 0.85
      ),
    ]).animate(_animationController);
  }
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) {
        return Stack(
          children: const [
            LevelSelectionScreen(
              key: Key('level selection'),
            ),
          ],
        );
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(0.0, 1.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final audioController = context.watch<AudioController>();
    final scaffoldKey = GlobalKey<ScaffoldState>();
    return Container(
      decoration: BoxDecoration(
        gradient: Palette().backgroundLoadingSessionGradient,
      ),
      child: Scaffold(
        drawer: CustomAppDrawer(),
        key: scaffoldKey,
        appBar: CustomAppBar_notitle(
          onMenuButtonPressed: () {
            scaffoldKey.currentState?.openDrawer();
          },
          title: '',
        ),
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                Center(
                child: LogoWidget(),
          ),
          ResponsiveSizing.responsiveHeightGapWithCondition(context, 30, 45, 650),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ResponsiveSizing.responsiveHeightGapWithCondition(context, 5, 10, 650),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Palette().bluegrey, // color
                  foregroundColor: Palette().menudark, // textColor
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  minimumSize: Size(ResponsiveSizing.scaleWidth(context, 200),
                    ResponsiveSizing.responsiveHeightWithCondition(context, 51, 41, 650)),
                  //textStyle: TextStyle(fontFamily: 'HindMadurai', fontSize: ResponsiveText.scaleHeight(context, 20)),
                ),
                icon: Icon(Icons.question_mark, size: ResponsiveSizing.scaleHeight(context, 32)),
                onPressed: () {
                  Future.delayed(Duration(milliseconds: 150), () {
                    showDialog<void>(
                      context: context,
                      builder: (context) {
                        return InstructionDialog();
                      },
                    );
                  });
                },
                label: translatedText(context,'game_rules', 20, Palette().menudark),
              ),
              ResponsiveSizing.responsiveHeightGapWithCondition(context, 5, 10, 650),
              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) => Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                ), child:
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Palette().pink, // color
                  foregroundColor: Palette().white, // textColor
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  minimumSize: Size(ResponsiveSizing.scaleWidth(context, 200),
                      ResponsiveSizing.responsiveHeightWithCondition(context, 51, 41, 650)),
                  textStyle: TextStyle(fontFamily: 'HindMadurai', fontSize: ResponsiveSizing.scaleHeight(context, 20)),
                ),
                icon: Icon(Icons.play_arrow_rounded, size: 32),
                onPressed: () {
                  audioController.playSfx(SfxType.buttonTap);
                  Navigator.of(context).push(_createRoute());
                },
                label: translatedText(context,'play_now', 20, Palette().white),
              ),),
              ResponsiveSizing.responsiveHeightGapWithCondition(context, 5, 10, 650),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Palette().bluegrey, // color
                  foregroundColor: Palette().menudark, // textColor
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  minimumSize: Size(ResponsiveSizing.scaleWidth(context, 200),
                      ResponsiveSizing.responsiveHeightWithCondition(context, 51, 41, 650)),
                  textStyle: TextStyle(fontFamily: 'HindMadurai', fontSize: ResponsiveSizing.scaleHeight(context, 20)),
                ),
                icon: Icon(Icons.settings, size: ResponsiveSizing.scaleHeight(context, 32)),
                onPressed: () => GoRouter.of(context).go('/settings'),
                label: translatedText(context,'settings', 20, Palette().menudark),
              ),
              ResponsiveSizing.responsiveHeightGapWithCondition(context, 5, 10, 650),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Palette().bluegrey, // color
                  foregroundColor: Palette().menudark, // textColor
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  minimumSize: Size(ResponsiveSizing.scaleWidth(context, 200),
                      ResponsiveSizing.responsiveHeightWithCondition(context, 51, 41, 650)),
                  textStyle: TextStyle(fontFamily: 'HindMadurai', fontSize: ResponsiveSizing.scaleHeight(context, 20)),
                ),
                onPressed: () =>  SystemNavigator.pop(), //GoRouter.of(context).go('/loading'),
                child: translatedText(context,'exit', 20, Palette().menudark),
              ),
              SizedBox(height:ResponsiveSizing.scaleHeight(context, 80))
            ],
          ),
                ],),),),),
    );
  }
}
