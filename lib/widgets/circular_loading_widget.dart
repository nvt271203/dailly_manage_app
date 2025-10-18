import 'package:flutter/material.dart';

class CircularLoadingWidget extends StatelessWidget {
  const CircularLoadingWidget({super.key, this.message = "Loading..."});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.blueAccent, Colors.lightBlueAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            // const SizedBox(height: 16),
            // Text(
            //   message,
            //   style: const TextStyle(
            //     fontSize: 16,
            //     color: Colors.blueAccent,
            //     fontWeight: FontWeight.bold,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
