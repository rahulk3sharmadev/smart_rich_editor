import 'package:flutter/material.dart';
import 'package:smart_rich_editor/smart_rich_editor.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Smart Rich Editor Demo')),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RichTextEditorPage(
                    collapsibleToolbar: true,
                    editorHeight: 500,
                    toolbarAtBottom: true,
                  ),
                ),
              );
            },
            child: const Text('Open Rich Editor'),
          ),
        ),
      ),
    );
  }
}
