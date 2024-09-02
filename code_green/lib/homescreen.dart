// ignore_for_file: sort_child_properties_last

import 'package:code_green/employee.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // for formatting time

// ignore: use_key_in_widget_constructors
class HomeScreen extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String currentTime = '';

  @override
  void initState() {
    super.initState();
    _updateTime();
  }

  void _updateTime() {
    final now = DateTime.now();
    final formattedTime = DateFormat('hh:mm a').format(now); // 12-hour format
    setState(() {
      currentTime = formattedTime;
    });
    // Update the time every minute
    Future.delayed(const Duration(minutes: 1), _updateTime);
  }

  Future<List<Map<String, dynamic>>> _getBinStatus() async {
    final placesCollection = FirebaseFirestore.instance.collection('places');
    final placeDocs = await placesCollection.get();
    List<Map<String, dynamic>> binStatusList = [];

    for (var placeDoc in placeDocs.docs) {
      final placeName = placeDoc.id;
      final binsCollection = placesCollection.doc(placeName).collection('bins');
      final binDocs = await binsCollection.get();
      int filledCount = 0;

      for (var binDoc in binDocs.docs) {
        if (binDoc.data()['fillStatus'] == "1") {
          filledCount++;
        }
      }
      binStatusList.add({
        'placeName': placeName,
        'filledBins': filledCount,
      });
    }
    return binStatusList;
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        return false; // Disable back button
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Code Green'),
          backgroundColor: const Color(0xFFfbca03),
          automaticallyImplyLeading: false, // Remove the back button
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              color: Colors.red,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EmployeeListPage()), // Direct navigation
                );
              },
            ),
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/waste2.jpg"), // Replace with your image path
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.yellow[300]?.withOpacity(0.8),
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      currentTime,
                      style: const TextStyle(fontSize: 48, color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    'Bin Fill Status',
                    style: TextStyle(fontSize: 24, color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _getBinStatus(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No data available', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)));
                      } else {
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: const [
                              DataColumn(
                                label: Text('Place', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black,fontSize:25)),
                              ),
                              DataColumn(
                                label: Text('Total Filled Bins', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black,fontSize:25)),
                              ),
                            ],
                            rows: snapshot.data!.map((data) => DataRow(
                              cells: [
                                DataCell(
                                  Text(data['placeName'], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black,fontSize:25)),
                                ),
                                DataCell(
                                  Text('${data['filledBins']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black,fontSize:25)),
                                ),
                              ],
                            )).toList(),
                            columnSpacing: 20,
                            dividerThickness: 2,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(height: 20),
                // ignore: sized_box_for_whitespace
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/collect'); // Replace '/collect' with your route name
                    },
                    child: const Text(
                      'Collect',
                      style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      // ignore: deprecated_member_use
                      backgroundColor: Colors.yellow.shade700, // Bright yellow button color
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
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
