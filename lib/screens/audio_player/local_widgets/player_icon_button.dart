import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

class PlayerIconButton extends StatelessWidget {
  const PlayerIconButton({
    Key key,
    @required this.icon,
    this.iconSize = 45,
    @required this.paletteGenerator,
    @required this.onPressed,
  }) : super(key: key);

  final IconData icon;
  final double iconSize;
  final PaletteGenerator paletteGenerator;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        icon,
      ),
      iconSize: iconSize,
      color: paletteGenerator.dominantColor.titleTextColor,
      splashColor:
      paletteGenerator.dominantColor.bodyTextColor.withOpacity(0.2),
      splashRadius: 30,
      onPressed: onPressed,
    );
  }

}