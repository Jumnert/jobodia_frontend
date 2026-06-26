/// One technical interview question with a model answer the user can reveal.
class InterviewQuestion {
  const InterviewQuestion({required this.prompt, required this.modelAnswer});

  final String prompt;
  final String modelAnswer;
}

const mockInterviewQuestions = <InterviewQuestion>[
  InterviewQuestion(
    prompt:
        'Walk me through what happens when you type a URL into the '
        'browser and press Enter.',
    modelAnswer:
        'DNS resolves the domain to an IP, a TCP (and TLS) '
        'connection is established, the browser sends an HTTP request, the '
        'server responds, then the browser parses HTML, builds the DOM/CSSOM, '
        'runs JS, and paints the page.',
  ),
  InterviewQuestion(
    prompt: 'How would you design a URL shortener like bit.ly?',
    modelAnswer:
        'Generate a short unique key (base62 of an ID or a hash), '
        'store key→URL in a fast key-value store, redirect with 301/302 on '
        'lookup, and add caching plus analytics. Discuss collisions, scale, '
        'and read-heavy traffic.',
  ),
  InterviewQuestion(
    prompt: 'What is the difference between a process and a thread?',
    modelAnswer:
        'A process has its own isolated memory space; threads share '
        'the memory of their parent process. Threads are lighter to create '
        'and switch between but require synchronization to avoid race '
        'conditions.',
  ),
  InterviewQuestion(
    prompt: 'Explain time and space complexity. What is Big-O?',
    modelAnswer:
        'Big-O describes how runtime or memory grows relative to '
        'input size in the worst case. e.g. O(1) constant, O(log n) '
        'binary search, O(n) linear scan, O(n log n) good sorts, O(n²) '
        'nested loops.',
  ),
  InterviewQuestion(
    prompt: 'How do you reverse a linked list?',
    modelAnswer:
        'Iterate with three pointers (prev, curr, next). For each '
        'node, save next, point curr.next to prev, advance prev and curr. '
        'Return prev as the new head. O(n) time, O(1) space.',
  ),
  InterviewQuestion(
    prompt: 'What is the difference between SQL and NoSQL databases?',
    modelAnswer:
        'SQL is relational with a fixed schema and strong ACID '
        'guarantees, good for structured, related data. NoSQL is schema-'
        'flexible (document/key-value/graph/column) and scales horizontally, '
        'good for large or rapidly changing data.',
  ),
  InterviewQuestion(
    prompt: 'How would you detect and handle a memory leak?',
    modelAnswer:
        'Profile heap usage over time, look for objects that grow '
        'and are never freed (lingering listeners, caches, closures, global '
        'refs). Fix by removing references, disposing resources, and bounding '
        'cache size.',
  ),
  InterviewQuestion(
    prompt: 'Explain REST and what makes an API RESTful.',
    modelAnswer:
        'REST uses stateless HTTP with resources identified by URLs, '
        'standard verbs (GET/POST/PUT/DELETE), appropriate status codes, and '
        'representations like JSON. It is cacheable and uniform.',
  ),
  InterviewQuestion(
    prompt: 'How do you find a cycle in a linked list?',
    modelAnswer:
        "Floyd's algorithm: move a slow pointer one step and a fast "
        'pointer two steps. If they ever meet, there is a cycle; if fast '
        'reaches null, there is none. O(n) time, O(1) space.',
  ),
  InterviewQuestion(
    prompt: 'What are the SOLID principles?',
    modelAnswer:
        'Single responsibility, Open/closed, Liskov substitution, '
        'Interface segregation, Dependency inversion — five OOP guidelines '
        'for maintainable, loosely coupled code.',
  ),
];
