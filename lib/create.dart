import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


class Create extends StatefulWidget {
  const Create({Key? key}) : super(key: key);

  @override
  State<Create> createState() => _CreateState();
}

class _CreateState extends State<Create> {
  final _formKey = GlobalKey<FormState>();
  FirebaseFirestore db = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;
  final _storageRef = FirebaseStorage.instance.ref();
  final ImagePicker _picker = ImagePicker();
  late File _imageFile;

  String _message = '';
  String _description = '';
  String _imageUrl = "";

  _sendDataToFirebase() {
      CollectionReference collectionRef =
      FirebaseFirestore.instance.collection('task');

      DocumentReference docRef = collectionRef.doc();
      String documentId = docRef.id;
      Map<String, dynamic> data = {
        'Title': _message,
        'Description': _description,
        'Image': _imageUrl,
        'documentId': documentId,
        'Time' : DateTime.now(),
  };

      docRef.set(data).then((value) {}).catchError((error) {});
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(
      //     builder: (_) => const HomePage(),
      //   ),
      // );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data Entered")),
      );
    }

  _uploadImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );

    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });

      try {
        final imageRef = _storageRef.child("images/${image.name}");
        await imageRef.putFile(_imageFile);
        _imageUrl = await imageRef.getDownloadURL();
        debugPrint(_imageUrl);
      } on FirebaseException catch (e) {
        debugPrint("Error => ${e.message}");
      }
    } else {
      debugPrint("Error occurred while uploading image");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crud App'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey[200]),
                child: TextFormField(
                  maxLines: 2,
                  keyboardType: TextInputType.text,
                  onChanged: (value) => _message = value.trim(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Title';
                    }
                    return null;
                  },
                  style: const TextStyle(fontSize: 14),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Enter Title",
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey[200]),
                child: TextFormField(
                  maxLines: 5,
                  keyboardType: TextInputType.text,
                  onChanged: (value) => _description = value.trim(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Description';
                    }
                    return null;
                  },
                  style: const TextStyle(fontSize: 14),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Enter Description",
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey[300]),
                child: IconButton(
                  onPressed: () {
                    _uploadImage();
                  },
                  icon: const Icon(
                    Icons.image,
                    size: 20,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _sendDataToFirebase();
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
