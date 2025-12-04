import 'dart:async';
import 'package:flutter/material.dart';

/// A reusable widget that displays a typing effect, cycling through a list of texts.
/// It types each text, waits, then backspaces before typing the next one.
class TypingTextEffect extends StatefulWidget {
  const TypingTextEffect({
    super.key,
    required this.texts,
    required this.textStyle,
    this.typingDelay = const Duration(milliseconds: 50),
    this.backspaceDelay = const Duration(milliseconds: 30),
    this.pauseAfterTyping = const Duration(milliseconds: 2000),
    this.pauseAfterBackspace = const Duration(milliseconds: 500),
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.textScaler,
  });

  /// List of texts to cycle through
  final List<String> texts;
  
  /// Text style for the displayed text
  final TextStyle textStyle;
  
  /// Delay between typing each character
  final Duration typingDelay;
  
  /// Delay between backspacing each character
  final Duration backspaceDelay;
  
  /// Pause duration after typing is complete, before backspacing
  final Duration pauseAfterTyping;
  
  /// Pause duration after backspacing is complete, before typing next text
  final Duration pauseAfterBackspace;
  
  /// Text alignment
  final TextAlign? textAlign;
  
  /// Maximum lines
  final int? maxLines;
  
  /// Text overflow behavior
  final TextOverflow? overflow;
  
  /// Text scaler
  final TextScaler? textScaler;

  @override
  State<TypingTextEffect> createState() => _TypingTextEffectState();
}

class _TypingTextEffectState extends State<TypingTextEffect> {
  int _currentTextIndex = 0;
  String _displayedText = '';
  int _generationKey = 0;

  @override
  void initState() {
    super.initState();
    _startTypingCycle();
  }

  @override
  void dispose() {
    _generationKey++;
    super.dispose();
  }

  void _startTypingCycle() {
    if (widget.texts.isEmpty) return;
    
    _generationKey++;
    _typeCurrentText(_generationKey);
  }

  Future<void> _typeCurrentText(int runKey) async {
    if (runKey != _generationKey || !mounted) return;

    final targetText = widget.texts[_currentTextIndex];

    // Type forward
    for (int i = 0; i <= targetText.length; i++) {
      if (runKey != _generationKey || !mounted) return;
      
      setState(() {
        _displayedText = targetText.substring(0, i);
      });
      
      if (i < targetText.length) {
        await Future.delayed(widget.typingDelay);
      }
    }

    if (runKey != _generationKey || !mounted) return;

    // Pause after typing
    await Future.delayed(widget.pauseAfterTyping);
    
    if (runKey != _generationKey || !mounted) return;
    
    // Start backspacing
    await _backspaceText(runKey);
  }

  Future<void> _backspaceText(int runKey) async {
    if (runKey != _generationKey || !mounted) return;

    String currentText = _displayedText;
    
    // Backspace
    while (currentText.isNotEmpty) {
      if (runKey != _generationKey || !mounted) return;
      
      currentText = currentText.substring(0, currentText.length - 1);
      
      setState(() {
        _displayedText = currentText;
      });
      
      await Future.delayed(widget.backspaceDelay);
    }

    if (runKey != _generationKey || !mounted) return;

    // Pause after backspacing
    await Future.delayed(widget.pauseAfterBackspace);
    
    if (runKey != _generationKey || !mounted) return;
    
    // Move to next text
    _currentTextIndex = (_currentTextIndex + 1) % widget.texts.length;
    
    // Start typing next text
    _typeCurrentText(runKey);
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayedText,
      style: widget.textStyle,
      textAlign: widget.textAlign,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
      textScaler: widget.textScaler ?? TextScaler.noScaling,
    );
  }
}

