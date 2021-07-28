// Image Picker

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';

Future<File> pickImage() async {
  ImagePicker picker = ImagePicker();
  PickedFile pickedFile = await picker.getImage(
    source: ImageSource.gallery,);
  if (pickedFile != null)
    return File(pickedFile.path);
  return null;
}

Future uploadImageToFirebase(File img, String id) async {

  if (img != null) {
    File _image = File(img.path);

    firebase_storage.FirebaseStorage storage =
        firebase_storage.FirebaseStorage.instance;

    await storage
        .ref('profilePictures/$id.png')
        .putFile(_image);

    String url = await storage.ref('profilePictures/$id.png').getDownloadURL();
    print(url);
    return url;
  }
  else
    return null;
}

Future<void> changeUrl(String id, String url, String group) async {
  CollectionReference ref = FirebaseFirestore.instance.collection('groups').doc(group).collection('users');
  ref.doc(id).update({"url": url});
}
