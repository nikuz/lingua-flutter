import 'package:flutter/material.dart';

import './constants.dart';

class CustomTextField extends StatefulWidget {
  final String? defaultValue;
  final TextInputAction? textInputAction;
  final Widget? prefix;
  final Widget? prefixIcon;
  final VoidCallback? prefixAction;
  final Widget? suffix;
  final String? hintText;
  final TextEditingController? controller;
  final bool autofocus;
  final bool framed;
  final VoidCallback? onClearPressed;
  final Function(String value)? onChanged;
  final Function(String value)? onSubmitted;

  const CustomTextField({
    Key? key,
    this.defaultValue,
    this.prefix,
    this.prefixIcon,
    this.prefixAction,
    this.suffix,
    this.hintText,
    this.controller,
    this.textInputAction,
    this.autofocus = false,
    this.framed = false,
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
    _focusNode = FocusNode();
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
    _focusNode.dispose();
    super.dispose();
  }

  Widget _buildIcon({
    Widget? icon,
    VoidCallback? callback,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Material(
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: callback,
          child: icon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget? prefixIcon;
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

    Widget? suffixIcon;
    if (_textValue != null && _textValue!.isNotEmpty) {
      suffixIcon = _buildIcon(
        icon: const Icon(
          Icons.clear,
          size: 25,
          color: Colors.grey,
        ),
        callback: () {
          _textController.clear();
          _focusNode.requestFocus();
          if (widget.onClearPressed != null) {
            widget.onClearPressed!();
          }
        },
      );
    }

    InputBorder border = const UnderlineInputBorder(
      borderSide: BorderSide(color: Color.fromRGBO(0, 0, 0, 0.2)),
    );
    if (widget.framed) {
      border = const OutlineInputBorder(
        borderSide: BorderSide(color: Color.fromRGBO(0, 0, 0, 0.2)),
      );
    }

    return TextField(
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
        fillColor: Theme.of(context).scaffoldBackgroundColor,
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
        border: InputBorder.none,
        enabledBorder: border,
        focusedBorder: border,
      ),
      style: const TextStyle(
        fontSize: 18,
      ),
    );
  }
}
