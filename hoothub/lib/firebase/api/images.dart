import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'clients.dart';

Future<void> uploadUserImage(String userId, Uint8List data) async {
  await usersImages.child(userId).putData(data);
}

/// Updates the test's images in Cloud Storage (located at `tests/{testId}`).
///
/// First, this function calls `testsImages.child(testId).listAll()` to list
/// all of test `testId`'s images. Then, this function deletes them one by one.
/// Finally, this function uploads the new images in `newTestImage` and `newQuestionImages`
/// in their places.
///
/// If any of these steps go wrong, this function notifies the error in its return string.
/// Otherwise, this function should return "Ok".
Future<String> updateTestImages(String testId, Uint8List? newTestImage, List<Uint8List?> newQuestionImages) async {
  ListResult testImageReferences;

  try {
    testImageReferences = await testsImages.child(testId).listAll();
  } catch (error) {
    print("Failed to list all images for test $testId: #error");
    return "Failed to delete previous test images";
  }

  List<Reference> failedToDeleteImages = <Reference>[];
  for (final Reference imageReference in testImageReferences.items) {
    try {
      imageReference.delete();
    } catch (error) {
      print("Failed to delete test's image ${imageReference.fullPath}: $error");
      failedToDeleteImages.add(imageReference);
    }
  }

  bool failedUploadingTestImage = false;

  if (newTestImage != null) {
    try {
      await testsImages.child('$testId/$testId').putData(newTestImage);
    } catch (error) {
      failedUploadingTestImage = true;
    }
  }

  final List<int> failedQuestionImageUploads = <int>[];

  for (final (int questionIndex, Uint8List? newQuestionImage) in newQuestionImages.indexed) {
    if (newQuestionImage != null) {
      try {
        await testsImages.child('$testId/$questionIndex').putData(newQuestionImage);
      } catch (error) {
        failedQuestionImageUploads.add(questionIndex);
      }
    }
  }

  String status = "Ok";

  if (failedToDeleteImages.isNotEmpty) {
    status += "Failed to delete some previous images! ";
  }

  if (failedUploadingTestImage) {
    status = "Failed to upload test's image! ";
  }

  if (failedQuestionImageUploads.isNotEmpty) {
    status += "Failed to upload these question's images: ${failedQuestionImageUploads.join(", ")}!";
  } else {
    status += "!";
  }

  return status;
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
