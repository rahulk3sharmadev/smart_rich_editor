# Smart Rich Editor 📝

[![pub package](https://img.shields.io/pub/v/smart_rich_editor.svg)](https://pub.dev/packages/smart_rich_editor)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A lightweight, highly customizable, and production-ready rich text editor for Flutter, built on top of [`flutter_quill`](https://pub.dev/packages/flutter_quill). Designed with **web compatibility** and **mobile-first** principles, Smart Rich Editor provides a seamless editing experience across all platforms.

## ✨ Features

- 🎨 **Collapsible Toolbar** - Toggle between basic and full editing modes
- 📋 **Rich Text Copy/Paste** - Preserve formatting across clipboard operations
- 🌐 **Web Optimized** - Full clipboard API support for web platforms
- 🖼️ **Image Support** - Built-in image embedding capabilities
- ⚙️ **Highly Customizable** - Configure height, toolbar position, and appearance
- 📱 **Cross-Platform** - Works seamlessly on iOS, Android, Web, macOS, Windows, and Linux
- 🎯 **Zero Configuration** - Works out of the box with sensible defaults
- 🚀 **Lightweight** - Minimal dependencies and small bundle size

## 📸 Screenshots

| Mobile | Web | Tablet |
|--------|-----|--------|
| ![Mobile](https://raw.githubusercontent.com/rahulk3sharmadev/smart_rich_editor/main/screenshots/mobile.png) | ![Web](https://raw.githubusercontent.com/rahulk3sharmadev/smart_rich_editor/main/screenshots/web.png) | ![Tablet](https://raw.githubusercontent.com/rahulk3sharmadev/smart_rich_editor/main/screenshots/tablet.png) |

> *Add screenshots to `/screenshots` folder in your repository*

## 🚀 Getting Started

### Installation

Add `smart_rich_editor` to your `pubspec.yaml`:

```yaml
dependencies:
  smart_rich_editor: ^1.0.1
```

Then run:

```bash
flutter pub get
```

### Basic Usage

Import the package:

```dart
import 'package:smart_rich_editor/smart_rich_editor.dart';
```

Use the editor in your widget:

```dart
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
      title: 'Smart Rich Editor Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const EditorDemoPage(),
    );
  }
}

class EditorDemoPage extends StatelessWidget {
  const EditorDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Rich Editor Demo'),
        elevation: 2,
      ),
      body: Center(
        child: ElevatedButton.icon(
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
          icon: const Icon(Icons.edit),
          label: const Text('Open Rich Editor'),
        ),
      ),
    );
  }
}
```

## 📖 Advanced Usage

### Custom Configuration

```dart
RichTextEditorPage(
  // Toolbar Configuration
  collapsibleToolbar: true,        // Enable collapsible toolbar
  toolbarAtBottom: false,          // Position toolbar at top
  
  // Editor Configuration
  editorHeight: 400,               // Set custom height
  placeholder: 'Start typing...',   // Custom placeholder text
  
  // Styling
  backgroundColor: Colors.white,
  toolbarColor: Colors.grey[200],
)
```

### Retrieving Editor Content

```dart
class MyEditorPage extends StatefulWidget {
  const MyEditorPage({super.key});

  @override
  State<MyEditorPage> createState() => _MyEditorPageState();
}

class _MyEditorPageState extends State<MyEditorPage> {
  final QuillController _controller = QuillController.basic();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Editor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveContent,
          ),
        ],
      ),
      body: RichTextEditorPage(
        controller: _controller,
        collapsibleToolbar: true,
      ),
    );
  }

  void _saveContent() {
    final document = _controller.document.toDelta();
    final plainText = _controller.document.toPlainText();
    
    // Save document or plainText to your database
    print('Saved: $plainText');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

### Web-Specific Configuration

For web platform, ensure you have the following in your `index.html`:

```html
<head>
  <!-- Enable clipboard API -->
  <meta name="clipboard-read" content="self">
  <meta name="clipboard-write" content="self">
</head>
```

## 🎯 API Reference

### RichTextEditorPage Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `collapsibleToolbar` | `bool` | `false` | Enable toolbar collapse functionality |
| `editorHeight` | `double` | `300` | Height of the editor area |
| `toolbarAtBottom` | `bool` | `false` | Position toolbar at bottom |
| `controller` | `QuillController?` | `null` | Custom controller for advanced usage |
| `placeholder` | `String?` | `null` | Placeholder text when editor is empty |
| `readOnly` | `bool` | `false` | Make editor read-only |
| `autoFocus` | `bool` | `false` | Auto-focus editor on load |
| `backgroundColor` | `Color?` | `null` | Background color of the editor |
| `toolbarColor` | `Color?` | `null` | Background color of the toolbar |

## 🔧 Platform Support

| Platform | Support |
|----------|---------|
| Android  | ✅      |
| iOS      | ✅      |
| Web      | ✅      |
| macOS    | ✅      |
| Windows  | ✅      |
| Linux    | ✅      |

## 📦 Dependencies

This package depends on:

- [`flutter_quill`](https://pub.dev/packages/flutter_quill) - Core rich text editing functionality
- [`flutter_quill_extensions`](https://pub.dev/packages/flutter_quill_extensions) - Extended features and embeds

## 🐛 Troubleshooting

### Web Clipboard Issues

If copy/paste doesn't work on web, ensure:
1. You're using HTTPS (required for Clipboard API)
2. Required permissions are set in `index.html`
3. Browser supports Clipboard API (Chrome 63+, Firefox 53+, Safari 13.1+)

### Build Issues

If you encounter build errors, try:

```bash
flutter clean
flutter pub get
flutter pub upgrade
```

### Common Issues

**Issue**: Toolbar not showing  
**Solution**: Make sure `collapsibleToolbar` is set to `true` or check if toolbar height is properly configured.

**Issue**: Images not displaying  
**Solution**: Ensure you have `flutter_quill_extensions` properly configured and image embed builder is set up.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

Please make sure to update tests as appropriate and follow the existing code style.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🧑‍💻 Author

**Rahul Sharma**

- GitHub: [@rahulk3sharmadev](https://github.com/rahulk3sharmadev)
- Email: contact@example.com
- LinkedIn: [Rahul Sharma](https://linkedin.com/in/rahulk3sharma)

## 💖 Support

If you find this package helpful, please:

- ⭐ Star the repository on [GitHub](https://github.com/rahulk3sharmadev/smart_rich_editor)
- 👍 Like the package on [pub.dev](https://pub.dev/packages/smart_rich_editor)
- 🐛 Report bugs or request features via [Issues](https://github.com/rahulk3sharmadev/smart_rich_editor/issues)
- 💬 Join discussions in [Discussions](https://github.com/rahulk3sharmadev/smart_rich_editor/discussions)

## 📚 Additional Resources

- [Example App](example/)
- [API Documentation](https://pub.dev/documentation/smart_rich_editor/latest/)
- [Changelog](CHANGELOG.md)
- [Flutter Quill Documentation](https://github.com/singerdmx/flutter-quill)

## 🗺️ Roadmap

- [ ] Add markdown import/export
- [ ] Support for custom toolbar buttons
- [ ] Theme customization options
- [ ] Collaborative editing support
- [ ] Offline mode with auto-save
- [ ] Enhanced mobile keyboard handling
- [ ] Table support
- [ ] Code syntax highlighting

## 📈 Version History

See [CHANGELOG.md](CHANGELOG.md) for a complete version history.

## 🙏 Acknowledgments

- Built on top of the excellent [flutter_quill](https://pub.dev/packages/flutter_quill) package
- Thanks to all contributors and users of this package
- Inspired by modern web-based rich text editors

---

Made with ❤️ by Rahul Sharma
