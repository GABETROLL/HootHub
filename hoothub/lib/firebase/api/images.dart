import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
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

/// Tries to await and return `reference.getData()`, which may or may not be null.
///
/// If a `FirebaseException` with `code: 'object-not-found'` is caught,
/// this function ALSO returns null, to indicate nothing was found.
///
/// ANY OTHER ERROR IS THROWN.
Future<Uint8List?> downloadImage(Reference reference) async {
  try {
    return await reference.getData();
  } on FirebaseException catch (error) {
    if (error.code == 'object-not-found') {
      return null;
    }
    rethrow;
  }
}

Future<Uint8List?> downloadUserImage(String userId) {
  return downloadImage(usersImages.child(userId));
}

Future<Uint8List?> downloadTestImage(String testId) {
  return downloadImage(testsImages.child('$testId/$testId'));
}

Future<Uint8List?> downloadQuestionImage(String testId, int questionIndex) {
  return downloadImage(testsImages.child('$testId/$questionIndex'));
}

Future<String> deleteLoggedInUserImage() async {
  String? currentUserId = auth.currentUser?.uid;

  if (currentUserId == null) {
    return "Cannot delete this user's profile picture, you're not logged in!";
  }

  try {
    await usersImages.child(currentUserId).delete();
  } catch (error) {
    return "Failed to delete you profile picture...";
  }

  return "Your profile picture was deleted successfully!";
}
