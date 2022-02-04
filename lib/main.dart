import 'dart:io' as io;
import 'dart:developer';
import 'dart:ffi';
// import 'dart:html';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart' as f;
import 'package:flutter/material.dart';
import 'package:image_compression/image_compression.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return f.FluentApp(debugShowCheckedModeBanner: false, home: HomeScreen());
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
  TextEditingController _controller = TextEditingController(text: '50');
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
              backgroundColor: Colors.amber,
              onPressed: () async {
                await compressImage();
              }),
          FloatingActionButton(
              backgroundColor: Colors.green,
              onPressed: () async {
                await saveFiletoDesktop();
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
          f.TextFormBox(
            controller: _controller,
            keyboardType: TextInputType.number,
          ),
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

  Future saveFiletoDesktop() async {
    final saveLocation = await FilePicker.platform.saveFile(
        type: FileType.image,
        fileName: '${DateTime.now().millisecondsSinceEpoch}.jpg');
    print(saveLocation);
    final io.File file = io.File(saveLocation!);
    await file.writeAsBytes(cfile!.rawBytes);
  }

  Future<void> pickUpFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

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
        config: Configuration(
          jpgQuality: _controller.value.text.isNotEmpty
              ? int.parse(_controller.value.text)
              : 50,
        )));
    setState(() {
      cfile = va;
    });
  }
}
