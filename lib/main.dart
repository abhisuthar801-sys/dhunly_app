import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: DhunlyProApp(),
    ));

class DhunlyProApp extends StatefulWidget {
  @override
  _DhunlyProAppState createState() => _DhunlyProAppState();
}

class _DhunlyProAppState extends State<DhunlyProApp> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List songs = [];
  List filteredSongs = [];
  bool isLoading = true;
  var currentSong;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    fetchMusic();
  }

  fetchMusic() async {
    try {
      final res = await http.get(Uri.parse("https://api.jsonsilo.com/public/69094396-e176-474c-8302-3866d56d788e"));
      if (res.statusCode == 200) {
        setState(() {
          songs = json.decode(res.body)['songs'];
          filteredSongs = songs;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void playMusic(song) {
    _audioPlayer.play(UrlSource(song['url']));
    setState(() {
      currentSong = song;
      isPlaying = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Image.asset('assets/logo.png', height: 40), // AAPKA LOGO
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 🔎 Working Search Bar
          Padding(
            padding: EdgeInsets.all(12),
            child: TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search for songs or artists...",
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.search, color: Colors.blueAccent),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
              onChanged: (query) {
                setState(() {
                  filteredSongs = songs.where((s) => s['title'].toLowerCase().contains(query.toLowerCase()) || s['artist'].toLowerCase().contains(query.toLowerCase())).toList();
                });
              },
            ),
          ),
          // 🎶 Song List
          isLoading 
            ? Expanded(child: Center(child: CircularProgressIndicator(color: Colors.blueAccent)))
            : Expanded(
                child: ListView.builder(
                  itemCount: filteredSongs.length,
                  itemBuilder: (context, i) => ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(filteredSongs[i]['img'], width: 50, height: 50, fit: BoxFit.cover),
                    ),
                    title: Text(filteredSongs[i]['title'], style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(filteredSongs[i]['artist'], style: TextStyle(color: Colors.grey)),
                    trailing: Icon(Icons.play_circle_fill, color: Colors.blueAccent),
                    onTap: () => playMusic(filteredSongs[i]),
                  ),
                ),
              ),
          // 📱 Mini Player (Working Bottom Bar)
          if (currentSong != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.9), borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
              child: Row(
                children: [
                  ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(currentSong['img'], width: 45, height: 45)),
                  SizedBox(width: 15),
                  Expanded(child: Text(currentSong['title'], style: TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                  IconButton(
                    icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, size: 40, color: Colors.white),
                    onPressed: () {
                      if (isPlaying) { _audioPlayer.pause(); } else { _audioPlayer.resume(); }
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
