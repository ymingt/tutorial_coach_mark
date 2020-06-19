import 'dart:async';

import 'package:rxdart/rxdart.dart';

import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/animated_focus_light.dart';
import 'package:tutorial_coach_mark/content_target.dart';
import 'package:tutorial_coach_mark/target_focus.dart';
import 'package:tutorial_coach_mark/target_position.dart';
import 'package:tutorial_coach_mark/util.dart';

class TutorialCoachMarkWidget extends StatefulWidget {
  final List<TargetFocus> targets;
  final Function(TargetFocus) clickTarget;
  final Function() finish;
  final Color colorShadow;
  final double opacityShadow;
  final double paddingFocus;
  final Function() clickSkip;
  final String textSkip;
  final TextStyle textStyle;
  final bool hideSkip;
  final String textPrevious;
  final String textNext;
  final String textDone;

  const TutorialCoachMarkWidget({
    Key key,
    this.targets,
    this.finish,
    this.paddingFocus = 10,
    this.clickTarget,
    this.textSkip = "SKIP",
    this.clickSkip,
    this.textPrevious,
    this.textNext,
    this.textDone,
    this.colorShadow = Colors.black,
    this.opacityShadow = 0.8,
    this.textStyle = const TextStyle(color: Colors.white),
    this.hideSkip,
  }) : super(key: key);

  @override
  _TutorialCoachMarkWidgetState createState() =>
      _TutorialCoachMarkWidgetState();
}

class _TutorialCoachMarkWidgetState extends State<TutorialCoachMarkWidget> {
  StreamController _controllerFade = StreamController<double>.broadcast();
  StreamController _controllerTapChild = StreamController<void>.broadcast();
  StreamController _controllerTapPrevious = StreamController<void>.broadcast();
  StreamController _controllerTapNext = StreamController<void>.broadcast();
  @required
  final alignSkip = BehaviorSubject<AlignmentGeometry>();
  @required
  final alignPrevious = BehaviorSubject<AlignmentGeometry>();
  @required
  final alignNext = BehaviorSubject<AlignmentGeometry>();

  TargetFocus currentTarget;
  bool _isFirst = true;
  bool _isLast = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: <Widget>[
          AnimatedFocusLight(
            targets: widget.targets,
            finish: widget.finish,
            paddingFocus: widget.paddingFocus,
            colorShadow: widget.colorShadow,
            opacityShadow: widget.opacityShadow,
            clickTarget: (target) {
              if (widget.clickTarget != null) widget.clickTarget(target);
            },
            focus: (target, isFirst, isLast) {
              currentTarget = target;
              _controllerFade.sink.add(1.0);
              if (currentTarget.contents.first.align == AlignContent.top) {
                alignNext.add(Alignment.centerRight);
                alignPrevious.add(Alignment.topLeft);
                alignSkip.add(Alignment.topRight);
              } else if (currentTarget.contents.first.alignPreviousCenter) {
                alignNext.add(Alignment.bottomRight);
                alignPrevious.add(Alignment.centerLeft);
                alignSkip.add(Alignment.centerRight);
              } else {
                alignNext.add(Alignment.bottomRight);
                alignPrevious.add(Alignment.topLeft);
                alignSkip.add(Alignment.topRight);
              }
              setState(() {
                _isFirst = isFirst;
                _isLast = isLast;
              });
            },
            removeFocus: () {
              _controllerFade.sink.add(0.0);
            },
            streamTap: _controllerTapChild.stream,
            streamPreviousTap: _controllerTapPrevious.stream,
            streamNextTap: _controllerTapNext.stream,
          ),
          _buildContents(),
          _buildSkip(),
          _buildPrevious(),
          widget.textNext != null ? _buildNext() : Container(),
        ],
      ),
    );
  }

  _buildContents() {
    return StreamBuilder(
      stream: _controllerFade.stream,
      initialData: 0.0,
      builder: (_, snapshot) {
        try {
          return AnimatedOpacity(
            opacity: snapshot.data,
            duration: Duration(milliseconds: 300),
            child: _buildPositionedsContents(),
          );
        } catch (err) {
          return Container();
        }
      },
    );
  }

  _buildPositionedsContents() {
    if (currentTarget == null) {
      return Container();
    }

    List<Widget> widgtes = List();

    TargetPosition target = getTargetCurrent(currentTarget);
    var positioned = Offset(target.offset.dx + target.size.width / 2,
        target.offset.dy + target.size.height / 2);
    double haloWidth;
    double haloHeight;
    if (currentTarget.shape == ShapeLightFocus.Circle) {
      haloWidth = target.size.width > target.size.height
          ? target.size.width
          : target.size.height;
      haloHeight = haloWidth;
    } else {
      haloWidth = target.size.width;
      haloHeight = target.size.height;
    }
    haloWidth = haloWidth * 0.6 + widget.paddingFocus;
    haloHeight = haloHeight * 0.6 + widget.paddingFocus;
    double weight = 0.0;

    double top;
    double bottom;
    double left;

    widgtes = currentTarget.contents.map<Widget>((i) {
      switch (i.align) {
        case AlignContent.bottom:
          {
            weight = MediaQuery.of(context).size.width;
            left = 0;
            top = positioned.dy + haloHeight;
            bottom = null;
          }
          break;
        case AlignContent.top:
          {
            weight = MediaQuery.of(context).size.width;
            left = 0;
            top = null;
            bottom = haloHeight +
                (MediaQuery.of(context).size.height - positioned.dy);
          }
          break;
        case AlignContent.left:
          {
            weight = positioned.dx - haloWidth;
            left = 0;
            top = positioned.dy - target.size.height / 2 - haloHeight;
            bottom = null;
          }
          break;
        case AlignContent.right:
          {
            left = positioned.dx + haloWidth;
            top = positioned.dy - target.size.height / 2 - haloHeight;
            bottom = null;
            weight = MediaQuery.of(context).size.width - left;
          }
          break;
      }

      return Positioned(
        top: top,
        bottom: bottom,
        left: left,
        child: GestureDetector(
          onTap: () {
            _controllerTapChild.add(null);
          },
          child: Container(
            width: weight,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: i.child,
            ),
          ),
        ),
      );
    }).toList();

    return Stack(
      children: widgtes,
    );
  }

  _buildSkip() {
    if (widget.hideSkip) {
      return Container();
    }
    return StreamBuilder<AlignmentGeometry>(
      stream: alignSkip,
      builder: (context, snapshot) {
        return Align(
          alignment: snapshot.data ?? Alignment.topRight,
          child: SafeArea(
            child: StreamBuilder(
              stream: _controllerFade.stream,
              initialData: 0.0,
              builder: (_, snapshot) {
                return AnimatedOpacity(
                  opacity: snapshot.data,
                  duration: Duration(milliseconds: 300),
                  child: InkWell(
                    onTap: () {
                      widget.finish();
                      if (widget.clickSkip != null) {
                        widget.clickSkip();
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        widget.textSkip,
                        style: widget.textStyle,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  _buildPrevious() {
    if (widget.textPrevious != null && !_isFirst) {
      return StreamBuilder<AlignmentGeometry>(
        stream: alignPrevious,
        builder: (context, snapshot) {
          return Align(
            alignment: snapshot.data ?? Alignment.topLeft,
            child: SafeArea(
              child: StreamBuilder(
                stream: _controllerFade.stream,
                initialData: 0.0,
                builder: (_, snapshot) {
                  return AnimatedOpacity(
                    opacity: snapshot.data,
                    duration: Duration(milliseconds: 300),
                    child: InkWell(
                      onTap: () {
                        _controllerTapPrevious.add(null);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          widget.textPrevious,
                          style: widget.textStyle,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      );
    }
    return Container();
  }

  _buildNext() {
    return StreamBuilder<AlignmentGeometry>(
      stream: alignNext,
      builder: (context, snapshot) {
        return Align(
          alignment: snapshot.data ?? Alignment.bottomRight,
          child: SafeArea(
            child: StreamBuilder(
              stream: _controllerFade.stream,
              initialData: 0.0,
              builder: (_, snapshot) {
                return AnimatedOpacity(
                  opacity: snapshot.data,
                  duration: Duration(milliseconds: 300),
                  child: BorderedContainer(
                    margin: EdgeInsets.only(right: 16.0),
                    child: InkWell(
                      onTap: () {
                        _controllerTapNext.add(null);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          _isLast && widget.textDone != null
                              ? widget.textDone
                              : widget.textNext,
                          style: widget.textStyle,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controllerFade.close();
    _controllerTapChild.close();
    _controllerTapPrevious.close();
    _controllerTapNext.close();
    super.dispose();
  }
}

class BorderedContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry margin;

  BorderedContainer({
    this.child,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minWidth: 88.0,
      ),
      margin: margin,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.transparent,
        border: Border.all(
          width: 1.0,
          color: Colors.white,
        ),
        borderRadius: BorderRadius.all(
          Radius.circular(6.0),
        ),
      ),
      child: child,
    );
  }
}
