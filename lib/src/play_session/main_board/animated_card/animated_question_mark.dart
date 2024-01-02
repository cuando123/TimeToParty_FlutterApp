import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:game_template/src/app_lifecycle/responsive_sizing.dart';

import '../../../app_lifecycle/translated_text.dart';
import '../../../style/palette.dart';
import '../../custom_style_buttons.dart';

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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: translatedText(context, "moving_left_right_swipe_card", 18, Palette().darkGrey,
                        textAlign: TextAlign.center)),
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
            Center(
              child: CustomStyledButton(
                icon: null,
                onPressed: () {
                  Navigator.of(context).pop();
                },
                text: "OK",
                backgroundColor: Palette().pink,
                foregroundColor: Palette().white,
              ),
            ),
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
          width: ResponsiveSizing.scaleWidth(context, 110), // Ustaw stałą wysokość
          child: translatedText(context, textKey, 15, Colors.white, textAlign: TextAlign.center),
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
