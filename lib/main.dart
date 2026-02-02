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
        title: Image.asset('assets/logo.png', height: 40, errorBuilder: (c,e,s) => Text("DHUNLY PRO")),
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
                fillColor: Colors.white10,
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
            ? Expanded(child: Center(child: CircularProgressIndicator(color: Colors.blue)))
            : Expanded(
                child: ListView.builder(
                  itemCount: filteredSongs.length,
                  itemBuilder: (ctx, i) => ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.network(filteredSongs[i]['img'], width: 50, height: 50, fit: BoxFit.cover),
                    ),
                    title: Text(filteredSongs[i]['title'], style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(filteredSongs[i]['artist'], style: TextStyle(color: Colors.grey)),
                    trailing: Icon(Icons.play_circle_fill, color: Colors.blue, size: 30),
                    onTap: () => playMusic(filteredSongs[i]),
                  ),
                ),
              ),
          if (currentSong != null)
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blueGrey[900],
                borderRadius: BorderRadius.vertical(top: Radius.circular(20))
              ),
              child: Row(
                children: [
                  ClipRRect(borderRadius: BorderRadius.circular(5), child: Image.network(currentSong['img'], width: 50, height: 50)),
                  SizedBox(width: 15),
                  Expanded(child: Text(currentSong['title'], style: TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                  IconButton(
                    icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, size: 40, color: Colors.blue),
                    onPressed: () {
                      if (isPlaying) _player.pause(); else _player.resume();
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
