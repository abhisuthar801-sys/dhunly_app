import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'dart:ui';

void main() => runApp(DhunlyProFinal());

class DhunlyProFinal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: SpotifyHome(),
    );
  }
}

class SpotifyHome extends StatefulWidget {
  @override
  _SpotifyHomeState createState() => _SpotifyHomeState();
}

class _SpotifyHomeState extends State<SpotifyHome> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  bool isLoading = false;
  int currentIndex = 0;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  // --- ASLI TRENDING SONGS (Direct High Speed Links) ---
  final List<Map<String, String>> allSongs = [
    {"title": "Pasoori", "artist": "Ali Sethi", "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3", "img": "https://i.ytimg.com/vi/5Eqb_-j3FDA/0.jpg"},
    {"title": "295", "artist": "Sidhu Moose Wala", "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3", "img": "https://i.ytimg.com/vi/n_Wce6z38ps/0.jpg"},
    {"title": "Elevated", "artist": "Shubh", "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3", "img": "https://i.ytimg.com/vi/mH7-K8nSIsU/0.jpg"},
    {"title": "Softly", "artist": "Karan Aujla", "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3", "img": "https://i.ytimg.com/vi/cWMXkGuV_Sg/0.jpg"},
  ];

  List<Map<String, String>> displayedSongs = [];

  @override
  void initState() {
    super.initState();
    displayedSongs = allSongs;
    _audioPlayer.onDurationChanged.listen((d) => setState(() => duration = d));
    _audioPlayer.onPositionChanged.listen((p) => setState(() => position = p));
    _audioPlayer.onPlayerComplete.listen((s) => nextSong());
  }

  void filterSongs(String query) {
    setState(() {
      displayedSongs = allSongs.where((s) => s['title']!.toLowerCase().contains(query.toLowerCase())).toList();
    });
  }

  Future<void> playMusic(int index) async {
    setState(() { currentIndex = index; isLoading = true; });
    await _audioPlayer.stop();
    await _audioPlayer.play(UrlSource(allSongs[index]['url']!));
    setState(() { isPlaying = true; isLoading = false; });
  }

  void nextSong() => playMusic((currentIndex + 1) % allSongs.length);
  void prevSong() => playMusic((currentIndex - 1 + allSongs.length) % allSongs.length);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Aesthetic
          _glow(Alignment.topLeft, Colors.blueAccent),
          _glow(Alignment.bottomRight, Colors.purpleAccent),
          
          SafeArea(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: Column(
                children: [
                  _searchBar(),
                  _heroCard(),
                  _listTitle(),
                  _songList(),
                ],
              ),
            ),
          ),
          if (isLoading) _loader(),
        ],
      ),
    );
  }

  Widget _glow(Alignment align, Color c) => Align(alignment: align, child: Container(width: 250, height: 250, decoration: BoxDecoration(shape: BoxShape.circle, color: c.withOpacity(0.2), boxShadow: [BoxShadow(color: c.withOpacity(0.2), blurRadius: 150, spreadRadius: 50)])));

  Widget _searchBar() => Padding(
    padding: EdgeInsets.all(20),
    child: TextField(
      onChanged: filterSongs,
      decoration: InputDecoration(
        hintText: "Search Songs...",
        prefixIcon: Icon(Icons.search, color: Colors.blueAccent),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    ),
  );

  Widget _heroCard() => Container(
    margin: EdgeInsets.symmetric(horizontal: 20),
    padding: EdgeInsets.all(20),
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.white10)),
    child: Column(
      children: [
        ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.network(allSongs[currentIndex]['img']!, height: 130, width: double.infinity, fit: BoxFit.cover)),
        SizedBox(height: 10),
        Text(allSongs[currentIndex]['title']!, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Slider(
          activeColor: Colors.blueAccent,
          value: position.inSeconds.toDouble(),
          max: duration.inSeconds.toDouble() > 0 ? duration.inSeconds.toDouble() : 1.0,
          onChanged: (v) => _audioPlayer.seek(Duration(seconds: v.toInt())),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          IconButton(icon: Icon(Icons.skip_previous), onPressed: prevSong),
          IconButton(icon: Icon(isPlaying ? Icons.pause_circle : Icons.play_circle, size: 55, color: Colors.blueAccent), onPressed: () {
            if (isPlaying) _audioPlayer.pause(); else _audioPlayer.resume();
            setState(() => isPlaying = !isPlaying);
          }),
          IconButton(icon: Icon(Icons.skip_next), onPressed: nextSong),
        ]),
      ],
    ),
  );

  Widget _listTitle() => Padding(padding: EdgeInsets.only(left: 25, top: 20), child: Align(alignment: Alignment.centerLeft, child: Text("Trending Songs", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))));

  Widget _songList() => Expanded(
    child: ListView.builder(
      itemCount: displayedSongs.length,
      itemBuilder: (context, index) => ListTile(
        leading: ClipRRect(borderRadius: BorderRadius.circular(5), child: Image.network(displayedSongs[index]['img']!, width: 45)),
        title: Text(displayedSongs[index]['title']!),
        subtitle: Text(displayedSongs[index]['artist']!),
        onTap: () => playMusic(allSongs.indexOf(displayedSongs[index])),
      ),
    ),
  );

  Widget _loader() => Container(color: Colors.black54, child: Center(child: LoadingAnimationWidget.staggeredDotsWave(color: Colors.blueAccent, size: 50)));
}
