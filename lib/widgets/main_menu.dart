import 'package:flutter/material.dart';
import 'package:json_buddy/widgets/main_menu_header.dart';
import 'package:json_buddy/widgets/main_menu_item.dart';

class MainMenu extends StatelessWidget {
  final List<MainMenuItem> menuItems;
  const MainMenu({
    required this.menuItems,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      children: [
        const MainMenuHeader(),
        ...menuItems,
      ],
    );
  }
}
