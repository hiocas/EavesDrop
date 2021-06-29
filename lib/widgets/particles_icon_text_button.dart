import 'dart:async';
import 'package:flutter/material.dart';
import 'icon_text_button.dart';
import 'package:confetti/confetti.dart';

class ParticlesIconTextButton extends StatefulWidget {
  final String label;
  final String subtext;
  final IconData icon;
  final IconData iconPressed;
  final Color color;
  final Color subtextColor;
  final Color backgroundColor;
  final void Function() onPressed;

  ///The duration can't be smaller then a millisecond, else it'll be 300.
  final Duration confettiDuration;
  final List<Color> confettiColors;
  final int millisecondsBeforeOnPressed;

  final bool mini;

  const ParticlesIconTextButton({
    Key key,
    @required this.label,
    this.subtext,
    @required this.icon,
    this.iconPressed,
    this.color,
    this.subtextColor,
    this.backgroundColor,
    @required this.onPressed,
    @required this.confettiDuration,
    this.confettiColors,
    this.millisecondsBeforeOnPressed,
    this.mini = false,
  }) : super(key: key);

  @override
  _ParticlesIconTextButtonState createState() =>
      _ParticlesIconTextButtonState();
}

class _ParticlesIconTextButtonState extends State<ParticlesIconTextButton> {
  ConfettiController _confettiController;
  Timer _timer;
  IconData _icon;

  @override
  void initState() {
    _icon = widget.icon;
    _confettiController = ConfettiController(
        duration: widget.confettiDuration.inMilliseconds > 1
            ? widget.confettiDuration
            : Duration(milliseconds: 300));
    super.initState();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    if (_timer != null) {
      _timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Feedback.forTap(context);
            _confettiController.play();
            /* For some reason for the confetti to not get stuck I need to
            update the UI. */
            setState(() {
              _icon = widget.iconPressed ?? widget.icon;
            });
            _timer = new Timer(
                Duration(
                    milliseconds: (widget.millisecondsBeforeOnPressed ?? 2000) +
                        (widget.confettiDuration.inMilliseconds > 1
                            ? widget.confettiDuration.inMilliseconds
                            : 300)), () {
              widget.onPressed.call();
            });
          },
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              IconTextButtonElement(
                mini: widget.mini,
                label: this.widget.label,
                icon: _icon,
                color: this.widget.color,
                backgroundColor: this.widget.backgroundColor,
              ),
              ConfettiWidget(
                emissionFrequency: 0.2,
                numberOfParticles: 10,
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                colors: widget.confettiColors ??
                    [
                      Colors.blue,
                      Colors.green,
                      Colors.orange,
                      Colors.pink,
                      Colors.purple
                    ],
              ),
            ],
          ),
        ),
        (widget.mini ? Container() : IconTextButtonSubtext(
          subtext: this.widget.subtext ?? '',
          subtextColor: this.widget.subtextColor,
        ))
      ],
    );
  }
}

class ParticlesIconTextToggleButton extends StatefulWidget {
  final String label;
  final String subtext;
  final String disabledSubtext;
  final IconData icon;
  final IconData iconPressed;
  final Color color;
  final Color subtextColor;
  final Color backgroundColor;
  final void Function() onPressed;

  /// Should the icon be [iconPressed] initially?
  /// The actually toggling behaviour doesn't depend on this value, but instead
  /// changed internally.
  final bool initialPressed;

  ///The duration can't be smaller then a millisecond, else it'll be 300.
  final Duration confettiDuration;
  final List<Color> confettiColors;
  final int millisecondsBeforeOnPressed;

  final bool mini;

  const ParticlesIconTextToggleButton({
    Key key,
    @required this.label,
    this.subtext,
    this.disabledSubtext,
    @required this.icon,
    @required this.iconPressed,
    this.color,
    this.subtextColor,
    this.backgroundColor,
    @required this.onPressed,
    @required this.initialPressed,
    @required this.confettiDuration,
    this.confettiColors,
    this.millisecondsBeforeOnPressed,
    this.mini = false,
  }) : super(key: key);

  @override
  _ParticlesIconTextToggleButtonState createState() =>
      _ParticlesIconTextToggleButtonState();
}

class _ParticlesIconTextToggleButtonState
    extends State<ParticlesIconTextToggleButton> {
  ConfettiController _confettiController;
  Timer _timer;
  IconData _icon;
  bool _toggled;

  @override
  void initState() {
    _icon = widget.initialPressed
        ? (widget.iconPressed ?? widget.icon)
        : widget.icon;
    _toggled = widget.initialPressed;
    _confettiController = ConfettiController(
        duration: widget.confettiDuration.inMilliseconds > 1
            ? widget.confettiDuration
            : Duration(milliseconds: 300));
    super.initState();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    if (_timer != null) {
      _timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: widget.onPressed == null
              ? null
              : () {
                  Feedback.forTap(context);
                  if (!_toggled) {
                    _confettiController.play();
                  }
                  /* For some reason for the confetti to not get stuck I need to
            update the UI. */
                  setState(() {
                    _toggled = !_toggled;
                    _icon = _toggled
                        ? (widget.iconPressed ?? widget.icon)
                        : widget.icon;
                  });
                  _timer = new Timer(
                      Duration(
                          milliseconds:
                              (widget.millisecondsBeforeOnPressed ?? 2000) +
                                  (widget.confettiDuration.inMilliseconds > 1
                                      ? widget.confettiDuration.inMilliseconds
                                      : 300)), () {
                    widget.onPressed.call();
                  });
                },
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              IconTextButtonElement(
                mini: widget.mini,
                label: this.widget.label,
                icon: _icon,
                color: widget.onPressed == null
                    ? widget.color.withOpacity(0.4)
                    : this.widget.color,
                backgroundColor: this.widget.backgroundColor,
              ),
              ConfettiWidget(
                emissionFrequency: 0.2,
                numberOfParticles: 10,
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                colors: widget.confettiColors ??
                    [
                      Colors.blue,
                      Colors.green,
                      Colors.orange,
                      Colors.pink,
                      Colors.purple
                    ],
              ),
            ],
          ),
        ),
        (widget.mini ? Container() : IconTextButtonSubtext(
          subtext: widget.onPressed == null
              ? (this.widget.disabledSubtext ?? (this.widget.subtext ?? ''))
              : (this.widget.subtext ?? ''),
          subtextColor: widget.onPressed == null
              ? this.widget.subtextColor == null
                  ? Colors.grey.withOpacity(0.6)
                  : (this.widget.subtextColor.withOpacity(0.6))
              : this.widget.subtextColor,
        ))
      ],
    );
  }
}
