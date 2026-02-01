import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: DhunlySmartApp()));

class DhunlySmartApp extends StatefulWidget {
  const DhunlySmartApp({super.key});
  @override
  State<DhunlySmartApp> createState() => _DhunlySmartAppState();
}

class _DhunlySmartAppState extends State<DhunlySmartApp> {
  final AudioPlayer _player = AudioPlayer();
  List allSongs = [];
  List displayedSongs = [];
  String selectedCat = "All";
  bool isLoading = true;
  bool isPlaying = false;
  
  String currentTitle = "Dhunly Pro";
  String currentImg = "https://i.ibb.co/Ldx999X/dhunly-logo.png";

  @override
  void initState() {
    super.initState();
    fetchCloudData();
  }

  Future<void> fetchCloudData() async {
    try {
      final res = await http.get(Uri.parse("https://api.jsonsilo.com/public/69094396-e176-474c-8302-3866d56d788e"));
      if (res.statusCode == 200) {
        var data = json.decode(res.body)['songs'];
        setState(() {
          allSongs = data;
          displayedSongs = data;
          isLoading = false;
        });
      }
    } catch (e) { setState(() => isLoading = false); }
  }

  void filterCategory(String cat) {
    setState(() {
      selectedCat = cat;
      if (cat == "All") {
        displayedSongs = allSongs;
      } else {
        displayedSongs = allSongs.where((s) => s['category'] == cat).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildCategoryList(),
            if (isLoading) const Expanded(child: Center(child: CircularProgressIndicator())),
            _buildSongList(),
            _buildPlayer(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() => const Padding(
    padding: EdgeInsets.all(20),
    child: Text("DHUNLY PRO", style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 2)),
  );

  Widget _buildCategoryList() {
    List<String> cats = ["All", "Punjabi", "Sad", "Party", "Lofi"];
    return Container(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: cats.length,
        itemBuilder: (context, i) => GestureDetector(
          onTap: () => filterCategory(cats[i]),
          child: Container(
            margin: const EdgeInsets.only(left: 20),
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            decoration: BoxDecoration(
              color: selectedCat == cats[i] ? Colors.blueAccent : Colors.white10,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Center(child: Text(cats[i], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          ),
        ),
      ),
    );
  }

  Widget _buildSongList() => Expanded(
    child: ListView.builder(
      itemCount: displayedSongs.length,
      padding: const EdgeInsets.all(20),
      itemBuilder: (context, i) => ListTile(
        leading: ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(displayedSongs[i]['img'], width: 50, height: 50, fit: BoxFit.cover)),
        title: Text(displayedSongs[i]['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(displayedSongs[i]['artist'], style: const TextStyle(color: Colors.white38)),
        onTap: () {
          _player.play(UrlSource(displayedSongs[i]['url']));
          setState(() {
            currentTitle = displayedSongs[i]['title'];
            currentImg = displayedSongs[i]['img'];
            isPlaying = true;
          });
        },
      ),
    ),
  );

  Widget _buildPlayer() => Container(
    padding: const EdgeInsets.all(15),
    color: const Color(0xFF111111),
    child: Row(
      children: [
        CircleAvatar(backgroundImage: NetworkImage(currentImg)),
        const SizedBox(width: 15),
        Expanded(child: Text(currentTitle, style: const TextStyle(color: Colors.white))),
        IconButton(
          icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, color: Colors.blueAccent, size: 40),
          onPressed: () {
            isPlaying ? _player.pause() : _player.resume();
            setState(() => isPlaying = !isPlaying);
          },
        )
      ],
    ),
  );
}
