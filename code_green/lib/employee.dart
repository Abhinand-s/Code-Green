import 'package:code_green/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeListPage extends StatelessWidget {
  const EmployeeListPage({Key? key}) : super(key: key);

  Future<User?> getCurrentUser() async {
    return FirebaseAuth.instance.currentUser;
  }

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false); // Adjust your login page route
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false; // Disable back button
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Employee List'),
          backgroundColor: Colors.green, // Greenish color for the app bar
          automaticallyImplyLeading: false, // Remove the back button
        ),
        body: Container(
          decoration: BoxDecoration(
            color: Colors.green.shade50, // Subtle green background color
            image: DecorationImage(
              image: AssetImage('assets/images/waste_manage.png'), // Replace with your waste-related icon image path
              fit: BoxFit.contain,
              colorFilter: ColorFilter.mode(Colors.white.withOpacity(0.8), BlendMode.dstIn), // Dimming effect
            ),
          ),
          child: FutureBuilder<User?>(
            future: getCurrentUser(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text('Error fetching user'));
              }
              if (snapshot.hasData) {
                final User? user = snapshot.data;
                if (user != null) {
                  return Column(
                    children: [
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .collection('employee')
                              .snapshots(),
                          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (snapshot.hasError) {
                              return const Center(child: Text('Error fetching employees'));
                            }
                            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                              return const Center(child: Text('No employees found'));
                            }
                            return ListView(
                              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                                Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                                String employeeName = data['name'] ?? 'No Name';
                                String keyFromFirestore = data['key'] ?? '';

                                return Card(
                                  elevation: 2,
                                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  child: ListTile(
                                    title: Text(
                                      employeeName,
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                      'Position: ${data['position'] ?? 'No Position'}',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                    trailing: Icon(Icons.arrow_forward_ios), // Forward arrow icon
                                    onTap: () {
                                      _navigateToVerificationPage(context, employeeName, keyFromFirestore);
                                    },
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.all(10),
                        child: ElevatedButton(
                          onPressed: () => _signOut(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red, // Red color for the sign-out button
                            padding: EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: Text(
                            'Sign Out',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return const Center(child: Text('No user logged in'));
                }
              } else {
                return const Center(child: Text('No user logged in'));
              }
            },
          ),
        ),
      ),
    );
  }

  void _navigateToVerificationPage(BuildContext context, String employeeName, String keyFromFirestore) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => VerificationPage(employeeName: employeeName, correctKey: keyFromFirestore)),
    );
  }
}

class VerificationPage extends StatefulWidget {
  final String employeeName;
  final String correctKey;

  const VerificationPage({Key? key, required this.employeeName, required this.correctKey}) : super(key: key);

  @override
  _VerificationPageState createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  TextEditingController keyController = TextEditingController();
  bool isKeyVerified = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true; // Disable back button
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Verification for ${widget.employeeName}'),
          backgroundColor: Colors.green, // Greenish color for the app bar
        ),
        body: Container(
          decoration: BoxDecoration(
            color: Colors.green.shade50, // Subtle green background color
            image: DecorationImage(
              image: AssetImage('assets/images/waste1.png'), // Replace with your waste-related icon image path
              fit: BoxFit.contain,
              colorFilter: ColorFilter.mode(Colors.white.withOpacity(0.3), BlendMode.dstIn), // Dimming effect
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Enter verification key for ${widget.employeeName}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: keyController,
                  decoration: InputDecoration(
                    hintText: 'Enter verification key',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (keyController.text.trim() == widget.correctKey) {
                      setState(() {
                        isKeyVerified = true;
                      });
                      // Navigate to HomeScreen page upon successful verification
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                      );
                    } else {
                      // Handle incorrect key input
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Incorrect key. Please try again.')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Greenish color for the button
                    minimumSize: Size(double.infinity, 50), // Set button width to full width
                  ),
                  child: const Text(
                    'Verify',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
                if (isKeyVerified)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      'Verification successful!',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 18),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
