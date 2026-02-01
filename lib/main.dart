import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MaterialApp(home: DhunlyFinalCheck(), debugShowCheckedModeBanner: false));

class DhunlyFinalCheck extends StatefulWidget {
  @override
  _DhunlyFinalCheckState createState() => _DhunlyFinalCheckState();
}

class _DhunlyFinalCheckState extends State<DhunlyFinalCheck> {
  List songs = [];
  bool loading = true;
  String errorMsg = "";

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    try {
      var res = await http.get(Uri.parse("https://api.jsonsilo.com/public/69094396-e176-474c-8302-3866d56d788e")).timeout(Duration(seconds: 10));
      if (res.statusCode == 200) {
        setState(() { songs = json.decode(res.body)['songs']; loading = false; });
      } else {
        setState(() { errorMsg = "Server Error: ${res.statusCode}"; loading = false; });
      }
    } catch (e) {
      setState(() { errorMsg = "Internet Connection Problem!"; loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Image.asset('assets/logo.png', height: 40, 
          errorBuilder: (context, error, stackTrace) => Text("DHUNLY PRO", style: TextStyle(color: Colors.green))), 
        backgroundColor: Colors.transparent,
      ),
      body: loading 
        ? Center(child: CircularProgressIndicator(color: Colors.green))
        : errorMsg.isNotEmpty 
          ? Center(child: Text(errorMsg, style: TextStyle(color: Colors.red)))
          : ListView.builder(
              itemCount: songs.length,
              itemBuilder: (context, i) => ListTile(
                leading: Image.network(songs[i]['img']),
                title: Text(songs[i]['title'], style: TextStyle(color: Colors.white)),
                subtitle: Text(songs[i]['artist'], style: TextStyle(color: Colors.grey)),
                onTap: () => AudioPlayer().play(UrlSource(songs[i]['url'])),
              ),
            ),
    );
  }
}
