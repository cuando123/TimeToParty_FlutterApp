import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../customAppBar/customAppBar_notitle.dart';
import '../drawer/drawer.dart';
import '../games_services/games_services.dart';
import '../instruction_dialog/instruction_dialog.dart';
import '../style/palette.dart';
import '../app_lifecycle/translated_text.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

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
              ValueListenableBuilder<int?>(
                valueListenable: selectedNumberOfTeams,
                builder: (BuildContext context, int? value, Widget? child) {
                  return Container(
                    width: ResponsiveText.scaleWidth(context, 200),
                    decoration: BoxDecoration(
                      color: Palette().bluegrey,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: DropdownButton<int?>(
                      value: value,
                      items: <int>[2, 3, 4, 5, 6]
                          .map<DropdownMenuItem<int>>((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '$value ',
                                style: TextStyle(
                                  fontFamily: 'HindMadurai',
                                  fontSize: ResponsiveText.scaleHeight(context, 20),
                                  color: Palette().menudark,
                                ),
                              ),
                              translatedTextSpan(context, 'x_teams', 20, Palette().menudark),
                            ],
                          ),
                        ),
                        );
                      }).toList(),
                      onChanged: (int? newValue) {
                        if (newValue != null) {
                          selectedNumberOfTeams.value = newValue;
                        }
                      },
                      dropdownColor: Palette().bluegrey,
                      style: TextStyle(
                        color: Palette().menudark,
                        fontSize: ResponsiveText.scaleHeight(context, 20),
                        fontFamily: 'HindMadurai',
                      ),
                      hint: translatedText(context,'how_many_teams', 20, Palette().menudark),
                      isExpanded: true,
                    ),
                  );
                },
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
                  GoRouter.of(context).go('/play/${selectedNumberOfTeams.value}');
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

class LogoWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    print("Screen Height: $screenHeight");
    print("Screen Width: $screenWidth");
    return Padding(
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).size.height < 650
              ? 1
              : ResponsiveText.scaleHeight(context, 20)),
      child: Column(
      children: [
        SvgPicture.asset(
          'assets/time_to_party_assets/all_stars_title.svg',
          width: ResponsiveText.scaleWidth(context, 261),
          height: ResponsiveText.scaleHeight(context, 126),
        ),
        SvgPicture.asset(
          'assets/time_to_party_assets/time_to_party_logo.svg',
          width: ResponsiveText.scaleWidth(context, 257),
          height: ResponsiveText.scaleHeight(context, 134),
        ),
      ],
    ),);
  }
}
