import 'package:flutter/material.dart';

/// A single study flashcard. [front] holds the concept/question, [back] holds
/// the answer or a code snippet. [isCode] renders [back] in a monospace style.
class Flashcard {
  const Flashcard({
    required this.front,
    required this.back,
    this.isCode = false,
  });

  final String front;
  final String back;
  final bool isCode;
}

/// A named group of flashcards shown as one deck.
class FlashcardCategory {
  const FlashcardCategory({
    required this.name,
    required this.icon,
    required this.accent,
    required this.cards,
  });

  final String name;
  final IconData icon;
  final Color accent;
  final List<Flashcard> cards;
}

const List<FlashcardCategory> flashcardCategories = [
  FlashcardCategory(
    name: 'HTML',
    icon: Icons.html_rounded,
    accent: Color(0xFFE44D26),
    cards: _htmlCards,
  ),
  FlashcardCategory(
    name: 'CSS',
    icon: Icons.css_rounded,
    accent: Color(0xFF2965F1),
    cards: _cssCards,
  ),
  FlashcardCategory(
    name: 'JavaScript',
    icon: Icons.javascript_rounded,
    accent: Color(0xFFF0DB4F),
    cards: _jsCards,
  ),
];

const List<Flashcard> _htmlCards = [
  Flashcard(
    front: 'What does HTML stand for?',
    back:
        'HyperText Markup Language — the standard markup language for '
        'documents designed to be displayed in a web browser.',
  ),
  Flashcard(
    front: 'What is the purpose of the <!DOCTYPE html> declaration?',
    back:
        'It tells the browser to render the page in standards mode using '
        'the latest HTML specification, avoiding quirks mode.',
  ),
  Flashcard(
    front: 'Difference between block and inline elements?',
    back:
        'Block elements start on a new line and take the full available '
        'width (e.g. <div>, <p>). Inline elements flow within text and only '
        'take the width of their content (e.g. <span>, <a>).',
  ),
  Flashcard(
    front: 'What are semantic HTML elements? Give examples.',
    back:
        'Tags that describe their meaning to the browser and developer: '
        '<header>, <nav>, <main>, <article>, <section>, <aside>, <footer>.',
  ),
  Flashcard(
    front: 'How do you create a hyperlink that opens in a new tab?',
    back:
        '<a href="https://example.com" target="_blank" '
        'rel="noopener noreferrer">Link</a>',
    isCode: true,
  ),
  Flashcard(
    front: 'What is the difference between id and class attributes?',
    back:
        'An id must be unique per page and targets a single element. A '
        'class can be reused on many elements for shared styling/behavior.',
  ),
  Flashcard(
    front: 'Why is the alt attribute on <img> important?',
    back:
        'It provides alternative text for screen readers and is shown if '
        'the image fails to load — essential for accessibility and SEO.',
  ),
  Flashcard(
    front: 'What is the difference between <section> and <div>?',
    back:
        '<section> is semantic and groups thematically related content '
        '(usually with a heading). <div> is a generic, non-semantic '
        'container used purely for styling or scripting hooks.',
  ),
  Flashcard(
    front: 'How do you create an ordered vs unordered list?',
    back: '<ol>\n  <li>First</li>\n</ol>\n<ul>\n  <li>Bullet</li>\n</ul>',
    isCode: true,
  ),
  Flashcard(
    front: 'What are data-* attributes used for?',
    back:
        'Custom attributes that store extra information on elements, '
        'readable in JS via element.dataset. Example: data-user-id="42".',
  ),
  Flashcard(
    front: 'What is the difference between <b> and <strong>?',
    back:
        '<b> only bolds visually with no semantic meaning. <strong> '
        'conveys importance and is announced by assistive technology.',
  ),
  Flashcard(
    front: 'What does the <meta name="viewport"> tag do?',
    back:
        '<meta name="viewport" '
        'content="width=device-width, initial-scale=1.0">',
    isCode: true,
  ),
  Flashcard(
    front: 'How do you associate a <label> with an input?',
    back:
        'Match the label\'s for attribute to the input\'s id, or wrap the '
        'input inside the label. Improves accessibility and click target.',
  ),
  Flashcard(
    front: 'What is the difference between GET and POST forms?',
    back:
        'GET appends data to the URL as query params (visible, cacheable, '
        'idempotent). POST sends data in the request body (for sensitive or '
        'state-changing submissions).',
  ),
  Flashcard(
    front: 'What are void (self-closing) elements?',
    back:
        'Elements with no closing tag or children: <img>, <br>, <hr>, '
        '<input>, <meta>, <link>.',
  ),
  Flashcard(
    front: 'What is the purpose of the <head> element?',
    back:
        'It contains metadata about the document — title, charset, links '
        'to stylesheets, scripts, and meta tags — not rendered as content.',
  ),
  Flashcard(
    front: 'How do you embed a video in HTML5?',
    back:
        '<video controls width="320">\n'
        '  <source src="clip.mp4" type="video/mp4">\n'
        '</video>',
    isCode: true,
  ),
  Flashcard(
    front: 'What is the difference between <script>, async, and defer?',
    back:
        'Plain <script> blocks parsing. async downloads in parallel and '
        'runs as soon as ready (order not guaranteed). defer downloads in '
        'parallel but runs in order after the DOM is parsed.',
  ),
  Flashcard(
    front: 'What are ARIA roles?',
    back:
        'Accessible Rich Internet Application attributes that describe an '
        'element\'s role/state to assistive tech when native semantics are '
        'insufficient, e.g. role="dialog", aria-label, aria-hidden.',
  ),
  Flashcard(
    front: 'What does the <canvas> element do?',
    back:
        'Provides a bitmap drawing surface controlled via JavaScript for '
        'graphics, charts, games, and image manipulation.',
  ),
  Flashcard(
    front: 'What is the difference between <article> and <section>?',
    back:
        '<article> is a self-contained, independently distributable piece '
        '(blog post, comment). <section> groups related content within a '
        'larger document.',
  ),
  Flashcard(
    front: 'How do you make an input required and validated as an email?',
    back: '<input type="email" required>',
    isCode: true,
  ),
  Flashcard(
    front: 'What is the difference between innerHTML and textContent?',
    back:
        'innerHTML parses and renders an HTML string (XSS risk). '
        'textContent sets/reads plain text, escaping any markup.',
  ),
  Flashcard(
    front: 'What is the purpose of the <figure> and <figcaption> tags?',
    back:
        '<figure> groups self-contained media (image, diagram, code) with '
        'an optional caption provided by <figcaption>.',
  ),
  Flashcard(
    front: 'What does the contenteditable attribute do?',
    back:
        'Makes an element\'s content directly editable by the user, e.g. '
        '<div contenteditable="true">Edit me</div>.',
  ),
];

const List<Flashcard> _cssCards = [
  Flashcard(
    front: 'What does CSS stand for?',
    back:
        'Cascading Style Sheets — describes how HTML elements are '
        'presented on screen, paper, or other media.',
  ),
  Flashcard(
    front: 'Explain the CSS box model.',
    back:
        'Every element is a box made of: content, padding, border, and '
        'margin (from inside out). Total size depends on box-sizing.',
  ),
  Flashcard(
    front: 'Difference between content-box and border-box?',
    back:
        'box-sizing: content-box (default) — width excludes padding and '
        'border. border-box — width includes padding and border, so the '
        'rendered size matches the set width.',
  ),
  Flashcard(
    front: 'What is CSS specificity and how is it calculated?',
    back:
        'A weight that decides which rule wins. Inline styles > IDs > '
        'classes/attributes/pseudo-classes > elements. More specific or '
        'later rules override earlier ones.',
  ),
  Flashcard(
    front: 'Difference between relative, absolute, fixed, and sticky?',
    back:
        'relative: offset from its normal spot. absolute: positioned to '
        'nearest positioned ancestor. fixed: positioned to the viewport. '
        'sticky: relative until a scroll threshold, then fixed.',
  ),
  Flashcard(
    front: 'How do you center a div horizontally and vertically with flexbox?',
    back:
        '.parent {\n'
        '  display: flex;\n'
        '  justify-content: center;\n'
        '  align-items: center;\n'
        '}',
    isCode: true,
  ),
  Flashcard(
    front: 'Difference between flexbox and grid?',
    back:
        'Flexbox is one-dimensional (a row OR a column). Grid is '
        'two-dimensional (rows AND columns simultaneously).',
  ),
  Flashcard(
    front: 'What is the difference between em, rem, %, vw/vh, and px?',
    back:
        'px: absolute. em: relative to parent font-size. rem: relative to '
        'root font-size. %: relative to parent. vw/vh: relative to viewport '
        'width/height.',
  ),
  Flashcard(
    front: 'What does the z-index property control?',
    back:
        'The stacking order of positioned elements along the z-axis. '
        'Higher values appear in front. Only works on positioned elements.',
  ),
  Flashcard(
    front: 'Difference between display: none and visibility: hidden?',
    back:
        'display: none removes the element from layout entirely. '
        'visibility: hidden hides it but it still occupies space.',
  ),
  Flashcard(
    front: 'What are pseudo-classes vs pseudo-elements?',
    back:
        'Pseudo-classes target a state (:hover, :focus, :nth-child). '
        'Pseudo-elements style a part of an element (::before, ::after, '
        '::first-line).',
  ),
  Flashcard(
    front: 'How do you create a responsive layout with media queries?',
    back:
        '@media (max-width: 600px) {\n'
        '  .sidebar { display: none; }\n'
        '}',
    isCode: true,
  ),
  Flashcard(
    front: 'What is the difference between margin and padding?',
    back:
        'Margin is the transparent space outside an element\'s border. '
        'Padding is the space inside the border, around the content.',
  ),
  Flashcard(
    front: 'What is margin collapsing?',
    back:
        'Adjacent vertical margins of block elements combine into a '
        'single margin equal to the larger of the two, rather than summing.',
  ),
  Flashcard(
    front: 'How do CSS custom properties (variables) work?',
    back:
        ':root { --brand: #2b5df0; }\n'
        '.btn { color: var(--brand); }',
    isCode: true,
  ),
  Flashcard(
    front: 'Difference between transition and animation?',
    back:
        'transition animates between two states triggered by a change '
        '(e.g. :hover). animation uses @keyframes for multi-step, '
        'looping, self-running sequences.',
  ),
  Flashcard(
    front: 'What does position: sticky require to work?',
    back:
        'A threshold (top/bottom/left/right) and a scrollable ancestor '
        'that does not clip overflow with hidden/auto in the wrong axis.',
  ),
  Flashcard(
    front: 'How do you make a CSS Grid with 3 equal columns?',
    back:
        '.grid {\n'
        '  display: grid;\n'
        '  grid-template-columns: repeat(3, 1fr);\n'
        '  gap: 16px;\n'
        '}',
    isCode: true,
  ),
  Flashcard(
    front: 'What is the difference between absolute and relative units?',
    back:
        'Absolute units (px, cm) are fixed sizes. Relative units (em, '
        'rem, %, vw) scale based on another value, aiding responsiveness.',
  ),
  Flashcard(
    front: 'What does the cascade mean in CSS?',
    back:
        'The algorithm that resolves conflicting declarations using '
        'origin/importance, specificity, then source order.',
  ),
  Flashcard(
    front: 'How do you truncate text with an ellipsis?',
    back:
        '.truncate {\n'
        '  white-space: nowrap;\n'
        '  overflow: hidden;\n'
        '  text-overflow: ellipsis;\n'
        '}',
    isCode: true,
  ),
  Flashcard(
    front: 'What is a stacking context?',
    back:
        'A 3D conceptual layer formed by certain properties (position + '
        'z-index, opacity < 1, transform). Children are stacked relative to '
        'it, isolated from outside elements.',
  ),
  Flashcard(
    front: 'Difference between :nth-child and :nth-of-type?',
    back:
        ':nth-child counts all siblings. :nth-of-type counts only '
        'siblings of the same element type.',
  ),
  Flashcard(
    front: 'What is the difference between inline, inline-block, and block?',
    back:
        'inline: flows in text, ignores width/height. inline-block: flows '
        'in text but respects width/height/margins. block: full-width, new '
        'line.',
  ),
  Flashcard(
    front: 'How does specificity rank an ID vs a class selector?',
    back:
        'An ID selector (#id = 1,0,0) always beats any number of class '
        'selectors (.a.b.c = 0,3,0), regardless of source order.',
  ),
];

const List<Flashcard> _jsCards = [
  Flashcard(
    front: 'Difference between var, let, and const?',
    back:
        'var is function-scoped and hoisted. let and const are '
        'block-scoped. const cannot be reassigned (but objects stay '
        'mutable).',
  ),
  Flashcard(
    front: 'What is the difference between == and ===?',
    back:
        '== compares values with type coercion. === compares value and '
        'type with no coercion (strict equality). Prefer ===.',
  ),
  Flashcard(
    front: 'Explain closures.',
    back:
        'A closure is a function that retains access to variables from its '
        'lexical scope even after the outer function has returned.',
  ),
  Flashcard(
    front: 'What is hoisting?',
    back:
        'JS moves declarations to the top of their scope before '
        'execution. var is initialized as undefined; let/const are in the '
        'temporal dead zone until declared.',
  ),
  Flashcard(
    front: 'Difference between null and undefined?',
    back:
        'undefined: a variable declared but not assigned. null: an '
        'intentional absence of value, assigned by the developer.',
  ),
  Flashcard(
    front: 'What does the this keyword refer to?',
    back:
        'The object executing the current function — depends on call site. '
        'Arrow functions inherit this from their enclosing lexical scope.',
  ),
  Flashcard(
    front: 'What is the event loop?',
    back:
        'The mechanism that lets single-threaded JS handle async work: it '
        'runs the call stack, then drains the microtask queue, then the '
        'macrotask (callback) queue, repeating.',
  ),
  Flashcard(
    front: 'Difference between microtasks and macrotasks?',
    back:
        'Microtasks (Promises, queueMicrotask) run after the current task '
        'and before rendering. Macrotasks (setTimeout, events) run one per '
        'loop iteration, after all microtasks.',
  ),
  Flashcard(
    front: 'What are Promises?',
    back:
        'Objects representing the eventual result of an async operation, '
        'with states pending, fulfilled, or rejected; consumed via '
        '.then/.catch or async/await.',
  ),
  Flashcard(
    front: 'How does async/await work?',
    back:
        'async function load() {\n'
        '  const res = await fetch(url);\n'
        '  return res.json();\n'
        '}',
    isCode: true,
  ),
  Flashcard(
    front: 'Difference between map, filter, and reduce?',
    back:
        'map transforms each item into a new array. filter keeps items '
        'passing a test. reduce folds the array into a single accumulated '
        'value.',
  ),
  Flashcard(
    front: 'What is the difference between function and arrow functions?',
    back:
        'Arrow functions have no own this/arguments, cannot be used as '
        'constructors, and are always anonymous. They bind this lexically.',
  ),
  Flashcard(
    front: 'What is event delegation?',
    back:
        'Attaching one listener to a parent and using event.target to '
        'handle events from many children, leveraging event bubbling.',
  ),
  Flashcard(
    front: 'Difference between shallow and deep copy?',
    back:
        'Shallow copy duplicates top-level properties; nested objects are '
        'shared by reference. Deep copy duplicates all nested levels '
        '(e.g. structuredClone).',
  ),
  Flashcard(
    front: 'What does the spread operator do?',
    back:
        'const merged = { ...a, ...b };\n'
        'const clone = [...arr];',
    isCode: true,
  ),
  Flashcard(
    front: 'What is destructuring?',
    back:
        'const { name, age } = user;\n'
        'const [first, second] = list;',
    isCode: true,
  ),
  Flashcard(
    front: 'Difference between call, apply, and bind?',
    back:
        'call/apply invoke immediately with a given this (call takes '
        'comma args, apply takes an array). bind returns a new function '
        'with this permanently set.',
  ),
  Flashcard(
    front: 'What is the prototype chain?',
    back:
        'Objects link to a prototype object; property lookups walk up the '
        'chain until found or null, enabling inheritance.',
  ),
  Flashcard(
    front: 'Difference between synchronous and asynchronous code?',
    back:
        'Synchronous code runs line by line, blocking until done. '
        'Asynchronous code defers work (callbacks/Promises) so the thread '
        'stays free.',
  ),
  Flashcard(
    front: 'What is a higher-order function?',
    back:
        'A function that takes another function as an argument and/or '
        'returns a function (e.g. map, filter, setTimeout).',
  ),
  Flashcard(
    front: 'What does "use strict" do?',
    back:
        'Enables strict mode: throws on silent errors, forbids undeclared '
        'variables, and makes this undefined in plain function calls.',
  ),
  Flashcard(
    front: 'Difference between localStorage, sessionStorage, and cookies?',
    back:
        'localStorage persists with no expiry. sessionStorage clears on '
        'tab close. Cookies are sent with every HTTP request and can set '
        'expiry/HttpOnly.',
  ),
  Flashcard(
    front: 'What is debouncing vs throttling?',
    back:
        'Debounce delays a call until activity stops for N ms. Throttle '
        'caps a call to at most once per N ms during continuous activity.',
  ),
  Flashcard(
    front: 'What are template literals?',
    back: 'const msg = `Hi \${name}, you have \${count} new items`;',
    isCode: true,
  ),
  Flashcard(
    front: 'Explain the difference between == null and === undefined checks.',
    back:
        'value == null is true for both null and undefined (loose). '
        'value === undefined matches only undefined (strict).',
  ),
  Flashcard(
    front: 'What is the difference between forEach and map?',
    back:
        'forEach runs a callback for side effects and returns undefined. '
        'map returns a new transformed array and should be used when you '
        'need the result.',
  ),
];
