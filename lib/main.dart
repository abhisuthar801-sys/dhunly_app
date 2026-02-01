import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const MaterialApp(
  debugShowCheckedModeBanner: false, 
  home: DhunlyFinal()
));

class DhunlyFinal extends StatefulWidget {
  const DhunlyFinal({super.key});
  @override
  State<DhunlyFinal> createState() => _DhunlyFinalState();
}

class _DhunlyFinalState extends State<DhunlyFinal> {
  final AudioPlayer _player = AudioPlayer();
  List songs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Ye link aapki library se connect hai
    http.get(Uri.parse("https://api.jsonsilo.com/public/69094396-e176-474c-8302-3866d56d788e")).then((res) {
      setState(() {
        songs = json.decode(res.body)['songs'];
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          children: [
            // Header Logo
            Image.network("https://i.ibb.co/Ldx999X/dhunly-logo.png", height: 35),
            const SizedBox(width: 10),
            const Text("DHUNLY PRO", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : ListView.builder(
            itemCount: songs.length,
            itemBuilder: (context, i) => ListTile(
              leading: Image.network(songs[i]['img'], width: 50),
              title: Text(songs[i]['title'], style: const TextStyle(color: Colors.white)),
              onTap: () => _player.play(UrlSource(songs[i]['url'])),
            ),
          ),
    );
  }
}
