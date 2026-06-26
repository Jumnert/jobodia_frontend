// ignore_for_file: deprecated_member_use, avoid_print, curly_braces_in_flow_control_structures, unused_import, unnecessary_underscores, unused_field, unused_local_variable, use_build_context_synchronously, duplicate_ignore
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/features/interview/controller/flashcards_controller.dart';
import 'package:jobodia_frontend/features/interview/data/flashcard_data.dart';

/// Lists the flashcard categories (HTML/CSS/JS), each opening a swipeable deck.
class FlashcardsScreen extends StatelessWidget {
  const FlashcardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.isRegistered<FlashcardsController>()
        ? Get.find<FlashcardsController>()
        : Get.put(FlashcardsController());
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.scaffold,
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: Get.back,
                  tooltip: 'Back',
                  icon: Icon(
                    Icons.chevron_left_rounded,
                    size: 30,
                    color: palette.iconPrimary,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Flash Cards',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                backgroundColor: palette.surface,
                onRefresh: () async {
                  await Future<void>.delayed(const Duration(milliseconds: 600));
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                  children: [
                    Text(
                      'Pick a topic to start studying. Tap a card to flip it, '
                      'swipe to move to the next one.',
                      style: TextStyle(
                        color: palette.textSecondary,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Obx(() {
                      if (ctrl.isLoadingData.value) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final widgets = <Widget>[];

                      if (ctrl.bookmarkedKeys.isNotEmpty) {
                        final bookmarkedCards = flashcardCategories
                            .expand(
                              (c) => c.cards
                                  .asMap()
                                  .entries
                                  .where(
                                    (e) => ctrl.isBookmarked(c.name, e.key),
                                  )
                                  .map((e) => e.value),
                            )
                            .toList();

                        widgets.add(
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _CategoryTile(
                              category: FlashcardCategory(
                                name: 'Bookmarks',
                                icon: Icons.bookmark_rounded,
                                accent: const Color(0xFF6C5CE7),
                                cards: bookmarkedCards,
                              ),
                              onTap: () {
                                Get.to<void>(
                                  () => FlashcardDeckScreen(
                                    category: FlashcardCategory(
                                      name: 'Bookmarks',
                                      icon: Icons.bookmark_rounded,
                                      accent: const Color(0xFF6C5CE7),
                                      cards: bookmarkedCards,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      }

                      for (final category in flashcardCategories) {
                        widgets.add(
                          _CategoryTile(
                            category: category,
                            onTap: () => Get.to<void>(
                              () => FlashcardDeckScreen(category: category),
                            ),
                          ),
                        );
                        widgets.add(const SizedBox(height: 12));
                      }

                      return Column(children: widgets);
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category, required this.onTap});

  final FlashcardCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: palette.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: category.accent.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(category.icon, color: category.accent, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (category.name != 'Bookmarks') ...[
                    Obx(() {
                      final ctrl = Get.find<FlashcardsController>();
                      final studied = ctrl.getLastIndex(category.name) + 1;
                      return Text(
                        '$studied / ${category.cards.length} cards studied',
                        style: TextStyle(
                          color: palette.textSecondary,
                          fontSize: 12.5,
                        ),
                      );
                    }),
                  ] else ...[
                    Text(
                      'Your saved cards',
                      style: TextStyle(
                        color: palette.textSecondary,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: palette.iconMuted,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

/// Swipeable, tap-to-flip deck for one category.
class FlashcardDeckScreen extends StatefulWidget {
  const FlashcardDeckScreen({super.key, required this.category});

  final FlashcardCategory category;

  @override
  State<FlashcardDeckScreen> createState() => _FlashcardDeckScreenState();
}

class _FlashcardDeckScreenState extends State<FlashcardDeckScreen> {
  late final FlashcardsController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.isRegistered<FlashcardsController>()
        ? Get.find<FlashcardsController>()
        : Get.put(FlashcardsController());
    _index = _ctrl.getLastIndex(widget.category.name);
    if (_index >= _cards.length) _index = 0;
  }

  int _index = 0;
  double _dragDx = 0;

  List<Flashcard> get _cards => widget.category.cards;

  void _advance() {
    final ctrl = Get.find<FlashcardsController>();
    setState(() {
      _dragDx = 0;
      _index = _index + 1 < _cards.length ? _index + 1 : 0;
    });
    ctrl.recordProgress(widget.category.name, _index);
  }

  void _reset() => setState(() {
    _index = 0;
    _dragDx = 0;
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final accent = widget.category.accent;

    return Scaffold(
      backgroundColor: palette.scaffold,
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: Get.back,
                  tooltip: 'Back',
                  icon: Icon(
                    Icons.chevron_left_rounded,
                    size: 30,
                    color: palette.iconPrimary,
                  ),
                ),
                Expanded(
                  child: Text(
                    widget.category.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _reset,
                  tooltip: 'Restart deck',
                  icon: Icon(Icons.refresh_rounded, color: palette.iconPrimary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${_index + 1} / ${_cards.length}',
              style: TextStyle(
                color: palette.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
                child: _DeckStack(
                  cards: _cards,
                  index: _index,
                  dragDx: _dragDx,
                  accent: accent,
                  category: widget.category.name,
                  onDragUpdate: (dx) => setState(() => _dragDx += dx),
                  onDragEnd: () {
                    if (_dragDx.abs() > 110) {
                      _advance();
                    } else {
                      setState(() => _dragDx = 0);
                    }
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: Text(
                'Tap card to flip · swipe to continue',
                textAlign: TextAlign.center,
                style: TextStyle(color: palette.textSecondary, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeckStack extends StatelessWidget {
  const _DeckStack({
    required this.cards,
    required this.index,
    required this.dragDx,
    required this.accent,
    required this.category,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  final List<Flashcard> cards;
  final int index;
  final double dragDx;
  final Color accent;
  final String category;
  final ValueChanged<double> onDragUpdate;
  final VoidCallback onDragEnd;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final hasNext = index + 1 < cards.length;
    return Stack(
      alignment: Alignment.center,
      children: [
        if (hasNext)
          Transform.translate(
            offset: const Offset(0, 14),
            child: Transform.scale(
              scale: 0.94,
              child: _CardFace(
                card: cards[index + 1],
                accent: accent,
                interactive: false,
              ),
            ),
          ),
        GestureDetector(
          onHorizontalDragUpdate: (d) => onDragUpdate(d.delta.dx),
          onHorizontalDragEnd: (_) => onDragEnd(),
          child: Transform.translate(
            offset: Offset(dragDx, 0),
            child: Transform.rotate(
              angle: dragDx / 1400,
              child: Stack(
                children: [
                  _CardFace(
                    key: ValueKey(index),
                    card: cards[index],
                    accent: accent,
                    interactive: true,
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Obx(() {
                      final ctrl = Get.find<FlashcardsController>();
                      return GestureDetector(
                        onTap: () {
                          unawaited(HapticFeedback.lightImpact());
                          ctrl.toggleBookmark(category, index);
                        },
                        child: Icon(
                          ctrl.isBookmarked(category, index)
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          color: Colors.white,
                          size: 28,
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A single flippable card face. Manages its own front/back flip state.
class _CardFace extends StatefulWidget {
  const _CardFace({
    super.key,
    required this.card,
    required this.accent,
    required this.interactive,
  });

  final Flashcard card;
  final Color accent;
  final bool interactive;

  @override
  State<_CardFace> createState() => _CardFaceState();
}

class _CardFaceState extends State<_CardFace> {
  bool _showBack = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final card = widget.card;
    final content = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: widget.accent.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _showBack ? 'ANSWER' : 'CONCEPT',
            style: TextStyle(
              color: widget.accent,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: SingleChildScrollView(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: _showBack
                    ? _BackBody(key: const ValueKey('back'), card: card)
                    : Text(
                        card.front,
                        key: const ValueKey('front'),
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontSize: 20,
                          height: 1.35,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 320, maxHeight: 460),
      child: widget.interactive
          ? GestureDetector(
              onTap: () => setState(() => _showBack = !_showBack),
              child: content,
            )
          : content,
    );
  }
}

class _BackBody extends StatelessWidget {
  const _BackBody({super.key, required this.card});

  final Flashcard card;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    if (card.isCode) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: palette.surfaceMuted,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          card.back,
          style: TextStyle(
            color: palette.textPrimary,
            fontSize: 14,
            height: 1.45,
            fontFamily: 'monospace',
          ),
        ),
      );
    }
    return Text(
      card.back,
      style: TextStyle(
        color: palette.textPrimary,
        fontSize: 16,
        height: 1.45,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
