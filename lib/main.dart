import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: DhunlyUltimate()));

class DhunlyUltimate extends StatefulWidget {
  const DhunlyUltimate({super.key});
  @override
  State<DhunlyUltimate> createState() => _DhunlyUltimateState();
}

class _DhunlyUltimateState extends State<DhunlyUltimate> {
  final player = AudioPlayer();
  bool isPlaying = false;
  bool isLoading = false;
  List songs = [];
  String currentTitle = "Search your song";

  // Saavn API se gaane dhoondne ka function
  Future<void> searchSongs(String query) async {
    setState(() => isLoading = true);
    try {
      // Ye API fast hai aur direct high quality links deti hai
      final response = await http.get(Uri.parse("https://saavn.dev/api/search/songs?query=$query"));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          songs = data['data']['results'];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void playSong(String url, String title) async {
    await player.stop();
    // 320kbps ya 160kbps link select karna (fast loading ke liye)
    await player.play(UrlSource(url)); 
    setState(() {
      currentTitle = title;
      isPlaying = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Dhunly Search", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent.withOpacity(0.1),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextField(
              onSubmitted: (v) => searchSongs(v),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search: Arijit, Sidhu Moose Wala...",
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
            ),
          ),

          if (isLoading) const LinearProgressIndicator(color: Colors.blueAccent),

          // Search Results
          Expanded(
            child: ListView.builder(
              itemCount: songs.length,
              itemBuilder: (context, index) {
                var song = songs[index];
                // Hum high quality link uthayenge
                String streamUrl = song['downloadUrl'].last['url']; 
                String imageUrl = song['image'].last['url'];

                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.network(imageUrl, width: 50, height: 50, fit: BoxFit.cover),
                  ),
                  title: Text(song['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), maxLines: 1),
                  subtitle: Text(song['artists']['primary'][0]['name'], style: const TextStyle(color: Colors.white54)),
                  trailing: const Icon(Icons.play_circle_outline, color: Colors.blueAccent),
                  onTap: () => playSong(streamUrl, song['name']),
                );
              },
            ),
          ),

          // Mini Player
          if (isPlaying || currentTitle != "Search your song")
            Container(
              padding: const EdgeInsets.all(15),
              color: Colors.blueAccent.withOpacity(0.2),
              child: Row(
                children: [
                  const Icon(Icons.music_note, color: Colors.blueAccent),
                  const SizedBox(width: 15),
                  Expanded(child: Text(currentTitle, style: const TextStyle(color: Colors.white), maxLines: 1)),
                  IconButton(
                    icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white),
                    onPressed: () {
                      if (isPlaying) { player.pause(); } else { player.resume(); }
                      setState(() => isPlaying = !isPlaying);
                    },
                  )
                ],
              ),
            ),
        ],
      ),
    );
  }
}
