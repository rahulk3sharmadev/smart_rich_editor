// Imports
import 'dart:convert';
import 'dart:html' as html; // For Web clipboard
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';

/// ✅ Safe JSON encode/decode for clipboard
String safeJsonEncode(Object data) {
  return jsonEncode(
    data,
  ).replaceAll('\n', '\\n').replaceAll('\r', '\\r').replaceAll('\t', '\\t');
}

dynamic safeJsonDecode(String jsonStr) {
  try {
    return jsonDecode(jsonStr);
  } catch (e) {
    debugPrint("Invalid JSON decode: $e");
    return [];
  }
}

class RichTextEditorPage extends StatefulWidget {
  final bool showToolbar;
  final bool toolbarAtBottom;
  final bool collapsibleToolbar;
  final double? toolbarHeight;
  final double? toolbarWidth;
  final double? editorHeight;
  final double? editorWidth;
  final bool showBottomSection;
  final String hintText;
  final QuillController? controller;

  const RichTextEditorPage({
    Key? key,
    this.showToolbar = true,
    this.toolbarAtBottom = false,
    this.collapsibleToolbar = true,
    this.toolbarHeight,
    this.toolbarWidth,
    this.editorHeight,
    this.editorWidth,
    this.showBottomSection = true,
    this.hintText = "Start typing here...",
    this.controller,
  }) : super(key: key);

  @override
  State<RichTextEditorPage> createState() => _RichTextEditorPageState();
}

class _RichTextEditorPageState extends State<RichTextEditorPage> {
  late QuillController _controller;
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  Delta? _richClipboard;
  bool _toolbarCollapsed = true;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? QuillController.basic();
    if (kIsWeb) _registerWebShortcuts();
  }

  void _registerWebShortcuts() {
    html.window.onKeyDown.listen((html.KeyboardEvent e) {
      final bool isCtrlOrMeta = e.ctrlKey || e.metaKey;
      if (isCtrlOrMeta && e.key?.toLowerCase() == 'c') {
        e.preventDefault();
        _handleCopy();
      }
      if (isCtrlOrMeta && e.key?.toLowerCase() == 'v') {
        e.preventDefault();
        _handlePaste();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// ✅ Copy handler
  Future<void> _handleCopy() async {
    final selection = _controller.selection;
    if (selection.isCollapsed) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No selection to copy')));
      return;
    }

    try {
      final docDelta = _controller.document.toDelta();
      final selectedDelta = docDelta.slice(selection.start, selection.end);
      _richClipboard = selectedDelta;

      final plainText = _controller.document.getPlainText(
        selection.start,
        selection.end - selection.start,
      );
      await Clipboard.setData(ClipboardData(text: plainText));

      if (kIsWeb) {
        final jsonStr = safeJsonEncode(selectedDelta.toJson());
        await html.window.navigator.clipboard?.writeText(jsonStr);
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Copied rich text!')));
    } catch (e) {
      debugPrint('Copy error: $e');
    }
  }

  /// ✅ Paste handler
  void _handlePaste() {
    if (_richClipboard == null || _richClipboard!.isEmpty) {
      _handlePlainTextPaste();
      return;
    }

    try {
      final selection = _controller.selection;
      if (!selection.isValid) return;

      _controller.replaceText(
        selection.start,
        selection.end - selection.start,
        _richClipboard!,
        TextSelection.collapsed(
          offset: selection.start + _richClipboard!.length,
        ),
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pasted with formatting!')));
    } catch (e) {
      debugPrint('Paste error: $e');
      _handlePlainTextPaste();
    }
  }

  Future<void> _handlePlainTextPaste() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      if (data?.text == null) return;
      final selection = _controller.selection;
      _controller.replaceText(
        selection.start,
        selection.end - selection.start,
        data!.text!,
        TextSelection.collapsed(offset: selection.start + data.text!.length),
      );
    } catch (e) {
      debugPrint('Plain paste failed: $e');
    }
  }

  /// ✅ Collapsible toolbar builder
  Widget _buildToolbar() {
    if (!widget.showToolbar) return const SizedBox.shrink();

    // --- Collapsed Toolbar (Basic tools only) ---
    final collapsedToolbar = QuillSimpleToolbar(
      controller: _controller,
      config: QuillSimpleToolbarConfig(
        showAlignmentButtons: true,
        showBoldButton: true,
        showItalicButton: true,
        showUnderLineButton: true,
        showColorButton: true,
        showBackgroundColorButton: false,
        showListBullets: true,
        showListNumbers: true,
        showUndo: false,
        showRedo: false,
        showLink: false,
        showCodeBlock: false,
        showInlineCode: false,
        // showImageButton: false,
        // showVideoButton: false,
        showQuote: false,
        showIndent: false,
        showDirection: false,
        showHeaderStyle: false,
        showFontFamily: false,
        showFontSize: false,
        showDividers: false,


        // embedButtons: FlutterQuillEmbeds.toolbarButtons(
        //   imageButtonOptions: QuillToolbarImageButtonOptions(
        //     iconData: Icons.image,
        //     imageButtonConfig: QuillToolbarImageConfig(
        //       onImageInsertCallback: (image, controller) async {
        //         final offset = controller.selection.baseOffset;
        //
        //         // Encode width/height inside a JSON string
        //         final embedData = jsonEncode({
        //           'source': image,
        //           'width': 200,
        //           'height': 200,
        //         });
        //
        //         controller.replaceText(
        //           offset,
        //           0,
        //           BlockEmbed.image(embedData),
        //           TextSelection.collapsed(offset: offset + 1),
        //         );
        //
        //         return null;
        //       },
        //
        //     ),
        //   ),
        // ),
      ),
    );

    // --- Expanded Toolbar (All tools visible) ---
    final expandedToolbar = QuillSimpleToolbar(
      controller: _controller,
      config: const QuillSimpleToolbarConfig(),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          color: Colors.grey.shade300,
          child: InkWell(
            onTap: () => setState(() => _toolbarCollapsed = !_toolbarCollapsed),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _toolbarCollapsed ? "Expand Toolbar" : "Collapse Toolbar",
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Icon(
                    _toolbarCollapsed
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_up,
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: collapsedToolbar,
          secondChild: expandedToolbar,
          crossFadeState: _toolbarCollapsed
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          duration: const Duration(milliseconds: 250),
        ),
      ],
    );
  }

  /// ✅ Rich editor
  Widget _buildEditor() {
    return Container(
      width: widget.editorWidth ?? double.infinity,
      height: widget.editorHeight ?? 350,
      padding: const EdgeInsets.all(12),
      child: QuillEditor(
        controller: _controller,
        focusNode: _focusNode,
        scrollController: _scrollController,
        config: QuillEditorConfig(
          placeholder: widget.hintText,
          scrollable: true,
          expands: false,
          maxHeight: widget.editorHeight,
          // embedBuilders: [
          //   // Use default image/video embeds first
          //   ...FlutterQuillEmbeds.editorWebBuilders(),
          //
          //   // Custom fixed-height image renderer
          //   CustomImageEmbedBuilder(),
          // ],


        ),
      ),
    );
  }

  /// ✅ Bottom buttons (Copy / Paste)
  Widget _buildBottomSection() {
    if (!widget.showBottomSection) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.grey[50],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _handleCopy,
                icon: const Icon(Icons.copy),
                label: const Text('Copy'),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _handlePaste,
                icon: const Icon(Icons.paste),
                label: const Text('Paste'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final toolbar = _buildToolbar();
    final editor = _buildEditor();
    final bottom = _buildBottomSection();

    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(13, 0, 0, 0),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: widget.toolbarAtBottom
              ? [editor, bottom, toolbar]
              : [toolbar, editor, bottom],
        ),
      ),
    );
  }
}



class CustomImageEmbedBuilder implements EmbedBuilder {
  @override
  String get key => 'image';

  // some versions expect `bool get expanded`
  @override
  bool get expanded => false;

  // Build the widget (called by the editor)
  // The EmbedContext parameter exists on many versions; we implement it if available.
  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final String imageUrl = embedContext.node.value.data?.toString() ?? '';

    // If embedContext provides `readOnly` / `inline` etc, it's fine — we only need node
    return _buildFixedImage(imageUrl);
  }

  // Some flutter_quill versions use a different signature for build (without EmbedContext).
  // Keep a fallback build that might be called by older/newer versions (no-op forwarding).
  // If your version doesn't expect this, it will be ignored.
  Widget buildFallback(BuildContext context, Embed node) {
    final String imageUrl = node.value.data?.toString() ?? '';
    return ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 200),child: _buildFixedImage(imageUrl));
  }

  Widget _buildFixedImage(String imageUrl) {
    final imageWidget = imageUrl.startsWith('http')
        ? Image.network(
      imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: 100, // still needed for BoxFit
      errorBuilder: (context, error, stack) => Container(
        color: const Color(0xFFEFEFEF),
        alignment: Alignment.center,
        child: const Icon(Icons.broken_image, size: 40),
      ),
    )
        : Image.asset(
      imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: 100,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        width: double.infinity,
        height: 100, // ✅ Forces exact height inside editor
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: imageWidget,
        ),
      ),
    );
  }


  // Convert embed to plain text for clipboard/export
  @override
  String toPlainText(Embed node) {
    return '[Image:${node.value.data}]';
  }

  // Many versions expect `WidgetSpan Function(Widget child)` — implement that.
  // We return a WidgetSpan wrapping the child (the editor will supply the child widget).
  @override
  WidgetSpan buildWidgetSpan(Widget child) {
    return WidgetSpan(child: child);
  }
}



