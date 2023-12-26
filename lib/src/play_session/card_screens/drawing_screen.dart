import 'dart:ui' as ui;

import 'package:draw_your_image/draw_your_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:game_template/src/app_lifecycle/translated_text.dart';

import '../../style/palette.dart';
import '../alerts_and_dialogs.dart';
import '../custom_style_buttons.dart';

class DrawingScreen extends StatefulWidget {
  final String itemToShow;
  final String category;
  final List<String> teamNames;
  final List<Color> teamColors;

  const DrawingScreen({super.key, required this.itemToShow, required this.category, required this.teamColors, required this.teamNames});

  @override
  _DrawingScreenState createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {
  bool hasShownAlertDialog = false;

  var _currentColor = Colors.black;
  var _currentWidth = 4.0;
  final _drawController = DrawController();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _convertAndNavigate() async {
    // Wywołaj convertToImage, który uruchomi callback onConvertImage
    _drawController.convertToImage();
  }

  Future<void> onConvertImage(Uint8List imageData) async {
    // Konwersja na ui.Image i zwrócenie jako wynik
    ui.Image image = await convertUint8ListToUiImage(imageData);
    Navigator.of(context).pop(DrawingResult(image: image, category: widget.category));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        AnimatedAlertDialog.showExitGameDialog(context, hasShownAlertDialog, '', widget.teamNames, widget.teamColors);
        return false; // return false to prevent the pop operation
      }, // Zablokowanie możliwości cofnięcia
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: Palette().backgroundLoadingSessionGradient,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 30.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.home_rounded, color: Colors.white, size: 30),
                      onPressed: () {
                        AnimatedAlertDialog.showExitGameDialog(context, hasShownAlertDialog, '' ,widget.teamNames, widget.teamColors);
                        //Navigator.of(context).pop('response');
                      },
                    ),
                    Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                      // Odstępy wewnątrz prostokąta
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        // Przezroczysty czarny kolor
                        borderRadius: BorderRadius.circular(8.0), // Zaokrąglenie rogów
                      ),
                      child: Row(
                        children: [
                          //..._displayTeamNames(),
                        ..._createTeamWidgets(),
                          // ..._displayTeamColors(),
                        ],
                      ),
                    ),
                    Spacer(),
                    InkWell(
                      onTap: () {
                        setState(() {
                          hasShownAlertDialog = true;
                        });
                        AnimatedAlertDialog.showCardDescriptionDialog(
                                context, 'field_star_green', AlertOrigin.cardScreen)
                            .then((_) {
                          setState(() {
                            hasShownAlertDialog = false;
                          });
                        });
                      },
                      child: Container(
                        child: CircleAvatar(
                          radius: 18, // Dostosuj rozmiar w zależności od potrzeb
                          backgroundColor: Color(0xFF2899F3),
                          child: Text(
                            '?',
                            style: TextStyle(
                                color: Palette().white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                fontFamily: 'HindMadurai'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: createRowItems(context),
              ),
              const SizedBox(height: 10),
          Row(mainAxisSize: MainAxisSize.min,
            children: [
            letsText(
                context,
                getTranslatedString(
                    context,
                    widget.category == 'draw_movie'
                        ? 'category_draw_movie'
                        : widget.category == 'draw_proverb'
                        ? 'category_draw_proverbs'
                        : widget.category == 'draw_love_pos'
                        ? 'category_love_positions'
                        : 'default_category'),
                14,
                Palette().white),
              const SizedBox(width: 5),
            Icon(widget.category == 'draw_movie'
                ? Icons.movie
                : widget.category == 'draw_proverb'
                ? Icons.message
                : widget.category == 'draw_love_pos'
                ? Icons.man
                : Icons.hourglass_empty, color: Palette().bluegrey),
          ],),
              const SizedBox(height: 10),
              Text(
                  widget.itemToShow,
                style: TextStyle(
                  fontFamily: 'HindMadurai',
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Palette().pink,
                  shadows: const [
                    Shadow(
                      offset: Offset(1.0, 4.0),
                      blurRadius: 15.0,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    border: Border.all(color: Palette().white, width: 13.0),
                  ),
                  child: Draw(
                    controller: _drawController,
                    backgroundColor: Colors.blue.shade50,
                    strokeColor: _currentColor,
                    strokeWidth: _currentWidth,
                    isErasing: false,
                    onConvertImage: (imageData) async {
                      await onConvertImage(imageData);
                    },
                  ),
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedIconButton(
                    icon: Icon(Icons.undo),
                    iconColor: Color(0xFFCB48EF),
                    onPressed: () {
                      if (!_drawController.undo()) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(getTranslatedString(context, 'no_actions_to_undo')),
                        ));
                      }
                    },
                    backgroundColor: Colors.white,
                    width: 50,
                    height: 50,
                  ),
                  SizedBox(width: 5),
                  AnimatedIconButton(
                    icon: Icon(Icons.redo),
                    iconColor: Color(0xFFCB48EF),
                    onPressed: () {
                      if (!_drawController.redo()) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(getTranslatedString(context, 'no_actions_to_redo')),
                        ));
                      }
                    },
                    backgroundColor: Colors.white,
                    width: 50,
                    height: 50,
                  ),
                  SizedBox(width: 5),
                  AnimatedIconButton(
                    icon: Icon(Icons.clear),
                    iconColor: Color(0xFFCB48EF),
                    onPressed: () => _drawController.clear(),
                    backgroundColor: Colors.white,
                    width: 50,
                    height: 50,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              buildColorPicker(),
              const SizedBox(height: 10),
              buildBrushSizeSlider(),
              const SizedBox(height: 10),
              CustomStyledButton(icon: Icons.play_arrow_rounded, text: getTranslatedString(context, 'im_guessing'), onPressed: _convertAndNavigate),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  static List<Widget> createRowItems(BuildContext context) {
    List<Widget> rowItems = [];
    rowItems.add(
      Text(
        getTranslatedString(context, 'drawing'),
        style: TextStyle(
          fontFamily: 'HindMadurai',
          fontSize: 30.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [
            Shadow(
              offset: Offset(1.0, 4.0),
              blurRadius: 15.0,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
          ],
        ),
      ),
    );
    rowItems.add(
      Padding(
        padding: const EdgeInsets.only(left: 10.0),
        child: SvgPicture.asset(
          'assets/time_to_party_assets/cards_screens/star_green_icon_color.svg',
          height: 30.0,
          fit: BoxFit.contain,
        ),
      ),
    );
    return rowItems;
  }

  Widget buildColorPicker() {
    return Wrap(
      spacing: 16,
      children: [Colors.black, Colors.blue, Colors.red, Colors.green, Colors.yellow].map((color) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _currentColor = color;
            });
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 40,
              height: 40,
              color: color,
              child: Center(
                child: _currentColor == color ? Icon(Icons.brush, color: Colors.white) : SizedBox.shrink(),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget buildBrushSizeSlider() {
    return Slider(
      max: 40,
      min: 1,
      value: _currentWidth,
      onChanged: (value) {
        setState(() {
          _currentWidth = value;
        });
      },
    );
  }

  Future<ui.Image> convertUint8ListToUiImage(Uint8List imageData) async {
    // Tworzenie kodeka obrazu z danych binarnych
    final ui.Codec codec = await ui.instantiateImageCodec(imageData);

    // Dekodowanie pierwszej klatki obrazu (w przypadku obrazów statycznych, będzie to jedyna klatka)
    final ui.FrameInfo frameInfo = await codec.getNextFrame();

    // Zwrócenie obrazu
    return frameInfo.image;
  }

  List<Widget> _createTeamWidgets() {
    List<Widget> teamWidgets = [];
    List<Color> teamColors = widget.teamColors;
    List<String> teamNames = widget.teamNames;

    for (int i = 0; i < teamColors.length; i++) {
      String flagAsset = getFlagAssetFromColor(teamColors[i]);
      teamWidgets.add(SvgPicture.asset(flagAsset));
      teamWidgets.add(SizedBox(width: 10.0));
      teamWidgets.add(SizedBox(height: 20.0));

      if (i < teamNames.length) {
        teamWidgets.add(Text(
          teamNames[i],
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ));
        teamWidgets.add(SizedBox(height: 20.0));
      }
    }

    return teamWidgets;
  }
  String getFlagAssetFromColor(Color color) {
    List<String> flagAssets = [
      'assets/time_to_party_assets/main_board/flags/kolko00A2AC.svg',
      'assets/time_to_party_assets/main_board/flags/kolko01B210.svg',
      'assets/time_to_party_assets/main_board/flags/kolko9400AC.svg',
      'assets/time_to_party_assets/main_board/flags/kolkoF50000.svg',
      'assets/time_to_party_assets/main_board/flags/kolkoFFD335.svg',
      'assets/time_to_party_assets/main_board/flags/kolko1C1AAA.svg',
    ];
    for (String flag in flagAssets) {
      String flagColorHex = 'FF${flag.split('/').last.split('.').first.substring(5)}'; //zmiana z 4 na 5
      Color flagColor = Color(int.parse(flagColorHex, radix: 16));
      if (color.value == flagColor.value) {
        return flag;
      }
    }
    return 'assets/time_to_party_assets/main_board/flags/kolko00A2AC.svg';
  }
}

class DrawingResult {
  final ui.Image image;
  final String category;

  DrawingResult({required this.image, required this.category});
}

class AnimatedIconButton extends StatefulWidget {
  final Icon icon;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color iconColor;
  final double width;
  final double height;

  const AnimatedIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.iconColor = Colors.black,
    this.backgroundColor = Colors.white,
    this.width = 50.0, // Domyślna szerokość i wysokość dla ikony
    this.height = 50.0,
  });

  @override
  _AnimatedIconButtonState createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<AnimatedIconButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onPressed() {
    _animationController.forward().then((_) {
      _animationController.reverse();
      widget.onPressed();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(5),
          ),
          alignment: Alignment.center,
          child: Icon(
            widget.icon.icon,
            color: widget.iconColor,
            size: widget.icon.size,
          ),
        ),
      ),
    );
  }
}


