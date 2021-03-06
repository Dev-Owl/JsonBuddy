import 'package:flutter/material.dart';
import 'package:json_buddy/helper/global.dart';

class MainMenuItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? toolTipText;
  final VoidCallback? onTap;

  const MainMenuItem({
    required this.title,
    required this.icon,
    this.toolTipText,
    this.onTap,
    Key? key,
  }) : super(key: key);

  Widget _optionalWrapInTooltip(Widget child) {
    if (toolTipText != null) {
      return Tooltip(
        message: toolTipText,
        waitDuration: Duration(seconds: onTap == null ? 0 : 1),
        child: child,
      );
    }
    return child;
  }

  @override
  Widget build(BuildContext context) {
    return _optionalWrapInTooltip(
      ListTile(
        leading: Icon(icon),
        title: Text(title),
        onTap: onTap == null
            ? null
            : () {
                if (isDesktopSize(context) == false) {
                  Navigator.of(context).pop();
                }
                onTap!.call();
              },
      ),
    );
  }
}
