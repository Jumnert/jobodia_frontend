import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/features/interview/data/flashcard_data.dart';

/// Lists the flashcard categories (HTML/CSS/JS), each opening a swipeable deck.
class FlashcardsScreen extends StatelessWidget {
  const FlashcardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? const Color(0xFF101214)
        : const Color(0xFFF5F6F8);
    final foregroundColor = isDark ? Colors.white : Colors.black;
    final mutedColor = isDark
        ? const Color(0xFFA5ABB1)
        : const Color(0xFF6F7378);
    final cardColor = isDark ? const Color(0xFF1A1D20) : Colors.white;
    final borderColor = isDark
        ? const Color(0xFF2A2E33)
        : const Color(0xFFEDEDED);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: Get.back,
                  icon: Icon(
                    Icons.chevron_left_rounded,
                    size: 30,
                    color: foregroundColor,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Flash Cards',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: foregroundColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                children: [
                  Text(
                    'Pick a topic to start studying. Tap a card to flip it, '
                    'swipe to move to the next one.',
                    style: TextStyle(
                      color: mutedColor,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (final category in flashcardCategories) ...[
                    _CategoryTile(
                      category: category,
                      cardColor: cardColor,
                      borderColor: borderColor,
                      foregroundColor: foregroundColor,
                      mutedColor: mutedColor,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              FlashcardDeckScreen(category: category),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.cardColor,
    required this.borderColor,
    required this.foregroundColor,
    required this.mutedColor,
    required this.onTap,
  });

  final FlashcardCategory category;
  final Color cardColor;
  final Color borderColor;
  final Color foregroundColor;
  final Color mutedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
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
                      color: foregroundColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${category.cards.length} cards',
                    style: TextStyle(color: mutedColor, fontSize: 12.5),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: mutedColor, size: 22),
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
  int _index = 0;
  double _dragDx = 0;

  List<Flashcard> get _cards => widget.category.cards;

  void _advance() {
    setState(() {
      _dragDx = 0;
      _index = _index + 1 < _cards.length ? _index + 1 : 0;
    });
  }

  void _reset() => setState(() {
    _index = 0;
    _dragDx = 0;
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? const Color(0xFF101214)
        : const Color(0xFFF5F6F8);
    final foregroundColor = isDark ? Colors.white : Colors.black;
    final mutedColor = isDark
        ? const Color(0xFFA5ABB1)
        : const Color(0xFF6F7378);
    final cardColor = isDark ? const Color(0xFF1A1D20) : Colors.white;
    final accent = widget.category.accent;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: Get.back,
                  icon: Icon(
                    Icons.chevron_left_rounded,
                    size: 30,
                    color: foregroundColor,
                  ),
                ),
                Expanded(
                  child: Text(
                    widget.category.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: foregroundColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _reset,
                  tooltip: 'Restart deck',
                  icon: Icon(Icons.refresh_rounded, color: foregroundColor),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${_index + 1} / ${_cards.length}',
              style: TextStyle(
                color: mutedColor,
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
                  cardColor: cardColor,
                  foregroundColor: foregroundColor,
                  mutedColor: mutedColor,
                  accent: accent,
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
                style: TextStyle(color: mutedColor, fontSize: 12),
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
    required this.cardColor,
    required this.foregroundColor,
    required this.mutedColor,
    required this.accent,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  final List<Flashcard> cards;
  final int index;
  final double dragDx;
  final Color cardColor;
  final Color foregroundColor;
  final Color mutedColor;
  final Color accent;
  final ValueChanged<double> onDragUpdate;
  final VoidCallback onDragEnd;

  @override
  Widget build(BuildContext context) {
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
                cardColor: cardColor,
                foregroundColor: foregroundColor,
                mutedColor: mutedColor,
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
              child: _CardFace(
                key: ValueKey(index),
                card: cards[index],
                cardColor: cardColor,
                foregroundColor: foregroundColor,
                mutedColor: mutedColor,
                accent: accent,
                interactive: true,
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
    required this.cardColor,
    required this.foregroundColor,
    required this.mutedColor,
    required this.accent,
    required this.interactive,
  });

  final Flashcard card;
  final Color cardColor;
  final Color foregroundColor;
  final Color mutedColor;
  final Color accent;
  final bool interactive;

  @override
  State<_CardFace> createState() => _CardFaceState();
}

class _CardFaceState extends State<_CardFace> {
  bool _showBack = false;

  @override
  Widget build(BuildContext context) {
    final card = widget.card;
    final content = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: widget.cardColor,
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
                    ? _BackBody(
                        key: const ValueKey('back'),
                        card: card,
                        foregroundColor: widget.foregroundColor,
                      )
                    : Text(
                        card.front,
                        key: const ValueKey('front'),
                        style: TextStyle(
                          color: widget.foregroundColor,
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
  const _BackBody({
    super.key,
    required this.card,
    required this.foregroundColor,
  });

  final Flashcard card;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    if (card.isCode) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: foregroundColor.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          card.back,
          style: TextStyle(
            color: foregroundColor,
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
        color: foregroundColor,
        fontSize: 16,
        height: 1.45,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
