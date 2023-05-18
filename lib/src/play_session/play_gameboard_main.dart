import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import '../app_lifecycle/translated_text.dart';
import '../settings/settings.dart';
import '../style/palette.dart';

class PlayGameboard extends StatefulWidget {
  final List<String> teamNames;
  final List<Color> teamColors;

  PlayGameboard({required this.teamNames, required this.teamColors});

  @override
  _PlayGameboardState createState() => _PlayGameboardState();
}

class _PlayGameboardState extends State<PlayGameboard>
    with SingleTickerProviderStateMixin {
  late StreamController<int> _selectedController =
      StreamController<int>.broadcast();
  late AnimationController _animationController;
  late Animation<double> _buttonAnimation;
  bool _buttonClicked = false;
  List<int> _wheelValues = [0, 1, 2, 0, 1, 2];
  late StreamSubscription<int> _subscription;
  int selectedValue = 0;


  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    _animationController.stop();
    _selectedController = StreamController<int>.broadcast();
    _subscription = _selectedController.stream.listen((selectedIndex) {
      setState(() {
        selectedValue = _wheelValues[selectedIndex] + 1; // Zaktualizuj wartość selectedValue
      });
      print(
          'Wylosowana wartość: $selectedValue, Wylosowany index: $selectedIndex');
    });
  }
  bool isAnimationStarted = false;

  @override
  Widget build(BuildContext context) {
    _buttonAnimation = Tween<double>(
            begin: 0,
            end: MediaQuery.of(context).size.width * 0.5) // Change here
        .animate(CurvedAnimation(
            parent: _animationController, curve: Curves.easeInOut));
    return Container(
      decoration: BoxDecoration(
        gradient: Palette().backgroundLoadingSessionGradient,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Next Screen'),
        ),
        body: Column(
          children: [
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    15.0, 10.0, 15.0, 2.0), // left, top, right, bottom
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      left: 0,
                      top: 0,
                      child: Column(
                        children: [
                          SvgPicture.asset(
                              'assets/time_to_party_assets/field_sheet.svg',
                              width: ResponsiveSizing.scaleHeight(context, 50)),
                          ResponsiveSizing.responsiveHeightGap(context, 6),
                          SvgPicture.asset(
                              'assets/time_to_party_assets/field_pantomime.svg',
                              width: ResponsiveSizing.scaleHeight(context, 50)),
                          ResponsiveSizing.responsiveHeightGap(context, 6),
                          SvgPicture.asset(
                              'assets/time_to_party_assets/field_letters.svg',
                              width: ResponsiveSizing.scaleHeight(context, 50)),
                          ResponsiveSizing.responsiveHeightGap(context, 6),
                          SvgPicture.asset(
                              'assets/time_to_party_assets/field_arrows.svg',
                              width: ResponsiveSizing.scaleHeight(context, 50)),
                          ResponsiveSizing.responsiveHeightGap(context, 6),
                          SvgPicture.asset(
                              'assets/time_to_party_assets/field_sheet.svg',
                              width: ResponsiveSizing.scaleHeight(context, 50)),
                          ResponsiveSizing.responsiveHeightGap(context, 6),
                          SvgPicture.asset(
                              'assets/time_to_party_assets/field_microphone.svg',
                              width: ResponsiveSizing.scaleHeight(context, 50)),
                          ResponsiveSizing.responsiveHeightGap(context, 6),
                          SvgPicture.asset(
                              'assets/time_to_party_assets/field_letters.svg',
                              width: ResponsiveSizing.scaleHeight(context, 50)),
                          ResponsiveSizing.responsiveHeightGap(context, 6),
                          SvgPicture.asset(
                              'assets/time_to_party_assets/field_star_blue.svg',
                              width: ResponsiveSizing.scaleHeight(context, 50)),
                          ResponsiveSizing.responsiveHeightGap(context, 6),
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              SvgPicture.asset('assets/time_to_party_assets/field_start.svg',
                                  width: ResponsiveSizing.scaleHeight(context, 50)),
                              ...widget.teamColors.asMap().entries.expand((entry) {
                                int index = entry.key;
                                Color color = entry.value;
                                final flagCount = widget.teamColors.length;
                                // Lista dostępnych flag
                                List<String> flagAssets = [
                                  'assets/time_to_party_assets/main_board/flags/flag00A2AC.svg',
                                  'assets/time_to_party_assets/main_board/flags/flag01B210.svg',
                                  'assets/time_to_party_assets/main_board/flags/flag9400AC.svg',
                                  'assets/time_to_party_assets/main_board/flags/flagF50000.svg',
                                  'assets/time_to_party_assets/main_board/flags/flagFFD335.svg',
                                  'assets/time_to_party_assets/main_board/flags/flagFFFFFF.svg',
                                ];

                                // Zwracamy tylko te flagi, które mają kolor pasujący do kolorów z teamColors
                                return flagAssets.where((flag) {
                                  // Dodajemy "FF" na początku kodu koloru, aby dodać kanał alfa
                                  String flagColorHex = 'FF' + flag.split('/').last.split('.').first.substring(4);

                                  // Konwersja na Color
                                  Color flagColor = Color(int.parse(flagColorHex, radix: 16));

                                  // Porównujemy wartości RGB
                                  if (color.value == flagColor.value) {
                                    return true;
                                  } else {
                                    return false;
                                  }
                                }).map((flag) {
                                  return Positioned(
                                    // Jeżeli index >= 3, przesuwamy flagę do drugiego rzędu
                                    top: flagCount == 2
                                        ? 10.0 // Dwie flagi - po środku
                                        : flagCount < 4
                                        ? 0.0 // Mniej niż 4 flagi - po środku
                                        : index >= 3
                                        ? 25.0 // Więcej niż 4 flagi - drugi rząd
                                        : -5.0, // Więcej niż 4 flagi - pierwszy rząd
                                    left: flagCount == 2
                                        ? index * 25.0 + 3
                                        : flagCount < 4
                                        ? index * 25.0 - 7.0 // Mniej niż 4 flagi - obecna wartość
                                        : index >= 3
                                        ? (index - 3) * 25.0 - 7.0 // Więcej niż 4 flagi - drugi rząd
                                        : index * 25.0 - 7.0,   // Pozycja zależna od indeksu
                                    child: Transform.rotate(
                                      angle: (index % 3 == 0 ? -10 : index % 3 == 2 ? 15 : 0) * (3.14 / 180),
                                  child: Transform(
                                  transform:  Matrix4.identity()..scale(index == 0 || index == 3 ? -1.0 : 1.0, 1.0), // Odbicie w poziomie tylko dla flag po lewej
                                  alignment: Alignment.center,
                                  child:
                                      SvgPicture.asset(
                                        flag,
                                        width: 30,  // Szerokość flagi
                                        height: 30,  // Wysokość flagi
                                      ),
                                    ),),
                                  );
                                });
                              }).toList(),
                            ],
                          )
                        ],
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Column(
                        children: List.generate(
                          9,
                          (index) => Column(
                            children: [
                              SvgPicture.asset(
                                'assets/time_to_party_assets/field_sheet.svg',
                                width: 50,
                                height: 50,
                              ),
                              ResponsiveSizing.responsiveHeightGap(context, 6),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(4, (index) {
                          return Row(
                            children: [
                              SvgPicture.asset(
                                'assets/time_to_party_assets/field_sheet.svg',
                                width: 50,
                                height: 50,
                              ),
                              ResponsiveSizing.responsiveWidthGap(context, 6),
                            ],
                          );
                        }),
                      ),
                    ),
                    Positioned(
                      bottom: 0, // adjust this value as needed
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(4, (index) {
                          return Row(
                            children: [
                              SvgPicture.asset(
                                'assets/time_to_party_assets/field_sheet.svg',
                                width: 50,
                                height: 50,
                              ),
                              ResponsiveSizing.responsiveWidthGap(context, 6),
                            ],
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SafeArea(
              child: Expanded(
                flex: 1,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: 10,
                      left: _buttonClicked ? 0 : _buttonAnimation.value,
                      child: ElevatedButton(
                        onPressed: () {
                          _animationController.repeat(reverse: true);
                          final randomIndex =
                              Fortune.randomInt(0, _wheelValues.length);
                          _selectedController.add(randomIndex);
                          setState(() {
                            _buttonClicked = true;
                            _animationController.stop();
                            isAnimationStarted = true;
                          });
                        },
                        child: Text('Zakręć kołem'),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0), //
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.width * 0.45,
                        child: GestureDetector(
                          onTap: () {
                            if (isAnimationStarted) {
                              _animationController.repeat(reverse: true);
                            }
                          },
                          child: FortuneWheel(
                            selected: _selectedController.stream,
                            indicators: const <FortuneIndicator>[
                              FortuneIndicator(
                                alignment: Alignment.topCenter,
                                child: TriangleIndicator(
                                  color: Colors.green,
                                ),
                              ),
                            ],
                            items: [
                              FortuneItem(
                                child: Transform.rotate(
                                  angle: 90 * 3.14 / 180,
                                  child: Text(
                                    '1',
                                    style: TextStyle(
                                        fontFamily: 'HindMadurai',
                                        fontSize: 20),
                                  ),
                                ),
                                style: FortuneItemStyle(
                                  color: Colors.red,
                                  borderColor: Colors.green,
                                  borderWidth: 3,
                                ),
                              ),
                              FortuneItem(child: Text('2')),
                              FortuneItem(child: Text('3')),
                              FortuneItem(child: Text('1')),
                              FortuneItem(child: Text('2')),
                              FortuneItem(child: Text('3')),
                            ],
                          ),
                        ),
                      ),

                    ),
                    Text('Wylosowana wartość: $selectedValue'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    _animationController.dispose();
    _selectedController.close();
    super.dispose();
  }
}
