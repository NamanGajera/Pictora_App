import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';

import '../constants/colors.dart';

class CustomText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  final double? textScaleFactor;
  final int? maxLines;
  final String? semanticsLabel;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final Color? selectionColor;
  final FontWeight? fontWeight;
  final double? fontSize;
  final Color? color;
  final FontStyle? fontStyle;
  final double? letterSpacing;
  final double? wordSpacing;
  final TextBaseline? textBaseline;
  final double? height;
  final Paint? foreground;
  final Paint? background;
  final List<Shadow>? shadows;
  final List<FontFeature>? fontFeatures;
  final TextDecoration? decoration;
  final Color? decorationColor;
  final TextDecorationStyle? decorationStyle;
  final double? decorationThickness;
  final String? fontFamily;
  final List<String>? fontFamilyFallback;
  final String? package;

  const CustomText(
    this.text, {
    super.key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaleFactor,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
    // Shortcut properties
    this.fontWeight,
    this.fontSize,
    this.color,
    this.fontStyle,
    this.letterSpacing,
    this.wordSpacing,
    this.textBaseline,
    this.height,
    this.foreground,
    this.background,
    this.shadows,
    this.fontFeatures,
    this.decoration,
    this.decorationColor,
    this.decorationStyle,
    this.decorationThickness,
    this.fontFamily,
    this.fontFamilyFallback,
    this.package,
  });

  @override
  Widget build(BuildContext context) {
    final defaultTextStyle = DefaultTextStyle.of(context);

    TextStyle effectiveTextStyle = style ?? defaultTextStyle.style;

    // Apply shortcut properties if they are provided
    if (color != null ||
        fontWeight != null ||
        fontSize != null ||
        fontStyle != null ||
        letterSpacing != null ||
        wordSpacing != null ||
        textBaseline != null ||
        height != null ||
        foreground != null ||
        background != null ||
        shadows != null ||
        fontFeatures != null ||
        decoration != null ||
        decorationColor != null ||
        decorationStyle != null ||
        decorationThickness != null ||
        fontFamily != null ||
        fontFamilyFallback != null) {
      effectiveTextStyle = effectiveTextStyle.copyWith(
        color: color,
        fontWeight: fontWeight,
        fontSize: fontSize,
        fontStyle: fontStyle,
        letterSpacing: letterSpacing,
        wordSpacing: wordSpacing,
        textBaseline: textBaseline,
        height: height,
        foreground: foreground,
        background: background,
        shadows: shadows,
        fontFeatures: fontFeatures,
        decoration: decoration,
        decorationColor: decorationColor,
        decorationStyle: decorationStyle,
        decorationThickness: decorationThickness,
        fontFamily: fontFamily,
        fontFamilyFallback: fontFamilyFallback,
      );
    }

    return Text(
      text,
      key: key,
      style: effectiveTextStyle,
      strutStyle: strutStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap,
      overflow: overflow,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      selectionColor: selectionColor,
    );
  }
}

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String hintText;
  final TextStyle? hintStyle;
  final TextStyle? textStyle;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool obscureText;
  final bool showObscureToggle; // NEW: show eye icon toggle
  final Color borderColor;
  final Color focusedBorderColor;
  final Color enabledBorderColor;
  final Color disabledBorderColor;
  final Color errorBorderColor;
  final Color focusedErrorBorderColor;
  final Color? suffixIconColor;
  final Color? prefixIconColor;
  final Color cursorColor;
  final double borderWidth;
  final double? suffixIconSize;
  final double? prefixIconSize;
  final InputDecoration? customDecoration;
  final BoxConstraints? constraints;
  final BoxConstraints? prefixIconConstraints;
  final BoxConstraints? suffixIconConstraints;
  final String? Function(String?)? validator;
  final String? counterText;
  final Color? fillColor;
  final bool? filled;
  final EdgeInsets contentPadding;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final int? minLines;
  final int? maxLines;
  final int? maxLength;
  final void Function()? onTapSuffixIcon;
  final double borderRadius;
  final String? labelText;
  final TextStyle? labelStyle;
  final AutovalidateMode? autovalidateMode;
  final bool isRequired;
  final Widget? suffix;
  final EdgeInsetsGeometry? labelPadding;
  final bool readOnly;
  final bool enabled;
  final void Function()? onTap;
  final String? initialValue;
  final TextAlign textAlign;
  final TextCapitalization textCapitalization;

  const CustomTextField({
    super.key,
    this.controller,
    required this.hintText,
    this.hintStyle,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.showObscureToggle = false,
    this.borderColor = Colors.grey,
    this.focusedBorderColor = primaryColor,
    this.disabledBorderColor = Colors.grey,
    this.enabledBorderColor = Colors.grey,
    this.errorBorderColor = Colors.red,
    this.focusedErrorBorderColor = Colors.red,
    this.cursorColor = primaryColor,
    this.borderWidth = 1.5,
    this.customDecoration,
    this.validator,
    this.prefixIconColor,
    this.prefixIconSize,
    this.suffixIconColor,
    this.suffixIconSize,
    this.constraints,
    this.counterText,
    this.fillColor = Colors.white,
    this.filled = true,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onTapSuffixIcon,
    this.onFieldSubmitted,
    this.maxLength,
    this.maxLines,
    this.minLines,
    this.textStyle,
    this.prefixIconConstraints,
    this.suffixIconConstraints,
    this.borderRadius = 12,
    this.labelText,
    this.labelStyle,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.isRequired = false,
    this.suffix,
    this.labelPadding,
    this.readOnly = false,
    this.enabled = true,
    this.onTap,
    this.initialValue,
    this.textAlign = TextAlign.start,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.labelText != null) ...[
          Padding(
            padding: widget.labelPadding ?? const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: widget.labelText,
                        style: widget.labelStyle ??
                            const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      if (widget.isRequired)
                        const TextSpan(
                          text: ' *',
                          style: TextStyle(color: Colors.red),
                        ),
                    ],
                  ),
                ),
                if (widget.suffix != null) ...[
                  const SizedBox(width: 8),
                  widget.suffix!,
                ],
              ],
            ),
          ),
        ],
        TextFormField(
          controller: widget.controller,
          initialValue: widget.initialValue,
          obscureText: _obscure,
          cursorColor: widget.cursorColor,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          maxLength: widget.maxLength,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onFieldSubmitted,
          style: widget.textStyle,
          autovalidateMode: widget.autovalidateMode,
          readOnly: widget.readOnly,
          enabled: widget.enabled,
          onTap: widget.onTap,
          textAlign: widget.textAlign,
          textCapitalization: widget.textCapitalization,
          decoration: widget.customDecoration ??
              InputDecoration(
                hintText: widget.hintText,
                hintStyle: widget.hintStyle,
                prefixIcon: widget.prefixIcon != null
                    ? Icon(
                        widget.prefixIcon,
                        color: widget.prefixIconColor,
                        size: widget.prefixIconSize,
                      )
                    : null,
                suffixIcon: widget.showObscureToggle
                    ? IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility_off : Icons.visibility,
                          color: widget.suffixIconColor ?? Colors.grey,
                        ),
                        onPressed: () {
                          setState(() => _obscure = !_obscure);
                        },
                      )
                    : widget.suffixIcon != null
                        ? (widget.onTapSuffixIcon != null
                            ? InkWell(
                                onTap: widget.onTapSuffixIcon,
                                child: Icon(
                                  widget.suffixIcon,
                                  color: widget.suffixIconColor,
                                  size: widget.suffixIconSize,
                                ),
                              )
                            : Icon(
                                widget.suffixIcon,
                                color: widget.suffixIconColor,
                                size: widget.suffixIconSize,
                              ))
                        : null,
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: widget.borderColor, width: widget.borderWidth),
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: widget.focusedBorderColor, width: widget.borderWidth),
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: widget.enabledBorderColor, width: widget.borderWidth),
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                ),
                disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: widget.disabledBorderColor, width: widget.borderWidth),
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: widget.errorBorderColor, width: widget.borderWidth),
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: widget.focusedErrorBorderColor, width: widget.borderWidth),
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                ),
                constraints: widget.constraints,
                counterText: widget.counterText,
                contentPadding: widget.contentPadding,
                prefixIconConstraints: widget.prefixIconConstraints,
                suffixIconConstraints: widget.suffixIconConstraints,
                fillColor: widget.fillColor,
                filled: widget.filled,
              ),
        ),
      ],
    );
  }
}

class CustomDropdownButton extends StatelessWidget {
  final String? label;
  final String hint;
  final List<DropDownValueModel> dropDownList;
  final dynamic value;
  final dynamic controller;
  final Function(dynamic)? onChanged;
  final bool? enableSearch;
  final bool? isRequired;
  final String? initialValue;
  final double? fontSize;
  final double? hintFontSize;
  final double? listFontSize;
  final EdgeInsets? contentPadding;
  final BoxConstraints? constraints;
  final BoxConstraints? suffixIconConstraints;
  final int? dropDownItemCount;
  final Color? hintTextColor;
  final FontWeight? fontWeight;
  final FontWeight? hintFontWeight;
  final bool showNoData;
  final bool showLoading;
  final String? loadingText;
  final String? noDataText;

  const CustomDropdownButton({
    super.key,
    this.label,
    required this.hint,
    required this.dropDownList,
    this.value,
    this.onChanged,
    required this.controller,
    this.enableSearch,
    this.isRequired = false,
    this.initialValue,
    this.fontSize = 14,
    this.hintFontSize = 14,
    this.listFontSize = 14,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 16),
    this.constraints,
    this.suffixIconConstraints,
    this.dropDownItemCount = 4,
    this.hintTextColor = const Color(0XFF828282),
    this.fontWeight = FontWeight.w500,
    this.hintFontWeight = FontWeight.normal,
    this.showLoading = false,
    this.showNoData = false,
    this.loadingText = 'Loading data....',
    this.noDataText = 'No Data Found',
  });

  @override
  Widget build(BuildContext context) {
    // Create the final dropdown list based on state
    List<DropDownValueModel> finalDropDownList = [];

    if (showLoading) {
      finalDropDownList = [DropDownValueModel(name: loadingText!, value: '__LOADING__')];
    } else if (showNoData) {
      finalDropDownList = [DropDownValueModel(name: noDataText!, value: '__NO_DATA__')];
    } else {
      finalDropDownList = dropDownList;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          RichText(
            text: TextSpan(
              text: label,
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              children: [
                if (isRequired == true)
                  TextSpan(
                    text: " *",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        if (label != null) const SizedBox(height: 8),
        DropDownTextField(
          initialValue: initialValue,
          textStyle: TextStyle(color: Colors.black, fontSize: fontSize, fontWeight: fontWeight),
          controller: controller,
          listPadding: ListPadding(bottom: 12, top: 12),
          listSpace: -8,
          dropdownRadius: 8,
          dropDownIconProperty: IconProperty(
            icon: Icons.keyboard_arrow_down_outlined,
            color: Color(0xff8f92a1),
          ),
          searchDecoration: InputDecoration(
            contentPadding: EdgeInsets.zero,
          ),
          listTextStyle: TextStyle(
            color: Colors.black,
            fontSize: listFontSize,
            fontWeight: FontWeight.w500,
            overflow: TextOverflow.visible,
          ),
          textFieldDecoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Color(0xFFE0D8D8)),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFE0D8D8)),
              borderRadius: BorderRadius.circular(6),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: primaryColor),
              borderRadius: BorderRadius.circular(6),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red.shade300),
              borderRadius: BorderRadius.circular(6),
            ),
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: hintFontSize,
              color: hintTextColor,
              fontWeight: hintFontWeight,
            ),
            suffixStyle: TextStyle(color: Colors.green, fontSize: 14, fontWeight: FontWeight.w500),
            contentPadding: contentPadding,
            constraints: constraints,
            suffixIconConstraints: suffixIconConstraints,
          ),
          clearOption: false,
          dropDownItemCount: dropDownItemCount!,
          dropDownList: finalDropDownList,
          onChanged: (value) {
            // Prevent selection of loading and no data items
            if (value?.value == '__LOADING__' || value?.value == '__NO_DATA__') {
              // Clear the controller to prevent showing the invalid selection
              Future.delayed(Duration(milliseconds: 50), () {
                controller?.clearDropDown();
              });
              return;
            }
            // Call the original onChanged for valid selections
            onChanged?.call(value);
          },
          enableSearch: enableSearch ?? false,
        )
      ],
    );
  }
}

class CustomCheckboxDropdown extends StatefulWidget {
  final List<CheckboxDropdownItem> items;
  final Function(List<int>) onSelectionChanged;
  final DropdownDecoration decoration;
  final String? placeholder;
  final String? selectAllText;
  final Widget? prefix;
  final Widget? suffix;
  final List<int>? initialValue;

  const CustomCheckboxDropdown({
    super.key,
    required this.items,
    required this.onSelectionChanged,
    this.decoration = const DropdownDecoration(),
    this.placeholder = 'Select Items',
    this.selectAllText = 'Select All',
    this.prefix,
    this.suffix,
    this.initialValue,
  });

  @override
  State<CustomCheckboxDropdown> createState() => _CustomCheckboxDropdownState();
}

class _CustomCheckboxDropdownState extends State<CustomCheckboxDropdown> {
  final LayerLink _layerLink = LayerLink();
  bool _isDropdownOpen = false;
  OverlayEntry? _overlayEntry;
  bool _selectAll = false;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _updateSelectAllState() {
    setState(() {
      _selectAll = widget.items.isEmpty ? false : widget.items.every((item) => item.isSelected == true);
    });
  }

  void _toggleSelectAll(bool? value) {
    setState(() {
      _selectAll = value ?? false;
      for (var item in widget.items) {
        item.isSelected = _selectAll;
      }
      _notifySelectionChanged();
    });
    Future.delayed(
      Duration(milliseconds: 50),
      () {
        _hideDropdown();
      },
    );
  }

  void _toggleItem(int index, bool? value) {
    setState(() {
      widget.items[index].isSelected = value ?? false;
      _updateSelectAllState();
      _notifySelectionChanged();
    });
    Future.delayed(
      Duration(milliseconds: 50),
      () {
        _hideDropdown();
      },
    );
  }

  void _loadInitialCheck(List<int> listOfInt) {
    setState(() {
      log("Received listOfInt: $listOfInt  ${widget.items.length}");
      for (var element in listOfInt) {
        log("Processing element: $element");
        for (var i = 0; i < widget.items.length; i++) {
          log("Comparing widget.items[$i].id (${widget.items[i].id}) with $element");
          if (widget.items[i].id == element) {
            widget.items[i].isSelected = true;
            log("Item matched: ${widget.items[i]}");
          }
        }
      }

      _updateSelectAllState();
    });
  }

  void _notifySelectionChanged() {
    final selectedIds = widget.items.where((item) => item.isSelected).map((item) => item.id).toList();
    widget.onSelectionChanged(selectedIds);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showDropdown() {
    _removeOverlay();

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _hideDropdown,
            ),
          ),
          Positioned(
            width: size.width,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0.0, size.height + 5.0),
              child: Material(
                elevation: widget.decoration.elevation,
                borderRadius: BorderRadius.circular(widget.decoration.borderRadius),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {},
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * widget.decoration.maxHeight,
                    ),
                    decoration: widget.decoration.dropdownDecoration ??
                        BoxDecoration(
                          color: widget.decoration.backgroundColor,
                          border: Border.all(color: widget.decoration.borderColor),
                          borderRadius: BorderRadius.circular(widget.decoration.borderRadius),
                        ),
                    child: StatefulBuilder(
                      builder: (context, setState) {
                        return SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CheckboxListTile(
                                title: Text(
                                  widget.selectAllText ?? 'Select All',
                                  style: widget.decoration.itemTextStyle,
                                ),
                                value: _selectAll,
                                onChanged: (value) {
                                  _toggleSelectAll(value);
                                  setState(() {});
                                },
                                activeColor: widget.decoration.checkboxActiveColor,
                                controlAffinity: ListTileControlAffinity.leading,
                              ),
                              const Divider(height: 1),
                              ...List.generate(
                                widget.items.length,
                                (index) => CheckboxListTile(
                                  title: Text(
                                    widget.items[index].name,
                                    style: widget.decoration.itemTextStyle,
                                  ),
                                  value: widget.items[index].isSelected,
                                  onChanged: (value) {
                                    _toggleItem(index, value);
                                    setState(() {});
                                  },
                                  activeColor: widget.decoration.checkboxActiveColor,
                                  controlAffinity: ListTileControlAffinity.leading,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isDropdownOpen = true);
  }

  void _hideDropdown() {
    _removeOverlay();
    setState(() => _isDropdownOpen = false);
  }

  @override
  void initState() {
    super.initState();
    _updateSelectAllState();

    log('widget.initialValue ${widget.initialValue}');

    if (widget.initialValue != null && widget.initialValue!.isNotEmpty) {
      _loadInitialCheck(widget.initialValue!);
    }
  }

  @override
  void didUpdateWidget(covariant CustomCheckboxDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);

    log('widget.didUpdateWidget ${widget.initialValue}');

    _updateSelectAllState();
    // Check if initialValue has changed
    if (widget.initialValue != oldWidget.initialValue) {
      if (widget.initialValue != null && widget.initialValue!.isNotEmpty) {
        _loadInitialCheck(widget.initialValue!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String selectedItemsText = widget.items.where((item) => item.isSelected).map((item) => item.name).join(', ');

    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: () {
          if (_isDropdownOpen) {
            _hideDropdown();
          } else {
            _showDropdown();
          }
        },
        child: Container(
          padding: widget.decoration.contentPadding,
          decoration: widget.decoration.buttonDecoration ??
              BoxDecoration(
                border: Border.all(color: widget.decoration.borderColor),
                borderRadius: BorderRadius.circular(widget.decoration.borderRadius),
                color: widget.decoration.backgroundColor,
              ),
          child: Row(
            children: [
              if (widget.prefix != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: widget.prefix,
                ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // If text overflows, show ellipsis
                    return Text(
                      selectedItemsText.isEmpty ? widget.placeholder ?? 'Select Items' : selectedItemsText,
                      style: selectedItemsText.isEmpty
                          ? widget.decoration.headerTextStyle
                          : TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    );
                  },
                ),
              ),
              if (widget.suffix != null) widget.suffix!,
              if (widget.suffix == null)
                widget.decoration.dropdownIcon ??
                    Icon(
                      _isDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                      color: widget.decoration.dropdownIconColor,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class DropdownDecoration {
  final double borderRadius;
  final Color borderColor;
  final Color backgroundColor;
  final EdgeInsets contentPadding;
  final double elevation;
  final double maxHeight;
  final TextStyle? headerTextStyle;
  final TextStyle? itemTextStyle;
  final Color? checkboxActiveColor;
  final Color? dropdownIconColor;
  final Widget? dropdownIcon;
  final Widget? selectedIcon;
  final BoxDecoration? buttonDecoration;
  final BoxDecoration? dropdownDecoration;
  final List<BoxShadow>? boxShadow;

  const DropdownDecoration({
    this.borderRadius = 6.0,
    this.borderColor = const Color(0xFFE0D8D8),
    this.backgroundColor = Colors.white,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    this.elevation = 4.0,
    this.maxHeight = 0.3, // 30% of screen height
    this.headerTextStyle = const TextStyle(color: Color(0XFF828282), fontSize: 14),
    this.itemTextStyle,
    this.checkboxActiveColor,
    this.dropdownIconColor = Colors.grey,
    this.dropdownIcon,
    this.selectedIcon,
    this.buttonDecoration,
    this.dropdownDecoration,
    this.boxShadow,
  });
}

class CheckboxDropdownItem {
  final String name;
  final int id;
  bool isSelected;

  CheckboxDropdownItem({
    required this.name,
    required this.id,
    this.isSelected = false,
  });
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Color textColor;
  final double height;
  final double? width;
  final double fontSize;
  final FontWeight fontWeight;
  final double borderRadius;
  final double loaderSize;
  final double loaderStrokeWidth;
  final Color loaderColor;
  final Color borderColor;
  final bool showLoader;

  const CustomButton({
    super.key,
    required this.text,
    required this.onTap,
    this.backgroundColor = primaryColor,
    this.borderColor = Colors.transparent,
    this.textColor = Colors.white,
    this.loaderColor = Colors.white,
    this.height = 45,
    this.width,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w500,
    this.borderRadius = 10.0,
    this.loaderSize = 22.0,
    this.loaderStrokeWidth = 2.0,
    this.showLoader = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: height,
        width: width ?? double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: showLoader
            ? SizedBox(
                height: loaderSize,
                width: loaderSize,
                child: CircularProgressIndicator(
                  color: loaderColor,
                  strokeWidth: loaderStrokeWidth,
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontSize: fontSize,
                  fontWeight: fontWeight,
                ),
              ),
      ),
    );
  }
}

class RoundProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final Color backgroundColor;
  final IconData fallbackIcon;

  const RoundProfileAvatar({
    super.key,
    this.imageUrl,
    this.radius = 42,
    this.backgroundColor = const Color(0xffF5F5F5),
    this.fallbackIcon = Icons.person_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = (imageUrl ?? '').isNotEmpty;

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      child: hasImage
          ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: imageUrl!,
                cacheKey: imageUrl!,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[100],
                  child: const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xff9CA3AF),
                        ),
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: const Color(0xffF3F4F6),
                  child: Icon(
                    Icons.image_outlined,
                    color: const Color(0xff9CA3AF),
                    size: radius, // scale with radius
                  ),
                ),
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                fadeInDuration: Duration.zero,
                fadeOutDuration: Duration.zero,
              ),
            )
          : Icon(
              fallbackIcon,
              size: radius, // scaled to avatar size
              color: const Color(0xff9CA3AF),
            ),
    );
  }
}
