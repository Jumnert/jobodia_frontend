import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// One technical interview question with a model answer the user can reveal.
class _InterviewQuestion {
  const _InterviewQuestion({required this.prompt, required this.modelAnswer});

  final String prompt;
  final String modelAnswer;
}

const _questions = <_InterviewQuestion>[
  _InterviewQuestion(
    prompt:
        'Walk me through what happens when you type a URL into the '
        'browser and press Enter.',
    modelAnswer:
        'DNS resolves the domain to an IP, a TCP (and TLS) '
        'connection is established, the browser sends an HTTP request, the '
        'server responds, then the browser parses HTML, builds the DOM/CSSOM, '
        'runs JS, and paints the page.',
  ),
  _InterviewQuestion(
    prompt: 'How would you design a URL shortener like bit.ly?',
    modelAnswer:
        'Generate a short unique key (base62 of an ID or a hash), '
        'store key→URL in a fast key-value store, redirect with 301/302 on '
        'lookup, and add caching plus analytics. Discuss collisions, scale, '
        'and read-heavy traffic.',
  ),
  _InterviewQuestion(
    prompt: 'What is the difference between a process and a thread?',
    modelAnswer:
        'A process has its own isolated memory space; threads share '
        'the memory of their parent process. Threads are lighter to create '
        'and switch between but require synchronization to avoid race '
        'conditions.',
  ),
  _InterviewQuestion(
    prompt: 'Explain time and space complexity. What is Big-O?',
    modelAnswer:
        'Big-O describes how runtime or memory grows relative to '
        'input size in the worst case. e.g. O(1) constant, O(log n) '
        'binary search, O(n) linear scan, O(n log n) good sorts, O(n²) '
        'nested loops.',
  ),
  _InterviewQuestion(
    prompt: 'How do you reverse a linked list?',
    modelAnswer:
        'Iterate with three pointers (prev, curr, next). For each '
        'node, save next, point curr.next to prev, advance prev and curr. '
        'Return prev as the new head. O(n) time, O(1) space.',
  ),
  _InterviewQuestion(
    prompt: 'What is the difference between SQL and NoSQL databases?',
    modelAnswer:
        'SQL is relational with a fixed schema and strong ACID '
        'guarantees, good for structured, related data. NoSQL is schema-'
        'flexible (document/key-value/graph/column) and scales horizontally, '
        'good for large or rapidly changing data.',
  ),
  _InterviewQuestion(
    prompt: 'How would you detect and handle a memory leak?',
    modelAnswer:
        'Profile heap usage over time, look for objects that grow '
        'and are never freed (lingering listeners, caches, closures, global '
        'refs). Fix by removing references, disposing resources, and bounding '
        'cache size.',
  ),
  _InterviewQuestion(
    prompt: 'Explain REST and what makes an API RESTful.',
    modelAnswer:
        'REST uses stateless HTTP with resources identified by URLs, '
        'standard verbs (GET/POST/PUT/DELETE), appropriate status codes, and '
        'representations like JSON. It is cacheable and uniform.',
  ),
  _InterviewQuestion(
    prompt: 'How do you find a cycle in a linked list?',
    modelAnswer:
        'Floyd\'s algorithm: move a slow pointer one step and a fast '
        'pointer two steps. If they ever meet, there is a cycle; if fast '
        'reaches null, there is none. O(n) time, O(1) space.',
  ),
  _InterviewQuestion(
    prompt: 'What are the SOLID principles?',
    modelAnswer:
        'Single responsibility, Open/closed, Liskov substitution, '
        'Interface segregation, Dependency inversion — five OOP guidelines '
        'for maintainable, loosely coupled code.',
  ),
];

/// Functional, question-by-question mock technical interview. No backend —
/// a static bank with reveal-able model answers and a finish summary.
class MockInterviewScreen extends StatefulWidget {
  const MockInterviewScreen({super.key});

  @override
  State<MockInterviewScreen> createState() => _MockInterviewScreenState();
}

class _MockInterviewScreenState extends State<MockInterviewScreen> {
  int _index = 0;
  bool _showAnswer = false;
  bool _finished = false;
  final Set<int> _reviewed = {};

  void _next() {
    if (_index + 1 < _questions.length) {
      setState(() {
        _reviewed.add(_index);
        _index++;
        _showAnswer = false;
      });
    } else {
      setState(() {
        _reviewed.add(_index);
        _finished = true;
      });
    }
  }

  void _previous() {
    if (_index > 0) {
      setState(() {
        _index--;
        _showAnswer = false;
      });
    }
  }

  void _restart() => setState(() {
    _index = 0;
    _showAnswer = false;
    _finished = false;
    _reviewed.clear();
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
                    'Mock Interview',
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
              child: _finished
                  ? _SummaryView(
                      total: _questions.length,
                      reviewed: _reviewed.length,
                      foregroundColor: foregroundColor,
                      mutedColor: mutedColor,
                      onRestart: _restart,
                      onDone: Get.back,
                    )
                  : _QuestionView(
                      index: _index,
                      total: _questions.length,
                      question: _questions[_index],
                      showAnswer: _showAnswer,
                      cardColor: cardColor,
                      borderColor: borderColor,
                      foregroundColor: foregroundColor,
                      mutedColor: mutedColor,
                      onToggleAnswer: () =>
                          setState(() => _showAnswer = !_showAnswer),
                      onNext: _next,
                      onPrevious: _previous,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionView extends StatelessWidget {
  const _QuestionView({
    required this.index,
    required this.total,
    required this.question,
    required this.showAnswer,
    required this.cardColor,
    required this.borderColor,
    required this.foregroundColor,
    required this.mutedColor,
    required this.onToggleAnswer,
    required this.onNext,
    required this.onPrevious,
  });

  final int index;
  final int total;
  final _InterviewQuestion question;
  final bool showAnswer;
  final Color cardColor;
  final Color borderColor;
  final Color foregroundColor;
  final Color mutedColor;
  final VoidCallback onToggleAnswer;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  @override
  Widget build(BuildContext context) {
    final isLast = index + 1 == total;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: (index + 1) / total,
                  minHeight: 6,
                  backgroundColor: borderColor,
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF7C3AED)),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Question ${index + 1} of $total',
                style: TextStyle(
                  color: mutedColor,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: borderColor),
                ),
                child: Text(
                  question.prompt,
                  style: TextStyle(
                    color: foregroundColor,
                    fontSize: 19,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              if (showAnswer)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C3AED).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFF7C3AED).withValues(alpha: 0.25),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'MODEL ANSWER',
                        style: TextStyle(
                          color: Color(0xFF7C3AED),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        question.modelAnswer,
                        style: TextStyle(
                          color: foregroundColor,
                          fontSize: 14.5,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 4),
              TextButton.icon(
                onPressed: onToggleAnswer,
                icon: Icon(
                  showAnswer
                      ? Icons.visibility_off_outlined
                      : Icons.lightbulb_outline_rounded,
                  size: 18,
                ),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF7C3AED),
                ),
                label: Text(showAnswer ? 'Hide answer' : 'Show model answer'),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Row(
            children: [
              if (index > 0) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: onPrevious,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: foregroundColor,
                      side: BorderSide(color: borderColor),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Previous',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: FilledButton(
                  onPressed: onNext,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    isLast ? 'Finish' : 'Next',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryView extends StatelessWidget {
  const _SummaryView({
    required this.total,
    required this.reviewed,
    required this.foregroundColor,
    required this.mutedColor,
    required this.onRestart,
    required this.onDone,
  });

  final int total;
  final int reviewed;
  final Color foregroundColor;
  final Color mutedColor;
  final VoidCallback onRestart;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF7C3AED),
              size: 46,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Interview complete',
            style: TextStyle(
              color: foregroundColor,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You worked through $reviewed of $total questions. Keep '
            'practicing to sharpen your delivery and timing.',
            textAlign: TextAlign.center,
            style: TextStyle(color: mutedColor, fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onRestart,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Practice again',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: onDone,
              style: TextButton.styleFrom(foregroundColor: foregroundColor),
              child: const Text(
                'Back to Interview',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
