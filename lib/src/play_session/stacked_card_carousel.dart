import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:game_template/src/play_session/play_gameboard_card.dart';
import 'package:stacked_card_carousel/stacked_card_carousel.dart';

class StackedCard extends StatelessWidget {
  final String title;
  final List<Widget> fancyCards;
  final VoidCallback? onDialogClose;

  StackedCard({required this.title, required this.fancyCards, this.onDialogClose});


  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,  // Możesz dostosować szerokość do swoich potrzeb
      height: double.maxFinite, // Możesz dostosować wysokość do swoich potrzeb
      child: ListView(
        children: fancyCards,
      ),
    );
  }

  Map<int, String> cardFieldNames = {
    0: 'field_taboo',
    1: 'field_microphone',
    2: 'field_letters',
    3: 'field_pantomime',
    4: 'field_rymes',
  };

  void onCardTap(BuildContext context, int index, String currentTeamName, Color currentTeamColor) {
    String selectedFieldName = cardFieldNames[index] ?? 'default_field';
    Navigator.of(context).pop(); //gasi wybor kart
    if (onDialogClose != null) onDialogClose!();
    Navigator.of(context).pop('response'); //gasi StackedCard
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayGameboardCard(
          teamNames: [currentTeamName],
          teamColors: [currentTeamColor],
          currentField: [selectedFieldName],
        ),
      ),
    );
  }

  static void showAsDialog(BuildContext context, String currentTeamName, Color currentTeamColor, {required VoidCallback onDialogClose}) {
    StackedCard stackedCardInstance = StackedCard(
        title: "Twój tytuł",
        fancyCards: [],
        onDialogClose: onDialogClose );// Przekazujemy callback tutaj

        // Przykładowe karty
    final List<Widget> exampleCards = <Widget>[
      FancyCard(
        image: SvgPicture.asset("assets/time_to_party_assets/card_taboo.svg"),
        onTap: (index) => stackedCardInstance.onCardTap(context, index, currentTeamName, currentTeamColor), // Używam instancji
        index: 0,
      ),
      FancyCard(
        image: SvgPicture.asset("assets/time_to_party_assets/card_microphone.svg"),
        onTap: (index) => stackedCardInstance.onCardTap(context, index, currentTeamName, currentTeamColor),
        index: 1,
      ),
      FancyCard(
        image: SvgPicture.asset("assets/time_to_party_assets/card_letters.svg"),
        onTap: (index) => stackedCardInstance.onCardTap(context, index, currentTeamName, currentTeamColor),
        index: 2,
      ),
      FancyCard(
        image: SvgPicture.asset("assets/time_to_party_assets/card_pantomime.svg"),
        onTap: (index) => stackedCardInstance.onCardTap(context, index, currentTeamName, currentTeamColor),
        index: 3,
      ),
      FancyCard(
        image: SvgPicture.asset("assets/time_to_party_assets/card_rymes.svg"),
        onTap: (index) => stackedCardInstance.onCardTap(context, index, currentTeamName, currentTeamColor),
        index: 4,
      ),
    ];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => false, // Blokuje przycisk wstecz
          child:
              Container(
                color: Colors.black.withOpacity(0.5),
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
              child:
              Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  SizedBox(height: 50),
                  PulsatingSvg(
                    svgAsset: 'assets/time_to_party_assets/cards_screens/choose_card_static_text.svg', // Ścieżka do pliku SVG w Twoich zasobach
                    size: 20.0, // Rozmiar obrazu SVG (zarówno szerokość, jak i wysokość)
                  ),
                  SizedBox(height: 150), // Dodaję trochę odstępu między tekstem a kartami
                  Expanded(child: StackedCardCarousel(items: exampleCards, spaceBetweenItems: 170, initialOffset: 1)),
                  SizedBox(height: 10),
                  AnimatedHandArrow(),
                  SizedBox(height: 10),
                  AnimatedQuestionMark(),
                  SizedBox(height: 150),
                ],
              ),),
        );
      },
    );
  }
}

class AnimatedHandArrow extends StatefulWidget {
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
  @override
  _AnimatedQuestionMarkState createState() => _AnimatedQuestionMarkState();
}

class _AnimatedQuestionMarkState extends State<AnimatedQuestionMark>
    with SingleTickerProviderStateMixin {
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
      CurvedAnimation(
          parent: _questionMarkPulseController, curve: Curves.easeInOut),
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
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
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
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        fontFamily: 'HindMadurai')),
              ),
            ),
          ),
    );
  }
}

class FancyCard extends StatelessWidget {
  const FancyCard({
    required this.image,
    required this.onTap, // Dodajemy tę linię
    required this.index, // Dodajemy tę linię
  });

  final Widget image;
  final Function(int) onTap; // Dodajemy tę linię
  final int index; // Dodajemy tę linię

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.centerLeft,
        child: GestureDetector(
      onTap: () => onTap(index), // Dodajemy tę linię
      child: Card(color: Colors.transparent,
        child: Column(
            children: <Widget>[
              SizedBox(
                width: 160,
                height: 240,
                child: image,
              ),
            ],
          ),
        ),
    ),);
  }
}

class PulsatingSvg extends StatefulWidget {
  final String svgAsset;
  final double size;

  const PulsatingSvg({Key? key, required this.svgAsset, required this.size}) : super(key: key);

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

