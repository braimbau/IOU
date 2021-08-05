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

Future removeImageOfFirebase(String id) async {
  firebase_storage.FirebaseStorage storage =
        firebase_storage.FirebaseStorage.instance;

  var ref = storage.ref('profilePictures/$id.png');
  try {
    await ref.getDownloadURL();
    await storage.ref('profilePictures/$id.png').delete();
    print("photo deleted");
  } catch(err) {
    print("No user photo in database, not deleted");
  }

}