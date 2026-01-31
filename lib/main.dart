// ... (baaki upar ka code same rahega, bas ye play function update kar lo)

final player = AudioPlayer(); // Ise class ke upar define kar dena
bool isPlaying = false;

void playSong(var songData) async {
  try {
    // Sabse fast load hone wala MP3 link uthao (usually 160kbps)
    String streamUrl = songData['downloadUrl'][2]['url']; 
    
    await player.stop();
    await player.play(UrlSource(streamUrl));
    
    setState(() {
      currentSong = songData['name'];
      currentArtist = songData['artists']['primary'][0]['name'];
      currentImg = songData['image'].last['url'];
      isPlaying = true;
    });
  } catch (e) {
    print("Error playing: $e");
  }
}

// ... Mini Player mein Play button ka logic:
IconButton(
  icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, color: Colors.white, size: 45),
  onPressed: () {
    if (isPlaying) {
      player.pause();
    } else {
      player.resume();
    }
    setState(() => isPlaying = !isPlaying);
  },
),
