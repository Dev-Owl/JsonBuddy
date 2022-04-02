import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:json_buddy/global.dart';
import 'package:json_buddy/helper/short_cut_provider.dart';
import 'package:json_buddy/main_screen.dart';
import 'package:json_buddy/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(
          LogicalKeyboardKey.keyF,
          control: true,
        ): () => GlobalConfig.shortCutProvider.triggerShortcut(
              JsonBuddyShortcut.search,
            )
      },
      child: MaterialApp(
        title: 'JSON Buddy',
        debugShowCheckedModeBanner: false,
        theme: jsonBoddyTheme,
        home: const MainScreen(),
      ),
    );
  }
}
