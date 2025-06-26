// lib/common/widgets/recipe_timer_button.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:frontend/main.dart';

/// Ein anpassbares Timer-Button-Widget für Rezeptschritte.
/// Es zeigt die verbleibende Zeit an und ermöglicht das Starten, Pausieren und Zurücksetzen des Timers.
/// Im Ruhezustand ist es kompakt und dehnt sich bei Aktivität sanft mit nahtlosen Animationen aus.
class RecipeTimerButton extends StatefulWidget {
  final int initialDurationInSeconds;
  final TextStyle? textStyle;
  final Color? iconColor;

  const RecipeTimerButton({
    super.key,
    required this.initialDurationInSeconds,
    this.textStyle,
    this.iconColor,
  });

  @override
  State<RecipeTimerButton> createState() => _RecipeTimerButtonState();
}

// Erweitere mit WidgetsBindingObserver
class _RecipeTimerButtonState extends State<RecipeTimerButton>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver { // <-- Hinzugefügt
  late int _remainingSeconds;
  Timer? _timer;
  bool _isRunning = false;
  bool _isPaused = false;
  bool _isExpanded = false;
  bool _isFinished = false;

  // NEU: Variablen für die Zeitberechnung
  DateTime? _lastStartOrResumeTime; // Zeitpunkt, wann der Timer zuletzt gestartet oder fortgesetzt wurde
  int _pausedAtSeconds = 0; // Sekunden, bei denen der Timer pausiert wurde


  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.initialDurationInSeconds;
    if (_remainingSeconds <= 0) {
      _remainingSeconds = 0;
      _isRunning = false;
      _isPaused = false;
      _isExpanded = false;
      _isFinished = true;
    }
    // NEU: Observer hinzufügen
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didUpdateWidget(covariant RecipeTimerButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDurationInSeconds != oldWidget.initialDurationInSeconds) {
      _resetTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // App kommt in den Vordergrund
      _handleAppResume();
    } else if (state == AppLifecycleState.paused) {
      // App geht in den Hintergrund (oder eine andere App kommt in den Vordergrund)
      // Der Timer läuft technisch weiter, wir müssen nur den Zeitpunkt merken.
    }
  }

  /// Behandelt das Wiederaufnehmen der App aus dem Hintergrund.
  void _handleAppResume() {
    if (_isRunning && _lastStartOrResumeTime != null) {
      final now = DateTime.now();
      final elapsedSinceLastStart = now.difference(_lastStartOrResumeTime!).inSeconds;

      int newRemainingSeconds = _remainingSeconds - elapsedSinceLastStart;
      if (newRemainingSeconds < 0) {
        newRemainingSeconds = 0;
      }

      setState(() {
        _remainingSeconds = newRemainingSeconds;
        if (_remainingSeconds <= 0) {
          _timer?.cancel();
          _isRunning = false;
          _isPaused = false;
          _isFinished = true;
          _isExpanded = true; // Bleibt erweitert, um Reset zu zeigen
          // Zeige die Benachrichtigung, wenn sie noch nicht gezeigt wurde (z.B. wenn sie vom System gekillt wurde)
          // Wenn die App im Vordergrund ist, können wir die Snackbar verwenden.
          _showCompletionNotification();
        } else {
          // Timer lief noch, starte ihn neu mit der angepassten Restzeit
          _startTimerInternal(); // Verwende eine interne Methode, die nicht _lastStartOrResumeTime aktualisiert
        }
      });
    }
  }


  /// Startet den Timer.
  void _startTimer() {
    // Wenn der Timer initial 0 ist und bereits fertig, kann er nicht gestartet werden.
    if (widget.initialDurationInSeconds <= 0 && _isFinished) {
      return;
    }

    // Wenn der Timer auf 0 ist (abgelaufen) und nicht initial 0 war, setze ihn zurück, bevor er startet.
    if (_remainingSeconds <= 0 && widget.initialDurationInSeconds > 0) {
      _remainingSeconds = widget.initialDurationInSeconds;
    }

    setState(() {
      _isRunning = true;
      _isPaused = false;
      _isFinished = false;
      _isExpanded = true;
      _lastStartOrResumeTime = DateTime.now(); // Zeitpunkt des Starts/Fortsetzens merken
    });
    _startTimerInternal(); // Starte den eigentlichen Timer
  }

  /// Interne Methode zum Starten des Timers, ohne den Startzeitpunkt zu setzen.
  /// Wird auch von _handleAppResume aufgerufen.
  void _startTimerInternal() {
    _timer?.cancel(); // Vorherigen Timer stoppen, falls vorhanden
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        _timer?.cancel();
        return;
      }
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer?.cancel();
          _isRunning = false;
          _isPaused = false;
          _isFinished = true;
          _isExpanded = true;
          _showCompletionNotification();
        }
      });
    });
  }

  /// Pausiert den Timer.
  void _pauseTimer() {
    if (!_isRunning) return;
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isPaused = true;
      _isExpanded = true;
      _pausedAtSeconds = _remainingSeconds; // Aktuelle Sekunden speichern, bei denen pausiert wurde
      _lastStartOrResumeTime = null; // Zurücksetzen, da der Timer nicht mehr läuft
    });
  }

  /// Setzt den Timer auf seine ursprüngliche Dauer zurück.
  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = widget.initialDurationInSeconds;
      _isRunning = false;
      _isPaused = false;
      _isFinished = (widget.initialDurationInSeconds <= 0);
      _isExpanded = false;
      _lastStartOrResumeTime = null; // Zurücksetzen
      _pausedAtSeconds = 0; // Zurücksetzen
    });
  }

  /// Formatiert Sekunden in einen menschenlesbaren String (MM:SS oder HH:MM:SS).
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

  /// Zeigt eine einfache Benachrichtigung an, wenn der Timer abgelaufen ist.
  void _showCompletionNotification() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }


      // Snackbar anzeigen using the global key
      // Sicherstellen, dass der Context verfügbar ist, bevor darauf zugegriffen wird
      if (scaffoldMessengerKey.currentContext != null) {
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text(
              'Timer finished!',
              style: TextStyle(color: Theme.of(scaffoldMessengerKey.currentContext!).colorScheme.onPrimary),
            ),
            duration: const Duration(seconds: 3),
            backgroundColor: Theme.of(scaffoldMessengerKey.currentContext!).colorScheme.primary,
          ),
        );
      } else {
        print('Error: scaffoldMessengerKey.currentContext is null. Cannot show SnackBar.');
      }

      // Sound abspielen
      try {
        final player = AudioPlayer();
        player.play(AssetSource('sounds/timer_done.mp3'));
        print('Playing timer completion sound!');
      } catch (e) {
        print('Error playing sound: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final defaultTextStyle = widget.textStyle ??
        TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        );
    final defaultIconColor = widget.iconColor ?? colorScheme.primary;

    final bool isInteractable = widget.initialDurationInSeconds > 0;

    // Bestimme, ob der seitliche Reset-Button angezeigt werden soll
    final bool showSideResetButton = _isPaused && _remainingSeconds > 0 && isInteractable;

    IconData mainActionButtonIcon;
    VoidCallback? mainActionButtonOnPressed;
    String mainActionButtonTooltip;

    if (!isInteractable) {
      mainActionButtonIcon = Icons.timer_outlined;
      mainActionButtonOnPressed = null;
      mainActionButtonTooltip = 'Timer not set';
    } else if (_isFinished && !_isRunning) {
      mainActionButtonIcon = Icons.refresh;
      mainActionButtonOnPressed = _resetTimer;
      mainActionButtonTooltip = 'Reset Timer';
    } else if (_isRunning) {
      mainActionButtonIcon = Icons.pause_circle_filled;
      mainActionButtonOnPressed = _pauseTimer;
      mainActionButtonTooltip = 'Pause Timer';
    } else {
      mainActionButtonIcon = Icons.play_circle_fill;
      mainActionButtonOnPressed = _startTimer;
      mainActionButtonTooltip = 'Start Timer';
    }

    Widget compactChild = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.timer_outlined, color: defaultIconColor.withOpacity(0.7), size: 18),
        const SizedBox(width: 4),
        Text(
          _formatTime(_remainingSeconds),
          style: defaultTextStyle.copyWith(
            fontSize: 14,
            color: defaultIconColor.withOpacity(0.8),
          ),
        ),
      ],
    );

    Widget expandedChild = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _formatTime(_remainingSeconds),
          style: defaultTextStyle.copyWith(
            fontSize: 16,
            color: defaultTextStyle.color,
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 32.0,
          height: 32.0,
          child: IconButton(
            icon: Icon(
              mainActionButtonIcon,
              color: defaultIconColor,
              size: 32.0,
            ),
            onPressed: mainActionButtonOnPressed,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: mainActionButtonTooltip,
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: SizedBox(
            width: showSideResetButton ? 32.0 : 0.0,
            height: 32.0,
            child: Visibility(
              visible: showSideResetButton,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: IgnorePointer(
                ignoring: !showSideResetButton,
                child: Opacity(
                  opacity: showSideResetButton ? 1.0 : 0.0,
                  child: IconButton(
                    icon: Icon(
                      Icons.refresh,
                      color: defaultIconColor.withOpacity(0.7),
                      size: 28.0,
                    ),
                    onPressed: _resetTimer,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Reset Timer',
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );

    return GestureDetector(
      onTap: isInteractable
          ? () {
              if (!_isExpanded) {
                setState(() {
                  _isExpanded = true;
                });
                if (!_isFinished || _remainingSeconds > 0) {
                    _startTimer();
                } else if (_isFinished) {
                  if (mainActionButtonOnPressed != null) {
                    mainActionButtonOnPressed!();
                  }
                }
              } else {
                if (mainActionButtonOnPressed != null) {
                  mainActionButtonOnPressed!();
                }
              }
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: _isExpanded
            ? const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0)
            : const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: _isExpanded ? defaultIconColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20.0),
          border: _isExpanded
              ? Border.all(color: defaultIconColor.withOpacity(0.3))
              : null,
        ),
        child: AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          firstChild: compactChild,
          secondChild: expandedChild,
          alignment: Alignment.center,
          sizeCurve: Curves.easeInOut,
        ),
      ),
    );
  }
}