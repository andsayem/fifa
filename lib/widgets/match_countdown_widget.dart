import 'dart:async';
import 'package:flutter/material.dart';

class MatchCountdownWidget extends StatefulWidget {
  final DateTime targetDateTime;
  final TextStyle? style;
  final Widget? finishedWidget;

  const MatchCountdownWidget({
    super.key,
    required this.targetDateTime,
    this.style,
    this.finishedWidget,
  });

  @override
  State<MatchCountdownWidget> createState() => _MatchCountdownWidgetState();
}

class _MatchCountdownWidgetState extends State<MatchCountdownWidget> {
  Timer? _timer;
  late Duration _timeLeft;

  @override
  void initState() {
    super.initState();
    _calculateTimeLeft();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant MatchCountdownWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetDateTime != widget.targetDateTime) {
      _calculateTimeLeft();
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    if (_timeLeft.isNegative) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _calculateTimeLeft();
        });
      }
    });
  }

  void _calculateTimeLeft() {
    final now = DateTime.now();
    _timeLeft = widget.targetDateTime.difference(now);
    if (_timeLeft.isNegative) {
      _timer?.cancel();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_timeLeft.isNegative) {
      return widget.finishedWidget ??
          const Text(
            'MATCH STARTED',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.green,
            ),
          );
    }

    final days = _timeLeft.inDays;
    final hours = _timeLeft.inHours % 24;
    final minutes = _timeLeft.inMinutes % 60;
    final seconds = _timeLeft.inSeconds % 60;

    String text = '';
    if (days > 0) {
      text += '${days}d ';
    }
    text += '${hours.toString().padLeft(2, '0')}h ${minutes.toString().padLeft(2, '0')}m ${seconds.toString().padLeft(2, '0')}s';

    return Text(
      text,
      style: widget.style ??
          const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
      textAlign: TextAlign.center,
    );
  }
}
