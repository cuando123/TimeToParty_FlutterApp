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
    Navigator.of(context).pop();
    if (onDialogClose != null) onDialogClose!();
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
      builder: (BuildContext context) {
        return WillPopScope(
            onWillPop: () async => false,  // Blokuje przycisk wstecz
        child: Dialog(backgroundColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Wybierz kartę",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 20), // Dodaję trochę odstępu między tekstem a kartami
          Expanded(child:StackedCardCarousel(items: exampleCards, spaceBetweenItems: 240, initialOffset: 1)),
            ],
          ),
        ),);
      },
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
    return GestureDetector(
      onTap: () => onTap(index), // Dodajemy tę linię
      child: Card(color: Colors.transparent,
        elevation: 15.0,
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Column(
            children: <Widget>[
              Container(
                width: 160,
                height: 240,
                child: image,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
