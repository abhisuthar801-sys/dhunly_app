import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: DhunlyGlass()));

class DhunlyGlass extends StatefulWidget {
  const DhunlyGlass({super.key});
  @override
  State<DhunlyGlass> createState() => _DhunlyGlassState();
}

class _DhunlyGlassState extends State<DhunlyGlass> {
  List songs = [];
  bool isLoading = false;
  String currentSongName = "No Song Playing";
  String currentArtist = "Select a track";
  String currentImg = "https://cdn-icons-png.flaticon.com/512/3844/3844724.png";

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
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1e3a8a), Color(0xFF000000), Color(0xFF581c87)],
              ),
            ),
          ),
          
          // Main Content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text("DHUNLY", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 4)),
                
                // Glass Search Bar
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: TextField(
                          onSubmitted: (v) => searchSongs(v),
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: "Search artist or song...",
                            hintStyle: TextStyle(color: Colors.white54),
                            border: InputBorder.none,
                            icon: Icon(Icons.search, color: Colors.white70),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                if (isLoading) const LinearProgressIndicator(backgroundColor: Colors.transparent, color: Colors.blueAccent),

                // Song List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    itemCount: songs.length,
                    itemBuilder: (context, index) {
                      var song = songs[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(song['image'].last['url'], width: 50, height: 50),
                          ),
                          title: Text(song['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600), maxLines: 1),
                          subtitle: Text(song['artists']['primary'][0]['name'], style: const TextStyle(color: Colors.white60)),
                          onTap: () {
                            setState(() {
                              currentSongName = song['name'];
                              currentArtist = song['artists']['primary'][0]['name'];
                              currentImg = song['image'].last['url'];
                            });
                            // Play logic yahan aayegi
                          },
                        ),
                      );
                    },
                  ),
                ),

                // Bottom Glass Player
                ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          CircleAvatar(backgroundImage: NetworkImage(currentImg), radius: 25),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(currentSongName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), maxLines: 1),
                                Text(currentArtist, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                              ],
                            ),
                          ),
                          IconButton(icon: const Icon(Icons.skip_previous, color: Colors.white), onPressed: () {}),
                          Container(
                            decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                            child: const Icon(Icons.play_arrow, color: Colors.black, size: 30),
                          ),
                          IconButton(icon: const Icon(Icons.skip_next, color: Colors.white), onPressed: () {}),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
