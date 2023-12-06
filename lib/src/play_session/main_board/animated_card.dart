import 'dart:math';

import 'package:fan_carousel_image_slider/fan_carousel_image_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:game_template/src/play_session/alerts_and_dialogs.dart';
import 'package:game_template/src/style/palette.dart';

import '../../app_lifecycle/translated_text.dart';
import '../custom_style_buttons.dart';

class AnimatedCard extends StatefulWidget {
  final Function onCardTapped;
  final Function onArrowCardTapped;
  late final String selectedCardIndex;
  final BuildContext parentContext;
  final String currentTeamName;
  final Color teamColor;
  final bool showAnimatedCard;
  final Function(String) onCardSelected;

  AnimatedCard(
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
    'field_arrows': 'Wybierz kartę i zaskocz wszystkich!',
    'field_sheet': 'Układaj rymy i baw się słowami!',
    'field_letters': 'Wymyśl 20 rzeczowników na daną literę!',
    'field_pantomime': 'Mów ciałem, nie słowami!',
    'field_microphone': 'Odgadnij sławne osobowości!',
    'field_taboo': 'Taboo - Opisuj, omijając zakazane słowa!',
    'field_star_blue_dark': 'Zadanie fizyczne? Zmierz się z czasem!',
    'field_star_pink': 'Baw się językiem! Twórz antonimy i synonimy.',
    'field_star_green': 'Ty rysujesz, oni zgadują. Gotowi?',
    'field_star_yellow': 'Porównaj, analizuj, odpowiadaj!',
  };
  String getCardDescription(String cardIndex) {
    return fieldDescriptions[cardIndex] ??
        'Brak opisu dla tej karty'; // Użycie operatora ??, aby zapewnić wartość domyślną
  }

  void onCardSelected(String selectedCard) {
    widget.onCardSelected(selectedCard); // Wywołaj callback przekazany do widgetu
  }

  @override
  Widget build(BuildContext context) {
    String cardDescription = getCardDescription(widget.selectedCardIndex);
    if (!widget.showAnimatedCard) {
      return Container();
    } else {
      return Stack(
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
                alignment: Alignment(0.0, -0.9),
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
          SlideTransition(
            position: _textTopPositionAnimation,
            child: Align(
                alignment: Alignment(0.0, -0.8),
                child:
                    SvgPicture.asset('assets/time_to_party_assets/team_icon.svg', height: 40, color: widget.teamColor)),
          ),
          SlideTransition(
            position: _textTopPositionAnimation,
            child: Align(
                alignment: Alignment(0.0, -2),
                child: Text(
                  cardDescription,
                  style: TextStyle(
                    fontStyle: FontStyle.italic, // Ustawienie tekstu na kursywę
                    height: 40.0, // Ustawienie wysokości tekstu
                    fontFamily: 'HindMadurai', // Ustawienie czcionki na Hind Madurai
                    color: Colors.white, // Ustawienie koloru tekstu na biały
                    fontSize: 15, // Możesz dostosować rozmiar czcionki zgodnie z potrzebami
                  ),
                )),
          ),

          SlideTransition(
            position: _textTopPositionAnimation,
            child: Align(
              alignment: Alignment(0.0, -0.5),
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) => Transform.scale(
                  scale: _pulseAnimation.value,
                  alignment: Alignment.center, // Zapewnia skalowanie wokół środka widgetu
                  child: child,
                ),
                child: Text(
                  "Kliknij w kartę aby zacząć",
                  style: TextStyle(color: Colors.white, fontSize: 20, fontFamily: 'HindMadurai'),
                ),
              ),
            ),
          ),
          SlideTransition(
            position: _textTopPositionAnimation,
            child: Align(
              alignment: Alignment(0.0, -0.4),
              child: SlideTransition(
                position: _arrowAnimation,
                child: Icon(Icons.arrow_downward_sharp, color: Colors.white, size: 30),
              ),
            ),
          ),

          SlideTransition(
            position: _textBottomPositionAnimation,
            child: GestureDetector(
              onTap: () {
                AnimatedAlertDialog.showCardDescriptionDialog(
                    context, widget.selectedCardIndex, AlertOrigin.otherScreen);
                //_showMyDialog(context); // Wywołanie funkcji wyświetlającej AlertDialog
              },
              child: Align(
                alignment: Alignment(0.0, 0.45),
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

          // Napis na dole
          SlideTransition(
            position: _textBottomPositionAnimation,
            child: Align(
              alignment: Alignment(0.0, 0.6), // Aby dostosować położenie napisu, możesz zmienić wartość 0.7
              child: Text(
                "Przekaż urządzenie osobie opisującej!",
                style: TextStyle(color: Colors.white, fontSize: 20, fontFamily: 'HindMadurai'),
              ),
            ),
          ),

          // Karta
          Center(
            child: SlideTransition(
              position: _positionAnimation,
              child: Transform.rotate(
                angle: _rotationAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: GestureDetector( //gesture detector na karcie ktora sie obroci nastepnie w nią klikamy
                    onTap: () {
                      if (widget.selectedCardIndex == 'field_arrows') {
                        widget.onArrowCardTapped();
                        _showStackedCardCrousel(context, widget.onCardSelected);
                      } else {
                        widget.onCardTapped(); // Dla innych kart
                      }
                    },
                    child: Container(
                      width: 150,
                      height: 300,
                      color: Colors.transparent,
                      child: _getCardContent(widget.selectedCardIndex),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget _getCardContent(String cardIndex) {
    // Sprawdzanie czy cardIndex istnieje w mapie cardTypeImagePaths
    if (cardTypeImagePaths.containsKey(cardIndex)) {
      return SvgPicture.asset(cardTypeImagePaths[cardIndex]!, fit: BoxFit.contain);
      // Użycie !, ponieważ jesteśmy pewni, że klucz istnieje
    }
    // Jeśli cardIndex nie istnieje w mapie, zwróć domyślny tekst
    return Text('Kliknij mnie!');
  }

  final Map<String, String> cardTypeImagePaths = {
    'field_arrows': 'assets/time_to_party_assets/card_arrows.svg',
    'field_sheet': 'assets/time_to_party_assets/card_rymes.svg',
    'field_letters': 'assets/time_to_party_assets/card_letters.svg',
    'field_pantomime': 'assets/time_to_party_assets/card_pantomime.svg',
    'field_microphone': 'assets/time_to_party_assets/card_microphone.svg',
    'field_taboo': 'assets/time_to_party_assets/card_taboo.svg',
    'field_star_blue_dark': 'assets/time_to_party_assets/card_star_blue_dark.svg',
    'field_star_pink': 'assets/time_to_party_assets/card_star_pink.svg',
    'field_star_green': 'assets/time_to_party_assets/card_star_green.svg',
    'field_star_yellow': 'assets/time_to_party_assets/card_star_yellow.svg'
  };

  final List<String> cardTypesToSelect = [
    'assets/time_to_party_assets/card_taboo.svg',
    'assets/time_to_party_assets/card_microphone.svg',
    'assets/time_to_party_assets/card_letters.svg',
    'assets/time_to_party_assets/card_pantomime.svg',
    'assets/time_to_party_assets/card_rymes.svg',
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
        return Dialog(
          backgroundColor: Colors.transparent,
         shadowColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          elevation: 0,
          child: SizedBox(
            width: MediaQuery.of(context).size.width, // Określ szerokość
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                SizedBox(height: 50),
                PulsatingSvg(
                  svgAsset:
                  'assets/time_to_party_assets/cards_screens/choose_card_static_text.svg',
                  size: 20.0,
                ),
                SizedBox(height: 50),
                AnimatedHandArrow(),
                Transform.scale(
                  child: FanCarouselImageSlider(
                  imagesLink: cardTypesToSelect,
                  slideViewportFraction: 0.5,
                  isAssets: true,
                  autoPlay: false,
                  autoPlayInterval: Duration(milliseconds: 5000),
                  sliderDuration: Duration(milliseconds: 200),
                  sliderHeight: 320,
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
                  scale: 0.8,
                ),
                SizedBox(height: 10),
                AnimatedQuestionMark(),
              ],
            )
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

class AnimatedHandArrow extends StatefulWidget {
  const AnimatedHandArrow({super.key});

  @override
  _AnimatedHandArrowState createState() => _AnimatedHandArrowState();
}

class _AnimatedHandArrowState extends State<AnimatedHandArrow> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _translationAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _translationAnimation = Tween<double>(
      begin: -0.15, // Przesunięcie o 25% szerokości ekranu w lewo
      end: 0.15, // Przesunięcie o 25% szerokości ekranu w prawo
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _rotationAnimation = Tween<double>(
      begin: -15, // Obrót o -10 stopni
      end: 15, // Obrót o 10 stopni
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_translationAnimation, _rotationAnimation]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_translationAnimation.value * MediaQuery.of(context).size.width, 0),
          child: Transform.rotate(
            angle: _rotationAnimation.value * (pi / 180), // Konwersja na radiany
            child: child,
          ),
        );
      },
      child: SvgPicture.asset('assets/time_to_party_assets/hand_arrow.svg', height: 50),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class AnimatedQuestionMark extends StatefulWidget {
  const AnimatedQuestionMark({super.key});

  @override
  _AnimatedQuestionMarkState createState() => _AnimatedQuestionMarkState();
}

class _AnimatedQuestionMarkState extends State<AnimatedQuestionMark> with SingleTickerProviderStateMixin {
  late Animation<double> _questionMarkPulseAnimation;
  late AnimationController _questionMarkPulseController;

  @override
  void initState() {
    super.initState();

    _questionMarkPulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _questionMarkPulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _questionMarkPulseController, curve: Curves.easeInOut),
    );

    _questionMarkPulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _questionMarkPulseController.dispose();
    super.dispose();
  }

  Future<void> _showMyDialogStacked(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Palette().white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: letsText(context, "Przesuwając lewo - prawo wybierz jedną z poniższych kart:", 18, Palette().darkGrey, textAlign: TextAlign.center)
                ),
                Wrap(
                  spacing: 15.0, // odstęp między elementami poziomo
                  runSpacing: 5.0, // odstęp między liniami pionowo
                  children: <Widget>[
                    buildGridItem("assets/time_to_party_assets/card_taboo.svg", 'taboo_words', context),
                    buildGridItem("assets/time_to_party_assets/card_microphone.svg", 'famous_people', context),
                    buildGridItem("assets/time_to_party_assets/card_letters.svg", 'alphabet', context),
                    buildGridItem("assets/time_to_party_assets/card_pantomime.svg", 'pantomime', context),
                    buildGridItem("assets/time_to_party_assets/card_rymes.svg", 'rymes', context),
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            CustomStyledButton(
              icon: null,
              onPressed: () {
                Navigator.of(context).pop();
              },
              text: "OK",
            )
          ],
        );
      },
    );
  }

  Widget buildGridItem(String assetPath, String textKey, BuildContext context) {
    return Column(
      children: [
        SvgPicture.asset(assetPath),
        SizedBox(
          width: 110, // Ustaw stałą wysokość
          child: translatedText(context, textKey, 15, Colors.white),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showMyDialogStacked(context);
      },
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
                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20, fontFamily: 'HindMadurai')),
          ),
        ),
      ),
    );
  }
}

class PulsatingSvg extends StatefulWidget {
  final String svgAsset;
  final double size;

  const PulsatingSvg({super.key, required this.svgAsset, required this.size});

  @override
  _PulsatingSvgState createState() => _PulsatingSvgState();
}

class _PulsatingSvgState extends State<PulsatingSvg> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
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
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) => Transform.scale(
        scale: _pulseAnimation.value,
        alignment: Alignment.center, // Zapewnia skalowanie wokół środka widgetu
        child: SvgPicture.asset(
          widget.svgAsset,
          height: widget.size,
          width: widget.size,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }
}
