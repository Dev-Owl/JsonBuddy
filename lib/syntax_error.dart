import 'package:flutter/material.dart';

class SyntaxError extends StatelessWidget {
  final FormatException lastError;
  const SyntaxError(this.lastError, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        color: Colors.red,
        width: double.infinity,
        padding: const EdgeInsets.only(
          top: 10,
        ),
        child: Text(
          lastError.toString(),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
