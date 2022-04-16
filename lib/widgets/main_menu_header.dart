import 'package:flutter/material.dart';

class MainMenuHeader extends StatelessWidget {
  const MainMenuHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DrawerHeader(
      decoration: BoxDecoration(
        color: Colors.orange[300]!,
      ),
      child: Stack(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Image(
              fit: BoxFit.scaleDown,
              image: AssetImage('assets/images/logo_128.png'),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'JSON Buddy',
              style: Theme.of(context).textTheme.headline6!.copyWith(
                    color: Colors.black,
                  ),
            ),
          )
        ],
      ),
    );
  }
}
