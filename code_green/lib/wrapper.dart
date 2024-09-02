import 'package:code_green/employee.dart';
//import 'package:code_green/maping.dart';
import 'package:code_green/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }
          if (snapshot.hasData) {
            final user = snapshot.data;
            if (user != null) {
              return const EmployeeListPage(); // Navigate to the main page
            }
          }
          return const Login(); // Show the Login screen if no user is logged in
        },
      ),
    );
  }
}
