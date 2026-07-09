import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/features/ai_chat/controller/ai_chat_controller.dart';

class MessageComposer extends StatefulWidget {
  const MessageComposer({super.key, required this.controller});

  final AiChatController controller;

  @override
  State<MessageComposer> createState() => _MessageComposerState();
}

class _MessageComposerState extends State<MessageComposer> {
  final FocusNode _focusNode = FocusNode();

  AiChatController get controller => widget.controller;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isDark = context.isDark;
    final fg = isDark ? Colors.white : palette.iconPrimary;

    return Row(
      children: [
        // "+" opens an adaptive popup menu (native glass on iOS 26+).
        AdaptivePopupMenuButton.icon<String>(
          icon: 'plus',
          tint: fg,
          size: 46,
          buttonStyle: PopupButtonStyle.glass,
          items: const [
            AdaptivePopupMenuItem(
              label: 'Camera',
              icon: 'camera',
              value: 'camera',
            ),
            AdaptivePopupMenuItem(
              label: 'Photo Library',
              icon: 'photo.on.rectangle',
              value: 'gallery',
            ),
            AdaptivePopupMenuItem(
              label: 'Deep Research',
              icon: 'doc.text.magnifyingglass',
              value: 'research',
            ),
            AdaptivePopupMenuItem(
              label: 'Interview Guide',
              icon: 'questionmark.circle',
              value: 'interview',
            ),
          ],
          onSelected: (index, entry) {
            switch (entry.value) {
              case 'camera':
                _pickImage(ImageSource.camera);
              case 'gallery':
                _pickImage(ImageSource.gallery);
              case 'research':
                controller.sendMessage(
                  'Help me do deep research for my job search.',
                );
              case 'interview':
                controller.sendMessage(
                  'Give me an interview preparation guide.',
                );
            }
          },
        ),
        const SizedBox(width: 14),
        // Message field on a real iOS 26 Liquid Glass surface (the same
        // `.glass()` effect used by the buttons/tab bar). The glass button is
        // the background; a transparent TextField is overlaid for input, since
        // the glass button ignores pointer events on its own child.
        Expanded(
          child: SizedBox(
            height: 46,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    Positioned.fill(
                      child: AdaptiveButton.child(
                        onPressed: _focusNode.requestFocus,
                        style: AdaptiveButtonStyle.glass,
                        minSize: Size(constraints.maxWidth, 46),
                        useSmoothRectangleBorder: false,
                        child: const SizedBox.shrink(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Center(
                        child: TextField(
                          focusNode: _focusNode,
                          controller: controller.messageController,
                          textInputAction: TextInputAction.send,
                          onSubmitted: controller.sendMessage,
                          maxLines: 1,
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontSize: 15,
                          ),
                          decoration: InputDecoration(
                            isCollapsed: true,
                            border: InputBorder.none,
                            hintText: 'Send a message...',
                            hintStyle: TextStyle(color: palette.textSecondary),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 14),
        AdaptiveButton.icon(
          onPressed: controller.sendMessage,
          icon: Icons.send_outlined,
          iconColor: fg,
          style: AdaptiveButtonStyle.glass,
          minSize: const Size(46, 46),
          useSmoothRectangleBorder: false,
        ),
      ],
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (file == null) return;
      // Send the image path as a message for now.
      controller.sendMessage('\u{1F4F7} Image attached: ${file.name}');
    } on Exception {
      Get.snackbar(
        'Error',
        'Could not access ${source == ImageSource.camera ? "camera" : "gallery"}.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    }
  }
}
