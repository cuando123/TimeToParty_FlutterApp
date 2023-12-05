import 'dart:math';

import 'package:fan_carousel_image_slider/fan_carousel_image_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:game_template/src/play_session/alerts_and_dialogs.dart';
import 'package:game_template/src/play_session/main_board/stacked_card_carousel.dart';

class AnimatedCard extends StatefulWidget {
  final Function onCardTapped;
  final Function onArrowCardTapped;
  final String selectedCardIndex;
  final BuildContext parentContext;
  final String currentTeamName;
  final Color teamColor;
  final bool showAnimatedCard;

  const AnimatedCard(
      {super.key,  required this.showAnimatedCard,
        required this.onCardTapped,
        required this.onArrowCardTapped,
      required this.selectedCardIndex,
      required this.parentContext,
      required this.currentTeamName,
      required this.teamColor});

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
      _controller.forward().then((value) {
      });
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
          weight: 0.05
      ),
      TweenSequenceItem(
          tween: ConstantTween<double>(1.1), // Utrzymuje skalę
          weight: 0.05
      ),
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.1, end: 1.0), // Zmniejsza skalę
          weight: 0.05
      ),
      TweenSequenceItem(
          tween: ConstantTween<double>(1.0), // Utrzymuje skalę
          weight: 0.85
      ),
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
      begin: Offset(0.0, -0.3),  // Małe przesunięcie w górę
      end: Offset(0.0, 0.3),     // Małe przesunięcie w dół
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
    return fieldDescriptions[cardIndex] ?? 'Brak opisu dla tej karty'; // Użycie operatora ??, aby zapewnić wartość domyślną
  }

  @override
  Widget build(BuildContext context) {
    String cardDescription = getCardDescription(widget.selectedCardIndex);
    if (!widget.showAnimatedCard) {
      return Container();
    } else {
      return  Stack(
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
          child:   Text(widget.currentTeamName,
              style:  TextStyle(
                fontStyle: FontStyle.normal,
                fontFamily: 'HindMadurai',
                color: Colors.white,
                fontSize: 20,
              ),)
        ),),
    SlideTransition(
    position: _textTopPositionAnimation,
    child: Align(
            alignment: Alignment(0.0, -0.8),
            child:  SvgPicture.asset('assets/time_to_party_assets/team_icon.svg',
                height: 40, color: widget.teamColor)
        ),),
        SlideTransition(
          position: _textTopPositionAnimation,
          child: Align(
              alignment: Alignment(0.0, -2),
              child:  Text(cardDescription,
                style: TextStyle(
                  fontStyle: FontStyle.italic, // Ustawienie tekstu na kursywę
                  height: 40.0, // Ustawienie wysokości tekstu
                  fontFamily: 'HindMadurai', // Ustawienie czcionki na Hind Madurai
                  color: Colors.white, // Ustawienie koloru tekstu na biały
                  fontSize: 15, // Możesz dostosować rozmiar czcionki zgodnie z potrzebami
                ),)
          ),),

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
    child:
        Align(
          alignment: Alignment(0.0, -0.4),
          child: SlideTransition(
            position: _arrowAnimation,
            child: Icon(Icons.arrow_downward_sharp, color: Colors.white, size: 30),
          ),
        ),),

        SlideTransition(
        position: _textBottomPositionAnimation,
    child:
    GestureDetector(
          onTap: () {
            AnimatedAlertDialog.showCardDescriptionDialog(context, widget.selectedCardIndex, AlertOrigin.otherScreen);
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
        ),),

        // Napis na dole
          SlideTransition(
            position: _textBottomPositionAnimation,
            child: Align(
              alignment: Alignment(0.0, 0.6),  // Aby dostosować położenie napisu, możesz zmienić wartość 0.7
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
                child: GestureDetector(
                  onTap: () {
                    if (widget.selectedCardIndex == 'field_arrows') {
                      widget.onArrowCardTapped(); // Ukryj AnimatedCard

                      _showMyDialog(context);

                      /*
                      StackedCard.showAsDialog(widget.parentContext, widget.currentTeamName, widget.teamColor, onDialogClose: () {
                        widget.onCardTapped(); // Wywołuje callback z zewnętrznego widgetu
                        //Navigator.of(context).pop(); // Zamknij StackedCard
                      });*/
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

  Widget _getCardContent(String cardIndex) {
    // Sprawdzanie czy cardIndex istnieje w mapie cardTypeImagePaths
    if (cardTypeImagePaths.containsKey(cardIndex)) {
      return SvgPicture.asset(cardTypeImagePaths[cardIndex]!, fit: BoxFit.contain);
      // Użycie !, ponieważ jesteśmy pewni, że klucz istnieje
    }

    // Jeśli cardIndex nie istnieje w mapie, zwróć domyślny tekst
    return Text('Kliknij mnie!');
  }

  static const List<String> sampleImages = [
    'https://img.freepik.com/free-photo/lovely-woman-vintage-outfit-expressing-interest-outdoor-shot-glamorous-happy-girl-sunglasses_197531-11312.jpg?w=1800&t=st=1673886721~exp=1673887321~hmac=57318aa37912a81d9c6e8f98d4e94fb97a766bf6161af66488f4d890f88a3109',
    'https://img.freepik.com/free-photo/attractive-curly-woman-purple-cashmere-sweater-fuchsia-sunglasses-poses-isolated-wall_197531-24158.jpg?w=1800&t=st=1673886680~exp=1673887280~hmac=258c92922874ad41d856e7fdba03ce349556cf619de4074143cec958b5b4cf05',
    'https://img.freepik.com/free-photo/stylish-blonde-woman-beret-beautiful-french-girl-jacket-standing-red-wall_197531-14428.jpg?w=1800&t=st=1673886821~exp=1673887421~hmac=5e77d3fab088b29a3b19a9023289fa95c1dc2af15565f290886bab4642fa2621',
    'https://img.freepik.com/free-photo/pretty-young-girl-with-pale-skin-dark-hair-french-beret-sunglasses-polka-dot-skirt-white-top-red-shirt-walking-around-sunny-city-laughing_197531-24480.jpg?w=1800&t=st=1673886800~exp=1673887400~hmac=9a1c61de63180118c5497ce105bbb36bfbb53050111de466d5110108848f2128',
    'https://img.freepik.com/free-photo/elegant-woman-brown-coat-spring-city_1157-33434.jpg?w=1800&t=st=1673886830~exp=1673887430~hmac=cc8c28a9332e008db251bdf9c7b838b7aa5077ec7663773087a8cc56d11138ff',
    'https://img.freepik.com/free-photo/high-fashion-look-glamor-closeup-portrait-beautiful-sexy-stylish-blond-young-woman-model-with-bright-yellow-makeup-with-perfect-clean-skin-with-gold-jewelery-black-cloth_158538-2003.jpg?w=826&t=st=1673886857~exp=1673887457~hmac=3ba51578e6a1e9c58e95a6b72e492cbbc26abf8e2f116a0672113770d3f4edbe',
  ];

  Future<void> _showMyDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Użytkownik musi nacisnąć przycisk, aby zamknąć dialog
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Informacja'),
          content: Container(
            width: MediaQuery.of(context).size.width, // Określ szerokość
            height: MediaQuery.of(context).size.height,
            child: FanCarouselImageSlider(
              imagesLink: sampleImages,
              isAssets: false,
              autoPlay: false,
              sliderDuration: Duration(milliseconds: 200),
                sliderHeight: 400,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Zamknięcie AlertDialog
              },
            ),
          ],
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
