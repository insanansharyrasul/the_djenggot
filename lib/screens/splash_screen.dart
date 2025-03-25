import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Splash Screen"),
            SizedBox(height: 8),
            ElevatedButton(onPressed: () => context.push('/home'), child: Text("Go to HomePage"))
          ],
        ),
      ),
    );
  }
}
