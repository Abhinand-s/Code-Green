import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:math';

class BinDetailsPage extends StatefulWidget {
  @override
  _BinDetailsPageState createState() => _BinDetailsPageState();
}

class _BinDetailsPageState extends State<BinDetailsPage> {
  String? selectedPlaceId;
  List<DocumentSnapshot> places = [];

  @override
  void initState() {
    super.initState();
    fetchPlaces();
  }

  void fetchPlaces() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('places').get();
    setState(() {
      places = querySnapshot.docs;
    });
  }

  // Method to calculate Euclidean distance between two points
  double calculateDistance(List<double> point1, List<double> point2) {
    double x1 = point1[0];
    double y1 = point1[1];
    double x2 = point2[0];
    double y2 = point2[1];

    double distance = sqrt(pow(x2 - x1, 2) + pow(y2 - y1, 2));
    return distance;
  }

  // Method to parse a string to a list of doubles
  List<double> parseLocation(String location) {
    try {
      List<String> parts = location.replaceAll('(', '').replaceAll(')', '').split(',');
      double x = double.parse(parts[0].trim());
      double y = double.parse(parts[1].trim());
      return [x, y];
    } catch (e) {
      print("Error parsing location: $e");
      return [0.0, 0.0]; // Return a default value in case of parsing error
    }
  }

  // Method to find the shortest path using the nearest neighbor algorithm
  List<DocumentSnapshot> findShortestPath(List<DocumentSnapshot> bins) {
    List<DocumentSnapshot> path = [];
    List<bool> visited = List<bool>.filled(bins.length, false);
    int currentIndex = 0;

    path.add(bins[currentIndex]);
    visited[currentIndex] = true;

    while (path.length < bins.length) {
      double minDistance = double.infinity;
      int nearestIndex = -1;

      for (int i = 0; i < bins.length; i++) {
        if (!visited[i]) {
          List<double> currentLocation = parseLocation((bins[currentIndex].data() as Map<String, dynamic>)['location']);
          List<double> candidateLocation = parseLocation((bins[i].data() as Map<String, dynamic>)['location']);
          double distance = calculateDistance(currentLocation, candidateLocation);

          if (distance < minDistance) {
            minDistance = distance;
            nearestIndex = i;
          }
        }
      }

      currentIndex = nearestIndex;
      path.add(bins[currentIndex]);
      visited[currentIndex] = true;
    }

    return path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bin Details'),
        backgroundColor: Colors.green[700],
      ),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/waste3.jpg', // Ensure this path is correct
              fit: BoxFit.cover,
            ),
          ),
          // Main content
          Column(
            children: [
              // Dropdown for selecting place
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Select a place',
                    filled: true,
                    fillColor: Colors.green[50],
                  ),
                  value: selectedPlaceId,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedPlaceId = newValue;
                    });
                  },
                  items: places.map<DropdownMenuItem<String>>((DocumentSnapshot document) {
                    return DropdownMenuItem<String>(
                      value: document.id,
                      child: Text(document.id),
                    );
                  }).toList(),
                ),
              ),
              // Display bins only if a place is selected
              if (selectedPlaceId != null)
                Expanded(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('places')
                        .doc(selectedPlaceId)
                        .collection('bins')
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(child: Text('No bins found for $selectedPlaceId.'));
                      }

                      // Extracting and filtering filled bins
                      List<DocumentSnapshot> filledBins = snapshot.data!.docs.where((doc) {
                        Map<String, dynamic> binData = doc.data() as Map<String, dynamic>;
                        return binData['fillStatus'] == '1';
                      }).toList();

                      // If no filled bins are found
                      if (filledBins.isEmpty) {
                        return Center(child: Text('No filled bins found for $selectedPlaceId.'));
                      }

                      // Finding the shortest path using the nearest neighbor algorithm
                      List<DocumentSnapshot> sortedBins = findShortestPath(filledBins);

                      return ListView.builder(
                        itemCount: sortedBins.length,
                        itemBuilder: (context, index) {
                          var binData = sortedBins[index].data() as Map<String, dynamic>;
                          var binId = sortedBins[index].id;
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                            child: ListTile(
                              leading: Icon(Icons.delete, color: Colors.green[800]),
                              title: Text(
                                'Step ${index + 1}: Go to Bin $binId',
                                style: TextStyle(color: Colors.green[900], fontSize: 25),
                              ),
                              subtitle: Text(
                                'Near ${binData['nearbyPoint']}',
                                style: TextStyle(color: Colors.green[700], fontSize: 20),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BinPhotoPage(
                                      binId: binId,
                                      placeName: selectedPlaceId!,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class BinPhotoPage extends StatefulWidget {
  final String binId;
  final String placeName;

  BinPhotoPage({required this.binId, required this.placeName});

  @override
  _BinPhotoPageState createState() => _BinPhotoPageState();
}

class _BinPhotoPageState extends State<BinPhotoPage> {
  late Future<String> _photoUrl;

  @override
  void initState() {
    super.initState();
    _photoUrl = fetchPhotoUrl(widget.placeName, widget.binId);
  }

  Future<String> fetchPhotoUrl(String placeName, String binId) async {
    try {
      final ref = FirebaseStorage.instance.ref().child('$placeName/$binId.jpg');
      return await ref.getDownloadURL();
    } catch (e) {
      print("Error fetching photo URL: $e");
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(' ${widget.binId} Photo'),
        backgroundColor: Colors.green[700],
      ),
      body: FutureBuilder<String>(
        future: _photoUrl,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Error loading photo'));
          }

          return Center(
            child: Image.network(snapshot.data!),
          );
        },
      ),
    );
  }
}
