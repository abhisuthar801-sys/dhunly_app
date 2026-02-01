import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui';

void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: ThemeData.dark(),
  home: SpotifyClone(),
));

class SpotifyClone extends StatefulWidget {
  @override
  _SpotifyCloneState createState() => _SpotifyCloneState();
}

class _SpotifyCloneState extends State<SpotifyClone> {
  final AudioPlayer _player = AudioPlayer();
  List songs = [];
  List filtered = [];
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
          filtered = songs;
          currentSong = songs[0];
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
      body: isLoading 
          ? Center(child: CircularProgressIndicator(color: Colors.green))
          : Stack(
              children: [
                _buildBody(),
                if (currentSong != null) _buildMiniPlayer(),
              ],
            ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: Text("Good Evening", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          _buildSearchBar(),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, i) => ListTile(
                leading: Image.network(filtered[i]['img'], width: 50, height: 50, fit: BoxFit.cover),
                title: Text(filtered[i]['title'], style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(filtered[i]['artist']),
                onTap: () {
                  _player.play(UrlSource(filtered[i]['url']));
                  setState(() { currentSong = filtered[i]; isPlaying = true; });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: TextField(
        onChanged: (v) {
          setState(() => filtered = songs.where((s) => s['title'].toLowerCase().contains(v.toLowerCase())).toList());
        },
        decoration: InputDecoration(
          hintText: "Search songs, artists...",
          prefixIcon: Icon(Icons.search),
          fillColor: Colors.white10,
          filled: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildMiniPlayer() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 65,
        color: Colors.grey[900],
        child: ListTile(
          leading: Image.network(currentSong['img']),
          title: Text(currentSong['title']),
          trailing: IconButton(
            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
            onPressed: () {
              isPlaying ? _player.pause() : _player.resume();
              setState(() => isPlaying = !isPlaying);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      backgroundColor: Colors.black,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
        BottomNavigationBarItem(icon: Icon(Icons.library_music), label: "Library"),
      ],
    );
  }
}
