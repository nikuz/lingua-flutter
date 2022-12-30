import 'package:flutter/material.dart';
import 'package:lingua_flutter/styles/styles.dart';
import 'package:lingua_flutter/widgets/resize_container/resize_container.dart';

class ModalContent extends StatefulWidget {
  final Widget child;
  final bool isFramed;
  final VoidCallback close;

  const ModalContent({
    Key? key,
    required this.child,
    this.isFramed = true,
    required this.close,
  }) : super(key: key);

  @override
  State<ModalContent> createState() => _ModalContentState();
}

class _ModalContentState extends State<ModalContent> {
  bool _isVisible = false;
  Offset? _childPosition;

  @override
  Widget build(BuildContext context) {
    final MyTheme theme = Styles.theme(context);
    Widget content = widget.child;

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
      child: Stack(
        children: [
          GestureDetector(
            onTap: widget.close,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: const Color(0x80000000),
            ),
          ),
          Positioned(
            left: _childPosition?.dx,
            top: (_childPosition?.dy ?? 0) - MediaQuery.of(context).viewInsets.bottom / 2,
            child: Opacity(
              opacity: _isVisible ? 1 : 0,
              child: ResizeContainer(
                onChange: (Size childSize) {
                  Size screenSize = MediaQuery.of(context).size;

                  setState(() {
                    _childPosition = Offset(
                      screenSize.width / 2 - childSize.width / 2,
                      screenSize.height / 2 - childSize.height / 2,
                    );
                    _isVisible = true;
                  });
                },
                child: content,
              ),
            ),
          ),
        ],
      ),
    );
  }
}