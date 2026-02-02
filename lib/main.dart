import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:ui';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: DhunlyUltimate(),
    ));

class DhunlyUltimate extends StatefulWidget {
  @override
  _DhunlyUltimateState createState() => _DhunlyUltimateState();
}

class _DhunlyUltimateState extends State<DhunlyUltimate> {
  final YoutubeExplode yt = YoutubeExplode();
  final AudioPlayer _player = AudioPlayer();
  
  bool isPlaying = false;
  bool isLoading = false;
  var currentSong;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  // Search results ke liye list
  List searchResults = [];

  @override
  void initState() {
    super.initState();
    _player.onDurationChanged.listen((d) => setState(() => duration = d));
    _player.onPositionChanged.listen((p) => setState(() => position = p));
  }

  // --- MAGIC FUNCTION: YouTube se Audio nikalna ---
  void searchAndPlay(String query) async {
    setState(() => isLoading = true);
    try {
      // 1. YouTube par Search karna
      var searchList = await yt.search.search(query);
      if (searchList.isNotEmpty) {
        var video = searchList.first;
        
        // 2. Audio Stream ka link nikalna
        var manifest = await yt.videos.streamsClient.getManifest(video.id);
        var audioStream = manifest.audioOnly.withHighestBitrate();

        // 3. Play karna
        await _player.play(UrlSource(audioStream.url.toString()));
        
        setState(() {
          currentSong = {
            "title": video.title,
            "artist": video.author,
            "img": video.thumbnails.highResUrl,
          };
          isPlaying = true;
          isLoading = false;
        });
        _showFullPlayer(); // Gaana milte hi player khulega
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("Error: $e");
    }
  }

  void _togglePlay() {
    if (isPlaying) _player.pause(); else _player.resume();
    setState(() => isPlaying = !isPlaying);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Aesthetic Glow
          _buildGlow(Colors.deepPurple.withOpacity(0.2), -100, -50),
          _buildGlow(Colors.greenAccent.withOpacity(0.1), 300, 200),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildSearchBar(),
                if (isLoading) LinearProgressIndicator(color: Colors.greenAccent),
                Expanded(child: _buildHomeContent()),
              ],
            ),
          ),
          
          if (currentSong != null) _buildMiniPlayer(),
        ],
      ),
    );
  }

  // --- Glass UI Components ---

  Widget _buildGlow(Color color, double top, double left) {
    return Positioned(top: top, left: left, child: Container(width: 400, height: 400, decoration: BoxDecoration(shape: BoxShape.circle, color: color, boxShadow: [BoxShadow(color: color, blurRadius: 100, spreadRadius: 50)])));
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Dhunly Pro", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          CircleAvatar(backgroundColor: Colors.white10, child: Icon(Icons.person, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: TextField(
            onSubmitted: (value) => searchAndPlay(value),
            decoration: InputDecoration(
              hintText: "Search any song from YouTube...",
              prefixIcon: Icon(Icons.search, color: Colors.greenAccent),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: Border.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    return Center(
      child: Opacity(
        opacity: 0.5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.music_note, size: 80),
            Text("Type a song name to start magic"),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniPlayer() {
    return Positioned(
      bottom: 20, left: 15, right: 15,
      child: GestureDetector(
        onTap: _showFullPlayer,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              height: 70,
              color: Colors.white.withOpacity(0.08),
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(currentSong['img'], width: 50, height: 50, fit: BoxFit.cover)),
                  SizedBox(width: 15),
                  Expanded(child: Text(currentSong['title'], style: TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                  IconButton(icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, size: 30), onPressed: _togglePlay),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showFullPlayer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _fullPlayerUI(),
    );
  }

  Widget _fullPlayerUI() {
    return StatefulBuilder(builder: (context, setModalState) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.vertical(top: Radius.circular(40))),
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              SizedBox(height: 50),
              ClipRRect(borderRadius: BorderRadius.circular(30), child: Image.network(currentSong['img'], height: 320, width: 320, fit: BoxFit.cover)),
              SizedBox(height: 40),
              Text(currentSong['title'], style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center, maxLines: 2),
              Text(currentSong['artist'], style: TextStyle(fontSize: 18, color: Colors.grey)),
              SizedBox(height: 30),
              Slider(
                activeColor: Colors.greenAccent,
                value: position.inSeconds.toDouble(),
                max: duration.inSeconds.toDouble() > 0 ? duration.inSeconds.toDouble() : 1.0,
                onChanged: (v) { _player.seek(Duration(seconds: v.toInt())); },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(Icons.shuffle, color: Colors.grey),
                  IconButton(icon: Icon(Icons.skip_previous, size: 40), onPressed: () {}),
                  IconButton(
                    icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, size: 80, color: Colors.greenAccent),
                    onPressed: () { _togglePlay(); setModalState(() {}); },
                  ),
                  IconButton(icon: Icon(Icons.skip_next, size: 40), onPressed: () {}),
                  Icon(Icons.repeat, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
