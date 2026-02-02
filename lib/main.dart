import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:ui';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: DhunlySpotifyGlass(),
    ));

class DhunlySpotifyGlass extends StatefulWidget {
  @override
  _DhunlySpotifyGlassState createState() => _DhunlySpotifyGlassState();
}

class _DhunlySpotifyGlassState extends State<DhunlySpotifyGlass> {
  final AudioPlayer _player = AudioPlayer();
  int _selectedIndex = 0;
  bool isPlaying = false;
  var currentSong;

  List songs = [
    {
      "title": "Door Des Koi Kudi",
      "artist": "Kaka",
      "url": "https://res.cloudinary.com/ds1bcvkop/video/upload/v1770036580/Door_Des_Koi_Kudi_-_Kaka_yvouzh.mp3",
      "img": "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=500&q=80"
    },
    {
      "title": "Starboy",
      "artist": "The Weeknd",
      "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
      "img": "https://images.unsplash.com/photo-1614613535308-eb5fbd3d2c17?w=500&q=80"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F0F0F),
      body: Stack(
        children: [
          // Background Glows (Spotify Vibe)
          Positioned(top: -100, left: -50, child: _blurCircle(Colors.greenAccent.withOpacity(0.2))),
          Positioned(bottom: 200, right: -50, child: _blurCircle(Colors.purpleAccent.withOpacity(0.15))),

          SafeArea(
            child: CustomScrollView(
              slivers: [
                _buildAppBar(),
                _buildSearchBox(),
                _buildSectionTitle("Your Mixes"),
                _buildHorizontalGrid(),
                _buildSectionTitle("Recently Played"),
                _buildSongList(),
              ],
            ),
          ),

          // Floating Glass Player
          if (currentSong != null) _buildMiniPlayer(),

          // Glass Bottom Nav
          _buildGlassBottomNav(),
        ],
      ),
    );
  }

  Widget _blurCircle(Color color) {
    return Container(width: 400, height: 400, decoration: BoxDecoration(shape: BoxShape.circle, color: color), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100), child: Container(color: Colors.transparent)));
  }

  Widget _buildAppBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Good Evening", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            Row(children: [
              Icon(Icons.notifications_none_outlined, size: 28),
              SizedBox(width: 20),
              CircleAvatar(backgroundImage: NetworkImage("https://picsum.photos/100")),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBox() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              height: 55,
              color: Colors.white.withOpacity(0.05),
              child: Row(children: [Icon(Icons.search, color: Colors.grey), SizedBox(width: 10), Text("Artists, songs, or podcasts", style: TextStyle(color: Colors.grey))]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 30, 20, 15),
        child: Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildHorizontalGrid() {
    return SliverToBoxAdapter(
      child: Container(
        height: 180,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.only(left: 20),
          itemCount: songs.length,
          itemBuilder: (context, i) => Container(
            width: 140,
            margin: EdgeInsets.only(right: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.network(songs[i]['img'], height: 130, width: 140, fit: BoxFit.cover)),
                SizedBox(height: 8),
                Text(songs[i]['title'], style: TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSongList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, i) => ListTile(
          onTap: () async {
            await _player.stop();
            await _player.play(UrlSource(songs[i]['url']));
            setState(() { currentSong = songs[i]; isPlaying = true; });
          },
          leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(songs[i]['img'], width: 50, height: 50, fit: BoxFit.cover)),
          title: Text(songs[i]['title'], style: TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(songs[i]['artist'], style: TextStyle(color: Colors.grey)),
          trailing: Icon(Icons.more_vert),
        ),
        childCount: songs.length,
      ),
    );
  }

  Widget _buildMiniPlayer() {
    return Positioned(
      bottom: 90, left: 10, right: 10,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 70,
            color: Colors.white.withOpacity(0.08),
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(currentSong['img'], width: 45, height: 45)),
                SizedBox(width: 12),
                Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(currentSong['title'], style: TextStyle(fontWeight: FontWeight.bold)), Text(currentSong['artist'], style: TextStyle(fontSize: 12, color: Colors.grey))])),
                IconButton(icon: Icon(Icons.favorite_border, color: Colors.greenAccent), onPressed: () {}),
                IconButton(icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, size: 30), onPressed: () {
                  if (isPlaying) _player.pause(); else _player.resume();
                  setState(() => isPlaying = !isPlaying);
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassBottomNav() {
    return Positioned(
      bottom: 20, left: 30, right: 30,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            height: 65,
            color: Colors.white.withOpacity(0.05),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(Icons.home_filled, "Home", 0),
                _navItem(Icons.search, "Search", 1),
                _navItem(Icons.library_music, "Library", 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    bool isSel = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: isSel ? Colors.greenAccent : Colors.grey, size: 28)]),
    );
  }
}
