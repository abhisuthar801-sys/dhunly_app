import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';

void main() => runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: DhunlyYT()));

class DhunlyYT extends StatefulWidget {
  const DhunlyYT({super.key});
  @override
  State<DhunlyYT> createState() => _DhunlyYTState();
}

class _DhunlyYTState extends State<DhunlyYT> {
  final AudioPlayer _player = AudioPlayer();
  List songs = [];
  bool isLoading = false;
  bool isPlaying = false;
  String currentSong = "Search Any Song";
  String currentImg = "https://cdn-icons-png.flaticon.com/512/3844/3844724.png";

  // --- NEW YOUTUBE HYBRID SEARCH ---
  Future<void> searchYT(String query) async {
    setState(() => isLoading = true);
    try {
      // Hum is open-source YouTube Search link ka use karenge
      final res = await http.get(Uri.parse("https://pipedapi.kavin.rocks/search?q=$query&filter=videos"));
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        setState(() {
          songs = data['items']; // YouTube results
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("Error: $e");
    }
  }

  void playYT(String videoId, String title, String img) async {
    // Hum direct stream link generate karenge
    String streamUrl = "https://pipedapi.kavin.rocks/streams/$videoId";
    try {
      final res = await http.get(Uri.parse(streamUrl));
      var data = json.decode(res.body);
      String audioUrl = data['audioStreams'][0]['url']; // High quality audio

      await _player.stop();
      await _player.play(UrlSource(audioUrl));
      setState(() {
        currentSong = title;
        currentImg = img;
        isPlaying = true;
      });
    } catch (e) {
      print("Play Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _background(),
          SafeArea(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("DHUNLY PRO", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 5)),
                ),
                _searchBar(),
                if (isLoading) const LinearProgressIndicator(color: Colors.redAccent),
                _songList(),
                _bottomPlayer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _background() => Stack(children: [
    Positioned(top: -50, left: -50, child: Container(width: 300, height: 300, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.redAccent))),
    BackdropFilter(filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100), child: Container(color: Colors.transparent)),
  ]);

  Widget _searchBar() => Padding(
    padding: const EdgeInsets.all(20),
    child: TextField(
      onSubmitted: (v) => searchYT(v),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: "Search YouTube Music...",
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: Colors.white10,
        prefixIcon: const Icon(Icons.search, color: Colors.redAccent),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    ),
  );

  Widget _songList() => Expanded(
    child: ListView.builder(
      itemCount: songs.length,
      itemBuilder: (context, i) {
        var s = songs[i];
        return ListTile(
          leading: Image.network(s['thumbnail'], width: 50, fit: BoxFit.cover),
          title: Text(s['title'], style: const TextStyle(color: Colors.white, fontSize: 14), maxLines: 1),
          subtitle: Text(s['uploaderName'] ?? "YouTube", style: const TextStyle(color: Colors.white54, fontSize: 11)),
          onTap: () {
            // Video ID se URL nikalne ke liye extract karna
            String vId = s['url'].split("=")[1];
            playYT(vId, s['title'], s['thumbnail']);
          },
        );
      },
    ),
  );

  Widget _bottomPlayer() => Container(
    padding: const EdgeInsets.all(15),
    color: Colors.white10,
    child: Row(
      children: [
        CircleAvatar(backgroundImage: NetworkImage(currentImg)),
        const SizedBox(width: 15),
        Expanded(child: Text(currentSong, style: const TextStyle(color: Colors.white), maxLines: 1)),
        IconButton(
          icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 35),
          onPressed: () {
            if (isPlaying) _player.pause(); else _player.resume();
            setState(() => isPlaying = !isPlaying);
          },
        )
      ],
    ),
  );
}
