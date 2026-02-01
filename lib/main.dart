import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: ThemeData.dark(),
  home: DhunlyFinal(),
));

class DhunlyFinal extends StatefulWidget {
  @override
  _DhunlyFinalState createState() => _DhunlyFinalState();
}

class _DhunlyFinalState extends State<DhunlyFinal> {
  final AudioPlayer _player = AudioPlayer();
  List songs = [];
  bool isLoading = true;
  var currentSong;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  // YE HAI ASLI CHEEZ: Internet se gaane khinchne wala logic
  Future<void> loadData() async {
    try {
      final res = await http.get(Uri.parse("https://api.jsonsilo.com/public/69094396-e176-474c-8302-3866d56d788e"));
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        setState(() {
          songs = data['songs'];
          currentSong = songs[0];
          isLoading = false;
        });
      }
    } catch (e) {
      // Agar internet nahi chala toh ye 1 gaana dikhayega
      setState(() {
        songs = [{"title": "Internet Connection Error", "artist": "Check Wi-Fi", "img": "https://i.imgur.com/S6Mv7X9.png", "url": ""}];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text("DHUNLY PRO", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)), backgroundColor: Colors.black, centerTitle: true),
      body: isLoading 
        ? Center(child: CircularProgressIndicator(color: Colors.green)) 
        : Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: songs.length,
                  itemBuilder: (context, i) => ListTile(
                    leading: Image.network(songs[i]['img'], width: 50, height: 50, fit: BoxFit.cover),
                    title: Text(songs[i]['title'], style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(songs[i]['artist']),
                    onTap: () async {
                      await _player.stop();
                      await _player.play(UrlSource(songs[i]['url']));
                      setState(() { currentSong = songs[i]; isPlaying = true; });
                    },
                  ),
                ),
              ),
              if (currentSong != null) _miniPlayer(),
            ],
          ),
    );
  }

  Widget _miniPlayer() => Container(
    padding: EdgeInsets.all(10),
    color: Colors.blueGrey[900],
    child: Row(
      children: [
        Image.network(currentSong['img'], width: 40, height: 40),
        SizedBox(width: 15),
        Expanded(child: Text(currentSong['title'])),
        IconButton(icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow), onPressed: () {
          isPlaying ? _player.pause() : _player.resume();
          setState(() => isPlaying = !isPlaying);
        })
      ],
    ),
  );
}
