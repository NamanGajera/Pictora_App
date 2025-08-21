// Flutter
import 'package:flutter/material.dart';

extension WidgetExtensions on Widget {
  // Add padding to a widget
  Widget withPadding([EdgeInsets padding = const EdgeInsets.all(8.0)]) {
    return Padding(
      padding: padding,
      child: this,
    );
  }

  // Add alignment to a widget
  Widget withAlignment(Alignment alignment) {
    return Align(
      alignment: alignment,
      child: this,
    );
  }

  // Wrap a widget in a Center
  Widget centered() {
    return Center(
      child: this,
    );
  }

  // Expand Widget
  Widget expand([int flex = 1]) {
    return Expanded(
      flex: flex,
      child: this,
    );
  }

  // Flexible Widget
  Widget flexible([int flex = 1]) {
    return Flexible(
      flex: flex,
      child: this,
    );
  }

  // Wrap a widget in a GestureDetector
  Widget onTap(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: this,
    );
  }
}

/// Extension for AutomaticKeepAliveClientMixin
extension KeepAliveExtension on Widget {
  /// Wraps the widget with AutomaticKeepAliveClientMixin behavior
  Widget withAutomaticKeepAlive() {
    return _KeepAliveWrapper(child: this);
  }
}

class _KeepAliveWrapper extends StatefulWidget {
  final Widget child;

  const _KeepAliveWrapper({required this.child});

  @override
  _KeepAliveWrapperState createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<_KeepAliveWrapper> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context); // Necessary for AutomaticKeepAliveClientMixin
    return widget.child;
  }

  @override
  bool get wantKeepAlive => true;
}
