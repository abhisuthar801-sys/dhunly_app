import 'package:flutter/material.dart';
import 'dart:ui';

void main() => runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: DhunlySpotify()));

class DhunlySpotify extends StatelessWidget {
  const DhunlySpotify({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Aesthetic
          Positioned(top: -100, left: -50, child: _orb(Colors.greenAccent.withOpacity(0.2))),
          Positioned(bottom: -100, right: -50, child: _orb(Colors.blueAccent.withOpacity(0.2))),
          
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(),
                  _searchBar(),
                  _sectionTitle("Start browsing"),
                  _browseGrid(),
                  _sectionTitle("Discover something new"),
                  _discoverCards(),
                  const SizedBox(height: 100), // Player ke liye jagah
                ],
              ),
            ),
          ),
          
          // Floating Glass Player (Niche wala bar)
          Positioned(bottom: 20, left: 10, right: 10, child: _glassPlayer()),
        ],
      ),
      bottomNavigationBar: _bottomNav(),
    );
  }

  Widget _orb(Color c) => Container(width: 400, height: 400, decoration: BoxDecoration(shape: BoxShape.circle, color: c), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100), child: Container(color: Colors.transparent)));

  Widget _header() => const Padding(
    padding: EdgeInsets.all(20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CircleAvatar(backgroundColor: Colors.purple, child: Text("A")),
        Text("Search", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        Icon(Icons.camera_alt_outlined, color: Colors.white),
      ],
    ),
  );

  Widget _searchBar() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 20),
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5)),
    child: const Row(
      children: [
        Icon(Icons.search, color: Colors.black),
        SizedBox(width: 10),
        Text("What do you want to listen to?", style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
      ],
    ),
  );

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.all(20),
    child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
  );

  Widget _browseGrid() => GridView.count(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    crossAxisCount: 2,
    padding: const EdgeInsets.symmetric(horizontal: 15),
    childAspectRatio: 1.8,
    children: [
      _categoryCard("Music", Colors.pink, "https://shorturl.at/afmP6"),
      _categoryCard("Podcasts", Colors.teal, "https://shorturl.at/afmP6"),
      _categoryCard("Live Events", Colors.deepPurple, "https://shorturl.at/afmP6"),
      _categoryCard("I-Pop", Colors.blueGrey, "https://shorturl.at/afmP6"),
    ],
  );

  Widget _categoryCard(String title, Color color, String img) => Container(
    margin: const EdgeInsets.all(5),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(5)),
    child: Stack(
      children: [
        Padding(padding: const EdgeInsets.all(10), child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        Positioned(bottom: -10, right: -10, child: RotationTransition(turns: const AlwaysStoppedAnimation(25 / 360), child: Image.network(img, width: 60))),
      ],
    ),
  );

  Widget _discoverCards() => SizedBox(
    height: 250,
    child: ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      children: [
        _largeCard("Music for you", "https://shorturl.at/afmP6"),
        _largeCard("#filmi", "https://shorturl.at/afmP6"),
        _largeCard("#bold", "https://shorturl.at/afmP6"),
      ],
    ),
  );

  Widget _largeCard(String label, String img) => Container(
    width: 160,
    margin: const EdgeInsets.only(right: 15),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), image: DecorationImage(image: NetworkImage(img), fit: BoxFit.cover)),
    alignment: Alignment.bottomLeft,
    padding: const EdgeInsets.all(10),
    child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
  );

  Widget _glassPlayer() => ClipRRect(
    borderRadius: BorderRadius.circular(10),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
      child: Container(
        height: 60,
        color: Colors.white.withOpacity(0.1),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            ClipRRect(borderRadius: BorderRadius.circular(5), child: Image.network("https://shorturl.at/afmP6", width: 45, height: 45, fit: BoxFit.cover)),
            const SizedBox(width: 10),
            const Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Toomba Vajjda", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)), Text("Kanwar Grewal", style: TextStyle(color: Colors.white70, fontSize: 11))])),
            const Icon(Icons.computer, color: Colors.white70),
            const SizedBox(width: 15),
            const Icon(Icons.play_arrow, color: Colors.white, size: 35),
          ],
        ),
      ),
    ),
  );

  Widget _bottomNav() => BottomNavigationBar(
    backgroundColor: Colors.black,
    unselectedItemColor: Colors.white54,
    selectedItemColor: Colors.white,
    type: BottomNavigationBarType.fixed,
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
      BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
      BottomNavigationBarItem(icon: Icon(Icons.library_music), label: "Your Library"),
      BottomNavigationBarItem(icon: Icon(Icons.add), label: "Create"),
    ],
  );
}
