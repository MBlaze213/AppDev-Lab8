import 'package:flutter/material.dart';
import 'lyrics_page.dart';

class Playlist extends StatelessWidget {
  final List<Map<String, String>> songs = [
    {
      'title': 'Song 1 - Maki - kahel na langit (Lyrics)',
      'path': 'assets/music/kahel na langit.mp3',
      'lyrics': 'assets/lyrics/kahel na langit.txt',
    },
    {
      'title': 'Song 2 -Black Eyed Peas - I Gotta Feeling ',
      'path': 'assets/music/Black Eyed Peas - I Gotta Feeling (Lyrics).mp3',
      'lyrics': 'assets/lyrics/i_gotta_feeling.txt',
    },
    {
      'title': 'Song  3-Jroa - Treat You Better',
      'path':
          'assets/music/Jroa - Treat You Better (Lyrics) [TikTok Song] Ilang Beses Mo Na Sinabi Sakin Na Masaya.mp3',
      'lyrics': 'assets/lyrics/jroa_treat_you_better.txt',
    },
    {
      'title': 'Song 4 -  James Arthur - Say You Won_t Let Go',
      'path': 'assets/music/James Arthur - Say You Won_t Let Go (Lyrics).mp3',
      'lyrics': 'assets/lyrics/Say You Won_t Let Go.txt',
    },
    {
      'title': 'Song 5 - Khalid - Young Dumb & Broke',
      'path': 'assets/music/Khalid - Young Dumb & Broke (Lyrics).mp3',
      'lyrics': 'assets/lyrics/Khalid - Young Dumb & Broke.txt',
    },
    {
      'title': 'Song 6 -LANY - ILYSB',
      'path': 'assets/music/LANY - ILYSB (Official Lyric).mp3',
      'lyrics': 'assets/lyrics/LANY - ILYSB (Official Lyric).txt',
    },
    {
      'title': 'Song 7 - One Direction - Drag Me Down',
      'path': 'assets/music/One Direction - Drag Me Down (Official Video).mp3',
      'lyrics': 'assets/lyrics/One Direction - Drag Me Down.txt',
    },
    {
      'title': 'Song 8 -Shawn Mendes - Stitches',
      'path':
          'assets/music/Shawn Mendes - Stitches (Lyrics)  The Chainsmokers, Justin Bieber, Ed Sheeran  Mixed Lyrics.mp3',
      'lyrics': 'assets/lyrics/Shawn Mendes - Stitches (Lyrics).txt',
    },
    {
      'title': 'Song 9 -Together - Ne-Yo',
      'path': 'assets/music/Together - Ne-Yo (Lyrics).mp3',
      'lyrics': 'assets/lyrics/Together - Ne-Yo.txt',
    },
    {
      'title': 'Song 10 - The Script - The Man Who Can_t Be Moved',
      'path':
          'assets/music/The Script - The Man Who Can_t Be Moved (Lyrics).mp3',
      'lyrics': 'assets/lyrics/The Script - The Man Who Can_t Be Moved.txt',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KawaiiBeats', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 56, 0, 66),
        leading: const Icon(
          Icons.music_note_rounded,
          color: Color.fromARGB(255, 12, 133, 48),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/image/download.jpg"),
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 20),
          itemCount: songs.length,
          itemBuilder: (context, index) {
            final song = songs[index];
            return Card(
              color: Colors.black54,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.music_note_rounded,
                  color: Color.fromARGB(255, 12, 133, 48),
                ),
                title: Text(
                  song['title']!,
                  style: const TextStyle(color: Colors.white),
                ),
                trailing: const Icon(Icons.play_arrow, color: Colors.white),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LyricsPage(
                        songTitle: song['title']!,
                        songPath: song['path']!,
                        lyricsPath: song['lyrics']!,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
