import 'dart:core';

import 'package:flutter/material.dart';
import 'package:game_template/src/drawer/drawer.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../app_lifecycle/responsive_sizing.dart';
import '../app_lifecycle/translated_text.dart';
import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../customAppBar/customAppBar.dart';
import '../in_app_purchase/services/firebase_service.dart';
import '../notifications/notifications_manager.dart';
import '../play_session/alerts_and_dialogs.dart';
import '../play_session/custom_style_buttons.dart';
import '../style/palette.dart';
import '../style/responsive_screen.dart';
import 'settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.scaffoldKey});
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String title = '';
  String allSoundsTitle = '';
  String soundEffectsTitle = '';
  String musicTitle = '';
  String allRightsReserved = '';
  String vibrations = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      title = getTranslatedString(context, 'settings_notifications');
      allSoundsTitle = getTranslatedString(context, 'settings_all_sounds');
      soundEffectsTitle = getTranslatedString(context, 'settings_sound_effects');
      musicTitle = getTranslatedString(context, 'settings_music');
      allRightsReserved = getTranslatedString(context, 'all_rights_reserved');
      vibrations = getTranslatedString(context, 'vibrations');
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final settingsController = context.watch<SettingsController>();
    final audioController = context.watch<AudioController>();
    return WillPopScope(
      onWillPop: () async {
        audioController.playSfx(SfxType.buttonBackExit);
        GoRouter.of(context).go('/');
        return false;
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: Palette().backgroundLoadingSessionGradient,
        ),
        child: Scaffold(
          key: widget.scaffoldKey,
          drawer: CustomAppDrawer(),
          appBar: CustomAppBar(
            title: translatedText(context, 'settings', 14, Palette().white),
            onMenuButtonPressed: () {
              audioController.playSfx(SfxType.buttonBackExit);
              widget.scaffoldKey.currentState?.openDrawer();
            },
          ),
          body: ResponsiveScreen(
            squarishMainArea: Theme(
              data: Theme.of(context).copyWith(
                scrollbarTheme: ScrollbarThemeData(
                  thumbColor: MaterialStateProperty.all(Palette().white),
                ),
              ),
              child: Scrollbar(
                thumbVisibility: true,
                trackVisibility: true,
                thickness: -6.0,
                radius: Radius.circular(10),
                child: Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: ListView(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomStyledButton(
                            icon: Icons.language,
                            text: getTranslatedString(context, 'select_language'),
                            onPressed: () async {
                              audioController.playSfx(SfxType.buttonBackExit);
                              await Future.delayed(Duration(milliseconds: 150));
                              GoRouter.of(context).go('/language_selector');
                            },
                            backgroundColor: Colors.white,
                            foregroundColor: Palette().pink,
                            width: 200,
                            height: 45,
                            fontSize: ResponsiveSizing.scaleHeight(context, 20),
                          ),
                        ],
                      ),
                      ResponsiveSizing.responsiveHeightGap(context, 10),
                      TogglesControl(
                        valueNotifier: settingsController.notificationsEnabled,
                        onToggle: () {
                          // Pobierz instancję NotificationsManager z kontekstu
                          final notificationsManager = Provider.of<NotificationsManager>(context, listen: false);
                          // Przekazujemy instancję NotificationsManager do metody toggleNotifications
                          settingsController.toggleNotifications(notificationsManager);
                        },
                        title: title,
                        iconOn: Icons.notifications,
                        iconOff: Icons.notifications_off,
                      ),
                      ResponsiveSizing.responsiveHeightGap(context, 10),
                      TogglesControl(
                        valueNotifier: settingsController.muted,
                        onToggle: settingsController.toggleMuted,
                        title: allSoundsTitle,
                        iconOn: Icons.volume_up,
                        iconOff: Icons.volume_off,
                      ),
                      ResponsiveSizing.responsiveHeightGap(context, 10),
                      TogglesControl(
                        valueNotifier: settings.soundsOn,
                        onToggle: settingsController.toggleSoundsOn,
                        title: soundEffectsTitle,
                        iconOn: Icons.graphic_eq,
                        iconOff: Icons.volume_off,
                      ),
                      ResponsiveSizing.responsiveHeightGap(context, 10),
                      TogglesControl(
                        valueNotifier: settings.musicOn,
                        onToggle: settingsController.toggleMusicOn,
                        title: musicTitle,
                        iconOn: Icons.music_note,
                        iconOff: Icons.music_off,
                      ),
                      ResponsiveSizing.responsiveHeightGap(context, 10),
                      TogglesControl(
                        valueNotifier: settingsController.vibrationsEnabled,
                        onToggle: settingsController.toggleVibrations,
                        title: vibrations,
                        iconOn: Icons.vibration,
                        iconOff: Icons.close,
                      ),
                      SizedBox(height: 20),
                      translatedText(context, 'game_help_address', 12, Palette().white, textAlign: TextAlign.center),
                      TextButton(
                        onPressed: () async {
                          audioController.playSfx(SfxType.buttonBackExit);
                          await Future.delayed(Duration(milliseconds: 150));
                          AnimatedAlertDialog.showExitDialog(context);
                        },
                        child: Text(
                          'https://frydoapps.com/contact-apps',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontFamily: 'HindMadurai',
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xFFFFFFFF),
                          ),
                        ),
                      ),
                      /*
            ElevatedButton(
              onPressed: () async {
                audioController.playSfx(SfxType.buttonBackExit);
                if (settingsController.notificationsEnabled.value) {
                  String translatedTitle = getTranslatedString(context, 'weekly_notification_up');
                  String translatedBody = getTranslatedString(context, 'weekly_notification_down');
                  tz.initializeTimeZones();
                  NotificationsManager notificationsManager =
                  NotificationsManager(context, _firebaseService);
                  WidgetsFlutterBinding.ensureInitialized();
                  await notificationsManager.initializeNotifications();
                  await notificationsManager.showNotificationNow(translatedTitle, translatedBody);
                  //await notificationsManager.scheduleWeeklyNotification();
                }
              },
              child: Text("Testuj notyfikacje"),
            ),*/
                    ],
                  ),
                ),
              ),
            ),
            rectangularMenuArea: Text(
                textAlign: TextAlign.center,
                'Time To Party® ©${DateTime.now().year} Frydo Poland. $allRightsReserved',
                style: TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontFamily: 'HindMadurai',
                  fontSize: 10,
                )),
          ),
        ),
      ),
    );
  }
}

class TogglesControl extends StatelessWidget {
  final ValueNotifier<bool> valueNotifier;
  final Function onToggle;
  final String title;
  final IconData iconOn;
  final IconData iconOff;

  const TogglesControl({
    super.key,
    required this.valueNotifier,
    required this.onToggle,
    required this.title,
    required this.iconOn,
    required this.iconOff,
  });

  @override
  Widget build(BuildContext context) {
    final audioController = context.watch<AudioController>();
    return ValueListenableBuilder<bool>(
      valueListenable: valueNotifier,
      builder: (context, muted, child) => Container(
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Color(0xFFCB48EF),
                    fontFamily: 'HindMadurai',
                    fontSize: 16,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    audioController.playSfx(SfxType.buttonBackExit);
                    onToggle();
                  },
                  icon: Icon(muted ? iconOn : iconOff, color: muted ? Color(0xFFCB48EF) : Colors.grey),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                audioController.playSfx(SfxType.buttonBackExit);
                onToggle();
              },
              child: Transform.scale(
                scale: 1.0,
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 200),
                  child: muted
                      ? Container(
                          key: Key('off'),
                          width: 48,
                          height: 28,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Color(0xFFCB48EF),
                          ),
                          child: Align(
                            alignment: Alignment(0.7, 0),
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      : Container(
                          key: Key('on'),
                          width: 48,
                          height: 28,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.grey,
                          ),
                          child: Align(
                            alignment: Alignment(-0.7, 0),
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                  transitionBuilder: (child, animation) => ScaleTransition(
                    scale: animation,
                    child: child,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RectSliderThumbShape extends SliderComponentShape {
  final double thumbRadius;

  const RectSliderThumbShape({required this.thumbRadius});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    bool? isDiscrete,
    TextPainter? labelPainter,
    RenderBox? parentBox,
    required SliderThemeData sliderTheme,
    TextDirection? textDirection,
    double? value,
    double? textScaleFactor,
    Size? sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;
    final Paint paint = Paint()
      ..color = sliderTheme.thumbColor!
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromCenter(
        center: center,
        width: thumbRadius * 2,
        height: thumbRadius * 2,
      ),
      paint,
    );
  }
}

class CustomRectangularSliderTrackShape extends SliderTrackShape {
  final Radius borderRadius;

  CustomRectangularSliderTrackShape({required this.borderRadius});

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    bool isEnabled = false,
    bool isDiscrete = false,
    Offset? secondaryOffset,
  }) {
    final double trackHeight = sliderTheme.trackHeight!;
    final double trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackLeft = offset.dx;
    final double trackWidth = parentBox.size.width;
    final double activeTrackWidth =
        thumbCenter.dx - trackLeft - sliderTheme.thumbShape!.getPreferredSize(isEnabled, isDiscrete).width / 2;

    final RRect leftTrack = RRect.fromLTRBR(
      trackLeft,
      trackTop,
      trackLeft + activeTrackWidth,
      trackTop + trackHeight,
      borderRadius,
    );
    final RRect rightTrack = RRect.fromLTRBR(
      trackLeft + activeTrackWidth,
      trackTop,
      trackLeft + trackWidth,
      trackTop + trackHeight,
      borderRadius,
    );

    context.canvas.drawRRect(leftTrack, Paint()..color = sliderTheme.activeTrackColor ?? Colors.black);
    context.canvas.drawRRect(rightTrack, Paint()..color = sliderTheme.inactiveTrackColor ?? Colors.black);
  }

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
    Offset offset = Offset.zero,
  }) {
    final double thumbWidth = sliderTheme.thumbShape!.getPreferredSize(isEnabled, isDiscrete).width;
    final double trackHeight = sliderTheme.trackHeight!;
    final double trackLeft = offset.dx + thumbWidth / 2;
    final double trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width - thumbWidth;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
