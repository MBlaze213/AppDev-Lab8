import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart' show rootBundle;

class LyricsPage extends StatefulWidget {
  final List<Map<String, String>> songs;
  final int currentIndex;

  const LyricsPage({required this.songs, required this.currentIndex, super.key});

  @override
  State<LyricsPage> createState() => _LyricsPageState();
}

class _LyricsPageState extends State<LyricsPage> {
  late int index;
  late String songTitle, songPath, lyricsPath, artist, albumCover;
  final player = AudioPlayer();
  bool isPlaying = false;
  String lyrics = "Loading lyrics...";
  Duration currentPosition = Duration.zero, totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    index = widget.currentIndex;
    player.onPositionChanged.listen((pos) => setState(() => currentPosition = pos));
    player.onDurationChanged.listen((dur) => setState(() => totalDuration = dur));
    player.onPlayerComplete.listen((_) => _nextSong());
    _loadSong();
  }

  void _loadSong() {
    final song = widget.songs[index];
    songTitle = song['title'] ?? '';
    artist = song['artist'] ?? '';
    songPath = song['path'] ?? '';
    lyricsPath = song['lyrics'] ?? '';
    albumCover = song['albumCover'] ?? '';
    _loadLyrics();
    _playMusic();
  }

  Future<void> _loadLyrics() async {
    String loadedContent = "Lyrics not found.";
    if (lyricsPath.isEmpty) loadedContent = "No lyrics provided.";
    else {
      try {
        loadedContent = lyricsPath.startsWith("assets/")
            ? await rootBundle.loadString(lyricsPath)
            : await File(lyricsPath).readAsString();
      } catch (_) {
        loadedContent = lyricsPath;
      }
    }
    setState(() => lyrics = loadedContent);
  }

  Future<void> _playMusic() async {
    await player.stop();
    if (songPath.startsWith("assets/")) {
      await player.play(AssetSource(songPath.replaceFirst("assets/", "")));
    } else {
      await player.play(DeviceFileSource(songPath));
    }
    setState(() => isPlaying = true);
  }

  void _toggleMusic() async {
    if (isPlaying) await player.pause();
    else await player.resume();
    setState(() => isPlaying = !isPlaying);
  }

  void _seekMusic(double value) => player.seek(Duration(seconds: value.toInt()));
  void _prevSong() { index = (index - 1 + widget.songs.length) % widget.songs.length; _loadSong(); }
  void _nextSong() { index = (index + 1) % widget.songs.length; _loadSong(); }

  @override
  void dispose() { player.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3E2723),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: albumCover.startsWith("assets/")
                      ? Image.asset(albumCover, width: 200, height: 200, fit: BoxFit.cover)
                      : Image.file(File(albumCover), width: 200, height: 200, fit: BoxFit.cover),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: Center(
                    child: Text(
                      songTitle,
                      style: const TextStyle(
                        fontSize: 28,
                        color: Color(0xFFFFF8E1),
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center, // ensures even long titles are centered
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  artist,
                  style: const TextStyle(fontSize: 14, color: Color(0xFFFFF8E1)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  lyrics,
                  style: const TextStyle(fontSize: 16, height: 1.5, color: Color(0xFFFFF8E1)),
                ),
              ),
            ),
            Column(
              children: [
                Slider(
                  activeColor: const Color(0xFFD9886A),
                  inactiveColor: const Color(0xFFF0C9B2),
                  min: 0,
                  max: totalDuration.inSeconds.toDouble(),
                  value: currentPosition.inSeconds.clamp(0, totalDuration.inSeconds).toDouble(),
                  onChanged: _seekMusic,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 26),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatDuration(currentPosition),
                          style: const TextStyle(color: Color(0xFFFFF8E1), fontSize: 12)),
                      Text(_formatDuration(totalDuration),
                          style: const TextStyle(color: Color(0xFFFFF8E1), fontSize: 12)),
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
                      child: Icon(isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white, size: 30),
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
    final min = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final sec = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$min:$sec";
  }
}
