import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class AddSongScreen extends StatefulWidget {
  const AddSongScreen({super.key});
  @override
  State<AddSongScreen> createState() => _AddSongScreenState();
}

class _AddSongScreenState extends State<AddSongScreen> {
  final titleController = TextEditingController();
  final artistController = TextEditingController();
  final lyricsController = TextEditingController();
  File? selectedImage;
  File? selectedMp3;

  Future pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => selectedImage = File(image.path));
  }

  Future pickMp3() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['mp3']);
    if (result != null) setState(() => selectedMp3 = File(result.files.single.path!));
  }

  Future _addSong(BuildContext context) async {
    if (titleController.text.isEmpty || artistController.text.isEmpty) return;
    final appDir = await getApplicationDocumentsDirectory();
    String finalCoverPath = 'assets/image/default.jpg';
    String finalMp3Path = 'assets/music/default.mp3';

    if (selectedImage != null) {
      final fName = '${DateTime.now().millisecondsSinceEpoch}_${p.basename(selectedImage!.path)}';
      finalCoverPath = p.join(appDir.path, fName);
      await selectedImage!.copy(finalCoverPath);
    }
    if (selectedMp3 != null) {
      final fName = '${DateTime.now().millisecondsSinceEpoch}_${p.basename(selectedMp3!.path)}';
      finalMp3Path = p.join(appDir.path, fName);
      await selectedMp3!.copy(finalMp3Path);
    }

    await FirebaseFirestore.instance.collection('songs').add({
      'title': titleController.text,
      'artist': artistController.text,
      'lyrics': lyricsController.text,
      'albumCover': finalCoverPath,
      'path': finalMp3Path,
      'createdBy': FirebaseAuth.instance.currentUser?.email,
      'timestamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Song added successfully')));
    Navigator.pop(context);
  }

  InputDecoration modernField(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Color(0xFF4B2E2B)),
    filled: true,
    fillColor: const Color(0xFFF4E1D2),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD8B4A6))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFB76E79), width: 1.8)),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFEFD8C5),
    appBar: AppBar(
      title: const Text('Add Song', style: TextStyle(color: Color(0xFF4B2E2B))),
      backgroundColor: const Color(0xFFEFD8C5),
      elevation: 0,
      iconTheme: const IconThemeData(color: Color(0xFF4B2E2B)),
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TextField(controller: titleController, decoration: modernField("Song Title"), style: const TextStyle(color: Color(0xFF4B2E2B))),
        const SizedBox(height: 16),
        TextField(controller: artistController, decoration: modernField("Artist"), style: const TextStyle(color: Color(0xFF4B2E2B))),
        const SizedBox(height: 16),
        TextField(controller: lyricsController, decoration: modernField("Lyrics"), style: const TextStyle(color: Color(0xFF4B2E2B)), maxLines: 5),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: pickImage,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            backgroundColor: const Color(0xFFB284BE),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text("Pick Album Cover Image", style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
        if (selectedImage != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Image.file(selectedImage!, height: 120, width: double.infinity, fit: BoxFit.cover),
          ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: pickMp3,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            backgroundColor: const Color(0xFFB284BE),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text("Pick MP3 File", style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
        if (selectedMp3 != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text("MP3 Selected: ${selectedMp3!.path.split('/').last}",
              style: const TextStyle(fontSize: 14, color: Color(0xFF4B2E2B))),
          ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () => _addSong(context),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(55),
            backgroundColor: const Color(0xFFB284BE),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text("Add Song", style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
        ),
      ]),
    ),
  );
}
