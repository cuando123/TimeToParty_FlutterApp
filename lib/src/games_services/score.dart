import 'package:flutter/cupertino.dart';

class TeamScore {
  final String teamName;
  final Color teamColor;
  double score;
  List<double> scoreHistory;
  static final Map<String, TeamScore> _teamScores = {};

  TeamScore({
    required this.teamName,
    required this.teamColor,
    this.score = 0,
    List<double>? scoreHistory,
  }) : scoreHistory = scoreHistory ?? [];

  double getTotalScore() {
    return scoreHistory.fold(score, (total, roundScore) => total + roundScore);
  }

  static TeamScore getTeamScore(String teamName, Color teamColor) {
    String identifier = _createTeamIdentifier(teamName, teamColor);
    return _teamScores.putIfAbsent(identifier, () => TeamScore(
      teamName: teamName,
      teamColor: teamColor,
    ));
  }

  static void updateTeamScore(TeamScore teamScore) {
    String identifier = _createTeamIdentifier(teamScore.teamName, teamScore.teamColor);
    _teamScores[identifier] = teamScore;
  }

  static int getRoundNumber(String teamName, Color teamColor) {
    String identifier = _createTeamIdentifier(teamName, teamColor);
    return _teamScores.containsKey(identifier) ? _teamScores[identifier]!.scoreHistory.length + 1 : 1;
  }

  static void updateForNextRound(String teamName, Color teamColor, double newPoints) {
    String identifier = _createTeamIdentifier(teamName, teamColor);
    var currentScore = _teamScores.putIfAbsent(identifier, () => TeamScore(teamName: teamName, teamColor: teamColor));

    // Aktualizacja aktualnego wyniku, ale nie dodawanie go jeszcze do historii
    currentScore.score += newPoints;

    // Dodaj poprzedni wynik do historii i zresetuj bieżący wynik na koniec rundy
    currentScore.scoreHistory.add(currentScore.score);
    currentScore.score = 0; // Resetuj wynik dla nowej rundy

    _teamScores[identifier] = currentScore;
  }


  static void resetAllScores() {
    _teamScores.clear();
  }

  static String _createTeamIdentifier(String teamName, Color teamColor) {
    return '$teamName:${teamColor.value}';
  }
}
