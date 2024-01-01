const Set<Song> songs = {
  Song('soundtrack.mp3', 'Upbeatinspiration', artist: 'Liborio Conti'),
};

class Song {
  final String filename;

  final String name;

  final String? artist;

  const Song(this.filename, this.name, {this.artist});

  @override
  String toString() => 'Song<$filename>';
}
