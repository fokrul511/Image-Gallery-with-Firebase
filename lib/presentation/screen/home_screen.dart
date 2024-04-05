import 'dart:io';

import 'package:firebase_gridview_projects/presentation/screen/view_image.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> allimageList = [];

  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  bool inProgress = false;

  @override
  void initState() {
    super.initState();
    fetchImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gallary"),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          fetchImage();
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GridView.builder(
            itemCount: allimageList.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
            ),
            itemBuilder: (context, index) {
              return Visibility(
                visible: inProgress == false,
                replacement: const Center(
                  child: CircularProgressIndicator(),
                ),
                child: GestureDetector(
                  onTap: () {
                    Get.to(() => ViewImage(image: allimageList[index]));
                  },
                  child: Card(
                    elevation: 5,
                    child: Image.network(
                      allimageList[index],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          pickImage();
        },
        child: const Icon(
          Icons.camera,
        ),
      ),
    );
  }

  Future<void> fetchImage() async {
    inProgress = true;
    setState(() {});
    var allImage = _firebaseStorage.ref().child('gallary/');
    ListResult imageList = await allImage.listAll();
    allimageList.clear();

    for (Reference ref in imageList.items) {
      String dwonlodeUrl = await ref.getDownloadURL();
      allimageList.add(dwonlodeUrl);
      setState(() {});
    }
    inProgress = false;
    setState(() {});
  }

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      String imageName = pickedFile.path.split('/').last;
      firebaseImageUpload(File(pickedFile.path), imageName);
    } else {
      print('No image selected.');
    }
  }

  Future<void> firebaseImageUpload(image, String imageName) async {
    Reference storage = _firebaseStorage.ref().child("gallary/$imageName");
    storage.putFile(image).whenComplete(() => {
          Get.back(),
          Get.snackbar(
            "Successful",
            "Image Uploaded Successfully",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.black,
            colorText: Colors.white,
            animationDuration: const Duration(milliseconds: 300),
          )
        });
  }
}
