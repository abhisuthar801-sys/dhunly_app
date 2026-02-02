import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: DhunlyProSpotify(),
    ));

class DhunlyProSpotify extends StatefulWidget {
  @override
  _DhunlyProSpotifyState createState() => _DhunlyProSpotifyState();
}

class _DhunlyProSpotifyState extends State<DhunlyProSpotify> {
  final AudioPlayer _player = AudioPlayer();
  List songs = [];
  List filteredSongs = [];
  bool isLoading = true;
  var currentSong;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    loadMusic();
  }

  // YAHAN APNA PASTEBIN RAW LINK DALNA HAI
  loadMusic() async {
    String apiUrl = "https://pastebin.com/raw/S67v8v0Q"; // Agar aapka link ban gaya hai toh yahan badal dein
    try {
      final res = await http.get(Uri.parse(apiUrl));
      if (res.statusCode == 200) {
        setState(() {
          songs = json.decode(res.body)['songs'];
          filteredSongs = songs;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading music: $e");
      setState(() => isLoading = false);
    }
  }

  void playMusic(song) {
    _player.play(UrlSource(song['url']));
    setState(() {
      currentSong = song;
      isPlaying = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Spotify Style Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.green.withOpacity(0.2), Colors.black],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text("Dhunly Pro", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                ),
                // Search Bar
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        filteredSongs = songs.where((s) => s['title'].toLowerCase().contains(value.toLowerCase())).toList();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Search songs, artists...",
                      prefixIcon: Icon(Icons.search, color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white12,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                // Music List
                isLoading 
                  ? Expanded(child: Center(child: CircularProgressIndicator(color: Colors.green)))
                  : Expanded(
                      child: ListView.builder(
                        itemCount: filteredSongs.length,
                        itemBuilder: (context, index) {
                          final song = filteredSongs[index];
                          return ListTile(
                            onTap: () => playMusic(song),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(song['img'], width: 50, height: 50, fit: BoxFit.cover, 
                                errorBuilder: (c, e, s) => Icon(Icons.music_note, size: 50)),
                            ),
                            title: Text(song['title'], style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(song['artist'], style: TextStyle(color: Colors.grey)),
                            trailing: Icon(Icons.play_circle_fill, color: Colors.green, size: 30),
                          );
                        },
                      ),
                    ),
                // Spotify Style Floating Player
                if (currentSong != null)
                  GestureDetector(
                    onTap: () {
                      // Yahan aap full screen player ka logic bhi daal sakte ho baad mein
                    },
                    child: Container(
                      margin: EdgeInsets.all(8),
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(currentSong['img'], width: 45, height: 45, fit: BoxFit.cover),
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(currentSong['title'], style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                                Text(currentSong['artist'], style: TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, size: 35, color: Colors.white),
                            onPressed: () {
                              if (isPlaying) _player.pause(); else _player.resume();
                              setState(() => isPlaying = !isPlaying);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.library_music_outlined), label: 'Library'),
        ],
      ),
    );
  }
}
