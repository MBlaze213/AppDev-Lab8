import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart' show rootBundle;

class LyricsPage extends StatefulWidget {
  final List<Map<String, String>> songs;
  final int currentIndex;

  const LyricsPage({
    required this.songs,
    required this.currentIndex,
    super.key,
  });

  @override
  State<LyricsPage> createState() => _LyricsPageState();
}

class _LyricsPageState extends State<LyricsPage> {
  late int index;
  late String songTitle;
  late String songPath;
  late String lyricsPath;
  late String artist;
  late String albumCover;

  final player = AudioPlayer();
  bool isPlaying = false;
  String lyrics = "Loading lyrics...";
  Duration currentPosition = Duration.zero;
  Duration totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    index = widget.currentIndex;
    _loadSong();

    player.onPositionChanged.listen((pos) => setState(() => currentPosition = pos));
    player.onDurationChanged.listen((dur) => setState(() => totalDuration = dur));
    player.onPlayerComplete.listen((_) => _nextSong()); // auto-next on song end
  }

  void _loadSong() {
    final song = widget.songs[index];
    songTitle = song['title']!;
    artist = song['artist']!;
    songPath = song['path']!;
    lyricsPath = song['lyrics']!;
    albumCover = song['albumCover']!;
    _loadLyrics();
    _playMusic();
  }

  Future<void> _loadLyrics() async {
    final loadedLyrics = await rootBundle.loadString(lyricsPath);
    setState(() => lyrics = loadedLyrics);
  }

  Future<void> _playMusic() async {
    await player.stop();
    await player.play(AssetSource(songPath.replaceFirst('assets/', '')));
    setState(() => isPlaying = true);
  }

  void _toggleMusic() async {
    if (isPlaying) {
      await player.pause();
    } else {
      await player.resume();
    }
    setState(() => isPlaying = !isPlaying);
  }

  void _seekMusic(double value) {
    final position = Duration(seconds: value.toInt());
    player.seek(position);
  }

  void _prevSong() {
    index = (index - 1 + widget.songs.length) % widget.songs.length;
    _loadSong();
  }

  void _nextSong() {
    index = (index + 1) % widget.songs.length;
    _loadSong();
  }

  @override
  void dispose() {
    player.stop();
    player.dispose();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFF3E2723), // Bakery cream background
    body: SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Album cover + title + artist
          Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  albumCover,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                songTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  color: Color(0xFFFFF8E1), // warm brown
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                artist,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFFFFF8E1), // lighter brown
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Lyrics
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                lyrics,
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Color(0xFFFFF8E1), // dark chocolate color
                ),
              ),
            ),
          ),
          // Slider + Controls
          Column(
            children: [
              Slider(
                activeColor: const Color(0xFFD9886A), // warm peach
                inactiveColor: const Color(0xFFF0C9B2), // light cream
                min: 0,
                max: totalDuration.inSeconds.toDouble(),
                value: currentPosition.inSeconds
                    .toDouble()
                    .clamp(0, totalDuration.inSeconds.toDouble()),
                onChanged: _seekMusic,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(currentPosition),
                      style: const TextStyle(
                        color: Color(0xFFFFF8E1), // brown
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      _formatDuration(totalDuration),
                      style: const TextStyle(
                        color: Color(0xFFFFF8E1),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _prevSong,
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      backgroundColor: const Color(0xFFD9886A),
                      padding: const EdgeInsets.all(14),
                    ),
                    child: const Icon(Icons.skip_previous, color: Colors.white),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: _toggleMusic,
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      backgroundColor: const Color(0xFFD9886A),
                      padding: const EdgeInsets.all(18),
                    ),
                    child: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: _nextSong,
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      backgroundColor: const Color(0xFFD9886A),
                      padding: const EdgeInsets.all(14),
                    ),
                    child: const Icon(Icons.skip_next, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    ),
  );
}


  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }
}
