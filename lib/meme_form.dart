import 'package:flutter/material.dart';
import 'package:meme_app/main.dart';

// Create a Form widget.
class MemeForm extends StatefulWidget {
  MemeForm({super.key, required this.future});
  late Future<List<MemeTemplate>> future;

  @override
  MemeFormState createState() {
    return MemeFormState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class MemeFormState extends State<MemeForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();
  String _chosenTemplate = '';
  List<MemeTemplate> _templates = [];
  List<String> _memeTemplates = [];

  MemeTemplate findTemplate(String templateName) {
    var defaultMemeTemplate = const MemeTemplate(
        id: '0', name: '', url: '', boxCount: 0, height: 0, width: 0);

    if (_templates == []) {
      return defaultMemeTemplate;
    }
    return _templates.firstWhere(
      (element) => element.name == templateName,
      orElse: (() => defaultMemeTemplate),
    );
  }

  @override
  void initState() {
    super.initState();
    widget.future.then((value) => {
          setState(() {
            _chosenTemplate = value[0].name;
            _memeTemplates = value.map((e) => e.name).toList();
            _templates = value;
          })
        });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      // FutureBuilder<List<MemeTemplate>>(
      //   future: widget.future,
      //   builder: (context, snapshot) {
      //     if (snapshot.hasError) {
      //       return Center(
      //         child: Text(snapshot.error.toString()),
      //       );
      //     } else if (snapshot.hasData) {
      //       _chosenTemplate = snapshot.data![0].name;
      //       return DropdownButton<String>(
      //         //elevation: 5,
      //         value: _chosenTemplate,
      //         style: const TextStyle(color: Colors.black),
      //         items: snapshot.data!
      //             .map<DropdownMenuItem<String>>((MemeTemplate value) {
      //           return DropdownMenuItem<String>(
      //             value: value.name,
      //             child: Text(value.name),
      //           );
      //         }).toList(),
      //         hint: const Text(
      //           "Please choose a language",
      //           style: TextStyle(
      //               color: Colors.black,
      //               fontSize: 16,
      //               fontWeight: FontWeight.w600),
      //         ),
      //         onChanged: (String? value) {
      //           setState(() {
      //             _chosenTemplate = value!;
      //           });
      //         },
      //       );
      //     } else {
      //       return const Center(
      //         child: CircularProgressIndicator(),
      //       );
      //     }
      //   },
      // ),
      DropdownButton<String>(
        value: _chosenTemplate,
        style: const TextStyle(color: Colors.black),
        items: _memeTemplates.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        hint: const Text(
          "Please choose a meme template",
          style: TextStyle(
              color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        onChanged: (String? value) {
          setState(() {
            _chosenTemplate = value!;
          });
        },
      ),
    ];

    for (int i = 0; i < findTemplate(_chosenTemplate).boxCount; i++) {
      children.add(
        TextFormField(
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please fill this field!';
            }
            return null;
          },
          decoration: InputDecoration(
            border: UnderlineInputBorder(),
            labelText: i == 0
                ? 'Enter ${i + 1}st text'
                : (i == 1
                    ? 'Enter ${i + 1}nd text'
                    : (i == 2
                        ? 'Enter ${i + 1}rd text'
                        : 'Enter ${i + 1}th text')),
          ),
        ),
      );
    }

    // Add the submit button
    children.add(
      Center(
          child: Padding(
        padding: EdgeInsets.symmetric(vertical: 30.0),
        child: ElevatedButton(
            onPressed: () {
              // Validate returns true if the form is valid, or false otherwise.
              if (_formKey.currentState!.validate()) {
                // If the form is valid, display a snackbar. In the real world,
                // you'd often call a server or save the information in a database.
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Processing Data')),
                );
              }
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 15.0),
              child: Text(
                'Submit',
                style: TextStyle(fontSize: 16),
              ),
            )),
      )),
    );

    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}
