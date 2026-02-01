import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui';

void main() => runApp(const MaterialApp(
  debugShowCheckedModeBanner: false,
  title: "Dhunly Pro",
  home: DhunlyUltimateApp(),
));

class DhunlyUltimateApp extends StatefulWidget {
  const DhunlyUltimateApp({super.key});
  @override
  State<DhunlyUltimateApp> createState() => _DhunlyUltimateAppState();
}

class _DhunlyUltimateAppState extends State<DhunlyUltimateApp> {
  final AudioPlayer _player = AudioPlayer();
  List allSongs = [];
  List filteredSongs = [];
  String selectedCategory = "All";
  bool isLoading = true;
  bool isPlaying = false;
  
  String currentTitle = "Dhunly Pro: Select Music";
  String currentArtist = "Your Personal Cloud";
  String currentImg = "assets/logo.png"; 

  @override
  void initState() {
    super.initState();
    syncWithDhunlyCloud();
  }

  // --- CLOUD SYNC: ISSE BAAR BAAR BUILD NAHI BANANA PADEGA ---
  Future<void> syncWithDhunlyCloud() async {
    try {
      final res = await http.get(Uri.parse("https://api.jsonsilo.com/public/69094396-e176-474c-8302-3866d56d788e"));
      if (res.statusCode == 200) {
        var data = json.decode(res.body)['songs'];
        setState(() {
          allSongs = data;
          filteredSongs = data;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void filterSongs(String query) {
    setState(() {
      filteredSongs = allSongs.where((s) => s['title'].toLowerCase().contains(query.toLowerCase())).toList();
    });
  }

  void selectCategory(String cat) {
    setState(() {
      selectedCategory = cat;
      filteredSongs = cat == "All" ? allSongs : allSongs.where((s) => s['category'] == cat).toList();
    });
  }

  void play(var s) async {
    await _player.stop();
    await _player.play(UrlSource(s['url']));
    setState(() {
      currentTitle = s['title'];
      currentArtist = s['artist'];
      currentImg = s['img'];
      isPlaying = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: Stack(
        children: [
          _backgroundGlow(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildSearchBar(),
                _buildCategoryChips(),
                if (isLoading) const Expanded(child: Center(child: CircularProgressIndicator(color: Colors.blueAccent))),
                if (!isLoading) _buildSongList(),
                _buildBottomMiniPlayer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _backgroundGlow() => Positioned(top: -100, left: -50, child: Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blueAccent.withOpacity(0.1))));

  Widget _buildHeader() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    child: Row(
      children: [
        Image.asset("assets/logo.png", height: 45, errorBuilder: (c, e, s) => const Icon(Icons.play_circle_fill, color: Colors.blueAccent, size: 45)),
        const SizedBox(width: 15),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("DHUNLY PRO", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1)),
            Text("Premium Music Experience", style: TextStyle(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    ),
  );

  Widget _buildSearchBar() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    child: TextField(
      onChanged: (v) => filterSongs(v),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: "Search your songs...",
        hintStyle: const TextStyle(color: Colors.white24),
        prefixIcon: const Icon(Icons.search, color: Colors.white54),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    ),
  );

  Widget _buildCategoryChips() {
    List<String> cats = ["All", "Punjabi", "Sad", "Lofi", "Party"];
    return Container(
      height: 60,
      padding: const EdgeInsets.only(left: 15),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: cats.length,
        itemBuilder: (context, i) => Padding(
          padding: const EdgeInsets.only(right: 10),
          child: ActionChip(
            label: Text(cats[i]),
            backgroundColor: selectedCategory == cats[i] ? Colors.blueAccent : Colors.white10,
            onPressed: () => selectCategory(cats[i]),
            labelStyle: TextStyle(color: selectedCategory == cats[i] ? Colors.white : Colors.white54),
          ),
        ),
      ),
    );
  }

  Widget _buildSongList() => Expanded(
    child: ListView.builder(
      itemCount: filteredSongs.length,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      itemBuilder: (context, i) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(15)),
        child: ListTile(
          onTap: () => play(filteredSongs[i]),
          leading: ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(filteredSongs[i]['img'], width: 55, height: 55, fit: BoxFit.cover)),
          title: Text(filteredSongs[i]['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          subtitle: Text(filteredSongs[i]['artist'], style: const TextStyle(color: Colors.white38, fontSize: 12)),
          trailing: const Icon(Icons.play_circle_outline, color: Colors.blueAccent),
        ),
      ),
    ),
  );

  Widget _buildBottomMiniPlayer() => ClipRRect(
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.black.withOpacity(0.8), border: Border(top: BorderSide(color: Colors.blueAccent.withOpacity(0.3)))),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: currentImg.startsWith('assets') ? AssetImage(currentImg) : NetworkImage(currentImg) as ImageProvider,
              radius: 25,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(currentTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), maxLines: 1),
                  Text(currentArtist, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                ],
              ),
            ),
            IconButton(
              icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, color: Colors.blueAccent, size: 45),
              onPressed: () {
                isPlaying ? _player.pause() : _player.resume();
                setState(() => isPlaying = !isPlaying);
              },
            ),
          ],
        ),
      ),
    ),
  );
}
