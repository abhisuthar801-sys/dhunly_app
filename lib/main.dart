import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt_exp;
import 'package:audioplayers/audioplayers.dart';
import 'dart:ui';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark(),
    home: DhunlyProApp(),
  ));
}

class DhunlyProApp extends StatefulWidget {
  @override
  _DhunlyProAppState createState() => _DhunlyProAppState();
}

class _DhunlyProAppState extends State<DhunlyProApp> {
  final yt_exp.YoutubeExplode yt = yt_exp.YoutubeExplode();
  final AudioPlayer _player = AudioPlayer();
  
  bool isPlaying = false;
  bool isLoading = false;
  var currentSong;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();
    // Listening to player updates
    _player.onDurationChanged.listen((d) => setState(() => duration = d));
    _player.onPositionChanged.listen((p) => setState(() => position = p));
    _player.onPlayerStateChanged.listen((s) => setState(() => isPlaying = s == PlayerState.playing));
  }

  void searchAndPlay(String query) async {
    if (query.isEmpty) return;
    setState(() => isLoading = true);
    
    try {
      var searchList = await yt.search.search(query);
      if (searchList.isNotEmpty) {
        var video = searchList.first;
        var manifest = await yt.videos.streamsClient.getManifest(video.id);
        var audioStream = manifest.audioOnly.withHighestBitrate();

        await _player.play(UrlSource(audioStream.url.toString()));
        
        setState(() {
          currentSong = {
            "title": video.title,
            "artist": video.author,
            "img": video.thumbnails.highResUrl,
          };
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: Song nahi mila!")));
    }
  }

  @override
  void dispose() {
    yt.close();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Glows
          _buildGlow(Colors.greenAccent.withOpacity(0.15), -50, -50),
          _buildGlow(Colors.blueAccent.withOpacity(0.1), 400, 150),
          
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildSearchBar(),
                if (isLoading) Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: LinearProgressIndicator(color: Colors.greenAccent, backgroundColor: Colors.white10),
                ),
                Expanded(child: _buildMainBody()),
                if (currentSong != null) _buildMiniPlayer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlow(Color color, double top, double left) {
    return Positioned(top: top, left: left, child: Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: color, blurRadius: 100, spreadRadius: 50)])));
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Dhunly Pro", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          Icon(Icons.waves, color: Colors.greenAccent),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(15)),
        child: TextField(
          onSubmitted: (v) => searchAndPlay(v),
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Artist ya Song ka naam likho...",
            hintStyle: TextStyle(color: Colors.grey),
            prefixIcon: Icon(Icons.search, color: Colors.greenAccent),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildMainBody() {
    if (currentSong == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.music_note, size: 80, color: Colors.white10),
            Text("Kaka ya Sidhu Moose Wala search karo!", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 40),
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Image.network(currentSong['img'], height: 280, width: 280, fit: BoxFit.cover),
          ),
          SizedBox(height: 30),
          Text(currentSong['title'], style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          Text(currentSong['artist'], style: TextStyle(color: Colors.grey, fontSize: 16)),
          
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              children: [
                Slider(
                  activeColor: Colors.greenAccent,
                  inactiveColor: Colors.white10,
                  value: position.inSeconds.toDouble(),
                  max: duration.inSeconds.toDouble() > 0 ? duration.inSeconds.toDouble() : 1.0,
                  onChanged: (v) => _player.seek(Duration(seconds: v.toInt())),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatDuration(position)),
                    Text(_formatDuration(duration)),
                  ],
                )
              ],
            ),
          ),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(icon: Icon(Icons.skip_previous, size: 40), onPressed: () {}),
              SizedBox(width: 20),
              IconButton(
                icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, size: 80, color: Colors.greenAccent),
                onPressed: () => isPlaying ? _player.pause() : _player.resume(),
              ),
              SizedBox(width: 20),
              IconButton(icon: Icon(Icons.skip_next, size: 40), onPressed: () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniPlayer() {
    return Positioned(
      bottom: 15, left: 15, right: 15,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            height: 75, color: Colors.white.withOpacity(0.1),
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(currentSong['img'], width: 55, height: 55, fit: BoxFit.cover)),
                SizedBox(width: 15),
                Expanded(child: Text(currentSong['title'], maxLines: 1, overflow: TextOverflow.ellipsis)),
                IconButton(
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.greenAccent),
                  onPressed: () => isPlaying ? _player.pause() : _player.resume(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    String minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    String seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }
}
