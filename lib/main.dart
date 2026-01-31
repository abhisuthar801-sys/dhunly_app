import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: DhunlyPro()));

class DhunlyPro extends StatefulWidget {
  const DhunlyPro({super.key});
  @override
  State<DhunlyPro> createState() => _DhunlyProState();
}

class _DhunlyProState extends State<DhunlyPro> {
  List songs = [];
  bool isLoading = false;
  String currentSong = "No Track Selected";
  String currentArtist = "Tap a song to play";
  String currentImg = "https://cdn-icons-png.flaticon.com/512/3844/3844724.png";
  int _selectedIndex = 0;

  Future<void> searchSongs(String query) async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse("https://saavn.dev/api/search/songs?query=$query"));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          songs = data['data']['results'];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Aesthetic Gradients
          Positioned(top: -100, left: -50, child: _blurCircle(Colors.blueAccent.withOpacity(0.4))),
          Positioned(bottom: -100, right: -50, child: _blurCircle(Colors.purpleAccent.withOpacity(0.4))),
          
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
            child: Container(color: Colors.transparent),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                _buildSearchBar(),
                if (isLoading) const LinearProgressIndicator(color: Colors.white12, valueColor: AlwaysStoppedAnimation(Colors.blueAccent)),
                _buildMainContent(),
                _buildGlassPlayer(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _blurCircle(Color color) => Container(width: 350, height: 350, decoration: BoxDecoration(shape: BoxShape.circle, color: color));

  Widget _buildAppBar() => const Padding(
    padding: EdgeInsets.symmetric(vertical: 15),
    child: Text("DHUNLY", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 8)),
  );

  Widget _buildSearchBar() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), border: Border.all(color: Colors.white.withOpacity(0.1))),
          child: TextField(
            onSubmitted: (v) => searchSongs(v),
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "Search artists, songs...",
              hintStyle: TextStyle(color: Colors.white38),
              prefixIcon: Icon(Icons.search, color: Colors.blueAccent),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(15),
            ),
          ),
        ),
      ),
    ),
  );

  Widget _buildMainContent() => Expanded(
    child: songs.isEmpty 
      ? const Center(child: Text("Search to explore your vibe", style: TextStyle(color: Colors.white38)))
      : ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: songs.length,
          itemBuilder: (context, index) {
            var s = songs[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                leading: ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(s['image'].last['url'])),
                title: Text(s['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), maxLines: 1),
                subtitle: Text(s['artists']['primary'][0]['name'], style: const TextStyle(color: Colors.white38, fontSize: 12)),
                trailing: const Icon(Icons.play_circle_fill, color: Colors.white24, size: 30),
                onTap: () => setState(() {
                  currentSong = s['name'];
                  currentArtist = s['artists']['primary'][0]['name'];
                  currentImg = s['image'].last['url'];
                }),
              ),
            );
          },
        ),
  );

  Widget _buildGlassPlayer() => ClipRect(
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05)))),
        child: Row(
          children: [
            Hero(tag: 'img', child: CircleAvatar(backgroundImage: NetworkImage(currentImg), radius: 25)),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(currentSong, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), maxLines: 1),
                  Text(currentArtist, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                ],
              ),
            ),
            IconButton(icon: const Icon(Icons.favorite_border, color: Colors.white), onPressed: () {}),
            const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 45),
          ],
        ),
      ),
    ),
  );

  Widget _buildBottomNav() => BottomNavigationBar(
    backgroundColor: Colors.black,
    currentIndex: _selectedIndex,
    onTap: (i) => setState(() => _selectedIndex = i),
    selectedItemColor: Colors.blueAccent,
    unselectedItemColor: Colors.white24,
    showSelectedLabels: false,
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
      BottomNavigationBarItem(icon: Icon(Icons.explore), label: "Explore"),
      BottomNavigationBarItem(icon: Icon(Icons.library_music), label: "Library"),
    ],
  );
}
