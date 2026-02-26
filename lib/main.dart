import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'dart:ui';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(DhunlyApp());
}

class DhunlyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: MusicHome(),
    );
  }
}

class MusicHome extends StatefulWidget {
  @override
  _MusicHomeState createState() => _MusicHomeState();
}

class _MusicHomeState extends State<MusicHome> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  bool isLoading = false;
  int currentIndex = 0;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  final List<Map<String, String>> songs = [
    {"title": "Pasoori", "artist": "Ali Sethi", "url": "https://pagalfree.com/musics/128-Pasoori%20-%20Shae%20Gill%20128%20Kbps.mp3", "img": "https://i.ytimg.com/vi/5Eqb_-j3FDA/0.jpg"},
    {"title": "295", "artist": "Sidhu Moose Wala", "url": "https://pagalfree.com/musics/128-295%20-%20Sidhu%20Moose%20Wala%20128%20Kbps.mp3", "img": "https://i.ytimg.com/vi/n_Wce6z38ps/0.jpg"},
    {"title": "Elevated", "artist": "Shubh", "url": "https://pagalfree.com/musics/128-Elevated%20-%20Shubh%20128%20Kbps.mp3", "img": "https://i.ytimg.com/vi/mH7-K8nSIsU/0.jpg"}
  ];

  @override
  void initState() {
    super.initState();
    _audioPlayer.onDurationChanged.listen((d) => setState(() => duration = d));
    _audioPlayer.onPositionChanged.listen((p) => setState(() => position = p));
    _audioPlayer.onPlayerComplete.listen((s) => nextSong());
  }

  Future<void> playMusic(int index) async {
    setState(() { currentIndex = index; isLoading = true; });
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(songs[index]['url']!));
      setState(() { isPlaying = true; isLoading = false; });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void nextSong() => playMusic((currentIndex + 1) % songs.length);
  void prevSong() => playMusic((currentIndex - 1 + songs.length) % songs.length);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _bgGlow(),
          SafeArea(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: Column(
                children: [
                  _header(),
                  _card(),
                  _list(),
                ],
              ),
            ),
          ),
          if (isLoading) _loader(),
        ],
      ),
    );
  }

  Widget _bgGlow() => Positioned(top: -50, right: -50, child: Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blueAccent.withOpacity(0.2), boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.3), blurRadius: 150)])));
  Widget _header() => Padding(padding: EdgeInsets.all(25), child: Text("DHUNLY V2", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueAccent)));
  Widget _card() => Container(
    margin: EdgeInsets.all(20), padding: EdgeInsets.all(20),
    decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(25)),
    child: Column(children: [
      ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.network(songs[currentIndex]['img']!, height: 140, fit: BoxFit.cover)),
      Slider(value: position.inSeconds.toDouble(), max: duration.inSeconds.toDouble() > 0 ? duration.inSeconds.toDouble() : 1.0, onChanged: (v) => _audioPlayer.seek(Duration(seconds: v.toInt()))),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        IconButton(icon: Icon(Icons.skip_previous), onPressed: prevSong),
        IconButton(icon: Icon(isPlaying ? Icons.pause_circle : Icons.play_circle, size: 60, color: Colors.blueAccent), onPressed: () {
          if (isPlaying) _audioPlayer.pause(); else _audioPlayer.resume();
          setState(() => isPlaying = !isPlaying);
        }),
        IconButton(icon: Icon(Icons.skip_next), onPressed: nextSong),
      ])
    ]),
  );
  Widget _list() => Expanded(child: ListView.builder(itemCount: songs.length, itemBuilder: (context, index) => ListTile(leading: Image.network(songs[index]['img']!, width: 40), title: Text(songs[index]['title']!), onTap: () => playMusic(index))));
  Widget _loader() => Container(color: Colors.black87, child: Center(child: LoadingAnimationWidget.staggeredDotsWave(color: Colors.blueAccent, size: 60)));
}
