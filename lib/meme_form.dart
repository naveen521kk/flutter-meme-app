import 'package:flutter/material.dart';
import 'package:meme_app/main.dart';
import 'package:meme_app/meme_display.dart';

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

  Map<int, String> formData = {};

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

  void submitForm() {
    if (_formKey.currentState!.validate()) {
      // If the form is valid, display a Snackbar.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generating Meme...')),
      );
      _formKey.currentState!.save();
      _formKey.currentState!.reset();
      Navigator.of(context).push(
        MaterialPageRoute(
          // Builder for the nextpage class's constructor.
          builder: (context) => DisplayMemePage(
            // Data as arguments to send to next page.
            template: findTemplate(_chosenTemplate),
            formData: formData,
          ),
        ),
      );
    }
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
          onSaved: (newValue) => {
            formData[i] = newValue!,
          },
          decoration: InputDecoration(
            border: const UnderlineInputBorder(),
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
          padding: const EdgeInsets.symmetric(vertical: 30.0),
          child: ElevatedButton(
            onPressed: () {
              submitForm();
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 15.0),
              child: Text(
                'Submit',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      ),
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
