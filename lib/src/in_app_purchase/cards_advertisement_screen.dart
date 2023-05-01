import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../customAppBar/customAppBar.dart';
import '../drawer/drawer.dart';
import '../style/palette.dart';

class CardAdvertisementScreen extends StatelessWidget {
  const CardAdvertisementScreen({super.key, required this.scaffoldKey});
  final GlobalKey<ScaffoldState> scaffoldKey;


  @override
  Widget build(BuildContext context) {
    final customAppDrawer = CustomAppDrawer();
    return Container(
      decoration: BoxDecoration(
        gradient: Palette().backgroundLoadingSessionGradient,
      ),
      child: Scaffold(
        key: scaffoldKey,
        drawer: CustomAppDrawer(),
        appBar: CustomAppBar(
          title: 'Kup Teraz!',
          onMenuButtonPressed: () {
            scaffoldKey.currentState?.openDrawer();
          },
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _gap,
              Text(
                'Ekskluzywna przygoda z kartami na wyciągnięcie ręki!',
                style: TextStyle(
                  color: Color(0xFFCB48EF),
                  fontFamily: 'HindMadurai',
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              SvgPicture.asset(
                'assets/time_to_party_assets/banner_cards_advert.svg',
              ),
              Text(
                'Zakup wersję UNLIMITED!',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'HindMadurai',
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
              _gap,
              SvgPicture.asset(
                'assets/time_to_party_assets/banner_cards_advert_linear.svg',
              ),
              _gap,
              Text(
                'Odkryj pełen potencjał gry z niesamowitymi bonusami!',
                style: TextStyle(
                  color: Color(0xFFCB48EF),
                  fontFamily: 'HindMadurai',
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              Padding(
                  padding: EdgeInsets.only(left: 80), // Dodaje wypełnienie górne i dolne
                  child:  Column(
                children: [
                  _gap,
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Image.asset(
                    'assets/time_to_party_assets/banner_baloon_icon_advert.png', // Podmień na ścieżkę do swojego obrazka SVG
                    height: MediaQuery.of(context).size.width * 0.06, // Dostosuj wysokość obrazka
                    width: MediaQuery.of(context).size.width * 0.06, // Dostosuj szerokość obrazka
                  ),
                  SizedBox(width: 10), // Odstęp między obrazkiem a tekstem
                  Text('Więcej zabawy!',
                      style: TextStyle(
                        fontFamily: 'HindMadurai',
                        fontSize: 14,
                        color: Color(0xFFE5E5E5),
                      )),
                ],),
              _gap,
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SvgPicture.asset(
                    'assets/time_to_party_assets/banner_random_icon_advert.svg', // Podmień na ścieżkę do swojego obrazka SVG
                    height: MediaQuery.of(context).size.width * 0.06, // Dostosuj wysokość obrazka
                    width: MediaQuery.of(context).size.width * 0.06, // Dostosuj szerokość obrazka
                  ),
                  SizedBox(width: 10), // Odstęp między obrazkiem a tekstem
                  Text('Więcej losowych zdarzeń! ',
                      style: TextStyle(
                        fontFamily: 'HindMadurai',
                        fontSize: 14,
                        color: Color(0xFFE5E5E5),
                      )),
                ],
              ),
              _gap,
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SvgPicture.asset(
                    'assets/time_to_party_assets/banner_timer_icon_advert.svg', // Podmień na ścieżkę do swojego obrazka SVG
                    height: MediaQuery.of(context).size.width * 0.06, // Dostosuj wysokość obrazka
                    width: MediaQuery.of(context).size.width * 0.06, // Dostosuj szerokość obrazka
                  ),
                  SizedBox(width: 10), // Odstęp między obrazkiem a tekstem
                  Text('Dłuższa i ciekawsza rozgrywka!',
                      style: TextStyle(
                        fontFamily: 'HindMadurai',
                        fontSize: 14,
                        color: Color(0xFFE5E5E5),
                      )),
                ],
              ),],),),
              _gap,
              _gap,
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFCB48EF), // color
                  foregroundColor: Colors.white, // textColor
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  minimumSize: Size(MediaQuery.of(context).size.width * 0.05,
                      MediaQuery.of(context).size.height * 0.05),
                  textStyle: TextStyle(fontFamily: 'HindMadurai', fontSize: 20),
                ),
                onPressed: () {},
                child: Text('8,99zł jednorazowo'),
              ),
              _gap,
              TextButton(
                onPressed: () async{
                  CustomAppDrawer.callPrivacyPolicyFunction(context, customAppDrawer);
                },
                child: Text(
                    'Polityka prywatności oraz regulamin danych osobowych',
                    style: TextStyle(
                      fontFamily: 'HindMadurai',
                      fontSize: 14,
                      color: Color(0xFFE5E5E5),
                    )),
              ),
              TextButton(
                onPressed: () {

                },
                child: Text('Przywróć płatności',
                    style: TextStyle(
                      fontFamily: 'HindMadurai',
                      fontSize: 14,
                      color: Color(0xFFE5E5E5),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const _gap = SizedBox(height: 10);
}

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          DrawerHeader(
            child: Text('Drawer Header'),
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          ListTile(
            title: Text('Item 1'),
            onTap: () {
              // Update the state of the app
              // ...
              // Then close the drawer
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('Item 2'),
            onTap: () {
              // Update the state of the app
              // ...
              // Then close the drawer
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class LogoWidget_notitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final mediaQueryData = MediaQuery.of(context);
    final screenHeight = mediaQueryData.size.height;
    final screenWidth = mediaQueryData.size.width;
    final StarBoxWidth = 60 / screenWidth * mediaQueryData.size.width;
    final StarBoxHeight = 60 / screenHeight * mediaQueryData.size.height;
    return Container(
      child: Stack(children: <Widget>[
        // blue star
        Positioned(
          top: 54 / screenHeight * mediaQueryData.size.height,
          left: 43 / screenWidth * mediaQueryData.size.width,
          child: Transform.rotate(
            angle: -20 * 3.14 / 180,
            child: Container(
              width: StarBoxWidth,
              height: StarBoxHeight,
              child: SvgPicture.asset(
                'assets/time_to_party_assets/blue_star.svg',
              ),
            ),
          ),
        ),
        // yellow star
        Positioned(
          top: 25 / screenHeight * mediaQueryData.size.height,
          left: 93 / screenWidth * mediaQueryData.size.width,
          child: Transform.rotate(
            angle: -20 * 3.14 / 180,
            child: Container(
              width: StarBoxWidth,
              height: StarBoxHeight,
              child: SvgPicture.asset(
                'assets/time_to_party_assets/yellow_star.svg',
              ),
            ),
          ),
        ),
        // grey star
        Positioned(
          top: 28 / screenHeight * mediaQueryData.size.height,
          left: 157 / screenWidth * mediaQueryData.size.width,
          child: Transform.rotate(
            angle: -20 * 3.14 / 180,
            child: Container(
              width: StarBoxWidth,
              height: StarBoxHeight,
              child: SvgPicture.asset(
                'assets/time_to_party_assets/grey_star.svg',
              ),
            ),
          ),
        ),
        // black star
        Positioned(
          top: 11 / screenHeight * mediaQueryData.size.height,
          left: 205 / screenWidth * mediaQueryData.size.width,
          child: Transform.rotate(
            angle: -20 * 3.14 / 180,
            child: Container(
              width: StarBoxWidth,
              height: StarBoxHeight,
              child: SvgPicture.asset(
                'assets/time_to_party_assets/black_star.svg',
              ),
            ),
          ),
        ),
        // pink star
        Positioned(
          top: 25 / screenHeight * mediaQueryData.size.height,
          left: 276 / screenWidth * mediaQueryData.size.width,
          child: Transform.rotate(
            angle: -20 * 3.14 / 180,
            child: Container(
              width: StarBoxWidth,
              height: StarBoxHeight,
              child: SvgPicture.asset(
                'assets/time_to_party_assets/pink_star.svg',
              ),
            ),
          ),
        ),
        // title logo
        // Loading bar slider
      ]),
    );
  }
}
