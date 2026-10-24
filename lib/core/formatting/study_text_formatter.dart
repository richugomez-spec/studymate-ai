/// Converts AI or user-authored study content into clean Library text while
/// preserving paragraphs, headings, and list structure.
class StudyTextFormatter {
  const StudyTextFormatter._();

  static String toPlainText(String input) {
    final lines = input.trim().split('\n');
    final output = <String>[];
    for (final sourceLine in lines) {
      var line = sourceLine.trimRight();
      final marker = line.trim();
      if (marker.startsWith('```')) continue;
      if (_isSeparator(marker) ||
          marker == '**' ||
          marker == '*' ||
          marker == '__') {
        continue;
      }

      line = _stripHeading(line);
      line = line.replaceFirst(RegExp(r'^\s*>\s?'), '');
      line = line.replaceFirst(RegExp(r'^\s*[-+*]\s+'), '• ');
      line = line.replaceAllMapped(
        RegExp(r'\[([^\]]+)\]\(([^)]+)\)'),
        (match) => '${match[1]} (${match[2]})',
      );
      line = _stripInlineMarkup(line);
      output.add(line.trimRight());
    }

    // Keep a blank line between bullets so each item reads like a separate
    // handwritten revision point. Preserve paragraph breaks from the source.
    final spaced = <String>[];
    for (var i = 0; i < output.length; i++) {
      final line = output[i];
      spaced.add(line);
      if (line.trimLeft().startsWith('• ') &&
          i + 1 < output.length &&
          output[i + 1].trimLeft().startsWith('• ')) {
        spaced.add('');
      }
    }
    return _normalizeBlankLines(spaced.join('\n'));
  }

  /// Removes decorative or malformed Markdown before the Coach's Markdown
  /// renderer handles intentional headings, emphasis, and lists.
  static String cleanForMarkdown(String input) {
    final lines = input.trim().split('\n');
    if (lines.isNotEmpty && lines.first.trim().startsWith('```')) {
      lines.removeAt(0);
    }
    if (lines.isNotEmpty && lines.last.trim() == '```') lines.removeLast();
    return _normalizeBlankLines(lines.where((line) {
      final marker = line.trim();
      return !_isSeparator(marker) &&
          marker != '**' &&
          marker != '*' &&
          marker != '__';
    }).join('\n'));
  }

  /// Adds display-only heading syntax to clean Library text. The stored and
  /// editable note remains plain text; the Markdown renderer hides this syntax.
  static String toMarkdownDisplay(String plainText) {
    final lines = plainText.split('\n');
    return List<String>.generate(lines.length, (index) {
      final line = lines[index];
      final clean = line.trim();
      if (clean.isEmpty || clean.startsWith('• ')) return line;
      final nextLineIsBlank =
          index + 1 < lines.length && lines[index + 1].trim().isEmpty;
      final looksLikeHeading = clean.length <= 100 &&
          nextLineIsBlank &&
          !RegExp(r'[.!?]$').hasMatch(clean);
      return looksLikeHeading ? '### $clean' : line;
    }).join('\n');
  }

  static bool _isSeparator(String value) =>
      value.length >= 3 &&
      value.runes.every((rune) => rune == 45 || rune == 42 || rune == 95);

  static String _stripHeading(String value) {
    final trimmed = value.trimLeft();
    var markerLength = 0;
    while (markerLength < trimmed.length &&
        trimmed.codeUnitAt(markerLength) == 35) {
      markerLength++;
    }
    if (markerLength > 0) {
      if (markerLength == trimmed.length) return '';
      if (trimmed.codeUnitAt(markerLength) == 32) {
        return trimmed.substring(markerLength + 1);
      }
      return trimmed.substring(markerLength).trimLeft();
    }
    return value;
  }

  static String _stripInlineMarkup(String value) {
    final code = <String>[];
    var line = value.replaceAllMapped(RegExp(r'`([^`]+)`'), (match) {
      final index = code.length;
      code.add(match[1] ?? '');
      return 'CODEPLACEHOLDER${index}END';
    });
    line = line.replaceAllMapped(
        RegExp(r'\*\*(.+?)\*\*'), (match) => match[1] ?? '');
    line =
        line.replaceAllMapped(RegExp(r'__(.+?)__'), (match) => match[1] ?? '');
    line = line.replaceAllMapped(
        RegExp(r'\*([^*]+)\*'), (match) => match[1] ?? '');
    line =
        line.replaceAllMapped(RegExp(r'_([^_]+)_'), (match) => match[1] ?? '');
    line = line.replaceAll('**', '').replaceAll('__', '');
    line = line.replaceAllMapped(RegExp(r'CODEPLACEHOLDER(\d+)END'), (match) {
      final index = int.tryParse(match[1] ?? '');
      return index != null && index < code.length ? code[index] : '';
    });
    return line;
  }

  static String _normalizeBlankLines(String value) => value
      .split('\n')
      .fold<List<String>>([], (lines, line) {
        if (line.trim().isEmpty) {
          if (lines.isNotEmpty && lines.last.isNotEmpty) lines.add('');
        } else {
          lines.add(line);
        }
        return lines;
      })
      .join('\n')
      .trim();
}
