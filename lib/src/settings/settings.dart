
import 'package:flutter/foundation.dart';

import '../notifications/notifications_manager.dart';
import 'persistence/settings_persistence.dart';


class SettingsController extends ChangeNotifier {
  final SettingsPersistence _persistence;

  ValueNotifier<bool> muted = ValueNotifier(false);

  ValueNotifier<String> playerName = ValueNotifier('Player');

  ValueNotifier<bool> soundsOn = ValueNotifier(true);

  ValueNotifier<bool> musicOn = ValueNotifier(true);

  ValueNotifier<bool> notificationsEnabled = ValueNotifier(true);

  ValueNotifier<bool> vibrationsEnabled = ValueNotifier(true);

  SettingsController({required SettingsPersistence persistence})
      : _persistence = persistence;

  Future<void> loadStateFromPersistence() async {
    await Future.wait([

      _persistence.getMuted().then((value) => muted.value = value),
      _persistence.getSoundsOn().then((value) => soundsOn.value = value),
      _persistence.getMusicOn().then((value) => musicOn.value = value),
      _persistence.getNotificationsOn().then((value) => notificationsEnabled.value = value),
      _persistence.getPlayerName().then((value) => playerName.value = value),
    ]);
  }

  void toggleNotifications(NotificationsManager notificationsManager) {
    notificationsEnabled.value = !notificationsEnabled.value;
    _persistence.saveNotificationsOn(notificationsEnabled.value);
    if (notificationsEnabled.value) {
      notificationsManager.initializeNotifications();// Włącz powiadomienia
    } else {
      notificationsManager.cancelAllNotifications(); // Wyłącz powiadomienia
    }
  }

  void setPlayerName(String name) {
    playerName.value = name;
    _persistence.savePlayerName(playerName.value);
  }

  void toggleMusicOn() {
    musicOn.value = !musicOn.value;
    _persistence.saveMusicOn(musicOn.value);
  }

  void toggleMuted() {
    muted.value = !muted.value;
    _persistence.saveMuted(muted.value);
  }

  void toggleSoundsOn() {
    soundsOn.value = !soundsOn.value;
    _persistence.saveSoundsOn(soundsOn.value);
  }

  void toggleVibrations() {
    vibrationsEnabled.value = !vibrationsEnabled.value;
    notifyListeners();
  }
}
