import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lingua_flutter/styles/styles.dart';
import 'package:lingua_flutter/widgets/button/button.dart';

import './constants.dart';

class CustomTextField extends StatefulWidget {
  final String? defaultValue;
  final TextInputAction? textInputAction;
  final Widget? prefix;
  final IconData? prefixIcon;
  final Color? prefixIconColor;
  final VoidCallback? prefixAction;
  final Widget? suffix;
  final String? hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool outlined;
  final bool underLined;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final BorderRadius? borderRadius;
  final Border? border;
  final double? elevation;
  final Color? shadowColor;
  final int? maxLength;
  final VoidCallback? onClearPressed;
  final Function(String value)? onChanged;
  final Function(String value)? onSubmitted;

  const CustomTextField({
    Key? key,
    this.defaultValue,
    this.prefix,
    this.prefixIcon,
    this.prefixIconColor,
    this.prefixAction,
    this.suffix,
    this.hintText,
    this.controller,
    this.focusNode,
    this.textInputAction,
    this.autofocus = false,
    this.underLined = false,
    this.outlined = false,
    this.padding,
    this.margin,
    this.borderRadius,
    this.border,
    this.elevation,
    this.shadowColor,
    this.maxLength,
    this.onClearPressed,
    this.onChanged,
    this.onSubmitted,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late TextEditingController _textController;
  late FocusNode _focusNode;
  String? _textValue;

  @override
  void initState() {
    super.initState();
    _textController = widget.controller ?? TextEditingController();
    _textController.addListener(_checkTextValueIntegrity);
    _focusNode = widget.focusNode ?? FocusNode();
    if (widget.defaultValue != null) {
      _textController.text = widget.defaultValue!;
      _textValue = widget.defaultValue!;
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _textController.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _checkTextValueIntegrity() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _textValue != _textController.text) {
        setState(() {
          _textValue = _textController.text;
        });
      }
    });
  }

  Widget _buildIcon({
    IconData? icon,
    VoidCallback? callback,
  }) {
    final MyTheme theme = Styles.theme(context);
    return Button(
      icon: icon,
      textColor: widget.prefixIconColor ?? theme.colors.primary,
      shape: ButtonShape.oval,
      width: 25,
      outlined: false,
      onPressed: callback,
    );
  }

  @override
  Widget build(BuildContext context) {
    final MyTheme theme = Styles.theme(context);
    final List<BoxShadow> boxShadow = [];
    BorderRadius? borderRadius = widget.borderRadius;
    Widget? prefixIcon;
    Widget? suffixIcon;
    Border? border = widget.border;

    if (widget.prefixIcon != null) {
      prefixIcon = _buildIcon(
        icon: widget.prefixIcon,
        callback: () {
          if (widget.prefixAction != null) {
            widget.prefixAction!();
          }
        },
      );
    }

    if (_textValue != null && _textValue!.isNotEmpty) {
      suffixIcon = _buildIcon(
        icon: Icons.clear,
        callback: () {
          _textController.clear();
          setState(() {
            _textValue = '';
          });
          _focusNode.requestFocus();
          if (widget.onChanged != null) {
            widget.onChanged!('');
          }
          if (widget.onClearPressed != null) {
            widget.onClearPressed!();
          }
        },
      );
    }

    if (widget.underLined) {
      border = Border(
        bottom: BorderSide(color: theme.colors.divider),
      );
    }

    if (widget.outlined) {
      border = Border.all(
        color: theme.colors.divider,
      );
      borderRadius ??= BorderRadius.circular(4);
    }

    if (widget.elevation != null) {
      boxShadow.add(
        BoxShadow(
          color: widget.shadowColor ?? Colors.black.withOpacity(0.25),
          spreadRadius: widget.elevation!,
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      );
    }

    return Container(
      margin: widget.margin,
      decoration: BoxDecoration(
        border: border,
        borderRadius: borderRadius,
        boxShadow: boxShadow,
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(0),
        child: TextField(
          controller: _textController,
          focusNode: _focusNode,
          autofocus: widget.autofocus,
          autocorrect: false,
          textInputAction: widget.textInputAction,
          onChanged: (String value) {
            setState(() {
              _textValue = value;
            });
            if (widget.onChanged != null) {
              widget.onChanged!(value);
            }
          },
          onSubmitted: (String value) {
            if (widget.onSubmitted != null) {
              widget.onSubmitted!(value);
            }
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: theme.colors.background,
            prefix: widget.prefix,
            prefixIcon: prefixIcon,
            prefixIconConstraints: const BoxConstraints(
              minWidth: TextFieldConstants.iconSize,
              minHeight: TextFieldConstants.iconSize,
            ),
            suffix: widget.suffix,
            suffixIcon: suffixIcon,
            suffixIconConstraints: const BoxConstraints(
              minWidth: TextFieldConstants.iconSize,
              minHeight: TextFieldConstants.iconSize,
            ),
            hintText: widget.hintText,
            hintStyle: const TextStyle(
              fontSize: 16,
            ),
            border: InputBorder.none,
            contentPadding: widget.padding ?? const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 14,
            ),
          ),
          inputFormatters: widget.maxLength != null
              ? [
                LengthLimitingTextInputFormatter(widget.maxLength),
              ]
              : null,
          style: const TextStyle(
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
