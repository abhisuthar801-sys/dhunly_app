import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: DhunlyProUltimate(),
    ));

class DhunlyProUltimate extends StatefulWidget {
  @override
  _DhunlyProUltimateState createState() => _DhunlyProUltimateState();
}

class _DhunlyProUltimateState extends State<DhunlyProUltimate> {
  int _currentIndex = 0;
  final AudioPlayer _player = AudioPlayer();
  List allSongs = []; // Pastebin se aane wale saare gaane
  List filteredSongs = []; // Search ke baad dikhne wale gaane
  bool isLoading = true;
  var currentSong;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    fetchSongs();
  }

  // Pastebin se data khichne wala function
  fetchSongs() async {
    // YAHAN APNA PASTEBIN RAW LINK DALO
    String url = "https://pastebin.com/raw/S67v8v0Q"; 
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          allSongs = data['songs'];
          filteredSongs = allSongs;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() => isLoading = false);
    }
  }

  void playMusic(song) async {
    await _player.stop();
    await _player.play(UrlSource(song['url']));
    setState(() {
      currentSong = song;
      isPlaying = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Teeno screens ka logic
    List<Widget> screens = [
      buildHomeScreen(), // Index 0
      buildSearchScreen(), // Index 1
      Center(child: Text("Library: Your Favorites Here", style: TextStyle(fontSize: 20))), // Index 2
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          screens[_currentIndex], // Current selected screen dikhayega
          if (currentSong != null) buildMiniPlayer(), // Niche wala player
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.black,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(icon: Icon(Icons.library_music), label: "Library"),
        ],
      ),
    );
  }

  // --- Screens Ke Widgets ---

  Widget buildHomeScreen() {
    return Column(
      children: [
        SizedBox(height: 50),
        Text("Dhunly Pro", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        Expanded(
          child: isLoading 
            ? Center(child: CircularProgressIndicator(color: Colors.green))
            : ListView.builder(
                itemCount: allSongs.length,
                itemBuilder: (context, i) => songTile(allSongs[i]),
              ),
        ),
      ],
    );
  }

  Widget buildSearchScreen() {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  filteredSongs = allSongs.where((s) => 
                    s['title'].toLowerCase().contains(value.toLowerCase())).toList();
                });
              },
              decoration: InputDecoration(
                hintText: "Search Songs or Artists",
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredSongs.length,
              itemBuilder: (context, i) => songTile(filteredSongs[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget songTile(song) {
    return ListTile(
      onTap: () => playMusic(song),
      leading: Image.network(song['img'], width: 50, height: 50, fit: BoxFit.cover),
      title: Text(song['title']),
      subtitle: Text(song['artist']),
      trailing: Icon(Icons.play_arrow, color: Colors.green),
    );
  }

  Widget buildMiniPlayer() {
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: Container(
        color: Colors.grey[900],
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        child: Row(
          children: [
            Image.network(currentSong['img'], width: 40, height: 40),
            SizedBox(width: 10),
            Expanded(child: Text(currentSong['title'])),
            IconButton(
              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
              onPressed: () {
                if (isPlaying) _player.pause(); else _player.resume();
                setState(() => isPlaying = !isPlaying);
              },
            )
          ],
        ),
      ),
    );
  }
}
