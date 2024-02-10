import 'settings_persistence.dart';

class MemoryOnlySettingsPersistence implements SettingsPersistence {
  bool musicOn = true;

  bool soundsOn = true;

  bool notificationsOn = true;

  bool muted = true;

  String playerName = 'Player';

  @override
  Future<bool> getNotificationsOn() async => musicOn;

  @override
  Future<void> saveNotificationsOn(bool value) async => musicOn = value;

  @override
  Future<bool> getMusicOn() async => musicOn;

  @override
  Future<bool> getMuted() async => muted;

  @override
  Future<String> getPlayerName() async => playerName;

  @override
  Future<bool> getSoundsOn() async => soundsOn;

  @override
  Future<void> saveMusicOn(bool value) async => musicOn = value;

  @override
  Future<void> saveMuted(bool value) async => muted = value;

  @override
  Future<void> savePlayerName(String value) async => playerName = value;

  @override
  Future<void> saveSoundsOn(bool value) async => soundsOn = value;
}
