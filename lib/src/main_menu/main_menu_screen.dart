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
import '../style/balloon_animation.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  Route _createRoute(int numberOfTeams) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) {
        return Stack(
          children: [
            LevelSelectionScreen(
              key: Key('level selection'),
            ),
            BalloonAnimation(),
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

    final _gap = SizedBox(height: MediaQuery.of(context).size.height < 650
        ? ResponsiveText.scaleHeight(context, 5)
        : ResponsiveText.scaleHeight(context, 10));
    final _gapBig = SizedBox(height: MediaQuery.of(context).size.height < 650
        ? ResponsiveText.scaleHeight(context, 30)
        : ResponsiveText.scaleHeight(context, 45));
    final audioController = context.watch<AudioController>();
    final scaffoldKey = GlobalKey<ScaffoldState>();
    ValueNotifier<int?> selectedNumberOfTeams = ValueNotifier<int?>(null);
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
          _gapBig,
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _gap,
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Palette().bluegrey, // color
                  foregroundColor: Palette().menudark, // textColor
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  minimumSize: Size(ResponsiveText.scaleWidth(context, 200),
                      MediaQuery.of(context).size.height < 650
                          ? ResponsiveText.scaleHeight(context, 51)
                          : ResponsiveText.scaleHeight(context, 41)),
                  //textStyle: TextStyle(fontFamily: 'HindMadurai', fontSize: ResponsiveText.scaleHeight(context, 20)),
                ),
                icon: Icon(Icons.question_mark, size: ResponsiveText.scaleHeight(context, 32)),
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
              _gap,
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Palette().pink, // color
                  foregroundColor: Palette().white, // textColor
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  minimumSize: Size(ResponsiveText.scaleWidth(context, 200),
                      MediaQuery.of(context).size.height < 650
                          ? ResponsiveText.scaleHeight(context, 51)
                          : ResponsiveText.scaleHeight(context, 41)),
                  textStyle: TextStyle(fontFamily: 'HindMadurai', fontSize: ResponsiveText.scaleHeight(context, 20)),
                ),
                icon: Icon(Icons.play_arrow_rounded, size: 32),
                onPressed: () {
                  audioController.playSfx(SfxType.buttonTap);
                  Navigator.of(context).push(_createRoute(selectedNumberOfTeams.value ?? 2));
                },
                label: translatedText(context,'play_now', 20, Palette().white),
              ),
              _gap,
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Palette().bluegrey, // color
                  foregroundColor: Palette().menudark, // textColor
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  minimumSize: Size(ResponsiveText.scaleWidth(context, 200),
                      MediaQuery.of(context).size.height < 650
                          ? ResponsiveText.scaleHeight(context, 51)
                          : ResponsiveText.scaleHeight(context, 41)),
                  textStyle: TextStyle(fontFamily: 'HindMadurai', fontSize: ResponsiveText.scaleHeight(context, 20)),
                ),
                icon: Icon(Icons.settings, size: ResponsiveText.scaleHeight(context, 32)),
                onPressed: () => GoRouter.of(context).go('/settings'),
                label: translatedText(context,'settings', 20, Palette().menudark),
              ),
              _gap,
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Palette().bluegrey, // color
                  foregroundColor: Palette().menudark, // textColor
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  minimumSize: Size(ResponsiveText.scaleWidth(context, 200),
                      MediaQuery.of(context).size.height < 650
                          ? ResponsiveText.scaleHeight(context, 51)
                          : ResponsiveText.scaleHeight(context, 41)),
                  textStyle: TextStyle(fontFamily: 'HindMadurai', fontSize: ResponsiveText.scaleHeight(context, 20)),
                ),
                onPressed: () =>  SystemNavigator.pop(), //GoRouter.of(context).go('/loading'),
                child: translatedText(context,'exit', 20, Palette().menudark),
              ),
              SizedBox(height:ResponsiveText.scaleHeight(context, 80))
            ],
          ),
                ],),),),),
    );
  }
}
