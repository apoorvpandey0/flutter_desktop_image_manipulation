import 'dart:developer';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_compression/image_compression.dart';

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
  PlatformFile? file;
  ImageFile? cfile;
  bool picked = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(onPressed: () async {
            await pickUpFile();
          }),
          FloatingActionButton(
              backgroundColor: Colors.green,
              onPressed: () async {
                await compressImage();
              }),
        ],
      ),
      body: Column(
        children: [
          file != null
              ? Column(
                  children: [
                    Image.memory(file!.bytes!),
                    // Text(file!.name),
                    Text((file!.size / 1024).toStringAsFixed(2) + " KB"),
                  ],
                )
              : Text("No file picked"),
          cfile != null
              ? Column(
                  children: [
                    Image.memory(cfile!.rawBytes),
                    Text(
                        (cfile!.sizeInBytes / 1024).toStringAsFixed(2) + " KB"),
                  ],
                )
              : Text("No file picked")
        ],
      ),
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
        file = result.files.single;
        picked = true;
      });
    } else {
      // User canceled the picker
    }
  }

  Future<void> compressImage() async {
    final input = ImageFile(
      rawBytes: file!.bytes!,
      filePath: file!.path!,
    );
    final va = await compressInQueue(ImageFileConfiguration(
        input: input,
        config: const Configuration(
          jpgQuality: 10,
        )));
    setState(() {
      cfile = va;
    });
  }
}
