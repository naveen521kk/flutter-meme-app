import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:meme_app/main.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

Future<Meme> createMeme(http.Client client, MemeTemplate template,
    Map<int, String> formData) async {
  // Get username and password from settings.
  final prefs = await SharedPreferences.getInstance();

  var templateId = template.id;
  var formBody = <String, String>{
    'template_id': templateId,
    'username': prefs.getString('username') ?? '',
    'password': prefs.getString('password') ?? '',
  };
  formData.forEach((key, value) {
    formBody['boxes[$key][text]'] = value;
  });
  final response = await http.post(
    Uri.parse('https://api.imgflip.com/caption_image'),
    //Uri.parse('https://httpbin.org/post'),
    body: formBody,
  );
  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    // Use the compute function to run parseMemesTemplates in a separate isolate.
    var decoded = jsonDecode(response.body);
    if (decoded['success'] == true) {
      return Meme.fromJson(decoded['data']);
    } else {
      throw Exception(decoded['error_message']);
    }
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to create meme');
  }
}

class Meme {
  final String url;
  final String pageUrl;

  const Meme({required this.url, required this.pageUrl});

  factory Meme.fromJson(Map<String, dynamic> json) {
    return Meme(
      url: json['url'],
      pageUrl: json['page_url'],
    );
  }
}

class DisplayMemePage extends StatefulWidget {
  MemeTemplate template;
  Map<int, String> formData;

  DisplayMemePage({
    super.key,
    required this.template,
    required this.formData,
  });

  @override
  State<DisplayMemePage> createState() => _CreateMemePageState();
}

class _CreateMemePageState extends State<DisplayMemePage> {
  late Future<Meme> futureMeme;
  String memeUrl = '';

  @override
  void initState() {
    super.initState();
    futureMeme = createMeme(http.Client(), widget.template, widget.formData);
  }

  Future<void> _openUrl(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Meme"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FutureBuilder<Meme>(
                future: futureMeme,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: Text(
                                snapshot.error.toString(),
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                                "Check settings for username and password.",
                                style: TextStyle(fontSize: 20)),
                          ),
                        ],
                      ),
                    );
                  } else if (snapshot.hasData) {
                    memeUrl = snapshot.data!.url;
                    return Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _openUrl(Uri.parse(snapshot.data!.url));
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 15.0),
                            child: Text(
                              'Open in Browser',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CachedNetworkImage(
                            placeholder: (context, url) =>
                                const CircularProgressIndicator(),
                            imageUrl: snapshot.data!.url,
                          ),
                        ),
                      ],
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
