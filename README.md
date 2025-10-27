# Smart Rich Editor 📝

A lightweight, collapsible, and web-compatible rich text editor built on top of [`flutter_quill`](https://pub.dev/packages/flutter_quill).

## ✨ Features
- ✅ Collapsible toolbar (basic or full)
- ✅ Copy/Paste support with rich formatting
- ✅ Web clipboard compatibility
- ✅ Supports images (via embed builder)
- ✅ Customizable height, toolbar position, and more

## 🚀 Usage

```dart
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
```

## 📦 Dependencies
- `flutter_quill`
- `flutter_quill_extensions`

## 🧑‍💻 Author
**Rahul Sharma**  
[GitHub](https://github.com/rahulk3sharmadev)
