import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:meme_app/meme_form.dart';
import 'package:meme_app/settings.dart';

Future<List<MemeTemplate>> fetchMemeTemplates(http.Client client) async {
  try {
    final response =
        await client.get(Uri.parse('https://api.imgflip.com/get_memes')
            //Uri.parse('http://localhost:5000/get_memes'),
            );
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      // Use the compute function to run parseMemesTemplates in a separate isolate.
      return compute(parseMemesTemplates, response.body);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load');
    }
  } catch (e) {
    debugPrint(e.toString());
    rethrow;
  }
}

// A function that converts a response body into a List<Photo>.
List<MemeTemplate> parseMemesTemplates(String responseBody) {
  final parsed =
      jsonDecode(responseBody)['data']['memes'].cast<Map<String, dynamic>>();

  return parsed
      .map<MemeTemplate>((json) => MemeTemplate.fromJson(json))
      .toList();
}

class MemeTemplate {
  final String id;
  final String name;
  final String url;
  final int boxCount;
  final int height;
  final int width;

  const MemeTemplate({
    required this.id,
    required this.name,
    required this.url,
    required this.boxCount,
    required this.height,
    required this.width,
  });

  factory MemeTemplate.fromJson(Map<String, dynamic> json) {
    return MemeTemplate(
      id: json['id'],
      name: json['name'],
      url: json['url'],
      boxCount: json['box_count'],
      height: json['height'],
      width: json['width'],
    );
  }
}

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Create Memes',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const CreateMemePage(title: 'Create a Meme'),
    );
  }
}

class CreateMemePage extends StatefulWidget {
  const CreateMemePage({super.key, required this.title});

  final String title;

  @override
  State<CreateMemePage> createState() => _CreateMemePageState();
}

class _CreateMemePageState extends State<CreateMemePage> {
  late Future<List<MemeTemplate>> futureMemeTemplates;

  @override
  void initState() {
    super.initState();
    futureMemeTemplates = fetchMemeTemplates(http.Client());
  }

  void _showSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(widget.title)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettings,
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            MemeForm(
              future: futureMemeTemplates,
            ),
          ],
        ),
      ),
    );
  }
}
