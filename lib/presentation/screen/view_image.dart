import 'package:flutter/material.dart';

class ViewImage extends StatelessWidget {
  final String image;

  const ViewImage({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Image(
          image: NetworkImage(image),
        ),
      ),
    );
  }
}
