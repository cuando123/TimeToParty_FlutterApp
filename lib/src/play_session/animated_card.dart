import 'package:flutter/material.dart';
import 'dart:math';

import 'package:flutter_svg/svg.dart';
import 'package:game_template/src/play_session/stacked_card_carousel.dart';

class AnimatedCard extends StatefulWidget {
  final Function onCardTapped;
  final String selectedCardIndex;
  final BuildContext parentContext;
  final String currentTeamName;
  final Color teamColor;

  AnimatedCard(
      {required this.onCardTapped,
      required this.selectedCardIndex,
      required this.parentContext,
      required this.currentTeamName,
      required this.teamColor});

  @override
  _AnimatedCardState createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _positionAnimation;
  bool showCardAnimation = true;

  bool _cardVisible = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.1, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _positionAnimation = Tween<Offset>(
      begin: Offset(0.0, -0.5),
      end: Offset(0.0, 0.0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (showCardAnimation) {
      _controller.forward().then((value) {
        setState(() {
          _cardVisible = true;
        });
      });
    }

    _controller.addListener(() {
      setState(() {});
    });
  }


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Przyciemnienie
        if (_cardVisible)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.7),
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
                      print("field_arrows tapped");
                      // idzie do show dialog, nastepnie idzie do natepnego ekranu.. robi set state, otwiera current ekran i go zamyka zeby nie pokazało karty jako wybór - zawiły bezsens ale dziala tak jak oczekiwano
                      StackedCard.showAsDialog(widget.parentContext, widget.currentTeamName, widget.teamColor, onDialogClose: () {setState(() {widget.onCardTapped();
                      Navigator.of(context).pop();});   });
                      print("Dialog closed");
                    } else {
                      print("onCardTapped triggered");
                      widget.onCardTapped();
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
