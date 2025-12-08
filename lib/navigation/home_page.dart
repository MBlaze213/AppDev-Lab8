import 'package:flutter/material.dart';
import 'lyrics_page.dart';

class Playlist extends StatelessWidget {
  final List<Map<String, String>> songs = [
    {
      'title': 'Kahel Na Langit', 'artist': 'Maki',
      'path': 'assets/music/kahel_na_langit.mp3',
      'lyrics': 'assets/lyrics/kahel_na_langit.txt',
      'albumCover':'assets/image/kahel_na_langit.jpg',
    },
    {
      'title': 'I Gotta Feeling ', 'artist': 'Black Eyed Peas ',
      'path': 'assets/music/i_gotta_feeling.mp3',
      'lyrics': 'assets/lyrics/i_gotta_feeling.txt',
      'albumCover':'assets/image/i_gotta_feeling.jpg',
    },
    {
      'title': 'Treat You Better', 'artist': 'Shawn Mendes',
      'path':'assets/music/treat_you_better.mp3',
      'lyrics': 'assets/lyrics/treat_you_better.txt',
      'albumCover':'assets/image/treat_you_better.jpg',
    },
    {
      'title': 'Say You Wont Let Go', 'artist': 'James Arthur',
      'path': 'assets/music/say_you_wont_let_go.mp3',
      'lyrics': 'assets/lyrics/say_you_wont_let_go.txt',
      'albumCover':'assets/image/say_you_wont_let_go.jpg',
    },
    {
      'title': 'Young Dumb & Broke', 'artist': 'Khalid',
      'path': 'assets/music/young_dumb.mp3',
      'lyrics': 'assets/lyrics/young_dumb.txt',
      'albumCover':'assets/image/young_dumb.jpg',
    },
    {
      'title': 'ILYSB', 'artist': 'LANY',
      'path': 'assets/music/ilysb.mp3',
      'lyrics': 'assets/lyrics/ilysb.txt',
      'albumCover':'assets/image/ilysb.jpg',
    },
    {
      'title': 'Drag Me Down', 'artist': 'One Direction',
      'path': 'assets/music/drag_me_down.mp3',
      'lyrics': 'assets/lyrics/drag_me_down.txt',
      'albumCover':'assets/image/drag_me_down.jpg',
    },
    {
      'title': 'Stitches', 'artist': 'Shawn Mendes',
      'path':'assets/music/stitches.mp3',
      'lyrics': 'assets/lyrics/stitches.txt',
      'albumCover':'assets/image/stitches.jpg',
    },
    {
      'title': 'Together', 'artist': 'Ne-Yo',
      'path': 'assets/music/together.mp3',
      'lyrics': 'assets/lyrics/together.txt',
      'albumCover':'assets/image/together.jpg',
    },
    {
      'title': 'The Man Who Cant Be Moved','artist': 'The Script',
      'path':'assets/music/the_man_who_cant_be_moved.mp3',
      'lyrics': 'assets/lyrics/the_man_who_cant_be_moved.txt',
      'albumCover':'assets/image/the_man_who_cant_be_moved.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KawaiiBeats',
            style: TextStyle(color: Color(0xFF3B1F1F), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        leading: const Icon(Icons.music_note_rounded, color: Color(0xFF4B2E2E)),
        elevation: 0,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Image(
            image: AssetImage("assets/image/download.jpg"),
            fit: BoxFit.cover,
          ),
          Container(
            color: const Color(0xCCF3E6D8),
          ),
          ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LyricsPage(
                        songs: songs,
                        currentIndex: index,
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE0D6), 
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black26, blurRadius: 6, offset: Offset(2, 2)),
                    ],
                    border: Border.all(color: const Color(0xFFFFC1CC), width: 1.2),
                  ),
                  child:Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: AssetImage(song['albumCover']!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              song['title']!,
                              style: const TextStyle(
                                color: Color(0xFF3B1F1F),
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              song['artist']!,
                              style: const TextStyle(
                                color: Color(0xFF4B2E2E),
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.play_arrow, color: Color(0xFF4B2E2E), size: 28),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
