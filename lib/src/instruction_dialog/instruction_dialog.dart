import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:game_template/src/main_menu/main_menu_screen.dart';
import '../customAppBar/customAppBar.dart';
import '../drawer/drawer.dart';

class InstructionDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        textTheme: ThemeData().textTheme.copyWith(
              titleLarge: TextStyle(
                  fontFamily: 'HindMadurai',
                  color: Color(0xFFCB48EF),
                fontSize: 24,
              ),
              bodyLarge: TextStyle(fontSize: 16),
            ),
      ),
      child: Builder(
        builder: (BuildContext context) {
          return AlertDialog(
            title: Center(child: Text('Zasady gry')),
            content: Container(
              width: double.maxFinite,
              child: Column(
                children: [
                  SvgPicture.asset('assets/time_to_party_assets/line_instruction_screen.svg'),
                  SizedBox(height: 16), // gap
                  Expanded(
                    child: ListView(
                      children: [
                        buildStyledTextPink('Wstęp do gry'),
                        _gap,
                        Text('W Time to Party, uczestnicy tłumaczą znaczenia słów innym graczom poprzez użycie synonimów, antonimów i wskazówek. Pola premiowe oferują dodatkowe zadania, takie jak prezentowanie zwierząt czy zawodów, znajdowanie rymów, opisywanie sławnych osób, czy wymyślanie słów zaczynających się na tę samą literę i inne.'),
                        _gap,
                        SvgPicture.asset(
                            'assets/time_to_party_assets/cards_instruction_linear.svg'),
                        _gap,
                        buildStyledTextPink('Cel gry'),
                        _gap,
                        Text('Gracze podzieleni na drużyny mają za zadanie odgadnąć jak najwięcej przedstawionych lub opisanych słów i jako pierwsi dotrzeć do mety.'),
                        _gap,
                        buildStyledTextPink('Drużyny i role'),
                        _gap,
                        Text('W grze drużyny wybierają kolor i nazwę, reprezentowane przez kolorowe flagi. W każdej turze jedna drużyna zgaduje, a druga sprawdza. Osoba opisująca w drużynie zgadującej przedstawia słowa z karty, a reszta członków stara się je odgadnąć.'),
                        _gap,
                        SvgPicture.asset(
                            'assets/time_to_party_assets/instruction_flags_field.svg'),
                        _gap,
                        buildStyledTextPink('Mechanika'),
                        _gap,
                        Text('Drużyna zaczynająca wybierana jest losowo. Gra zaczyna się od kręcenia ruletką. Wylosowany wynik przesuwa flagę o określoną liczbę pól, zatrzymując się na odpowiednim polu. Drużyna wyznacza jednego członka do opisywania (lub prezentowania) słów.'),
                        Text('Opisujący ma za zadanie przedstawić hasła, aby reszta drużyny odgadła wszystkie słowa w określonym czasie, nie używając słów z karty ani ich fragmentów. W zależności od rodzaju pola, na którym drużyna się zatrzyma, będą do wykonania różne zadania. Kolejność drużyn ustalana jest zgodnie z ruchem wskazówek zegara. Wygrywa drużyna, której pionek dotrze na metę jako pierwszy.'),
                        Text('Gra odbywa się na jednym urządzeniu, które trafia do opisującego w każdej turze. Przeciwna drużyna powinna mieć wgląd w ekran, aby kontrolować, czy nie ma oszustwa. Odgadujący nie mogą widzieć ekranu opisującego podczas odgadywania.'),
                        _gap,
                        buildStyledTextPink('Punktacja'),
                        _gap,
                        Text('Jeśli słowo wydaje się zbyt trudne, można je pominąć. Po opisaniu (lub pokazaniu) pozostałych słów, jeśli zostanie czas, można do niego wrócić. Drużyna nie traci punktów za pominięcie słów. Gracze zdobywają punkt za każde prawidłowo odgadnięte słowo. Pamiętaj! - SAMEMU WPROWADZASZ LICZBĘ PUNKTÓW o ile następnie zostanie przesunięta flaga! Przykład: '),
                        Text('Drużyna odgadła 5 słów, a więc powinna zyskać 5 punktów, niestety gracz opisujący słowa popełnił 2 błędy (np. 2x użył słowa którego nie mógł użyć). Dlatego 2 punkty zostają odjęte od wyniku drużyny i pionek przesuwa się tylko o 3 pola.',
                        style: TextStyle(
                          color: Colors.black26,
                        )),
                        _gap,
                        Row(
                          children: [
                            buildStyledTextPink("Słowa tabu"),
                            SizedBox(width: 10),
                            SvgPicture.asset(
                                'assets/time_to_party_assets/field_star_blue.svg'),
                          ],
                        ),
                        _gap,
                        Text('Pola z gwiazdką to karty ze słowami tabu. Kolor karty określa dodatkowe zadania, które pojawiają się losowo.'),
                        _gap,
                        SvgPicture.asset(
                            'assets/time_to_party_assets/instruction_cards_linear_2.svg'),
                        _gap,
                        Text('Gracz, który ma opisywać słowa, bierze urządzenie. Musi opisać 5 słów z danej karty według poniższych zasad:'),
                        Text('Gracze muszą odgadnąć słowo w identycznej formie jak opisana na karcie, a opisujący pomaga swojej drużynie. Jeśli słowo składa się z dwóch części, a jedna z nich zostanie odgadnięta, można jej użyć do opisania reszty słowa. Antonimy mogą być używane, ale nie wolno mówić w językach obcych ani wskazywać na cokolwiek, chyba że uzgodni się inaczej. Należy dawać jak najwięcej podpowiedzi i wskazówek, dopóki gracze nie odgadną słowa lub nie skończy się czas.'),
                        _gap,
                        Row(
                          children: [
                            buildStyledTextPink("Rymowanie"),
                            SizedBox(width: 10),
                            SvgPicture.asset(
                                'assets/time_to_party_assets/field_sheet.svg'),
                          ],
                        ),
                        _gap,
                        Text('Waszym zadaniem jest odnaleźć odpowiedni rym do podanych słów, który dopełni powiedziane zdanie. Np. jeśli macie słowo „kwiat” jeden z graczy może powiedzieć: „na wietrze buja kwiat” a reszta drużyny: „jaki piękny jest ten świat”. Nie wystarczy powiedzieć tylko kwiat - świat.'),
                        _gap,
                        Row(
                          children: [
                            buildStyledTextPink("Pantomimy"),
                            SizedBox(width: 10),
                            SvgPicture.asset(
                                'assets/time_to_party_assets/field_pantomime.svg'),
                          ],
                        ),
                        _gap,
                        Text('Waszym zadaniem jest przedstawienie pozostałym graczom drużyny danego słowa za pomocą pokazywania. W trakcie pokazywania gracz nie może mówić.'),
                        _gap,
                        Row(
                          children: [
                            buildStyledTextPink("Alfabet"),
                            SizedBox(width: 10),
                            SvgPicture.asset(
                                'assets/time_to_party_assets/field_letters.svg'),
                          ],
                        ),
                        _gap,
                        Text('Waszym zadaniem będzie wymienienie 20 rzeczowników na podaną literę. Nazwy własne nie są dozwolone. Jeśli uda się wam wymienić wszystkie – macie premiowy ruch ruletką, jeśli nie – zostajecie na tym samym polu.'),
                        _gap,
                        Row(
                          children: [
                            buildStyledTextPink("Sławni ludzie"),
                            SizedBox(width: 10),
                            SvgPicture.asset(
                                'assets/time_to_party_assets/field_microphone.svg'),
                          ],
                        ),
                        _gap,
                        Text('Jeżeli flaga będzie na tym polu, waszym zadaniem jest opisać znaną postać. Są tu nazwiska aktorów, grup muzycznych, znanych osób z różnych dziedzin, także zmyślonych postaci z bajek'),
                        _gap,
                        Row(
                          children: [
                            buildStyledTextPink("Pole wyboru"),
                            SizedBox(width: 10),
                            SvgPicture.asset(
                                'assets/time_to_party_assets/field_arrows.svg'),
                          ],
                        ),
                        _gap,
                        Text('To pole umożliwia wybór, które zadanie wasza drużyna ma wykonać. Mogą tutaj również pojawić się dodatkowe premiowe zadania.'),
                        _gap,
                        buildStyledTextPink("Podsumowanie"),
                        _gap,
                        Text('Najważniejsze jest, że chodzi o wspólną zabawę, a więc nie bierzcie wszystkich tych zasad zbyt poważnie! Uzgodnijcie między sobą, jeśli chcecie dostosować zasady do waszych potrzeb.')
                      ],
                    ),
                  ), // Dodaj swoją linię SVG tutaj
                ],
              ),
            ),
            actionsPadding: EdgeInsets.symmetric(
                horizontal: 20), // Zmniejsz obramowanie przycisków
            actions: [
              Expanded(
                child: Center(
                  heightFactor: 1.5,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFCB48EF), // color
                      foregroundColor: Colors.white, // textColor
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      minimumSize: Size(MediaQuery.of(context).size.width * 0.5,
                          MediaQuery.of(context).size.height * 0.05),
                      textStyle:
                          TextStyle(fontFamily: 'HindMadurai', fontSize: 20),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('OK'),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
  static const _gap = SizedBox(height: 10);
  Widget buildStyledTextPink(String text) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'HindMadurai',
        color: Color(0xFFCB48EF),
        fontSize: 24,
      ),
    );
  }
}
