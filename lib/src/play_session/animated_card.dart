import 'package:flutter/material.dart';
import 'dart:math';

import 'package:flutter_svg/svg.dart';
import 'package:game_template/src/play_session/stacked_card_carousel.dart';

class AnimatedCard extends StatefulWidget {
  final Function onCardTapped;
  final Function onArrowCardTapped;
  final String selectedCardIndex;
  final BuildContext parentContext;
  final String currentTeamName;
  final Color teamColor;
  final bool showAnimatedCard;

  AnimatedCard(
      { required this.showAnimatedCard,
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
      duration: const Duration(seconds: 2),
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
      duration: const Duration(milliseconds: 500), // Okres jednego pulsowania
      vsync: this,
    )..repeat(reverse: true); // Powtarza animację w nieskończoność z odwróceniem

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
    Future.delayed(Duration(seconds: 2), () {
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


  @override
  Widget build(BuildContext context) {
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
          child:   Text('${widget.currentTeamName}',
              style: TextStyle(color: Colors.white, fontSize: 20)),
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
            _showMyDialog(context); // Wywołanie funkcji wyświetlającej AlertDialog
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
                      StackedCard.showAsDialog(widget.parentContext, widget.currentTeamName, widget.teamColor, onDialogClose: () {
                        widget.onCardTapped(); // Wywołuje callback z zewnętrznego widgetu
                        //Navigator.of(context).pop(); // Zamknij StackedCard
                      });
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

  Future<void> _showMyDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Użytkownik musi nacisnąć przycisk, aby zamknąć dialog
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Informacja'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Twoja wiadomość informacyjna.'),
              ],
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
