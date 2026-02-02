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
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.asset('assets/logo.png', height: 40), // AAPKA LOGO
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search Songs...",
                prefixIcon: Icon(Icons.search, color: Colors.blue),
                filled: true,
                fillColor: Colors.white12,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onChanged: (v) {
                setState(() {
                  filteredSongs = songs.where((s) => s['title'].toLowerCase().contains(v.toLowerCase())).toList();
                });
              },
            ),
          ),
          isLoading 
            ? Expanded(child: Center(child: CircularProgressIndicator()))
            : Expanded(
                child: ListView.builder(
                  itemCount: filteredSongs.length,
                  itemBuilder: (ctx, i) => ListTile(
                    leading: CircleAvatar(backgroundImage: NetworkImage(filteredSongs[i]['img'])),
                    title: Text(filteredSongs[i]['title']),
                    subtitle: Text(filteredSongs[i]['artist']),
                    trailing: Icon(Icons.play_arrow, color: Colors.blue),
                    onTap: () => playMusic(filteredSongs[i]),
                  ),
                ),
              ),
          if (currentSong != null)
            Container(
              color: Colors.blueGrey[900],
              child: ListTile(
                leading: Image.network(currentSong['img']),
                title: Text(currentSong['title']),
                trailing: IconButton(
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: () {
                    if (isPlaying) _player.pause(); else _player.resume();
                    setState(() => isPlaying = !isPlaying);
                  },
                ),
              ),
            )
        ],
      ),
    );
  }
}
