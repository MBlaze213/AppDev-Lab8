import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart' show rootBundle;

class LyricsPage extends StatefulWidget {
  final String songTitle;
  final String songPath;
  final String lyricsPath;

  const LyricsPage({
    required this.songTitle,
    required this.songPath,
    required this.lyricsPath,
    super.key,
  });

  @override
  State<LyricsPage> createState() => _LyricsPageState();
}

class _LyricsPageState extends State<LyricsPage> {
  final player = AudioPlayer();
  bool isPlaying = false;
  String lyrics = "Loading lyrics...";

  @override
  void initState() {
    super.initState();
    _loadLyrics();
    _playMusic();
  }

  Future<void> _loadLyrics() async {
    final loadedLyrics = await rootBundle.loadString(widget.lyricsPath);
    setState(() => lyrics = loadedLyrics);
  }

  Future<void> _playMusic() async {
    await player.play(AssetSource(widget.songPath.replaceFirst('assets/', '')));
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

  @override
  void dispose() {
    player.stop();
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
        
          Image.asset('assets/image/bg.jpg', fit: BoxFit.cover),

          Container(color: Colors.black.withOpacity(0.4)),

          
          Column(
            children: [
              const SizedBox(height: 20),
              const Icon(Icons.music_note, size: 100, color: Colors.white),
              Text(
                'Now Playing:\n${widget.songTitle}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, color: Colors.white),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child:
                  Text(

                    lyrics,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 4,
                          color: Color.fromARGB(221, 26, 24, 24),
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _toggleMusic,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purpleAccent,
                    ),
                    child: Text(isPlaying ? 'Pause ⏸️' : 'Play ▶️'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      player.stop();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                    child: const Text('Back 🔙'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }
}
