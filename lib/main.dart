import 'dart:io';
import 'dart:ui';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  final GlobalKey _globalKey = GlobalKey();

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  Future<void> _captureAndSave() async {
    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage();
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final String? directoryPath = await getDirectoryPath();
      if (directoryPath == null) {
        // Operation was canceled by the user.
        return;
      } else {
        print('Directory path: $directoryPath');
        final file = File('$directoryPath/qr_image.png');
        await file.writeAsBytes(pngBytes);
        print('File saved to ${file.path}');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _captureAndSave2() async {
    try {
      final String svgContent = _generateSvgContent();
      final directoryPath = await getSaveLocation();
      if (directoryPath == null) {
        // Operation was canceled by the user.
        return;
      } else {
        print('Directory path: $directoryPath');
        final file = File('$directoryPath/qr_image.svg');
        await file.writeAsString(svgContent);
        print('File saved to ${file.path}');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  String _generateSvgContent() {
    // Generate SVG content for the widget
    return '''
<svg width="200" height="200" xmlns="http://www.w3.org/2000/svg">
  <rect width="200" height="200" fill="white"/>
  <text x="50%" y="50%" font-size="24" text-anchor="middle" fill="black" dy=".3em">$_counter</text>
</svg>
    ''';
  }

  Future<void> _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }

  Future<void> _pasteFromClipboard() async {
    ClipboardData? clipboardData = await Clipboard.getData('text/plain');
    if (clipboardData != null) {
      print('Clipboard data: ${clipboardData.text}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            RepaintBoundary(
              key: _globalKey,
              child: QrImageView(
                data: '$_counter',
                version: QrVersions.auto,
                size: 200.0,
              ),
            ),
            ElevatedButton(
              onPressed: () => _copyToClipboard('$_counter'),
              child: Text('Copy to Clipboard'),
            ),
            ElevatedButton(
              onPressed: _pasteFromClipboard,
              child: Text('Paste from Clipboard'),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _incrementCounter,
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _captureAndSave,
            tooltip: 'Save',
            child: const Icon(Icons.save),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _captureAndSave2,
            tooltip: 'Save2',
            child: const Icon(Icons.save_as),
          ),
        ],
      ),
    );
  }
}
