import 'package:flutter/material.dart';

class CaseDetailsPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const CaseDetailsPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [

            /// HEADER
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const Text(
                  "Case Details",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                )
              ],
            ),

            /// PATIENT INFO
            Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Patient Name: ${data['name']}"),
                      Text("Age: ${data['age']}"),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Gender: ${data['gender']}"),
                      Text("Case ID: ${data['id']}"),
                    ],
                  ),
                ],
              ),
            ),

            /// IMAGES
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.network(data['image1'], width: 140),
                Image.network(data['image2'], width: 140),
              ],
            ),

            const SizedBox(height: 15),

            /// ANALYSIS
            Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Analysis Results",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

                  const SizedBox(height: 10),

                  Text("Stenosis: ${data['stenosis']}%"),
                  Text("Detected Artery: ${data['artery']}"),

                  const SizedBox(height: 10),

                  /// Risk bar
                  LinearProgressIndicator(
                    value: data['stenosis'] / 100,
                    color: Colors.red,
                    backgroundColor: Colors.grey[300],
                  ),
                ],
              ),
            ),

            /// NOTES
            Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(data['notes']),
            ),

            const Spacer(),

            /// DOWNLOAD BUTTON
            ElevatedButton(
              onPressed: () {},
              child: const Text("Download Report"),
            ),

            const SizedBox(height: 20)
          ],
        ),
      ),
    );
  }
}