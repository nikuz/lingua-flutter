import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class MeasureSizeRenderObject extends RenderProxyBox {
  Size? oldSize;
  Function(Size) onChange;

  MeasureSizeRenderObject(this.onChange);

  @override
  void performLayout() {
    super.performLayout();

    Size? newSize = child?.size;
    if (oldSize == newSize) return;

    oldSize = newSize;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (newSize != null) {
        onChange(newSize);
      }
    });
  }
}

class ResizeContainer extends SingleChildRenderObjectWidget {
  final Function(Size) onChange;

  const ResizeContainer({
    super.key,
    required this.onChange,
    required Widget super.child,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return MeasureSizeRenderObject(onChange);
  }

  @override
  void updateRenderObject(BuildContext context, covariant MeasureSizeRenderObject renderObject) {
    renderObject.onChange = onChange;
  }
}