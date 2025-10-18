// File: typing_effect_widget.dart

import 'dart:async';
import 'package:flutter/cupertino.dart';

class TypingEffectWidget extends StatefulWidget {
  final String fullText;
  final TextStyle? textStyle;
  // Tốc độ gõ chữ (mili giây cho mỗi ký tự)
  final Duration speed;

  const TypingEffectWidget({
    Key? key,
    required this.fullText,
    this.textStyle,
    this.speed = const Duration(milliseconds: 50), // Tốc độ mặc định 50ms/ký tự
  }) : super(key: key);

  @override
  _TypingEffectWidgetState createState() => _TypingEffectWidgetState();
}

class _TypingEffectWidgetState extends State<TypingEffectWidget> {
  String _displayedText = '';
  Timer? _timer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  void _startTyping() {
    // Sử dụng Timer.periodic để thêm một ký tự sau mỗi khoảng thời gian `widget.speed`
    _timer = Timer.periodic(widget.speed, (timer) {
      if (_currentIndex < widget.fullText.length) {
        // Cập nhật state để rebuild widget với văn bản dài hơn
        setState(() {
          _displayedText += widget.fullText[_currentIndex];
          _currentIndex++;
        });
      } else {
        // Khi đã gõ xong, hủy timer để dừng animation
        _timer?.cancel();
      }
    });
  }

  // Rất quan trọng: Hủy timer khi widget bị xóa khỏi cây widget
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayedText,
      style: widget.textStyle,
    );
  }
}