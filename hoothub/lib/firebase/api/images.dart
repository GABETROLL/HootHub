import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'clients.dart';

Future<String> uploadImage(Reference reference, Uint8List data) async {
  await reference.putData(data);
  return reference.getDownloadURL();
}

Future<String> uploadTestImage(String testId, Uint8List data) {
  return uploadImage(testsImages.child('$testId/$testId'), data);
}

Future<String> uploadQuestionImage(String testId, int questionIndex, Uint8List data) {
  return uploadImage(testsImages.child('$testId/$questionIndex'), data);
}
