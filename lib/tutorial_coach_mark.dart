library tutorial_coach_mark;

import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/target_focus.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark_widget.dart';
export 'package:tutorial_coach_mark/content_target.dart';
export 'package:tutorial_coach_mark/target_focus.dart';

class TutorialCoachMark {
  final BuildContext _context;
  final List<TargetFocus> targets;
  final Function(TargetFocus) clickTarget;
  final Function() finish;
  final double paddingFocus;
  final Function() clickSkip;
  final String textSkip;
  final String textPrevious;
  final String textNext;
  final String textDone;
  final TextStyle textStyle;
  final bool hideSkip;
  final Color colorShadow;
  final double opacityShadow;

  OverlayEntry _overlayEntry;

  TutorialCoachMark(
    this._context, {
    this.targets,
    this.colorShadow = Colors.black,
    this.clickTarget,
    this.finish,
    this.paddingFocus = 10,
    this.clickSkip,
    this.textSkip = "SKIP",
    this.textPrevious,
    this.textNext,
    this.textDone,
    this.textStyle = const TextStyle(color: Colors.white),
    this.hideSkip = false,
    this.opacityShadow = 0.8,
  }) : assert(targets != null, opacityShadow >= 0 && opacityShadow <= 1);

  OverlayEntry _buildOverlay() {
    return OverlayEntry(builder: (context) {
      return TutorialCoachMarkWidget(
        targets: targets,
        clickTarget: clickTarget,
        paddingFocus: paddingFocus,
        clickSkip: clickSkip,
        textSkip: textSkip,
        textStyle: textStyle,
        textNext: textNext,
        textDone: textDone,
        textPrevious: textPrevious,
        hideSkip: hideSkip,
        colorShadow: colorShadow,
        opacityShadow: opacityShadow,
        finish: () {
          hide();
        },
      );
    });
  }

  void show() {
    if (_overlayEntry == null) {
      _overlayEntry = _buildOverlay();
      Overlay.of(_context).insert(_overlayEntry);
    }
  }

  void hide() {
    if (finish != null) finish();
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
