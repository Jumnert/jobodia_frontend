import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/features/ai_chat/controller/ai_chat_controller.dart';
import 'package:jobodia_frontend/features/ai_chat/model/chat_message_model.dart';

class AiChatScreen extends GetView<AiChatController> {
  const AiChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      endDrawer: _ChatHistoryDrawer(controller: controller),
      body: SafeArea(
        child: Column(
          children: [
            const _ChatHeader(),
            Expanded(
              child: Obx(
                () => controller.hasMessages
                    ? _ConversationList(messages: controller.messages)
                    : _EmptyChatState(controller: controller),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(14, 8, 14, bottomPadding * 0.05),
              child: _MessageComposer(controller: controller),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 84,
      child: Row(
        children: [
          IconButton(
            onPressed: Get.back,
            icon: const Icon(Icons.chevron_left_rounded, size: 30),
          ),
          const Expanded(
            child: Text(
              'Jobodia Ai',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
          ),
          IconButton(
            onPressed: () => Scaffold.of(context).openEndDrawer(),
            icon: const Icon(Icons.more_horiz_rounded),
          ),
        ],
      ),
    );
  }
}

class _ChatHistoryDrawer extends StatelessWidget {
  const _ChatHistoryDrawer({required this.controller});

  final AiChatController controller;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Chat history',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              Container(
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F3F3),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded, color: Color(0xFF7A7A7A)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: controller.historySearchController,
                        onChanged: controller.updateHistorySearch,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Search chats',
                          hintStyle: TextStyle(
                            color: Color(0xFF7A7A7A),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _NewChatTile(
                onTap: () {
                  controller.startNewChat();
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 14),
              Expanded(
                child: Obx(() {
                  final history = controller.filteredChatHistory;

                  if (history.isEmpty) {
                    return const Center(
                      child: Text(
                        'No chats found.',
                        style: TextStyle(color: Color(0xFF7A7A7A)),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: history.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 4),
                    itemBuilder: (context, index) => _HistoryTile(
                      title: history[index],
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NewChatTile extends StatelessWidget {
  const _NewChatTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: const SizedBox(
        height: 42,
        child: Row(
          children: [
            SizedBox(width: 4),
            Icon(Icons.add_comment_outlined, color: Color(0xFF5F5F5F)),
            SizedBox(width: 12),
            Text(
              'New chat',
              style: TextStyle(
                color: Color(0xFF5F5F5F),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: SizedBox(
        height: 38,
        child: Row(
          children: [
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF777777),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}

class _EmptyChatState extends StatelessWidget {
  const _EmptyChatState({required this.controller});

  final AiChatController controller;

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.article_outlined, controller.suggestions[0]),
      (Icons.work_outline_rounded, controller.suggestions[1]),
      (Icons.psychology_alt_outlined, controller.suggestions[2]),
      (Icons.map_outlined, controller.suggestions[3]),
      (Icons.travel_explore_rounded, controller.suggestions[4]),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 20, 14, 12),
      children: [
        const SizedBox(height: 12),
        const Center(child: _BotAvatar(size: 96)),
        const SizedBox(height: 42),
        const Text(
          'Hi, Han!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF303036),
            fontSize: 25,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'How can I help you today?',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF303036), fontSize: 18),
        ),
        const SizedBox(height: 64),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _SuggestionTile(
              icon: item.$1,
              label: item.$2,
              onTap: () => controller.sendMessage(item.$2),
            ),
          ),
        ),
      ],
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: SizedBox(
          height: 54,
          child: Row(
            children: [
              const SizedBox(width: 20),
              Icon(icon, size: 27, color: Colors.black),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConversationList extends StatelessWidget {
  const _ConversationList({required this.messages});

  final List<ChatMessageModel> messages;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(18, 42, 18, 16),
      itemCount: messages.length,
      itemBuilder: (context, index) => _MessageBubble(message: messages[index]),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessageModel message;

  bool get isUser => message.sender == ChatMessageSender.user;

  @override
  Widget build(BuildContext context) {
    final bubble = Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.56,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        message.text,
        style: const TextStyle(color: Colors.black, fontSize: 13, height: 1.18),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: isUser
          ? Align(alignment: Alignment.centerRight, child: bubble)
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 1),
                  child: _BotAvatar(size: 50),
                ),
                const SizedBox(width: 8),
                bubble,
              ],
            ),
    );
  }
}

class _MessageComposer extends StatelessWidget {
  const _MessageComposer({required this.controller});

  final AiChatController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _RoundIconButton(
          icon: Icons.add_rounded,
          onTap: () => _showAttachmentMenu(context),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.messageController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Send a message...',
                      hintStyle: TextStyle(color: Colors.black, fontSize: 13),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: controller.sendMessage,
                  ),
                ),
                const Icon(Icons.mic_none_rounded, size: 24),
              ],
            ),
          ),
        ),
        const SizedBox(width: 14),
        _RoundIconButton(
          icon: Icons.send_outlined,
          onTap: controller.sendMessage,
        ),
      ],
    );
  }

  void _showAttachmentMenu(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => Align(
        alignment: Alignment.bottomLeft,
        child: SafeArea(
          minimum: const EdgeInsets.only(left: 14, bottom: 58),
          child: CupertinoPopupSurface(
            isSurfacePainted: true,
            child: SizedBox(
              width: 245,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CupertinoContextMenuAction(
                    trailingIcon: CupertinoIcons.camera,
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Camera'),
                  ),
                  CupertinoContextMenuAction(
                    trailingIcon: CupertinoIcons.photo_on_rectangle,
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Photo Library'),
                  ),
                  CupertinoContextMenuAction(
                    trailingIcon: CupertinoIcons.doc,
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('File'),
                  ),
                  CupertinoContextMenuAction(
                    trailingIcon: CupertinoIcons.book,
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('NotebookLM'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 46,
          height: 46,
          child: Icon(icon, color: Colors.black, size: 26),
        ),
      ),
    );
  }
}

class _BotAvatar extends StatelessWidget {
  const _BotAvatar({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: size * 0.62,
          height: size * 0.46,
          decoration: BoxDecoration(
            color: const Color(0xFF15161B),
            borderRadius: BorderRadius.circular(size * 0.18),
            border: Border.all(color: Colors.white, width: size * 0.025),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: size * 0.18,
                child: _BotEye(size: size * 0.055),
              ),
              Positioned(
                right: size * 0.18,
                child: _BotEye(size: size * 0.055),
              ),
              Positioned(
                bottom: size * 0.11,
                child: Container(
                  width: size * 0.16,
                  height: size * 0.035,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BotEye extends StatelessWidget {
  const _BotEye({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }
}
