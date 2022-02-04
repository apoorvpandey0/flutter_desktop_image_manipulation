import 'dart:developer';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: HomeScreen());
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Uint8List file = Uint8List(0);
  bool picked = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: () async {
        await pickUpFile();
      }),
      body: picked ? Image.memory(file) : Text("No file picked"),
    );
  }

  Future<void> pickUpFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        withData: true,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'bmp']);

    if (result != null) {
      log(result.files.single.path.toString());
      setState(() {
        PlatformFile file = result.files.single;
        this.file = file.bytes!;
        picked = true;
      });
    } else {
      // User canceled the picker
    }
  }
}
