import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  String username = '';
  String password = '';

  void loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? '';
      password = prefs.getString('password') ?? '';
    });
  }

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  void _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      _formKey.currentState!.reset();

      prefs.setString('username', username);
      prefs.setString('password', password);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved Successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fix the form errors!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Enter imgflip.com account details",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const Text(
                "Previously entered username and password are automatically filled."),
            TextFormField(
              //initialValue: username,
              controller: TextEditingController(text: username),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please fill this field!';
                }
                return null;
              },
              onSaved: (newValue) => {username = newValue!},
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: "Username",
              ),
            ),
            TextFormField(
              controller: TextEditingController(text: password),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please fill this field!';
                }
                return null;
              },
              onSaved: (newValue) => {password = newValue!},
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: "Password",
              ),
            ),
          ],
        ),
      )
    ];

    // Add the submit button
    children.add(
      Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30.0),
          child: ElevatedButton(
            onPressed: () {
              _saveData();
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 15.0),
              child: Text(
                'Save',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("Settings")),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ),
    );
  }
}
