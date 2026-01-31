import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';

void main() => runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: DhunlyFinal()));

class DhunlyFinal extends StatefulWidget {
  const DhunlyFinal({super.key});
  @override
  State<DhunlyFinal> createState() => _DhunlyFinalState();
}

class _DhunlyFinalState extends State<DhunlyFinal> {
  final AudioPlayer player = AudioPlayer();
  List songs = [];
  bool isLoading = false;
  bool isPlaying = false;
  
  String currentSong = "Select a Song";
  String currentArtist = "Dhunly Vibe";
  String currentImg = "https://cdn-icons-png.flaticon.com/512/3844/3844724.png";

  // Song Play Karne Ka Function
  Future<void> playMusic(var songData) async {
    try {
      // 320kbps ya fast link uthana
      String streamUrl = songData['downloadUrl'].last['url']; 
      
      await player.stop();
      await player.play(UrlSource(streamUrl));
      
      setState(() {
        currentSong = songData['name'];
        currentArtist = songData['artists']['primary'][0]['name'];
        currentImg = songData['image'].last['url'];
        isPlaying = true;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> searchSongs(String query) async {
    setState(() => isLoading = true);
    try {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Glass Background Effects
          Positioned(top: -50, left: -50, child: _blurOrb(Colors.blueAccent)),
          Positioned(bottom: -50, right: -50, child: _blurOrb(Colors.purpleAccent)),
          
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
            child: Container(color: Colors.transparent),
          ),

          SafeArea(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text("DHUNLY", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 8)),
                ),
                _searchBar(),
                if (isLoading) const LinearProgressIndicator(color: Colors.blueAccent),
                _songList(),
                _miniPlayer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _blurOrb(Color color) => Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.4)));

  Widget _searchBar() => Padding(
    padding: const EdgeInsets.all(20),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(20)),
          child: TextField(
            onSubmitted: (v) => searchSongs(v),
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "Search Sidhi Moose Wala, Arijit...",
              hintStyle: TextStyle(color: Colors.white38),
              prefixIcon: Icon(Icons.search, color: Colors.blueAccent),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(15),
            ),
          ),
        ),
      ),
    ),
  );

  Widget _songList() => Expanded(
    child: ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: songs.length,
      itemBuilder: (context, index) {
        var s = songs[index];
        return Card(
          color: Colors.white.withOpacity(0.05),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(s['image'].last['url'])),
            title: Text(s['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), maxLines: 1),
            subtitle: Text(s['artists']['primary'][0]['name'], style: const TextStyle(color: Colors.white54)),
            trailing: const Icon(Icons.play_arrow_rounded, color: Colors.blueAccent),
            onTap: () => playMusic(s),
          ),
        );
      },
    ),
  );

  Widget _miniPlayer() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.05),
      border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
    ),
    child: Row(
      children: [
        CircleAvatar(backgroundImage: NetworkImage(currentImg), radius: 25),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(currentSong, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), maxLines: 1),
              Text(currentArtist, style: const TextStyle(color: Colors.white54, fontSize: 11)),
            ],
          ),
        ),
        IconButton(
          icon: Icon(isPlaying ? Icons.pause_circle : Icons.play_circle, color: Colors.white, size: 40),
          onPressed: () {
            if (isPlaying) {
              player.pause();
            } else {
              player.resume();
            }
            setState(() => isPlaying = !isPlaying);
          },
        ),
      ],
    ),
  );
}
