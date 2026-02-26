import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'dart:ui';

void main() => runApp(DhunlyProApp());

class DhunlyProApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: DhunlyPlayer(),
    );
  }
}

class DhunlyPlayer extends StatefulWidget {
  @override
  _DhunlyPlayerState createState() => _DhunlyPlayerState();
}

class _DhunlyPlayerState extends State<DhunlyPlayer> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final YoutubeExplode yt = YoutubeExplode();
  
  bool isPlaying = false;
  bool isLoading = false;
  int currentIndex = 0;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  // Asli YouTube IDs jo test ki hui hain
  final List<Map<String, String>> songs = [
    {"title": "Pasoori", "artist": "Ali Sethi", "id": "5Eqb_-j3FDA", "img": "https://i.ytimg.com/vi/5Eqb_-j3FDA/0.jpg"},
    {"title": "295", "artist": "Sidhu Moose Wala", "id": "n_Wce6z38ps", "img": "https://i.ytimg.com/vi/n_Wce6z38ps/0.jpg"},
    {"title": "Elevated", "artist": "Shubh", "id": "mH7-K8nSIsU", "img": "https://i.ytimg.com/vi/mH7-K8nSIsU/0.jpg"},
    {"title": "Softly", "artist": "Karan Aujla", "id": "cWMXkGuV_Sg", "img": "https://i.ytimg.com/vi/cWMXkGuV_Sg/0.jpg"},
  ];

  @override
  void initState() {
    super.initState();
    _audioPlayer.onDurationChanged.listen((d) => setState(() => duration = d));
    _audioPlayer.onPositionChanged.listen((p) => setState(() => position = p));
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() => isPlaying = false);
      nextSong();
    });
  }

  // --- YE HAI ASLI FIX ---
  Future<void> playYoutube(int index) async {
    setState(() {
      currentIndex = index;
      isLoading = true;
    });

    try {
      // 1. YouTube se stream nikalna
      var manifest = await yt.videos.streamsClient.getManifest(songs[index]['id']!);
      var streamInfo = manifest.audioOnly.withHighestBitrate();
      
      // 2. Play karna
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(streamInfo.url.toString()));
      
      setState(() {
        isPlaying = true;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("YouTube Error! Try again.")));
    }
  }

  void nextSong() => playYoutube((currentIndex + 1) % songs.length);
  void prevSong() => playYoutube((currentIndex - 1 + songs.length) % songs.length);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _backgroundGlow(),
          SafeArea(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: Column(
                children: [
                  _searchBar(),
                  _playerCard(),
                  _songList(),
                ],
              ),
            ),
          ),
          if (isLoading) _loadingScreen(),
        ],
      ),
    );
  }

  Widget _backgroundGlow() => Positioned(top: -100, left: -50, child: Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blueAccent.withOpacity(0.3), boxShadow: [BoxShadow(blurRadius: 100, color: Colors.blueAccent.withOpacity(0.3))])));

  Widget _searchBar() => Padding(padding: EdgeInsets.all(20), child: TextField(decoration: InputDecoration(hintText: "Search Vibes...", prefixIcon: Icon(Icons.search), filled: true, fillColor: Colors.white10, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none))));

  Widget _playerCard() => Container(
    margin: EdgeInsets.all(20),
    padding: EdgeInsets.all(20),
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
    child: Column(
      children: [
        ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.network(songs[currentIndex]['img']!, height: 120, width: double.infinity, fit: BoxFit.cover)),
        Slider(value: position.inSeconds.toDouble(), max: duration.inSeconds.toDouble() > 0 ? duration.inSeconds.toDouble() : 1.0, onChanged: (v) => _audioPlayer.seek(Duration(seconds: v.toInt()))),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          IconButton(icon: Icon(Icons.skip_previous), onPressed: prevSong),
          IconButton(icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, size: 50, color: Colors.blueAccent), onPressed: () {
            if (isPlaying) _audioPlayer.pause(); else _audioPlayer.resume();
            setState(() => isPlaying = !isPlaying);
          }),
          IconButton(icon: Icon(Icons.skip_next), onPressed: nextSong),
        ]),
      ],
    ),
  );

  Widget _songList() => Expanded(child: ListView.builder(itemCount: songs.length, itemBuilder: (context, index) => ListTile(leading: Image.network(songs[index]['img']!, width: 40), title: Text(songs[index]['title']!), subtitle: Text(songs[index]['artist']!), onTap: () => playYoutube(index))));

  Widget _loadingScreen() => Container(color: Colors.black87, child: Center(child: LoadingAnimationWidget.staggeredDotsWave(color: Colors.blueAccent, size: 60)));

  @override
  void dispose() {
    yt.close();
    _audioPlayer.dispose();
    super.dispose();
  }
}
