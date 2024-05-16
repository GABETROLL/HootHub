import 'dart:typed_data';
import 'clients.dart';

Future<void> uploadUserImage(String userId, Uint8List data) async {
  await usersImages.child(userId).putData(data);
}

Future<void> uploadTestImage(String testId, Uint8List data) async {
  await testsImages.child('$testId/$testId').putData(data);
}

Future<void> uploadQuestionImage(String testId, int questionIndex, Uint8List data) async {
  await testsImages.child('$testId/$questionIndex').putData(data);
}

Future<Uint8List?> downloadUserImage(String userId) {
  return usersImages.child(userId).getData();
}

Future<Uint8List?> downloadTestImage(String testId) {
  return testsImages.child('$testId/$testId').getData();
}

Future<Uint8List?> downloadQuestionImage(String testId, int questionIndex) {
  return testsImages.child('$testId/$questionIndex').getData();
}
