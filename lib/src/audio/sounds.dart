List<String> soundTypeToFilename(SfxType type) {
  switch (type) {
    case SfxType.animationCardSound:
      return const [
        'animation_card_sound.mp3',
      ];
    case SfxType.aplauz:
      return const [
        'aplauz.mp3',
      ];
    case SfxType.booingSound:
      return const [
        'booing_sound.mp3',
      ];
    case SfxType.buttonAccept:
      return const [
        'button_accept.mp3',
      ];
    case SfxType.buttonBackExit:
      return const [
        'button_back_exit.mp3',
      ];
    case SfxType.button_infos:
      return const [
        'button_infos.mp3',
      ];
    case SfxType.buzzer_sound:
      return const [
        'buzzer_sound.mp3',
      ];
    case SfxType.card_skip_sound:
      return const [
        'card_skip_sound.mp3',
      ];
    case SfxType.card_tick_sound:
      return const [
        'card_tick_sound.mp3',
      ];
    case SfxType.card_x_sound:
      return const [
        'card_x_sound.mp3',
      ];
    case SfxType.correct_answer:
      return const [
        'correct_answer.mp3',
      ];
    case SfxType.heartbeat:
      return const [
        'heartbeat.mp3',
      ];
    case SfxType.pop_card_sound:
      return const [
        'pop_card_sound.mp3',
      ];
    case SfxType.ripple_sound:
      return const [
        'ripple_sound.mp3',
      ];
    case SfxType.roulette_wheel:
      return const [
        'roulette_wheel.mp3',
      ];
    case SfxType.win_game:
      return const [
        'win_game.mp3',
      ];
    case SfxType.score_sound_effect:
      return const [
        'score_sound_effect.mp3',
      ];
    case SfxType.physical_challenge_lottery:
      return const [
        'physical_challenge_lottery.mp3',
      ];
    case SfxType.clock_effect:
      return const [
        'clock_effect.mp3',
      ];
  }
}

//glosnosc
double soundTypeToVolume(SfxType type) {
  switch (type) {
    case SfxType.animationCardSound:
      return 0.4;
    case SfxType.card_x_sound:
      return 0.2;
    case SfxType.booingSound:
    case SfxType.buttonAccept:
    case SfxType.buttonBackExit:
    case SfxType.card_skip_sound:
    case SfxType.clock_effect:
      return 1.0;
      default: return 1.0;
  }
}

enum SfxType {
  animationCardSound,
  aplauz,
  booingSound,
  buttonAccept,
  buttonBackExit,
  button_infos,
  buzzer_sound,
  card_skip_sound,
  card_tick_sound,
  card_x_sound,
  correct_answer,
  heartbeat,
  pop_card_sound,
  ripple_sound,
  roulette_wheel,
  win_game,
  score_sound_effect,
  physical_challenge_lottery,
  clock_effect
}
