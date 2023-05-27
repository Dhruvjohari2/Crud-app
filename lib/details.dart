import 'package:flutter/material.dart';

class DetailsPage extends StatefulWidget {
  DetailsPage({
    Key? key,
    required this.image,
    required this.title,
    required this.description,
  }) : super(key: key);

  String image;
  String title;
  String description;

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50.0,
                backgroundImage: NetworkImage(widget.image),
              ),
              Text(
                widget.title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              Text(
                widget.description,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
