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
    // ... możesz dodać więcej jeśli potrzebujesz
  };

  void onCardTap(BuildContext context, int index, String currentTeamName, Color currentTeamColor) {
    String selectedFieldName = cardFieldNames[index] ?? 'default_field';
    Navigator.of(context).pop(); //gasi wybor kart
    if (onDialogClose != null) onDialogClose!();
    Navigator.of(context).pop(); //gasi StackedCard
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
          child: Stack(
            children: [
              // Tło z przezroczystością
              Container(
                color: Colors.black.withOpacity(0.5),
              ),
              // Zawartość nad tłem
              Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  SizedBox(height: 20),
                  Text(
                    "Wybierz kartę",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'HindMadurai',
                    ),
                  ),
                  SizedBox(height: 180), // Dodaję trochę odstępu między tekstem a kartami
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedIcon(
                        direction: AnimatedIconDirection.left, // Kierunek animacji
                      ),
                      SizedBox(width: 20), // Odstęp między ikonami
                      AnimatedIcon(
                        direction: AnimatedIconDirection.right, // Kierunek animacji
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Expanded(child: StackedCardCarousel(items: exampleCards, spaceBetweenItems: 170, initialOffset: 1)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class AnimatedIcon extends StatefulWidget {
  final AnimatedIconDirection direction;

  const AnimatedIcon({Key? key, required this.direction}) : super(key: key);

  @override
  _AnimatedIconState createState() => _AnimatedIconState();
}

class _AnimatedIconState extends State<AnimatedIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true); // Powtarza animację w nieskończoność z odwróceniem

    _animation = Tween<double>(
      begin: 0.0,
      end: widget.direction == AnimatedIconDirection.left ? -22.5 : 22.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_animation.value, 0),
          child: child,
        );
      },
      child: Icon(
        widget.direction == AnimatedIconDirection.left
            ? Icons.arrow_back_ios_new_outlined
            : Icons.arrow_forward_ios_outlined,
        color: Colors.white,
        size: 30,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

enum AnimatedIconDirection { left, right }


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
