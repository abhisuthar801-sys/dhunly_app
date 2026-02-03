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
  final AudioPlayer _player = AudioPlayer();
  bool isPlaying = false;
  bool isLoading = false;
  var currentSong;
  List searchResults = [];

  // SAAVN API SE GAANA DHUNDNA (Screenshots wala experience)
  void searchMusic(String query) async {
    if (query.isEmpty) return;
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse("https://saavn.dev/api/search/songs?query=$query"));
      final data = json.decode(response.body);

      setState(() {
        searchResults = data['data']['results'];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print("Search Error: $e");
    }
  }

  void playMusic(var song) async {
    try {
      String streamUrl = song['downloadUrl'].last['link']; 
      await _player.play(UrlSource(streamUrl));
      setState(() {
        currentSong = song;
        isPlaying = true;
      });
    } catch (e) {
      print("Play Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            if (isLoading) LinearProgressIndicator(color: Colors.greenAccent),
            Expanded(child: _buildMainContent()),
            if (currentSong != null) _buildBottomPlayer(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("DHUNLY PRO", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.greenAccent, letterSpacing: 2)),
          CircleAvatar(backgroundColor: Colors.white10, child: Icon(Icons.person, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextField(
        onSubmitted: (v) => searchMusic(v),
        decoration: InputDecoration(
          hintText: "Search Guru Randhawa, Kaka...",
          prefixIcon: Icon(Icons.search, color: Colors.greenAccent),
          filled: true,
          fillColor: Colors.white10,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    if (searchResults.isEmpty) {
      return Center(child: Text("Search karke gaane bajao bhai!", style: TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      itemCount: searchResults.length,
      padding: EdgeInsets.all(15),
      itemBuilder: (context, index) {
        var song = searchResults[index];
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(song['image'].last['link'], width: 50, height: 50, fit: BoxFit.cover),
          ),
          title: Text(song['name'], maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(song['artists']['primary'][0]['name'], style: TextStyle(color: Colors.grey)),
          trailing: Icon(Icons.play_circle_outline, color: Colors.greenAccent),
          onTap: () => playMusic(song),
        );
      },
    );
  }

  Widget _buildBottomPlayer() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFF1A1A1A),
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(currentSong['image'].last['link'], width: 45, height: 45),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(currentSong['name'], style: TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(currentSong['artists']['primary'][0]['name'], style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          IconButton(
            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.greenAccent, size: 30),
            onPressed: () {
              if (isPlaying) { _player.pause(); setState(() => isPlaying = false); }
              else { _player.resume(); setState(() => isPlaying = true); }
            },
          ),
        ],
      ),
    );
  }
}
