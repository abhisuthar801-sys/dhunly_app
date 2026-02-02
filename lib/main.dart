import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: DhunlyProFinal(),
    ));

class DhunlyProFinal extends StatefulWidget {
  @override
  _DhunlyProFinalState createState() => _DhunlyProFinalState();
}

class _DhunlyProFinalState extends State<DhunlyProFinal> {
  final AudioPlayer _player = AudioPlayer();
  List songs = [
    {
      "title": "Kesariya Pro",
      "artist": "Arijit Singh",
      "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
      "img": "https://picsum.photos/id/1/200/200"
    },
    {
      "title": "Raataan Lambiyan",
      "artist": "Jubin Nautiyal",
      "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3",
      "img": "https://picsum.photos/id/2/200/200"
    },
    {
      "title": "Manike Style",
      "artist": "Yohani",
      "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3",
      "img": "https://picsum.photos/id/3/200/200"
    }
  ];
  
  List filteredSongs = [];
  var currentSong;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    filteredSongs = songs; // App khulte hi list dikhegi
  }

  void playMusic(song) async {
    try {
      await _player.stop();
      await _player.play(UrlSource(song['url']));
      setState(() {
        currentSong = song;
        isPlaying = true;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Spotify Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.green.withOpacity(0.3), Colors.black],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("Dhunly Pro", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                ),
                // Search Bar
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    onChanged: (v) {
                      setState(() {
                        filteredSongs = songs.where((s) => s['title'].toLowerCase().contains(v.toLowerCase())).toList();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Search songs...",
                      prefixIcon: Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white10,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                // Song List
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredSongs.length,
                    itemBuilder: (context, index) {
                      final song = filteredSongs[index];
                      return ListTile(
                        onTap: () => playMusic(song),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(song['img'], width: 50, height: 50, fit: BoxFit.cover),
                        ),
                        title: Text(song['title'], style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(song['artist'], style: TextStyle(color: Colors.grey)),
                        trailing: Icon(Icons.play_circle_outline, color: Colors.green),
                      );
                    },
                  ),
                ),
                // Bottom Player Bar
                if (currentSong != null)
                  Container(
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(15)),
                    child: Row(
                      children: [
                        ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(currentSong['img'], width: 40, height: 40)),
                        SizedBox(width: 15),
                        Expanded(child: Text(currentSong['title'], style: TextStyle(fontSize: 14))),
                        IconButton(
                          icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, size: 30),
                          onPressed: () {
                            if (isPlaying) _player.pause(); else _player.resume();
                            setState(() => isPlaying = !isPlaying);
                          },
                        ),
                      ],
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(icon: Icon(Icons.library_music), label: "Library"),
        ],
      ),
    );
  }
}
