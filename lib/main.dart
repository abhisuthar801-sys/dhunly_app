import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// YE HAI ASLI DHUNLY PRO KA START
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    title: "Dhunly Pro", // Phone ki memory mein name fix
    debugShowCheckedModeBanner: false, 
    home: DhunlyFinalFix()
  ));
}

class DhunlyFinalFix extends StatefulWidget {
  const DhunlyFinalFix({super.key});
  @override
  State<DhunlyFinalFix> createState() => _DhunlyFinalFixState();
}

class _DhunlyFinalFixState extends State<DhunlyFinalFix> {
  final AudioPlayer _player = AudioPlayer();
  List cloudSongs = [];
  bool isLoading = true;
  bool isPlaying = false;

  // AAPKA LOGO (Direct High-Speed Link)
  final String myLogo = "https://cdn-icons-png.flaticon.com/512/3844/3844724.png"; 

  String currentSong = "Dhunly Pro: Tap to Play";
  String currentImg = "https://cdn-icons-png.flaticon.com/512/3844/3844724.png";

  @override
  void initState() {
    super.initState();
    loadMusic();
  }

  Future<void> loadMusic() async {
    setState(() => isLoading = true);
    try {
      // Is baar hum ek backup database use kar rahe hain
      final res = await http.get(Uri.parse("https://api.jsonsilo.com/public/69094396-e176-474c-8302-3866d56d788e"));
      if (res.statusCode == 200) {
        setState(() {
          cloudSongs = json.decode(res.body)['songs'];
          isLoading = false;
        });
      }
    } catch (e) {
      // Agar internet nahi chala toh ye 295 gaana dikhayega
      setState(() {
        cloudSongs = [
          {'title': '295 (Legend)', 'artist': 'Sidhu Moose Wala', 'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3', 'img': myLogo}
        ];
        isLoading = false;
      });
    }
  }

  void play(var s) async {
    try {
      await _player.stop();
      await _player.play(UrlSource(s['url']));
      setState(() {
        currentSong = s['title'];
        currentImg = s['img'];
        isPlaying = true;
      });
    } catch (e) {
      print("Error playing song: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text("DHUNLY PRO", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.network(myLogo), // LOGO IN TOP BAR
        ),
      ),
      body: Column(
        children: [
          if (isLoading) const Expanded(child: Center(child: CircularProgressIndicator(color: Colors.blueAccent))),
          if (!isLoading) Expanded(
            child: ListView.builder(
              itemCount: cloudSongs.length,
              itemBuilder: (context, i) => ListTile(
                leading: Image.network(cloudSongs[i]['img'], width: 50),
                title: Text(cloudSongs[i]['title'], style: const TextStyle(color: Colors.white)),
                subtitle: Text(cloudSongs[i]['artist'], style: const TextStyle(color: Colors.white54)),
                trailing: const Icon(Icons.play_arrow, color: Colors.blueAccent),
                onTap: () => play(cloudSongs[i]),
              ),
            ),
          ),
          _miniPlayer(),
        ],
      ),
    );
  }

  Widget _miniPlayer() => Container(
    padding: const EdgeInsets.all(20),
    color: Colors.white10,
    child: Row(
      children: [
        CircleAvatar(backgroundImage: NetworkImage(currentImg)),
        const SizedBox(width: 15),
        Expanded(child: Text(currentSong, style: const TextStyle(color: Colors.white))),
        IconButton(
          icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 35),
          onPressed: () {
            isPlaying ? _player.pause() : _player.resume();
            setState(() => isPlaying = !isPlaying);
          },
        )
      ],
    ),
  );
}
