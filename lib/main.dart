import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: DhunlyMasterApp(),
    ));

class DhunlyMasterApp extends StatefulWidget {
  @override
  _DhunlyMasterAppState createState() => _DhunlyMasterAppState();
}

class _DhunlyMasterAppState extends State<DhunlyMasterApp> {
  final AudioPlayer _player = AudioPlayer();
  List songs = [];
  List filtered = [];
  bool isLoading = true;
  bool isPlaying = false;
  var currentSong;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    loadCloudMusic();
  }

  // ☁️ CLOUD SYSTEM: Isse app baar-baar nahi banani padegi
  Future<void> loadCloudMusic() async {
    try {
      final res = await http.get(Uri.parse("https://api.jsonsilo.com/public/69094396-e176-474c-8302-3866d56d788e"));
      if (res.statusCode == 200) {
        setState(() {
          songs = json.decode(res.body)['songs'];
          filtered = songs;
          currentSong = songs[0];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void play(var s) async {
    await _player.stop();
    await _player.play(UrlSource(s['url']));
    setState(() { currentSong = s; isPlaying = true; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Glass Glow
          Positioned(top: -100, left: -50, child: _glow(Colors.blueAccent)),
          Positioned(bottom: -100, right: -50, child: _glow(Colors.purpleAccent)),
          
          SafeArea(
            child: Column(
              children: [
                _buildSpotifyHeader(),
                _buildSearchBar(),
                _buildCategories(),
                if (isLoading) const Expanded(child: Center(child: CircularProgressIndicator()))
                else _buildMainContent(),
                if (currentSong != null) _buildPremiumPlayer(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // --- FEATURES ---

  Widget _glow(Color c) => Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, color: c.withOpacity(0.15), boxShadow: [BoxShadow(color: c.withOpacity(0.1), blurRadius: 100)]));

  Widget _buildSpotifyHeader() => Padding(
    padding: const EdgeInsets.all(20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          Image.asset("assets/logo.png", height: 40, errorBuilder: (c, e, s) => Icon(Icons.music_note, color: Colors.blueAccent)),
          SizedBox(width: 10),
          Text("Dhunly Pro", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1)),
        ]),
        Row(children: [Icon(Icons.notifications_none), SizedBox(width: 15), Icon(Icons.settings_outlined)]),
      ],
    ),
  );

  Widget _buildSearchBar() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.07), borderRadius: BorderRadius.circular(10)),
      child: TextField(
        onChanged: (v) => setState(() => filtered = songs.where((s) => s['title'].toLowerCase().contains(v.toLowerCase())).toList()),
        decoration: InputDecoration(hintText: "Search artist, songs...", border: InputBorder.none, icon: Icon(Icons.search, color: Colors.white54)),
      ),
    ),
  );

  Widget _buildCategories() => Container(
    height: 60,
    child: ListView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.only(left: 20),
      children: ["Music", "Podcasts", "Punjabi Hits", "Lofi", "Sad"].map((t) => Container(
        margin: EdgeInsets.only(right: 10, top: 15, bottom: 5),
        child: ActionChip(label: Text(t), backgroundColor: Colors.white10),
      )).toList(),
    ),
  );

  Widget _buildMainContent() => Expanded(
    child: ListView.builder(
      itemCount: filtered.length,
      padding: EdgeInsets.all(15),
      itemBuilder: (context, i) => ListTile(
        onTap: () => play(filtered[i]),
        leading: ClipRRect(borderRadius: BorderRadius.circular(5), child: Image.network(filtered[i]['img'], width: 50, height: 50, fit: BoxFit.cover)),
        title: Text(filtered[i]['title'], style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(filtered[i]['artist'], style: TextStyle(color: Colors.white54)),
        trailing: Icon(Icons.more_vert, color: Colors.white54),
      ),
    ),
  );

  Widget _buildPremiumPlayer() => GestureDetector(
    onTap: () => _showFullPlayer(),
    child: ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          margin: EdgeInsets.all(10),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white10)),
          child: Row(
            children: [
              ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(currentSong['img'], width: 45, height: 45)),
              SizedBox(width: 15),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(currentSong['title'], style: TextStyle(fontWeight: FontWeight.bold)), Text(currentSong['artist'], style: TextStyle(color: Colors.white54, fontSize: 12))])),
              IconButton(icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, size: 35), onPressed: () {
                isPlaying ? _player.pause() : _player.resume();
                setState(() => isPlaying = !isPlaying);
              }),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _buildBottomNav() => BottomNavigationBar(
    currentIndex: _currentIndex,
    onTap: (i) => setState(() => _currentIndex = i),
    backgroundColor: Colors.black,
    selectedItemColor: Colors.blueAccent,
    unselectedItemColor: Colors.white54,
    type: BottomNavigationBarType.fixed,
    items: [
      BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
      BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
      BottomNavigationBarItem(icon: Icon(Icons.library_music), label: "Library"),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: "Premium"),
    ],
  );

  void _showFullPlayer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        padding: EdgeInsets.all(30),
        child: Column(children: [
          Icon(Icons.keyboard_arrow_down, color: Colors.white54),
          Spacer(),
          ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.network(currentSong['img'], width: 300, height: 300, fit: BoxFit.cover)),
          Spacer(),
          Text(currentSong['title'], style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          Text(currentSong['artist'], style: TextStyle(fontSize: 18, color: Colors.white54)),
          Spacer(),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            Icon(Icons.shuffle, color: Colors.white54),
            Icon(Icons.skip_previous, size: 45),
            IconButton(icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, size: 85, color: Colors.blueAccent), onPressed: () {
              isPlaying ? _player.pause() : _player.resume();
              setState(() => isPlaying = !isPlaying);
              Navigator.pop(context);
            }),
            Icon(Icons.skip_next, size: 45),
            Icon(Icons.repeat, color: Colors.white54),
          ]),
          Spacer(),
        ]),
      ),
    );
  }
}
