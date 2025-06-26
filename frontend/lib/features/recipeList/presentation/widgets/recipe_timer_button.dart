// lib/common/widgets/recipe_timer_button.dart
import 'dart:async';
import 'package:flutter/material.dart';

/// A customizable timer button widget for recipe steps.
/// It displays the remaining time and allows starting, pausing, and resetting the timer.
/// Touch targets, icon sizes, and animated transitions for the reset button have been improved.
class RecipeTimerButton extends StatefulWidget {
  final int initialDurationInSeconds;

  const RecipeTimerButton({
    super.key,
    required this.initialDurationInSeconds,
  });

  @override
  State<RecipeTimerButton> createState() => _RecipeTimerButtonState();
}

class _RecipeTimerButtonState extends State<RecipeTimerButton> {
  late int _remainingSeconds;
  Timer? _timer;
  bool _isRunning = false;
  bool _isPaused = false; // Added to distinguish between initial state and paused state

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.initialDurationInSeconds;
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer to prevent memory leaks
    super.dispose();
  }

  /// Starts the timer.
  void _startTimer() {
    if (_isRunning) return; // Prevent multiple timers

    setState(() {
      _isRunning = true;
      _isPaused = false; // No longer paused when starting
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer?.cancel(); // Timer finished
          _isRunning = false;
          _isPaused = false; // Reset paused state
          _showCompletionNotification();
        }
      });
    });
  }

  /// Pauses the timer.
  void _pauseTimer() {
    if (!_isRunning) return;
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isPaused = true;
    });
  }

  /// Resets the timer to its initial duration.
  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = widget.initialDurationInSeconds;
      _isRunning = false;
      _isPaused = false; // Ensure it's not in paused state after reset
    });
  }

  /// Formats seconds into a human-readable string (MM:SS or HH:MM:SS).
  String _formatTime(int seconds) {
    if (seconds < 0) seconds = 0;
    final Duration duration = Duration(seconds: seconds);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final String minutes = twoDigits(duration.inMinutes.remainder(60));
    final String hours = twoDigits(duration.inHours);
    final String secondsStr = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours > 0) {
      return '$hours:$minutes:$secondsStr';
    } else {
      return '$minutes:$secondsStr';
    }
  }

  /// Shows a simple notification when the timer completes.
  void _showCompletionNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Timer for step finished!'), // Customize message
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Determine if the reset button should be shown
    final bool showResetButton = !_isRunning && (_remainingSeconds != widget.initialDurationInSeconds || _isPaused);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Display the formatted time
          Text(
            _formatTime(_remainingSeconds),
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 16, // Slightly larger font for time
            ),
          ),
          const SizedBox(width: 12), // Increased spacing

          // Play/Pause button
          IconButton(
            icon: Icon(
              _isRunning ? Icons.pause_circle_filled : Icons.play_circle_fill,
              color: colorScheme.primary,
              size: 32, // EVEN LARGER: Increased from 28 to 32
            ),
            onPressed: _isRunning ? _pauseTimer : _startTimer,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32), // Ensure minimum tappable area
            tooltip: _isRunning ? 'Pause Timer' : 'Start Timer',
          ),

          // Animated Reset button
          AnimatedSize(
            duration: const Duration(milliseconds: 300), // Animation duration
            curve: Curves.easeInOut, // Animation curve
            child: SizedBox( // Use SizedBox to control initial size for animation
              width: showResetButton ? 32 : 0, // Animate width
              height: 32, // Keep height constant for animation
              child: showResetButton
                  ? IconButton(
                      icon: Icon(
                        Icons.refresh,
                        color: colorScheme.primary.withOpacity(0.7),
                        size: 28, // EVEN LARGER: Increased from 24 to 28
                      ),
                      onPressed: _resetTimer,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32), // Ensure minimum tappable area
                      tooltip: 'Reset Timer',
                    )
                  : null, // If not showing, set child to null
            ),
          ),
        ],
      ),
    );
  }
}
