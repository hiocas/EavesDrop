import 'dart:async';
import 'package:flutter/material.dart';
import 'icon_text_button.dart';
import 'package:confetti/confetti.dart';

class ParticlesIconTextButton extends StatefulWidget {
  final String label;
  final String subtext;
  final IconData icon;
  final Color color;
  final Color subtextColor;
  final Color backgroundColor;
  final void Function() onPressed;

  ///The duration can't be smaller then a millisecond, else it'll be 300.
  final Duration confettiDuration;
  final List<Color> confettiColors;
  final int millisecondsBeforeOnPressed;

  const ParticlesIconTextButton({
    Key key,
    @required this.label,
    this.subtext,
    @required this.icon,
    this.color,
    this.subtextColor,
    this.backgroundColor,
    @required this.onPressed,
    @required this.confettiDuration,
    this.confettiColors,
    this.millisecondsBeforeOnPressed,
  }) : super(key: key);

  @override
  _ParticlesIconTextButtonState createState() =>
      _ParticlesIconTextButtonState();
}

class _ParticlesIconTextButtonState extends State<ParticlesIconTextButton> {
  ConfettiController _confettiController;
  Timer _timer;

  @override
  void initState() {
    _confettiController = ConfettiController(
        duration: widget.confettiDuration.inMilliseconds > 1
            ? widget.confettiDuration
            : Duration(milliseconds: 300));
    super.initState();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    if (_timer != null){
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
            _confettiController.play();
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
                label: this.widget.label,
                icon: this.widget.icon,
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
        IconTextButtonSubtext(
          subtext: this.widget.subtext ?? '',
          subtextColor: this.widget.subtextColor,
        )
      ],
    );
  }
}