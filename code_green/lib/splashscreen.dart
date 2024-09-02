import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final Widget? child;
  const SplashScreen({Key? key, this.child}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => widget.child!),
        (Route<dynamic> route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFede1d1),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Image.asset(
                    'assets/images/imag1.jpg', // Ensure this path is correct
                    fit: BoxFit.contain, // Ensures the image fits the screen
                    //width: double.infinity,
                   // height: double.infinity,
                  ),
                ),
                //const SizedBox(height: 20),
                // const Text(
                //   "NEST",
                //   style: TextStyle(
                //     color: Color.fromARGB(255, 2, 7, 3),
                //     fontSize: 30,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
                // const SizedBox(height: 30),
                // const Text(
                //   "Not Just For New Born Babies..But For New Born Parents Too..",
                //   style: TextStyle(
                //     color: Color.fromARGB(255, 3, 16, 4),
                //     fontSize: 16,
                //   ),
                //   textAlign: TextAlign.center,
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
