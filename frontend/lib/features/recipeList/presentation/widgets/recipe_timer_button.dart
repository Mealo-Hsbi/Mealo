// lib/common/widgets/recipe_timer_button.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart'; // Import für SchedulerBinding
import 'package:audioplayers/audioplayers.dart';
import 'package:frontend/main.dart'; // Füge diese Zeile hinzu, wenn du Sounds verwenden willst

/// Ein anpassbares Timer-Button-Widget für Rezeptschritte.
/// Es zeigt die verbleibende Zeit an und ermöglicht das Starten, Pausieren und Zurücksetzen des Timers.
/// Im Ruhezustand ist es kompakt und dehnt sich bei Aktivität sanft mit nahtlosen Animationen aus.
class RecipeTimerButton extends StatefulWidget {
  final int initialDurationInSeconds;
  final TextStyle? textStyle; // Optionaler Textstil vom übergeordneten Widget
  final Color? iconColor; // Optionale Icon-Farbe vom übergeordneten Widget

  const RecipeTimerButton({
    super.key, // <-- Denke daran, hier einen Key zu übergeben, wenn du es instanziierst!
    required this.initialDurationInSeconds,
    this.textStyle,
    this.iconColor,
  });

  @override
  State<RecipeTimerButton> createState() => _RecipeTimerButtonState();
}

class _RecipeTimerButtonState extends State<RecipeTimerButton> with SingleTickerProviderStateMixin {
  late int _remainingSeconds;
  Timer? _timer;
  bool _isRunning = false;
  bool _isPaused = false;
  bool _isExpanded = false; // Steuert, ob der Timer die vollständigen Steuerelemente anzeigt
  bool _isFinished = false; // Neuer Zustand: Timer ist abgelaufen

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.initialDurationInSeconds; // Zurückgesetzt auf initialDurationInSeconds
    // _remainingSeconds = 2;
    if (_remainingSeconds <= 0) {
      _remainingSeconds = 0;
      _isRunning = false;
      _isPaused = false;
      _isExpanded = false;
      _isFinished = true; // Timer ist effektiv beendet, wenn die anfängliche Dauer 0 ist
    }
  }

  @override
  void didUpdateWidget(covariant RecipeTimerButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Wenn sich initialDurationInSeconds ändert, setze den Timer auf seinen neuen Anfangszustand zurück.
    if (widget.initialDurationInSeconds != oldWidget.initialDurationInSeconds) {
      _resetTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Startet den Timer.
  void _startTimer() {
    // Verhindere den Start, wenn bereits läuft oder wenn initial 0 ist und bereits fertig.
    if (_isRunning || (widget.initialDurationInSeconds <= 0 && _isFinished)) {
      return;
    }

    // Wenn der Timer auf 0 ist (abgelaufen) und nicht initial 0 war, setze ihn zurück, bevor er startet.
    if (_remainingSeconds <= 0 && widget.initialDurationInSeconds > 0) {
      _remainingSeconds = widget.initialDurationInSeconds;
    }

    setState(() {
      _isRunning = true;
      _isPaused = false;
      _isFinished = false; // Nicht mehr fertig, sobald gestartet
      _isExpanded = true; // Immer erweitern, wenn gestartet
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        // Prüfe, ob das Widget noch gemountet ist, bevor du den Status aktualisierst oder Benachrichtigungen anzeigst
        _timer?.cancel();
        return;
      }
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          // Timer beendet
          _timer?.cancel();
          _isRunning = false;
          _isPaused = false;
          _isFinished = true; // Setze auf fertig, wenn 0 erreicht
          _isExpanded = true; // Bleibt erweitert, um Reset-Option zu zeigen

          // WICHTIG: Benachrichtigung direkt nach dem Status-Update aufrufen
          _showCompletionNotification();
        }
      });
    });
  }

  /// Pausiert den Timer.
  void _pauseTimer() {
    if (!_isRunning) return; // Nur pausieren, wenn er läuft
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isPaused = true;
      _isExpanded = true; // Bleibt erweitert, wenn pausiert
    });
  }

  /// Setzt den Timer auf seine ursprüngliche Dauer zurück.
  void _resetTimer() {
    _timer?.cancel(); // Stoppe laufenden Timer
    setState(() {
      _remainingSeconds = widget.initialDurationInSeconds;
      _isRunning = false;
      _isPaused = false;
      _isFinished = (widget.initialDurationInSeconds <= 0); // Wenn initial 0, ist er fertig.
      _isExpanded = false; // Nach Reset immer kollabieren
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
  // No need for the initial mounted check here if using GlobalKey for ScaffoldMessenger
  // as the GlobalKey directly references the ScaffoldMessengerState.

  SchedulerBinding.instance.addPostFrameCallback((_) {
    // We still check mounted for the sound player, as AudioPlayer might
    // have its own lifecycle considerations.
    if (!mounted) {
      print('[_showCompletionNotification] Innerhalb von addPostFrameCallback - Widget ist nicht gemountet. Abbruch für Sound.');
      // Even if unmounted, the GlobalKey for ScaffoldMessenger might still be valid.
    }

    print('[_showCompletionNotification] Innerhalb von addPostFrameCallback - Versuche Snackbar und Sound.');

    // Snackbar anzeigen using the global key
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(
          'Timer finished!',
          // Access theme data from the root context or directly from the ScaffoldMessenger's context
          // For consistent theme, you might need to pass theme data down or retrieve it from a broader context.
          // For simplicity, let's keep it minimal or get it from a common theme helper if available.
          // Or, if your MaterialApp is already themed, the SnackBar will pick it up.
          style: TextStyle(color: Theme.of(scaffoldMessengerKey.currentContext!).colorScheme.onPrimary),
        ),
        duration: const Duration(seconds: 3),
        backgroundColor: Theme.of(scaffoldMessengerKey.currentContext!).colorScheme.primary,
      ),
    );

    // Sound abspielen (still check mounted for this specific widget's lifecycle)
    if (mounted) { // Only play sound if this specific widget is still mounted
      try {
        final player = AudioPlayer();
        player.play(AssetSource('sounds/timer_done.mp3'));
        print('Playing timer completion sound!');
      } catch (e) {
        print('Error playing sound: $e');
      }
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

    // Nur interaktiv, wenn initialDurationInSeconds > 0
    final bool isInteractable = widget.initialDurationInSeconds > 0;

    // Bestimme, ob der seitliche Reset-Button angezeigt werden soll
    // Dieser wird nur angezeigt, wenn der Timer pausiert ist UND noch Zeit übrig ist.
    final bool showSideResetButton = _isPaused && _remainingSeconds > 0 && isInteractable;

    // Bestimme, welches Icon der Haupt-Action-Button zeigen und welche Funktion er haben soll
    IconData mainActionButtonIcon;
    VoidCallback? mainActionButtonOnPressed;
    String mainActionButtonTooltip;

    if (!isInteractable) {
      // Wenn der Timer nicht interaktiv ist (initial 0), ist der Button deaktiviert.
      mainActionButtonIcon = Icons.timer_outlined; // Zeigt ein Timer-Icon für inaktive Buttons
      mainActionButtonOnPressed = null;
      mainActionButtonTooltip = 'Timer not set';
    } else if (_isFinished && !_isRunning) {
      // WICHTIG: Prüfe zuerst, ob der Timer ABGELAUFEN und NICHT MEHR LÄUFT.
      // In diesem Fall wird der Haupt-Button zum RESET-Knopf.
      mainActionButtonIcon = Icons.refresh;
      mainActionButtonOnPressed = _resetTimer;
      mainActionButtonTooltip = 'Reset Timer';
    } else if (_isRunning) {
      // Wenn der Timer läuft -> Pause-Knopf
      mainActionButtonIcon = Icons.pause_circle_filled;
      mainActionButtonOnPressed = _pauseTimer;
      mainActionButtonTooltip = 'Pause Timer';
    } else {
      // In allen anderen Fällen (pausiert, oder im initialen Zustand, aber nicht abgelaufen) -> Play-Knopf
      mainActionButtonIcon = Icons.play_circle_fill;
      mainActionButtonOnPressed = _startTimer;
      mainActionButtonTooltip = 'Start Timer';
    }


    // Widget für den kompakten Zustand
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

    // Widget für den erweiterten Zustand
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
          width: 32.0, // Feste Größe für Play/Pause/Reset-Hauptbutton
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
        // Seitlicher Reset-Button: Nur sichtbar, wenn pausiert UND nicht auf 0
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: SizedBox(
            width: showSideResetButton ? 32.0 : 0.0, // Animiert die Breite
            height: 32.0, // Behalte die Höhe konstant
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
              // Wenn nicht erweitert und interaktiv, expandiere und starte
              if (!_isExpanded) {
                setState(() {
                  _isExpanded = true;
                });
                // Starte den Timer sofort, wenn von kompakt zu erweitert gewechselt wird
                // aber nur wenn er nicht schon fertig ist (damit er nicht neu startet, wenn man auf den abgelaufenen drückt)
                if (!_isFinished || _remainingSeconds > 0) {
                    _startTimer();
                } else if (_isFinished) { // Wenn er fertig ist, aktiviere den Reset über den Hauptbutton
                  if (mainActionButtonOnPressed != null) {
                    mainActionButtonOnPressed!();
                  }
                }
              } else {
                // Wenn bereits erweitert, und der Hauptbutton eine Funktion hat, führe diese aus.
                if (mainActionButtonOnPressed != null) {
                  mainActionButtonOnPressed!();
                }
              }
            }
          : null, // Wenn nicht interaktiv, kein onTap
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
