import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:ui';

void main() => runApp(DhunlyFinal());

class DhunlyFinal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: SpotifyGlassHome(),
    );
  }
}

class SpotifyGlassHome extends StatefulWidget {
  @override
  _SpotifyGlassHomeState createState() => _SpotifyGlassHomeState();
}

class _SpotifyGlassHomeState extends State<SpotifyGlassHome> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  int currentIndex = 0;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  // --- DIRECT PUBLIC LINKS (Bina Upload Wale Gaane) ---
  final List<Map<String, String>> songs = [
    {"title": "Pasoori", "artist": "Ali Sethi", "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3", "img": "https://picsum.photos/id/1/200/200"},
    {"title": "Excuses", "artist": "AP Dhillon", "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3", "img": "https://picsum.photos/id/2/200/200"},
    {"title": "Insane", "artist": "AP Dhillon", "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3", "img": "https://picsum.photos/id/3/200/200"},
    {"title": "Desire", "artist": "Gur Sidhu", "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3", "img": "https://picsum.photos/id/4/200/200"},
    {"title": "295", "artist": "Sidhu Moose Wala", "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3", "img": "https://picsum.photos/id/5/200/200"},
    {"title": "The Last Ride", "artist": "Sidhu", "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-10.mp3", "img": "https://picsum.photos/id/10/200/200"},
    {"title": "Elevated", "artist": "Shubh", "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-12.mp3", "img": "https://picsum.photos/id/12/200/200"},
    {"title": "No Love", "artist": "Shubh", "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-15.mp3", "img": "https://picsum.photos/id/15/200/200"},
    // Aap aur bhi links yahan bina upload kiye daal sakte ho
  ];

  @override
  void initState() {
    super.initState();
    _audioPlayer.onDurationChanged.listen((d) => setState(() => duration = d));
    _audioPlayer.onPositionChanged.listen((p) => setState(() => position = p));
    _audioPlayer.onPlayerComplete.listen((event) => nextSong());
  }

  void playMusic(int index) async {
    setState(() => currentIndex = index);
    await _audioPlayer.stop();
    await _audioPlayer.play(UrlSource(songs[index]['url']!));
    setState(() => isPlaying = true);
  }

  void nextSong() => playMusic((currentIndex + 1) % songs.length);
  void prevSong() => playMusic((currentIndex - 1 + songs.length) % songs.length);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Spotify Glass Background
          Positioned(top: -100, left: -50, child: _glow(Colors.blueAccent)),
          Positioned(bottom: -100, right: -50, child: _glow(Colors.purpleAccent)),
          
          SafeArea(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
              child: Column(
                children: [
                  _appBar(),
                  _mainPlayer(),
                  _listHeader(),
                  _songList(),
                  if (isPlaying || position > Duration.zero) _floatingMiniPlayer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glow(Color c) => Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: c.withOpacity(0.4), blurRadius: 150, spreadRadius: 50)]));

  Widget _appBar() => Padding(padding: EdgeInsets.all(20), child: Row(children: [Text("DHUNLY PRO", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2))]));

  Widget _mainPlayer() => Container(
    margin: EdgeInsets.all(20),
    padding: EdgeInsets.all(20),
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white10)),
    child: Column(
      children: [
        ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.network(songs[currentIndex]['img']!, height: 150, width: 150, fit: BoxFit.cover)),
        SizedBox(height: 15),
        Text(songs[currentIndex]['title']!, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(songs[currentIndex]['artist']!, style: TextStyle(color: Colors.white54)),
        Slider(
          activeColor: Colors.blueAccent,
          value: position.inSeconds.toDouble(),
          max: duration.inSeconds.toDouble() > 0 ? duration.inSeconds.toDouble() : 1.0,
          onChanged: (v) => _audioPlayer.seek(Duration(seconds: v.toInt())),
        ),
      ],
    ),
  );

  Widget _listHeader() => Padding(padding: EdgeInsets.symmetric(horizontal: 25), child: Align(alignment: Alignment.centerLeft, child: Text("Direct Playlist", style: TextStyle(fontSize: 18, color: Colors.blueAccent, fontWeight: FontWeight.bold))));

  Widget _songList() => Expanded(
    child: ListView.builder(
      itemCount: songs.length,
      itemBuilder: (context, index) => ListTile(
        leading: ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(songs[index]['img']!, width: 50, height: 50, fit: BoxFit.cover)),
        title: Text(songs[index]['title']!),
        subtitle: Text(songs[index]['artist']!),
        onTap: () => playMusic(index),
      ),
    ),
  );

  Widget _floatingMiniPlayer() => Container(
    margin: EdgeInsets.all(10),
    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
    decoration: BoxDecoration(color: Colors.grey.shade900, borderRadius: BorderRadius.circular(15)),
    child: Row(
      children: [
        Icon(Icons.music_note, color: Colors.blueAccent),
        SizedBox(width: 15),
        Expanded(child: Text(songs[currentIndex]['title']!, style: TextStyle(fontSize: 12))),
        IconButton(icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow), onPressed: () { if(isPlaying) _audioPlayer.pause(); else _audioPlayer.resume(); setState(() => isPlaying = !isPlaying); }),
        IconButton(icon: Icon(Icons.skip_next), onPressed: nextSong),
      ],
    ),
  );
}
