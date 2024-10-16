import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lingua_flutter/styles/styles.dart';
import 'package:lingua_flutter/widgets/resize_container/resize_container.dart';
import 'package:lingua_flutter/utils/remap_value.dart';

import './constants.dart';

class ImagePreviewModal {
  final BuildContext context;
  final Widget child;
  final bool isFramed;

  const ImagePreviewModal({
    required this.context,
    required this.child,
    this.isFramed = true,
  });

  static dismiss(BuildContext context) {
    Navigator.of(context, rootNavigator: true).maybePop();
  }

  Future show() {
    return showGeneralDialog(
      context: context,
      barrierLabel: '',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 100),
      pageBuilder: (BuildContext context, Animation animation, Animation secondaryAnimation) {
        return ImagePreviewModalContent(
          isFramed: isFramed,
          close: () {
            ImagePreviewModal.dismiss(context);
          },
          child: child,
        );
      },
    );
  }
}

class ImagePreviewModalContent extends StatefulWidget {
  final Widget child;
  final bool isFramed;
  final VoidCallback close;

  const ImagePreviewModalContent({
    super.key,
    required this.child,
    this.isFramed = true,
    required this.close,
  });

  @override
  State<ImagePreviewModalContent> createState() => _ImagePreviewModalContentState();
}

class _ImagePreviewModalContentState extends State<ImagePreviewModalContent> {
  bool _isVisible = false;
  late Size _screenSize;
  Size? _childSize;
  Offset _childPosition = Offset.zero;
  Offset _initialFocalPoint = Offset.zero;
  Offset _offset = Offset.zero;
  Offset _initialOffset = Offset.zero;
  double _scale = 1.0;
  double _initialScale = 1.0;
  bool _animated = false;
  double _opacity = 1;
  bool _scalingIsInProgress = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final screenSize = MediaQuery.of(context).size;

    setState(() {
      _screenSize = screenSize;
      _childPosition = _getChildScaledPosition(scale: _scale, screenSize: screenSize);
      // next properties are set for proper centering on screen rotation change
      _animated = false;
      _offset = Offset.zero;
    });
  }

  Offset? _getChildCenterPosition({Size? screenSize, Size? childSize}) {
    screenSize ??= _screenSize;
    childSize ??= _childSize;

    if (childSize != null) {
      return Offset(
        screenSize.width / 2 - childSize.width / 2,
        screenSize.height / 2 - childSize.height / 2,
      );
    }

    return null;
  }

  Size _getChildScaledSize(double scale) {
    final childSize = _childSize ?? Size.zero;
    return Size(childSize.width * scale, childSize.height * scale);
  }

  Offset _getChildScaledPosition({required double scale, Size? screenSize}) {
    final scaledChildSize = _getChildScaledSize(scale);
    if (scaledChildSize == Size.zero) {
      return Offset.zero;
    }
    return _getChildCenterPosition(childSize: scaledChildSize, screenSize: screenSize) ?? Offset.zero;
  }

  void _onChildResize(Size childSize) {
    final childPosition = _getChildCenterPosition(childSize: childSize);
    setState(() {
      _childSize = childSize;
      _childPosition = childPosition ?? _childPosition;
      _isVisible = true;
    });
  }

  double _getHideThreshold() => _screenSize.height * 0.2;

  bool _getIsDismissible({required double scale}) {
    final childSize = _getChildScaledSize(scale);
    final childHeightIsBiggerThanScreen = childSize.height > _screenSize.height;

    return _scale == 1 || !childHeightIsBiggerThanScreen;
  }

  void _onDoubleTap() {
    double scale = 1;
    if (_scale == 1) {
      scale = 2;
    }

    setState(() {
      _scale = scale;
      _animated = true;
      _offset = Offset.zero;
      _childPosition = _getChildScaledPosition(scale: scale);
    });
  }

  void _onScaleStart(ScaleStartDetails details) {
    _scalingIsInProgress = true;
    _initialFocalPoint = details.focalPoint;
    _initialScale = _scale;
    _initialOffset = _offset;
    _animated = false;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (!_scalingIsInProgress) {
      return;
    }

    double scale = 1;
    Offset offset = _initialOffset + (details.focalPoint - _initialFocalPoint);
    double opacity = 1;
    Offset childPosition = _childPosition;
    Size childSize = _childSize ?? Size.zero;

    scale = min(max(_initialScale * details.scale, ImagePreviewConstants.minScale), ImagePreviewConstants.maxScale);
    childPosition = _getChildScaledPosition(scale: scale);
    childSize = _getChildScaledSize(scale);

    final isDismissible = _getIsDismissible(scale: scale);
    if (isDismissible) {
      opacity = remapValue(
        value: offset.dy.abs(),
        inMin: 30,
        inMax: _getHideThreshold(),
        outMin: 1,
        outMax: 0,
      );
    }

    if (scale == _scale) {
      if (childSize.width > _screenSize.width) {
        // if width-oversized picture is dragged farther than the left screen edge
        if (childPosition.dx + offset.dx > 0) {
          // then stick the left picture edge to the left screen edge
          offset = Offset((childSize.width - _screenSize.width) / 2, offset.dy);
        }
        // if width-oversized picture is dragged farther than the right screen edge
        else if (childPosition.dx + offset.dx < _screenSize.width - childSize.width) {
          // then stick the right picture edge to the right screen edge
          offset = Offset((_screenSize.width - childSize.width) / 2, offset.dy);
        }
      }
      if (childSize.height > _screenSize.height) {
        // if height-oversized picture is dragged farther than the top screen edge
        if (childPosition.dy + offset.dy > 0) {
          // then stick the top picture edge to the top screen edge
          offset = Offset(offset.dx, (childSize.height - _screenSize.height) / 2);
        }
        // if height-oversized picture is dragged farther than the bottom screen edge
        else if (childPosition.dy + offset.dy < _screenSize.height - childSize.height) {
          // then stick right picture edge to the right screen edge
          offset = Offset(offset.dx, (_screenSize.height - childSize.height) / 2);
        }
      }
    }

    // we still need to check for _scalingIsInProgress here, because _onScaleEnd can be called after _onScaleUpdate already started but not finished yet
    if (_scalingIsInProgress && (offset != _offset || scale != _scale)) {
      setState(() {
        _offset = offset;
        _scale = scale;
        _opacity = opacity;
        _childPosition = childPosition;
      });
    }
  }

  void _onScaleEnd(ScaleEndDetails details) {
    _scalingIsInProgress = false;
    double hideThreshold = _getHideThreshold();
    final isDismissible = _getIsDismissible(scale: _scale);

    if (isDismissible && _offset.dy.abs() > hideThreshold) {
      widget.close();
    } else {
      Offset offset = _offset;
      if (_scale == 1) {
        offset = Offset.zero;
      }
      if (_childSize != null) {
        if (_childSize!.width * _scale < _screenSize.width) {
          offset = Offset(0, offset.dy);
        }
        if (_childSize!.height * _scale < _screenSize.height) {
          offset = Offset(offset.dx, 0);
        }
      }
      setState(() {
        _offset = offset;
        _animated = true;
        _opacity = 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final MyTheme theme = Styles.theme(context);
    Widget content = widget.child;
    final animationDuration = _animated ? ImagePreviewConstants.positionAnimationDuration : Duration.zero;

    if (widget.isFramed) {
      final double screenWidth = MediaQuery.of(context).size.width;
      content = Container(
        width: screenWidth - screenWidth * 0.2,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.colors.background,
          borderRadius: BorderRadius.circular(4),
        ),
        child: widget.child,
      );
    }

    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onScaleStart: _onScaleStart,
        onScaleUpdate: _onScaleUpdate,
        onScaleEnd: _onScaleEnd,
        child: Stack(
          children: [
            // hidden child for size measurement only
            if (_childPosition == Offset.zero)
              Positioned(
                left: -_screenSize.width,
                top: -_screenSize.height,
                child: Opacity(
                  opacity: 0,
                  child: ResizeContainer(
                    onChange: _onChildResize,
                    child: content,
                  ),
                ),
              ),

            GestureDetector(
              onTap: widget.close,
              child: AnimatedOpacity(
                duration: animationDuration,
                opacity: _opacity,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: const Color(0xA0000000),
                ),
              ),
            ),
            AnimatedPositioned(
              left: _childPosition.dx + _offset.dx,
              top: _childPosition.dy + _offset.dy - MediaQuery.of(context).viewInsets.bottom / 2,
              width: _childSize != null ? _childSize!.width * _scale : null,
              height: _childSize != null ? _childSize!.height * _scale : null,
              duration: animationDuration,
              curve: Styles.variables.easeInOut,
              child: AnimatedOpacity(
                opacity: _isVisible ? max(_opacity, 0.3) : 0,
                duration: animationDuration,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onDoubleTap: _onDoubleTap,
                  child: content,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}