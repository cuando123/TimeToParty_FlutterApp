import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../customAppBar/customAppBar.dart';
import '../drawer/drawer.dart';
import '../style/palette.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({Key? key, required this.scaffoldKey}) : super(key: key);
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: Palette().backgroundLoadingSessionGradient,
      ),
      child: Scaffold(
        key: scaffoldKey,
        drawer: CustomAppDrawer(),
        appBar: CustomAppBar(
          title: 'Zmień język',
          onMenuButtonPressed: () {
            scaffoldKey.currentState?.openDrawer();
          },
          ),
        body: Column(
          children: [
            Container(
              height: 100, // Określ wysokość wg własnego uznania
              child: LogoWidget_notitle(),
            ),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 3,
                children: [
                  languageButton('English', Icons.flag),
                  languageButton('Deutsch', Icons.flag),
                  languageButton('Italiano', Icons.flag),
                  languageButton('Espanol', Icons.flag),
                  languageButton('Polski', Icons.flag),
                  languageButton('Francais', Icons.flag),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget languageButton(String language, IconData icon) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: TextButton.icon(
        onPressed: () {
          // Dodaj obsługę kliknięcia przycisku
        },
        icon: Icon(icon),
        label: Text(language),
        style: TextButton.styleFrom(
          primary: Colors.black,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }
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