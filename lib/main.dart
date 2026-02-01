import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: DhunlyApp(),
    ));

class DhunlyApp extends StatefulWidget {
  @override
  _DhunlyAppState createState() => _DhunlyAppState();
}

class _DhunlyAppState extends State<DhunlyApp> {
  final AudioPlayer _player = AudioPlayer();
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

  Future<void> fetchMusic() async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.asset('assets/logo.png', height: 40), // AAPKA NAYA LOGO
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search Songs...",
                prefixIcon: Icon(Icons.search, color: Colors.blueAccent),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (v) {
                setState(() => filteredSongs = songs.where((s) => s['title'].toLowerCase().contains(v.toLowerCase())).toList());
              },
            ),
          ),
          isLoading 
            ? Expanded(child: Center(child: CircularProgressIndicator())) 
            : Expanded(
                child: ListView.builder(
                  itemCount: filteredSongs.length,
                  itemBuilder: (context, i) => ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.network(filteredSongs[i]['img'], width: 50, height: 50, fit: BoxFit.cover),
                    ),
                    title: Text(filteredSongs[i]['title'], style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(filteredSongs[i]['artist']),
                    onTap: () {
                      _player.play(UrlSource(filteredSongs[i]['url']));
                      setState(() { currentSong = filteredSongs[i]; isPlaying = true; });
                    },
                  ),
                ),
              ),
          if (currentSong != null) _miniPlayer(),
        ],
      ),
    );
  }

  Widget _miniPlayer() {
    return Container(
      color: Colors.blueAccent.withOpacity(0.8),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        children: [
          Image.network(currentSong['img'], width: 40, height: 40),
          SizedBox(width: 10),
          Expanded(child: Text(currentSong['title'], overflow: TextOverflow.ellipsis)),
          IconButton(
            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
            onPressed: () {
              isPlaying ? _player.pause() : _player.resume();
              setState(() => isPlaying = !isPlaying);
            },
          )
        ],
      ),
    );
  }
}
