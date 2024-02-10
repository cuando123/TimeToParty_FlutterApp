import 'package:flutter/cupertino.dart';

import '../app_lifecycle/translated_text.dart';

class TeamProvider with ChangeNotifier {
  String teams = '';
  List<String> teamNames = [];
  List<bool> hasUserInput = [];

  void initializeTeams(BuildContext context, int numberOfTeams) {
    teams = getTranslatedString(context, 'x_teams');
    teamNames = List<String>.generate(numberOfTeams, (index) => '$teams ${index + 1}');
    hasUserInput = List<bool>.generate(numberOfTeams, (index) => false);
    notifyListeners();
  }

  void updateTeams(BuildContext context, int numberOfTeams) {
    teams = getTranslatedString(context, 'x_teams');
    teamNames = List<String>.generate(numberOfTeams, (index) => '$teams ${index + 1}');
    hasUserInput = List<bool>.generate(numberOfTeams, (index) => false);
    notifyListeners();
  }

  void updateTeamName(int index, String newName) {
    teamNames[index] = newName;
    hasUserInput[index] = true;
    notifyListeners();
  }
}
