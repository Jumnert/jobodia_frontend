import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/app/routes/app_routes.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/core/widgets/quiet_glass_button.dart';
import 'package:jobodia_frontend/features/messaging/controller/messaging_controller.dart';
import 'package:jobodia_frontend/features/messaging/model/messaging_models.dart';

class PublicUserProfileScreen extends StatefulWidget {
  const PublicUserProfileScreen({super.key});

  @override
  State<PublicUserProfileScreen> createState() =>
      _PublicUserProfileScreenState();
}

class _PublicUserProfileScreenState extends State<PublicUserProfileScreen> {
  late final PublicUserModel user;
  bool _startingChat = false;

  MessagingController get messaging => Get.isRegistered<MessagingController>()
      ? Get.find<MessagingController>()
      : Get.put(MessagingController());

  @override
  void initState() {
    super.initState();
    user = Get.arguments as PublicUserModel;
  }

  Future<void> _messageUser() async {
    if (_startingChat) return;
    setState(() => _startingChat = true);
    try {
      final conversation = await messaging.startConversation(user);
      if (!mounted) return;
      unawaited(messaging.openConversation(conversation.id));
      Get.toNamed<void>(AppRoutes.conversationDetail, arguments: conversation);
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not start this conversation.')),
      );
    } finally {
      if (mounted) setState(() => _startingChat = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final top = MediaQuery.paddingOf(context).top;
    final initial = user.displayName.trim().isEmpty
        ? '?'
        : user.displayName.characters.first.toUpperCase();

    return Scaffold(
      backgroundColor: palette.scaffold,
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.fromLTRB(
              20,
              top + 82,
              20,
              MediaQuery.paddingOf(context).bottom + 28,
            ),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 58,
                  backgroundColor: palette.surfaceMuted,
                  backgroundImage: user.avatarUrl?.isNotEmpty == true
                      ? NetworkImage(user.avatarUrl!)
                      : null,
                  child: user.avatarUrl?.isNotEmpty == true
                      ? null
                      : Text(
                          initial,
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontSize: 38,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                user.displayName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '@${user.username} · ${user.role.toLowerCase()}',
                textAlign: TextAlign.center,
                style: TextStyle(color: palette.textSecondary),
              ),
              const SizedBox(height: 22),
              FButton(
                onPress: _startingChat ? null : _messageUser,
                prefix: _startingChat
                    ? const SizedBox.square(
                        dimension: 16,
                        child: FCircularProgress(),
                      )
                    : const Icon(FLucideIcons.messageCircle),
                child: const Text('Message'),
              ),
              if (user.bio?.trim().isNotEmpty == true ||
                  user.location?.trim().isNotEmpty == true) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: palette.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: palette.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (user.location?.trim().isNotEmpty == true)
                        Row(
                          children: [
                            const Icon(FLucideIcons.mapPin, size: 18),
                            const SizedBox(width: 8),
                            Expanded(child: Text(user.location!)),
                          ],
                        ),
                      if (user.bio?.trim().isNotEmpty == true) ...[
                        const SizedBox(height: 16),
                        Text(
                          user.bio!,
                          style: TextStyle(
                            color: palette.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
          Positioned(
            top: top + 14,
            left: 20,
            child: QuietGlassBackButton(onPressed: Get.back),
          ),
        ],
      ),
    );
  }
}
