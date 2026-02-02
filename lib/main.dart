import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:ui';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: SpotifyGlassPro(),
    ));

class SpotifyGlassPro extends StatefulWidget {
  @override
  _SpotifyGlassProState createState() => _SpotifyGlassProState();
}

class _SpotifyGlassProState extends State<SpotifyGlassPro> {
  final AudioPlayer _player = AudioPlayer();
  bool isPlaying = false;
  bool isLiked = false;
  bool isShuffle = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  var currentSong;

  List songs = [
    {
      "title": "Door Des Koi Kudi",
      "artist": "Kaka",
      "url": "https://res.cloudinary.com/ds1bcvkop/video/upload/v1770036580/Door_Des_Koi_Kudi_-_Kaka_yvouzh.mp3",
      "img": "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=500&q=80",
      "lyrics": "Door des koi kudi rehndi ae...\nGallan mithiyan kardi ae..."
    },
    // More songs here
  ];

  @override
  void initState() {
    super.initState();
    _player.onDurationChanged.listen((d) => setState(() => duration = d));
    _player.onPositionChanged.listen((p) => setState(() => position = p));
  }

  // --- UI Layouts ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Glows
          _backgroundGlow(),

          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(child: _buildMainList()),
                if (currentSong != null) _buildMiniPlayer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _backgroundGlow() {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(-0.8, -0.6),
          colors: [Colors.greenAccent.withOpacity(0.1), Colors.black],
          radius: 1.5,
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Dhunly Glass", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          IconButton(icon: Icon(Icons.settings), onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildMainList() {
    return ListView.builder(
      itemCount: songs.length,
      itemBuilder: (context, i) => ListTile(
        onTap: () => _play(songs[i]),
        leading: ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(songs[i]['img'])),
        title: Text(songs[i]['title']),
        subtitle: Text(songs[i]['artist']),
        trailing: Icon(Icons.play_circle_fill, color: Colors.greenAccent),
      ),
    );
  }

  // --- The Premium Player Screen (Spotify Style) ---

  void _showFullPlayer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _fullPlayerUI(),
    );
  }

  Widget _fullPlayerUI() {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
        ),
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            SizedBox(height: 15),
            Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(10))),
            SizedBox(height: 50),
            // Album Art
            ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.network(currentSong['img'], height: 300, width: 300, fit: BoxFit.cover)),
            SizedBox(height: 40),
            // Title & Like
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(currentSong['title'], style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Text(currentSong['artist'], style: TextStyle(fontSize: 18, color: Colors.grey)),
                ]),
                IconButton(
                  icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: isLiked ? Colors.red : Colors.white),
                  onPressed: () => setState(() => isLiked = !isLiked),
                )
              ],
            ),
            SizedBox(height: 30),
            // Seekbar
            Slider(
              activeColor: Colors.greenAccent,
              value: position.inSeconds.toDouble(),
              max: duration.inSeconds.toDouble() > 0 ? duration.inSeconds.toDouble() : 1.0,
              onChanged: (v) => _player.seek(Duration(seconds: v.toInt())),
            ),
            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Icon(Icons.shuffle, color: Colors.grey),
                Icon(Icons.skip_previous, size: 40),
                GestureDetector(
                  onTap: _togglePlay,
                  child: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, size: 80, color: Colors.greenAccent),
                ),
                Icon(Icons.skip_next, size: 40),
                Icon(Icons.repeat, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- Logic Functions ---

  void _play(song) async {
    await _player.stop();
    await _player.play(UrlSource(song['url']));
    setState(() { currentSong = song; isPlaying = true; });
    _showFullPlayer(); // Gaana bajte hi screen khulegi
  }

  void _togglePlay() {
    if(isPlaying) _player.pause(); else _player.resume();
    setState(() => isPlaying = !isPlaying);
  }

  Widget _buildMiniPlayer() {
    return GestureDetector(
      onTap: _showFullPlayer,
      child: Container(
        margin: EdgeInsets.all(10),
        height: 70,
        decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(15)),
        child: ListTile(
          leading: Image.network(currentSong['img']),
          title: Text(currentSong['title']),
          trailing: IconButton(icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow), onPressed: _togglePlay),
        ),
      ),
    );
  }
}
