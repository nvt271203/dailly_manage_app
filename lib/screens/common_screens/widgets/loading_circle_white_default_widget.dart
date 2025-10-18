import 'package:flutter/material.dart';
class LoadingCircleWhiteDefaultWidget extends StatelessWidget {
  const LoadingCircleWhiteDefaultWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      width: 30,
      child: CircularProgressIndicator(
        color: Colors.white,

      ),
    );
  }
}
