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
  List<String> memeTemplates = [];

  @override
  void initState() {
    super.initState();
    widget.future.then((value) => {
          setState(() {
            _chosenTemplate = value[0].name;
            memeTemplates = value.map((e) => e.name).toList();
          })
        });
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
            items: memeTemplates.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            hint: const Text(
              "Please choose a meme template",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
            onChanged: (String? value) {
              setState(() {
                _chosenTemplate = value!;
              });
            },
          ),
        ],
      ),
    );
  }
}
