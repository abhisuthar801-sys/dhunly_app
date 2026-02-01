import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';

void main() => runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: DhunlyFinalFix()));

class DhunlyFinalFix extends StatefulWidget {
  const DhunlyFinalFix({super.key});
  @override
  State<DhunlyFinalFix> createState() => _DhunlyFinalFixState();
}

class _DhunlyFinalFixState extends State<DhunlyFinalFix> {
  final AudioPlayer player = AudioPlayer();
  List songs = [];
  bool isLoading = false;
  bool isPlaying = false;
  String currentSong = "Tap to Play";

  // Emergency Playlist (Taaki empty na dikhe)
  List defaultSongs = [
    {"name": "Fast Stream 1", "artist": "Dhunly Cloud", "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3"},
    {"name": "Fast Stream 2", "artist": "Dhunly Cloud", "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3"},
  ];

  Future<void> search(String query) async {
    setState(() => isLoading = true);
    try {
      final res = await http.get(Uri.parse("https://saavn.dev/api/search/songs?query=$query")).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        setState(() {
          songs = json.decode(res.body)['data']['results'];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  void play(String url, String name) async {
    await player.stop();
    await player.play(UrlSource(url));
    setState(() {
      currentSong = name;
      isPlaying = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(title: const Text("DHUNLY FIX"), backgroundColor: Colors.black),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextField(
              onSubmitted: (v) => search(v),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search Arijit, Punjabi...",
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.white10,
                prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          if (isLoading) const LinearProgressIndicator(),
          Expanded(
            child: ListView.builder(
              itemCount: songs.isEmpty ? defaultSongs.length : songs.length,
              itemBuilder: (context, index) {
                if (songs.isEmpty) {
                  var s = defaultSongs[index];
                  return ListTile(
                    title: Text(s['name'], style: const TextStyle(color: Colors.white)),
                    trailing: const Icon(Icons.play_arrow, color: Colors.green),
                    onTap: () => play(s['url'], s['name']),
                  );
                }
                var s = songs[index];
                return ListTile(
                  leading: Image.network(s['image'][0]['url']),
                  title: Text(s['name'], style: const TextStyle(color: Colors.white)),
                  onTap: () => play(s['downloadUrl'].last['url'], s['name']),
                );
              },
            ),
          ),
          Container(
            color: Colors.blueAccent,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(child: Text(currentSong, style: const TextStyle(fontWeight: FontWeight.bold))),
                IconButton(
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: () {
                    if (isPlaying) player.pause(); else player.resume();
                    setState(() => isPlaying = !isPlaying);
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
