import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'create.dart';
import 'details.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  int _val = 0;
  DateTime currentTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('task')
          // .where(data['Time'], isGreaterThan: currentTime)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: CircularProgressIndicator());
        }

        if (snapshot.hasData) {
          List<DocumentSnapshot> documents = snapshot.data!.docs;
          List<Map<String, dynamic>> dataList = documents
              .map((document) => document.data() as Map<String, dynamic>)
              .toList();

          return Scaffold(
            appBar: AppBar(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Crud App 2.0.0'),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const Create(),
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
            body: ListView.builder(
              itemCount: dataList.length,
              itemBuilder: (BuildContext context, int index) {
                Map<String, dynamic> data = dataList[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailsPage(
                          image: data['Image'],
                          title: data['Title'],
                          description : data['Description'],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                          radius: 20.0,
                          backgroundImage:
                              NetworkImage(data['Image'].toString()),
                          backgroundColor: Colors.transparent,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Title : ${data['Title']}'),
                            Row(
                              children: [
                                const Text('Description :'),
                                SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.45,
                                    child: Text(
                                      data['Description'] ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                    )),
                              ],
                            ),
                          ],
                        ),
                        Radio(
                          value: index,
                          groupValue: _val,
                          onChanged: (value) {
                            final docRef =
                                db.collection("task").doc(data['documentId']);
                            docRef.delete();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Task Deleted")),
                            );
                            setState(() {
                              _val = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }
        return const Text('No data available');
      },
    );
  }
}
