import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

void main() => runApp(DhunlyFastApp());

class DhunlyFastApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, theme: ThemeData.dark(), home: FastPlayer());
  }
}

class FastPlayer extends StatefulWidget {
  @override
  _FastPlayerState createState() => _FastPlayerState();
}

class _FastPlayerState extends State<FastPlayer> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  bool isLoading = false;
  int currentIndex = 0;
  
  // --- HIGH-SPEED DIRECT MP3 LINKS (India Optimized) ---
  final List<Map<String, String>> fastSongs = [
    {
      "title": "Pasoori",
      "artist": "Ali Sethi",
      "url": "https://pagalfree.com/musics/128-Pasoori%20-%20Shae%20Gill%20128%20Kbps.mp3",
      "img": "https://i.ytimg.com/vi/5Eqb_-j3FDA/0.jpg"
    },
    {
      "title": "295",
      "artist": "Sidhu Moose Wala",
      "url": "https://pagalfree.com/musics/128-295%20-%20Sidhu%20Moose%20Wala%20128%20Kbps.mp3",
      "img": "https://i.ytimg.com/vi/n_Wce6z38ps/0.jpg"
    },
    {
      "title": "Elevated",
      "artist": "Shubh",
      "url": "https://pagalfree.com/musics/128-Elevated%20-%20Shubh%20128%20Kbps.mp3",
      "img": "https://i.ytimg.com/vi/mH7-K8nSIsU/0.jpg"
    }
  ];

  @override
  void initState() {
    super.initState();
    // Buffer settings for fast start
    _audioPlayer.setReleaseMode(ReleaseMode.stop);
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.playing) setState(() => isLoading = false);
    });
  }

  Future<void> playFast(int index) async {
    setState(() { currentIndex = index; isLoading = true; isPlaying = false; });
    try {
      await _audioPlayer.stop();
      // Fast source setting
      await _audioPlayer.setSource(UrlSource(fastSongs[index]['url']!));
      await _audioPlayer.resume();
      setState(() => isPlaying = true);
    } catch (e) {
      setState(() => isLoading = false);
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F0F0F),
      appBar: AppBar(title: Text("DHUNLY FAST"), centerTitle: true, backgroundColor: Colors.transparent),
      body: Column(
        children: [
          _nowPlayingCard(),
          Expanded(child: _songListView()),
        ],
      ),
    );
  }

  Widget _nowPlayingCard() {
    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.network(fastSongs[currentIndex]['img']!, height: 150, width: double.infinity, fit: BoxFit.cover)),
          SizedBox(height: 15),
          if (isLoading) LoadingAnimationWidget.staggeredDotsWave(color: Colors.blueAccent, size: 40)
          else IconButton(
            icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, size: 70, color: Colors.blueAccent),
            onPressed: () {
              if (isPlaying) _audioPlayer.pause(); else _audioPlayer.resume();
              setState(() => isPlaying = !isPlaying);
            },
          ),
        ],
      ),
    );
  }

  Widget _songListView() {
    return ListView.builder(
      itemCount: fastSongs.length,
      itemBuilder: (context, index) => ListTile(
        leading: CircleAvatar(backgroundImage: NetworkImage(fastSongs[index]['img']!)),
        title: Text(fastSongs[index]['title']!),
        subtitle: Text(fastSongs[index]['artist']!),
        onTap: () => playFast(index),
      ),
    );
  }
}
