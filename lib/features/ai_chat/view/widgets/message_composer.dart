import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/features/ai_chat/controller/ai_chat_controller.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

class MessageComposer extends StatelessWidget {
  const MessageComposer({super.key, required this.controller});

  final AiChatController controller;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(
      children: [
        GlassIconButton(
          icon: Icon(Icons.add_rounded, color: palette.iconPrimary, size: 26),
          onPressed: () => _showAttachmentMenu(context),
          size: 46,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: GlassTextField(
            controller: controller.messageController,
            placeholder: 'Send a message...',
            textInputAction: TextInputAction.send,
            onSubmitted: controller.sendMessage,
            shape: const LiquidRoundedSuperellipse(borderRadius: 999),
          ),
        ),
        const SizedBox(width: 14),
        GlassIconButton(
          icon: Icon(Icons.send_outlined, color: palette.iconPrimary, size: 24),
          onPressed: controller.sendMessage,
          size: 46,
        ),
      ],
    );
  }

  void _showAttachmentMenu(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => Align(
        alignment: Alignment.bottomLeft,
        child: SafeArea(
          minimum: const EdgeInsets.only(left: 14, bottom: 58),
          child: CupertinoPopupSurface(
            isSurfacePainted: true,
            child: SizedBox(
              width: 220,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CupertinoContextMenuAction(
                    trailingIcon: CupertinoIcons.camera,
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _pickImage(context, ImageSource.camera);
                    },
                    child: const Text('Camera'),
                  ),
                  CupertinoContextMenuAction(
                    trailingIcon: CupertinoIcons.photo_on_rectangle,
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _pickImage(context, ImageSource.gallery);
                    },
                    child: const Text('Photo Library'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
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
