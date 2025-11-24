import 'package:flutter/widgets.dart';

typedef TypingStatusChanged = void Function(bool isTyping);

class AiTypingEngine {
  AiTypingEngine({
    required this.controller,
    this.onTextChanged,
    this.onTypingStatusChanged,
    this.forwardDelay = const Duration(milliseconds: 24),
    this.backspaceDelay = const Duration(milliseconds: 12),
  });

  final TextEditingController controller;
  final ValueChanged<String>? onTextChanged;
  final TypingStatusChanged? onTypingStatusChanged;
  final Duration forwardDelay;
  final Duration backspaceDelay;

  int _generationKey = 0;
  bool _isTyping = false;

  bool get isTyping => _isTyping;

  void dispose() {
    _generationKey++;
    _setTyping(false);
  }

  Future<void> animateTo(String targetText) async {
    final String currentText = controller.text;
    if (targetText == currentText) {
      return;
    }

    if (targetText.startsWith(currentText)) {
      await _typeForward(
        ++_generationKey,
        suffix: targetText.substring(currentText.length),
      );
      return;
    }

    if (currentText.startsWith(targetText)) {
      await _typeBackspace(++_generationKey, targetText: targetText);
      return;
    }

    _generationKey++;
    _setTyping(false);
    _setTextImmediatelyInternal(targetText);
  }

  void setTextImmediately(String value) {
    _generationKey++;
    _setTyping(false);
    _setTextImmediatelyInternal(value);
  }

  Future<void> _typeForward(
    int runKey, {
    required String suffix,
  }) async {
    if (suffix.isEmpty) {
      return;
    }

    final StringBuffer buffer = StringBuffer(controller.text);
    _setTyping(true);

    for (final String char in suffix.characters) {
      await Future.delayed(forwardDelay);
      if (runKey != _generationKey) {
        _setTyping(false);
        return;
      }
      buffer.write(char);
      final String updatedText = buffer.toString();
      _setTextImmediatelyInternal(updatedText, emitCallback: true);
    }

    if (runKey == _generationKey) {
      _setTyping(false);
    }
  }

  Future<void> _typeBackspace(
    int runKey, {
    required String targetText,
  }) async {
    Characters currentChars = controller.text.characters;
    final Characters targetChars = targetText.characters;

    if (currentChars == targetChars) {
      return;
    }

    _setTyping(true);

    while (currentChars != targetChars) {
      if (currentChars.isEmpty) {
        break;
      }

      await Future.delayed(backspaceDelay);
      if (runKey != _generationKey) {
        _setTyping(false);
        return;
      }

      currentChars = currentChars.skipLast(1);
      final String updatedText = currentChars.toString();
      _setTextImmediatelyInternal(updatedText, emitCallback: true);

      if (updatedText == targetText) {
        break;
      }
    }

    if (controller.text != targetText) {
      _setTextImmediatelyInternal(targetText, emitCallback: true);
    }

    if (runKey == _generationKey) {
      _setTyping(false);
    }
  }

  void _setTextImmediatelyInternal(
    String value, {
    bool emitCallback = true,
  }) {
    controller.text = value;
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.text.length),
    );
    if (emitCallback) {
      onTextChanged?.call(controller.text);
    }
  }

  void _setTyping(bool value) {
    if (_isTyping == value) {
      return;
    }
    _isTyping = value;
    onTypingStatusChanged?.call(_isTyping);
  }
}

