import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF050505),
        primaryColor: Colors.greenAccent,
      ),
      home: DhunlyProFinal(),
    ));

class DhunlyProFinal extends StatefulWidget {
  @override
  _DhunlyProFinalState createState() => _DhunlyProFinalState();
}

class _DhunlyProFinalState extends State<DhunlyProFinal> {
  final AudioPlayer _player = AudioPlayer();
  bool isPlaying = false;
  bool isLoading = false;
  List searchResults = [];
  var currentSong;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player.onDurationChanged.listen((d) => setState(() => duration = d));
    _player.onPositionChanged.listen((p) => setState(() => position = p));
    _player.onPlayerStateChanged.listen((s) => setState(() => isPlaying = s == PlayerState.playing));
  }

  // SAAVN API ENGINE (100% Working)
  Future<void> searchMusic(String query) async {
    if (query.isEmpty) return;
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse("https://saavn.me/search/songs?query=$query&limit=15"));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          searchResults = data['data']['results'];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void playSong(var song) async {
    try {
      // Sabse high quality link select karna (320kbps)
      String url = song['downloadUrl'].last['link'];
      await _player.play(UrlSource(url));
      setState(() {
        currentSong = song;
      });
    } catch (e) {
      print("Error playing: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAppBar(),
                _buildSearchBar(),
                if (isLoading) LinearProgressIndicator(color: Colors.greenAccent),
                Expanded(
                  child: searchResults.isEmpty ? _buildHomeUI() : _buildSearchResults(),
                ),
                if (currentSong != null) const SizedBox(height: 140), // Space for player
              ],
            ),
            if (currentSong != null) _buildBottomPlayerUI(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("DHUNLY PRO", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.greenAccent)),
          CircleAvatar(backgroundColor: Colors.white10, child: Icon(Icons.person, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        onSubmitted: (v) => searchMusic(v),
        decoration: InputDecoration(
          hintText: "Gaana, Artist ya Album...",
          prefixIcon: const Icon(Icons.search, color: Colors.greenAccent),
          filled: true,
          fillColor: Colors.white10,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildHomeUI() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text("Quick Mixes", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _moodBtn("Romantic", Colors.pink, "Arijit Singh"),
            _moodBtn("Party", Colors.orange, "Badshah"),
            _moodBtn("Gym", Colors.red, "Workout Beats"),
          ],
        ),
        const SizedBox(height: 30),
        const Text("Trending Artists", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        _artistTile("Sidhu Moose Wala"),
        _artistTile("Karan Aujla"),
        _artistTile("Kaka"),
      ],
    );
  }

  Widget _moodBtn(String name, Color col, String q) {
    return GestureDetector(
      onTap: () => searchMusic(q),
      child: Column(
        children: [
          CircleAvatar(radius: 30, backgroundColor: col.withOpacity(0.2), child: Icon(Icons.music_note, color: col)),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _artistTile(String name) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(backgroundColor: Colors.white10, child: Text(name[0])),
      title: Text(name),
      subtitle: const Text("Verified Artist"),
      trailing: const Icon(Icons.play_circle_fill, color: Colors.greenAccent),
      onTap: () => searchMusic(name),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, i) {
        var song = searchResults[i];
        return ListTile(
          leading: Image.network(song['image'][0]['link']),
          title: Text(song['name'], maxLines: 1),
          subtitle: Text(song['primaryArtists'], maxLines: 1),
          onTap: () => playSong(song),
        );
      },
    );
  }

  Widget _buildBottomPlayerUI() {
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFF151515),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [BoxShadow(color: Colors.black, blurRadius: 10)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(currentSong['image'].last['link'], height: 60, width: 60)),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(currentSong['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1),
                    Text(currentSong['primaryArtists'], style: const TextStyle(color: Colors.grey, fontSize: 12), maxLines: 1),
                  ]),
                ),
                IconButton(icon: Icon(isPlaying ? Icons.pause_circle : Icons.play_circle, size: 45, color: Colors.greenAccent), onPressed: () => isPlaying ? _player.pause() : _player.resume()),
              ],
            ),
            Slider(
              activeColor: Colors.greenAccent,
              value: position.inSeconds.toDouble(),
              max: duration.inSeconds.toDouble() > 0 ? duration.inSeconds.toDouble() : 1.0,
              onChanged: (v) => _player.seek(Duration(seconds: v.toInt())),
            ),
          ],
        ),
      ),
    );
  }
}
