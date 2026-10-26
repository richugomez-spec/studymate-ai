/// Strips Markdown formatting from [text] and returns clean, readable plain
/// text safe to store in Firestore and display in the Library editor.
///
/// Removed:
///   • ATX headings  (# H1 … ###### H6)
///   • Setext headings (underline === and ---)
///   • Horizontal rules (---, ***, ___)
///   • Bold / italic emphasis (**text**, __text__, *text*, _text_)
///   • Inline code (`code`)
///   • Fenced code blocks (``` … ```)
///   • Blockquote markers (> )
///   • LaTeX fragments  \( … \), \[ … \], $…$, ${text(…)}
///   • Bare HTML tags
///   • Excess blank lines (collapsed to a single blank line)
///
/// Kept:
///   • Bullet points rendered as "• item"
///   • Numbered list items (1. item → kept as-is)
///   • Plain paragraphs
String stripMarkdown(String text) {
  if (text.trim().isEmpty) return text;

  var s = text;

  // 1. Normalise line endings.
  s = s.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

  // 2. Remove code fence delimiters (``` or ~~~) without discarding inner content.
  s = s.replaceAll(RegExp(r'^\s*```[a-zA-Z0-9_\-\.]*\s*$', multiLine: true), '');
  s = s.replaceAll(RegExp(r'^\s*~~~\s*$', multiLine: true), '');
  s = s.replaceAll('```', '');

  // 3. LaTeX fragments:
  // ${text(C)} or ${text(Java)} -> C / Java
  s = s.replaceAllMapped(
    RegExp(r'\$\{\s*text\s*\(([^)]*)\)\s*\}'),
    (m) => m.group(1)?.trim() ?? '',
  );
  // \text{...} -> ...
  s = s.replaceAllMapped(
    RegExp(r'\$\{\s*\\?text\s*\{([^}]*)\}\s*\}'),
    (m) => m.group(1)?.trim() ?? '',
  );
  s = s.replaceAllMapped(
    RegExp(r'\\text\{([^}]*)\}'),
    (m) => m.group(1)?.trim() ?? '',
  );
  s = s.replaceAllMapped(
    RegExp(r'\\(?:mathrm|mathbf|mathit)\{([^}]*)\}'),
    (m) => m.group(1)?.trim() ?? '',
  );
  // ${variable} -> variable
  s = s.replaceAllMapped(
    RegExp(r'\$\{([^}]+)\}'),
    (m) => m.group(1)?.trim() ?? '',
  );
  // Remove \(, \), \[, \]
  s = s.replaceAll(r'\(', '').replaceAll(r'\)', '');
  s = s.replaceAll(r'\[', '').replaceAll(r'\]', '');
  s = s.replaceAll(r'$$', '');
  // LaTeX fractions \frac{a}{b} -> a / b
  s = s.replaceAllMapped(
    RegExp(r'\\frac\{([^}]+)\}\{([^}]+)\}'),
    (m) => '${m.group(1)} / ${m.group(2)}',
  );
  // LaTeX square root \sqrt{x} -> √(x)
  s = s.replaceAllMapped(
    RegExp(r'\\sqrt\{([^}]+)\}'),
    (m) => '√(${m.group(1)})',
  );
  // LaTeX math symbols
  s = s
      .replaceAll(r'\times', '×')
      .replaceAll(r'\div', '÷')
      .replaceAll(r'\pm', '±')
      .replaceAll(r'\cdot', '·')
      .replaceAll(r'\approx', '≈')
      .replaceAll(r'\le', '≤')
      .replaceAll(r'\leq', '≤')
      .replaceAll(r'\ge', '≥')
      .replaceAll(r'\geq', '≥')
      .replaceAll(r'\ne', '≠')
      .replaceAll(r'\neq', '≠');
  // Strip inline math delimiters $math$ (avoiding bare currency like $5 or $10.50)
  s = s.replaceAllMapped(
    RegExp(r'(?<!\w)\$(?!\d+(?:\.\d+)?(?:\s|[.,;]|$))([^$\n]+)\$(?!\w)'),
    (m) => m.group(1) ?? '',
  );

  // 4. ATX headings — strip every heading marker (#, ##, ###, ####, etc.)
  s = s.replaceAllMapped(
    RegExp(r'^\s*#{1,6}\s*(.+)$', multiLine: true),
    (m) => m.group(1)!.trim(),
  );

  // 5. Horizontal rules (---, ***, ___ on their own line).
  s = s.replaceAll(RegExp(r'^\s*([*\-_]\s*){3,}\s*$', multiLine: true), '');
  // Setext-style headings (underlines === and ---).
  s = s.replaceAll(RegExp(r'^[=\-]{3,}\s*$', multiLine: true), '');

  // 6. Blockquote markers (> quote -> quote).
  s = s.replaceAll(RegExp(r'^\s*>\s?', multiLine: true), '');

  // 7. Markdown links [text](url) -> text.
  s = s.replaceAllMapped(
    RegExp(r'\[([^\]]+)\]\([^)]*\)'),
    (m) => m.group(1)!,
  );

  // 8. Markdown bullet list markers (* / - / +) → bullet character •.
  s = s.replaceAllMapped(
    RegExp(r'^(\s*)[*\-+]\s+', multiLine: true),
    (m) => '${m.group(1)}• ',
  );

  // 9. Bold+italic combined (***text*** or ___text___).
  s = s.replaceAllMapped(
    RegExp(r'\*{3}(.+?)\*{3}', dotAll: true),
    (m) => m.group(1)!,
  );
  s = s.replaceAllMapped(
    RegExp(r'_{3}(.+?)_{3}', dotAll: true),
    (m) => m.group(1)!,
  );

  // 10. Bold (**text** or __text__).
  s = s.replaceAllMapped(
    RegExp(r'\*{2}(.+?)\*{2}', dotAll: true),
    (m) => m.group(1)!,
  );
  s = s.replaceAllMapped(
    RegExp(r'_{2}(.+?)_{2}', dotAll: true),
    (m) => m.group(1)!,
  );

  // 11. Italic (*text* or _text_).
  s = s.replaceAllMapped(
    RegExp(r'(?<!\*)\*(?!\*)(.+?)(?<!\*)\*(?!\*)', dotAll: true),
    (m) => m.group(1)!,
  );
  s = s.replaceAllMapped(
    RegExp(r'\b_(?!_)(.+?)(?<!_)_\b', dotAll: true),
    (m) => m.group(1)!,
  );

  // 12. Inline code (`code` -> code).
  s = s.replaceAllMapped(
    RegExp(r'`([^`]+)`'),
    (m) => m.group(1)!,
  );
  s = s.replaceAll('`', '');

  // 13. Strikethrough (~~text~~ -> text).
  s = s.replaceAllMapped(
    RegExp(r'~~(.+?)~~'),
    (m) => m.group(1)!,
  );

  // 14. Bare HTML tags.
  s = s.replaceAll(RegExp(r'<[^>]+>'), '');

  // 15. Strip leftover stray asterisks or underscores.
  s = s.replaceAll('**', '').replaceAll('__', '');

  // 16. Spacing between bullets: keep blank line between successive bullet items
  final lines = s.split('\n');
  final spaced = <String>[];
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i].trimRight();
    spaced.add(line);
    final clean = line.trimLeft();
    if (clean.startsWith('• ') &&
        i + 1 < lines.length &&
        lines[i + 1].trimLeft().startsWith('• ')) {
      spaced.add('');
    }
  }

  // 17. Collapse multiple blank lines into a single blank line.
  final normalized = <String>[];
  for (final line in spaced) {
    if (line.trim().isEmpty) {
      if (normalized.isNotEmpty && normalized.last.isNotEmpty) {
        normalized.add('');
      }
    } else {
      normalized.add(line);
    }
  }

  return normalized.join('\n').trim();
}
