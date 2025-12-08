import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'lyrics_page.dart';
import '../log_in/login_screen.dart';
import '../add_song_screen.dart';

class Playlist extends StatefulWidget {
  const Playlist({super.key});
  @override
  State<Playlist> createState() => _PlaylistState();
}

class _PlaylistState extends State<Playlist> {
  final List<Map<String, String>> songs = [
    {
      'title': 'Kahel Na Langit',
      'artist': 'Maki',
      'path': 'assets/music/kahel_na_langit.mp3',
      'lyrics': 'assets/lyrics/kahel_na_langit.txt',
      'albumCover': 'assets/image/kahel_na_langit.jpg',
    },
    {
      'title': 'I Gotta Feeling',
      'artist': 'Black Eyed Peas',
      'path': 'assets/music/i_gotta_feeling.mp3',
      'lyrics': 'assets/lyrics/i_gotta_feeling.txt',
      'albumCover': 'assets/image/i_gotta_feeling.jpg',
    },
    {
      'title': 'Treat You Better',
      'artist': 'Shawn Mendes',
      'path': 'assets/music/treat_you_better.mp3',
      'lyrics': 'assets/lyrics/treat_you_better.txt',
      'albumCover': 'assets/image/treat_you_better.jpg',
    },
    {
      'title': 'Say You Wont Let Go',
      'artist': 'James Arthur',
      'path': 'assets/music/say_you_wont_let_go.mp3',
      'lyrics': 'assets/lyrics/say_you_wont_let_go.txt',
      'albumCover': 'assets/image/say_you_wont_let_go.jpg',
    },
    {
      'title': 'Young Dumb & Broke',
      'artist': 'Khalid',
      'path': 'assets/music/young_dumb.mp3',
      'lyrics': 'assets/lyrics/young_dumb.txt',
      'albumCover': 'assets/image/young_dumb.jpg',
    },
    {
      'title': 'ILYSB',
      'artist': 'LANY',
      'path': 'assets/music/ilysb.mp3',
      'lyrics': 'assets/lyrics/ilysb.txt',
      'albumCover': 'assets/image/ilysb.jpg',
    },
    {
      'title': 'Drag Me Down',
      'artist': 'One Direction',
      'path': 'assets/music/drag_me_down.mp3',
      'lyrics': 'assets/lyrics/drag_me_down.txt',
      'albumCover': 'assets/image/drag_me_down.jpg',
    },
    {
      'title': 'Stitches',
      'artist': 'Shawn Mendes',
      'path': 'assets/music/stitches.mp3',
      'lyrics': 'assets/lyrics/stitches.txt',
      'albumCover': 'assets/image/stitches.jpg',
    },
    {
      'title': 'Together',
      'artist': 'Ne-Yo',
      'path': 'assets/music/together.mp3',
      'lyrics': 'assets/lyrics/together.txt',
      'albumCover': 'assets/image/together.jpg',
    },
    {
      'title': 'The Man Who Cant Be Moved',
      'artist': 'The Script',
      'path': 'assets/music/the_man_who_cant_be_moved.mp3',
      'lyrics': 'assets/lyrics/the_man_who_cant_be_moved.txt',
      'albumCover': 'assets/image/the_man_who_cant_be_moved.jpg',
    },
  ];

  User? firebaseUser;
  GoogleSignInAccount? googleUser;
  String searchQuery='';

  @override
  void initState(){super.initState();_loadUser();}
  Future<void> _loadUser() async {firebaseUser=FirebaseAuth.instance.currentUser;googleUser=await GoogleSignIn().signInSilently();setState((){});}

  void _openAccountDrawer(){
    showModalBottomSheet(context: context,backgroundColor: Colors.transparent,isScrollControlled: true,builder: (_){
      final photoUrl=googleUser?.photoUrl;
      final name=googleUser?.displayName??firebaseUser?.displayName??'Guest User';
      final email=googleUser?.email??firebaseUser?.email??'guest@example.com';
      return FractionallySizedBox(widthFactor:1,child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: Color(0xFFF3E6D8),borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(mainAxisSize: MainAxisSize.min,children:[
          CircleAvatar(radius:40,backgroundImage: photoUrl!=null?NetworkImage(photoUrl):null,child: photoUrl==null?const Icon(Icons.account_circle,size:80,color: Color(0xFFB284BE)):null),
          const SizedBox(height:12),
          Text(name,style: const TextStyle(fontSize:18,fontWeight: FontWeight.bold,color: Color(0xFF3B1F1F))),
          const SizedBox(height:6),
          Text(email,style: const TextStyle(fontSize:14,color: Color(0xFF4B2E2E))),
          const SizedBox(height:20),
          ElevatedButton(onPressed: () async {await FirebaseAuth.instance.signOut();await GoogleSignIn().signOut();if(mounted)Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (_)=>const LoginScreen()),(route)=>false);},style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB284BE)),child: const Text("Logout",style: TextStyle(color: Colors.white)))
        ]),
      ));
    });
  }

  @override
  Widget build(BuildContext context){
    final songsStream=FirebaseFirestore.instance.collection('songs').orderBy('timestamp',descending:true).snapshots();
    return Scaffold(
      appBar: AppBar(
        title: const Text('KawaiiBeats',style: TextStyle(color: Color(0xFF3B1F1F),fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        leading: const Icon(Icons.music_note_rounded,color: Color(0xFF4B2E2E)),
        actions:[
          IconButton(icon: const Icon(Icons.add,color: Color(0xFF4B2E2E)),onPressed: ()=>Navigator.push(context,MaterialPageRoute(builder: (_)=>const AddSongScreen()))),
          IconButton(icon: CircleAvatar(backgroundColor: const Color(0xFFB284BE),backgroundImage: googleUser?.photoUrl!=null?NetworkImage(googleUser!.photoUrl!):null,child: googleUser?.photoUrl==null?const Icon(Icons.account_circle,color: Colors.white):null),onPressed: _openAccountDrawer),
          const SizedBox(width:12)
        ],
        elevation:0,
      ),
      body: Stack(fit: StackFit.expand,children:[
        const Image(image: AssetImage("assets/image/download.jpg"),fit: BoxFit.cover),
        Container(color: const Color(0xCCF3E6D8)),
        Column(children:[
          Padding(padding: const EdgeInsets.all(12.0),child: TextField(onChanged: (val)=>setState(()=>searchQuery=val.toLowerCase()),decoration: InputDecoration(hintText:'Search songs',prefixIcon: const Icon(Icons.search),border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),fillColor: Colors.white,filled:true))),
          Expanded(child: StreamBuilder<QuerySnapshot>(
            stream: songsStream,
            builder: (context,snapshot){
              if(!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final firestoreSongs=snapshot.data!.docs.map((doc){
                final data=doc.data() as Map<String,dynamic>;
                return {'title':data['title']?.toString()??'Unknown Title','artist':data['artist']?.toString()??'Unknown Artist','lyrics':data['lyrics']?.toString()??'','albumCover':data['albumCover']?.toString()??'assets/image/default.jpg','path':data['path']?.toString()??'assets/music/default.mp3'};
              }).toList();
              final allSongs=[...songs,...firestoreSongs];
              final filteredSongs=allSongs.where((song){
                final title=song['title']!.toLowerCase();
                final artist=song['artist']!.toLowerCase();
                return title.contains(searchQuery)||artist.contains(searchQuery);
              }).toList();
              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical:8,horizontal:12),
                itemCount: filteredSongs.length,
                itemBuilder: (context,index){
                  final song=filteredSongs[index];
                  final String coverPath=song['albumCover']!;
                  final bool isAsset=coverPath.startsWith('assets/');
                  return GestureDetector(
                    onTap: ()=>Navigator.push(context,MaterialPageRoute(builder: (_)=>LyricsPage(songs:filteredSongs,currentIndex:index))),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical:8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: const Color(0xFFFFE0D6),borderRadius: BorderRadius.circular(16),boxShadow: const [BoxShadow(color: Colors.black26,blurRadius:6,offset: Offset(2,2))],border: Border.all(color: const Color(0xFFFFC1CC),width:1.2)),
                      child: Row(children:[
                        Container(width:50,height:50,decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),image: DecorationImage(image: isAsset?AssetImage(coverPath):FileImage(File(coverPath)) as ImageProvider,fit: BoxFit.cover))),
                        const SizedBox(width:12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,children:[
                          Text(song['title']!,style: const TextStyle(color: Color(0xFF3B1F1F),fontSize:15,fontWeight: FontWeight.w500)),
                          Text(song['artist']!,style: const TextStyle(color: Color(0xFF4B2E2E),fontSize:12,fontWeight: FontWeight.w400))
                        ])),
                        isAsset
                          ? const Icon(Icons.play_arrow,color: Color(0xFF4B2E2E),size:28)
                          : PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert,color: Color(0xFF4B2E2E)),
                              onSelected: (value) async {
                                if(value=='delete'){
                                  final songDoc=await FirebaseFirestore.instance.collection('songs').where('title',isEqualTo:song['title']).where('artist',isEqualTo:song['artist']).get();
                                  for(var doc in songDoc.docs){await doc.reference.delete();}
                                  if(mounted){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Song deleted successfully')));}
                                }
                              },
                              itemBuilder: (_)=>[const PopupMenuItem(value:'delete',child: Text('Delete',style: TextStyle(color: Colors.red)))]
                            )
                      ]),
                    ),
                  );
                },
              );
            },
          ))
        ])
      ]),
    );
  }
}