import 'package:flutter/widgets.dart';
import 'package:tutorial_coach_mark/target_focus.dart';
import 'package:tutorial_coach_mark/target_position.dart';

RenderBox _getChildRenderObject(RenderObject renderObject) {
  RenderBox renderBox;
  renderObject.visitChildren((child) {
    renderBox = child;
  });
  return renderBox;
}

TargetPosition getTargetCurrent(TargetFocus target) {
  if (target.keyTarget != null) {
    var key = target.keyTarget;

    try {
      final RenderObject renderObject = key.currentContext.findRenderObject();
      final RenderBox renderBoxRed = renderObject is RenderBox
          ? renderObject
          : _getChildRenderObject(renderObject);
      final size = renderBoxRed.size;
      final offset = renderBoxRed.localToGlobal(Offset.zero);

      return TargetPosition(size, offset);
    } catch (e) {
      print("ERROR: Failed to get render box of key's current info");
      return null;
    }
  } else {
    return target.targetPosition;
  }
}
