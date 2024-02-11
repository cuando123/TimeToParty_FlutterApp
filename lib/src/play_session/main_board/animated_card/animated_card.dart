import 'dart:math';

import 'package:fan_carousel_image_slider/fan_carousel_image_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_template/src/app_lifecycle/responsive_sizing.dart';
import 'package:game_template/src/play_session/alerts_and_dialogs.dart';
import 'package:game_template/src/play_session/main_board/animated_card/pulsating_text.dart';
import 'package:game_template/src/style/palette.dart';
import 'package:newton_particles/newton_particles.dart';
import 'package:provider/provider.dart';

import '../../../app_lifecycle/translated_text.dart';
import '../../../audio/audio_controller.dart';
import '../../../audio/sounds.dart';
import 'animated_hand.dart';
import 'animated_question_mark.dart';

class AnimatedCard extends StatefulWidget {
  final Function onCardTapped;
  final Function onArrowCardTapped;
  final String selectedCardIndex;
  final BuildContext parentContext;
  final String currentTeamName;
  final Color teamColor;
  final bool showAnimatedCard;
  final Function(String) onCardSelected;

  const AnimatedCard(
      {super.key,
      required this.showAnimatedCard,
      required this.onCardTapped,
      required this.onArrowCardTapped,
      required this.selectedCardIndex,
      required this.parentContext,
      required this.currentTeamName,
      required this.teamColor,
      required this.onCardSelected});

  @override
  _AnimatedCardState createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _arrowController;
  late AnimationController _pulseController;
  late AnimationController _questionMarkPulseController;
  late AnimationController _fadeController;
  late Animation<double> _questionMarkPulseAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _positionAnimation;
  late Animation<Offset> _textTopPositionAnimation;
  late Animation<Offset> _textBottomPositionAnimation;
  late Animation<Offset> _arrowAnimation;
  bool showCardAnimation = true;
  bool hasShownAlertDialog = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500), //czas animacji wyskoku karty
      vsync: this,
    );
    _arrowController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(seconds: 1), // Czas trwania animacji przyciemnienia
      vsync: this,
    );

    // Rozpocznij animację przyciemnienia
    _fadeController.forward();

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _controller, curve: Interval(0.0, 0.5, curve: Curves.easeInOut)),
    );

    _scaleAnimation = Tween<double>(begin: 0.1, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Interval(0.0, 0.5, curve: Curves.easeInOut)),
    );

    _positionAnimation = Tween<Offset>(
      begin: Offset(0.0, -0.5),
      end: Offset(0.0, 0.0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (showCardAnimation) {
      _controller.forward().then((value) {});
    }

    _textTopPositionAnimation = Tween<Offset>(
      begin: Offset(0.0, -2.0),
      end: Offset(0.0, 0.0),
    ).animate(CurvedAnimation(parent: _controller, curve: Interval(0.6, 1.0, curve: Curves.easeInOut)));

    _textBottomPositionAnimation = Tween<Offset>(
      begin: Offset(0.0, 2.0),
      end: Offset(0.0, 0.0),
    ).animate(CurvedAnimation(parent: _controller, curve: Interval(0.6, 1.0, curve: Curves.easeInOut)));

    // Inicjalizacja kontrolera animacji pulsowania
    _pulseController = AnimationController(
      duration: Duration(seconds: 4), // Całkowity czas trwania cyklu animacji
      vsync: this,
    )..repeat(); // Powtarza animację w nieskończoność

    // Inicjalizacja animacji pulsowania używając TweenSequence
    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 1.1), // Zwiększa skalę
          weight: 0.05),
      TweenSequenceItem(
          tween: ConstantTween<double>(1.1), // Utrzymuje skalę
          weight: 0.05),
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.1, end: 1.0), // Zmniejsza skalę
          weight: 0.05),
      TweenSequenceItem(
          tween: ConstantTween<double>(1.0), // Utrzymuje skalę
          weight: 0.85),
    ]).animate(_pulseController);

    _questionMarkPulseController = AnimationController(
      duration: const Duration(seconds: 1), // Okres jednego pulsowania
      vsync: this,
    );

// Dodaj opóźnienie przed rozpoczęciem powtarzania animacji
    Future.delayed(Duration(seconds: 1), () {
      _questionMarkPulseController.repeat(reverse: true); // Powtarza animację w nieskończoność z odwróceniem
    });

    _questionMarkPulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _questionMarkPulseController, curve: Curves.easeInOut),
    );

    _arrowAnimation = Tween<Offset>(
      begin: Offset(0.0, -0.3), // Małe przesunięcie w górę
      end: Offset(0.0, 0.3), // Małe przesunięcie w dół
    ).animate(CurvedAnimation(parent: _arrowController, curve: Curves.easeInOut))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _arrowController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _arrowController.forward();
        }
      });
    _arrowController.forward();
    _controller.addListener(() {
      setState(() {});
    });
  }

  final Map<String, String> fieldDescriptions = {
    'field_arrows': 'field_arrows_description',
    'field_sheet': 'field_sheet_description',
    'field_letters': 'field_letters_description',
    'field_pantomime': 'field_pantomime_description',
    'field_microphone': 'field_microphone_description',
    'field_taboo': 'field_taboo_description',
    'field_start': 'field_start_description',
    'field_star_blue_dark': 'field_star_blue_dark_description',
    'field_star_pink': 'field_star_pink_description',
    'field_star_green': 'field_star_green_description',
    'field_star_yellow': 'field_star_yellow_description',
  };

  void onCardSelected(String selectedCard) {
    widget.onCardSelected(selectedCard); // Wywołaj callback przekazany do widgetu
  }

  @override
  Widget build(BuildContext context) {
    String cardDescription = getTranslatedString(context, fieldDescriptions[widget.selectedCardIndex] ?? "default_key");
    if (!widget.showAnimatedCard) {
      return Container();
    } else {
      return WillPopScope(
        onWillPop: () async {
          await SystemChrome.setEnabledSystemUIMode(
            SystemUiMode.manual,
            overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
          );
          AnimatedAlertDialog.showExitGameDialog(context, hasShownAlertDialog, '',
              widget.currentTeamName as List<String>, widget.teamColor as List<Color>, false);
          return false; // return false to prevent the pop operation
        }, // Zablokowanie możliwości cofnięcia
        child: Stack(
          children: [
            // Przyciemnienie
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _fadeController,
                builder: (context, child) {
                  return AnimatedOpacity(
                    opacity: _fadeController.value * 0.9, // Opacity będzie zmieniać się od 0 do 0.7
                    duration: const Duration(milliseconds: 500), // Czas trwania animacji
                    child: Container(
                      color: Colors.black,
                    ),
                  );
                },
              ),
            ),

            SlideTransition(
              position: _textTopPositionAnimation,
              child: Align(
                  alignment: Alignment(0.0, -0.8),
                  child: Text(
                    widget.currentTeamName,
                    style: TextStyle(
                      fontStyle: FontStyle.normal,
                      fontFamily: 'HindMadurai',
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  )),
            ),
            ResponsiveSizing.responsiveHeightGapWithCondition(context, 20, 0, 650),
            SlideTransition(
              position: _textTopPositionAnimation,
              child: Align(
                  alignment: Alignment(0.0, -0.7),
                  child: Image.asset('assets/time_to_party_assets/team_icon.png',
                      height: 40, color: widget.teamColor
                  )

              ),
            ),
            //TO_DO przetestowac co sie tu stanie
            ResponsiveSizing.responsiveHeightGapWithCondition(context, 20, 0, 650),
            SlideTransition(
              position: _textTopPositionAnimation,
              child: Align(
                  alignment: Alignment(0.0, -0.55),
                  child: Text(
                    cardDescription,
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontFamily: 'HindMadurai',
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  )),
            ),
            ResponsiveSizing.responsiveHeightGapWithCondition(context, 20, 0, 650),
            SlideTransition(
              position: _textTopPositionAnimation,
              child: Align(
                alignment: Alignment(0.0, -0.4),
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) => Transform.scale(
                    scale: _pulseAnimation.value,
                    alignment: Alignment.center, // Zapewnia skalowanie wokół środka widgetu
                    child: child,
                  ),
                  child: translatedText(context, 'click_the_card_to_start', 18, Colors.white),
                ),
              ),
            ),
            ResponsiveSizing.responsiveHeightGapWithCondition(context, 20, 0, 650),
            SlideTransition(
              position: _textTopPositionAnimation,
              child: Align(
                alignment: Alignment(0.0, -0.28),
                child: SlideTransition(
                  position: _arrowAnimation,
                  child: Icon(Icons.arrow_downward_sharp, color: Colors.white, size: 30),
                ),
              ),
            ),
            // Napis na dole
            ResponsiveSizing.responsiveHeightGapWithCondition(context, 20, 0, 650),
            SlideTransition(
              position: _textBottomPositionAnimation,
              child: Align(
                alignment: Alignment(0.0, 0.7), // Wyśrodkuj poziomo
                child: FractionallySizedBox(
                  widthFactor: 0.9, // Zapewnia, że box zajmuje pełną szerokość rodzica
                  child: translatedText(context, 'pass_the_device_to_the_person', 18, Colors.white,
                      textAlign: TextAlign.center),
                ),
              ),
            ),
            Newton(
              activeEffects: [
                ExplodeEffect(
                  particleConfiguration: ParticleConfiguration(
                    shape: CircleShape(),
                    size: Size(3, 3),
                    color: SingleParticleColor(color: Colors.white54.withAlpha(50)),
                  ),
                  effectConfiguration: EffectConfiguration(
                    particlesPerEmit: 1,
                    emitDuration: 200,
                    minAngle: 0, maxBeginScale: 1, maxEndScale: 2, minBeginScale: 1, minEndScale: 1,
                    maxAngle: 360, // Pełen zakres kątów dla efektu eksplozji
                    minDuration: 4000,
                    maxDuration: 7000,
                    minDistance: 200,
                    maxDistance: 200,
                    minFadeOutThreshold: 0.6,
                    maxFadeOutThreshold: 0.8,
                    scaleCurve: Curves.easeInOutCubic,
                    distanceCurve: Curves.decelerate,
                    origin: Offset(
                        MediaQuery.of(context).size.width / 2, MediaQuery.of(context).size.height / 2), // Środek ekranu
                  ),
                ),
              ],
            ),

            SlideTransition(
              position: _textBottomPositionAnimation,
              child: GestureDetector(
                onTap: () {
                  final audioController = context.read<AudioController>();
                  audioController.playSfx(SfxType.button_infos);
                  AnimatedAlertDialog.showCardDescriptionDialog(
                      context, widget.selectedCardIndex, AlertOrigin.otherScreen);
                },
                child: Align(
                  alignment: Alignment(0.0, 0.55),
                  child: AnimatedBuilder(
                    animation: _questionMarkPulseAnimation,
                    builder: (context, child) => Transform.scale(
                      scale: _questionMarkPulseAnimation.value,
                      child: child,
                    ),
                    child: Container(
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Color(0xFF2899F3),
                        child: Text('?',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                fontFamily: 'HindMadurai')),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Karta
            Align(
              alignment: Alignment(0.0, 0.15),
              child: SlideTransition(
                position: _positionAnimation,
                child: Transform.rotate(
                  angle: _rotationAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: GestureDetector(
                      //gesture detector na karcie ktora sie obroci nastepnie w nią klikamy
                      onTap: () {
                        final audioController = context.read<AudioController>();
                        audioController.playSfx(SfxType.buttonAccept);
                        if (widget.selectedCardIndex == 'field_arrows') {
                          widget.onArrowCardTapped();
                          _showStackedCardCrousel(context, widget.onCardSelected);
                        } else {
                          widget.onCardTapped(); // Dla innych kart
                        }
                      },
                      child: Container(
                        width: ResponsiveSizing.scaleWidth(context, 135),
                        height: ResponsiveSizing.scaleHeight(context, 250), //250 tablet, 290samsung?
                        color: Colors.transparent,
                        child: _getCardContent(widget.selectedCardIndex),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _getCardContent(String cardIndex) {
    // Sprawdzanie czy cardIndex istnieje w mapie cardTypeImagePaths
    if (cardTypeImagePaths.containsKey(cardIndex)) {
      return Image.asset(cardTypeImagePaths[cardIndex]!, fit: BoxFit.contain);
    }
    return Text('Kliknij mnie!');
  }

  final Map<String, String> cardTypeImagePaths = {
    'field_arrows': 'assets/time_to_party_assets/card_arrows.png',
    'field_sheet': 'assets/time_to_party_assets/card_rymes.png',
    'field_letters': 'assets/time_to_party_assets/card_letters.png',
    'field_pantomime': 'assets/time_to_party_assets/card_pantomime.png',
    'field_microphone': 'assets/time_to_party_assets/card_microphone.png',
    'field_taboo': 'assets/time_to_party_assets/card_taboo.png',
    'field_star_blue_dark': 'assets/time_to_party_assets/card_star_blue_dark.png',
    'field_star_pink': 'assets/time_to_party_assets/card_star_pink.png',
    'field_star_green': 'assets/time_to_party_assets/card_star_green.png',
    'field_star_yellow': 'assets/time_to_party_assets/card_star_yellow.png'
  };

  final List<String> cardTypesToSelect = [
    'assets/time_to_party_assets/card_taboo.png',
    'assets/time_to_party_assets/card_microphone.png',
    'assets/time_to_party_assets/card_letters.png',
    'assets/time_to_party_assets/card_pantomime.png',
    'assets/time_to_party_assets/card_rymes.png',
  ];

  Map<int, String> cardFieldNames = {
    0: 'field_taboo',
    1: 'field_microphone',
    2: 'field_letters',
    3: 'field_pantomime',
    4: 'field_sheet',
  };

  Future<void> _showStackedCardCrousel(BuildContext context, Function(String) onCardSelected) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return WillPopScope(
          onWillPop: () async {
            AnimatedAlertDialog.showExitGameDialog(context, hasShownAlertDialog, '',
                widget.currentTeamName as List<String>, widget.teamColor as List<Color>, false);
            return false; // return false to prevent the pop operation
          },
          child: Dialog(
            backgroundColor: Colors.black54,
            shadowColor: Colors.transparent,
            insetPadding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            elevation: 0,
            child: SizedBox(
                width: MediaQuery.of(context).size.width, // Określ szerokość
                height: MediaQuery.of(context).size.height,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PulsatingText(
                        text: getTranslatedString(context, 'choose_the_card'),
                        textStyle: TextStyle(fontFamily: 'HindMadurai', color: Colors.white),
                        size: 22),
                    SizedBox(height: 30),
                    AnimatedHandArrow(),
                    SizedBox(height: 20),
                    FanCarouselImageSlider(
                      imagesLink: cardTypesToSelect,
                      slideViewportFraction: MediaQuery.of(context).size.width >= 600 ? 0.38 : 0.42,
                      isAssets: true,
                      autoPlay: false,
                      sliderDuration: Duration(milliseconds: 200),
                      sliderHeight:
                          MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.height >= 800
                              ? MediaQuery.of(context).size.height * 0.4
                              : MediaQuery.of(context).size.height >= 780
                                  ? 260
                                  : MediaQuery.of(context).size.height * 0.4,
                      sliderWidth: MediaQuery.of(context).size.width,
                      imageRadius: 20,
                      indicatorActiveColor: Palette().pink,
                      initalPageIndex: 0,
                      onImageTaps: [
                        (index) {
                          onCardSelected(cardFieldNames[index] ?? 'default_field');
                        },
                        (index) {
                          onCardSelected(cardFieldNames[index] ?? 'default_field');
                        },
                        (index) {
                          onCardSelected(cardFieldNames[index] ?? 'default_field');
                        },
                        (index) {
                          onCardSelected(cardFieldNames[index] ?? 'default_field');
                        },
                        (index) {
                          onCardSelected(cardFieldNames[index] ?? 'default_field');
                        },
                      ],
                    ),
                    SizedBox(height: 30),
                    AnimatedQuestionMark(),
                    SizedBox(height: 90)
                  ],
                )),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _arrowController.dispose();
    _pulseController.dispose();
    _questionMarkPulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }
}
