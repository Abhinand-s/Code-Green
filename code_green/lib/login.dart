import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:code_green/employee.dart'; // Import your EmployeeListPage or replace with appropriate import

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  List<String> quotes = [
    "Reduce, reuse, recycle!",
    "Waste today, save tomorrow.",
    "Every little bit counts.",
    "Think green, act green.",
    "Keep calm and recycle on.",
  ];

  String selectedQuote = "Reduce, reuse, recycle!"; // Default quote

  Future<void> signIn() async {
    setState(() {
      isLoading = true;
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      // Navigate to EmployeeListPage on successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const EmployeeListPage()),
      );
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Error', e.message ?? 'Login failed', backgroundColor: Colors.white);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Select a random quote on initialization
    selectedQuote = quotes[DateTime.now().microsecondsSinceEpoch % quotes.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50, // Subtle green background color
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete, color: Colors.green, size: 50),
                  const SizedBox(width: 20),
                  Icon(Icons.cached, color: Colors.green, size: 50),
                  const SizedBox(width: 20),
                  Icon(Icons.eco, color: Colors.green, size: 50),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                selectedQuote,
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                'Login',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  hintText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined, color: Colors.grey),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline, color: Colors.grey),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: signIn,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green,
                ),
                child: const Text('Login'),
              ),
              if (isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
