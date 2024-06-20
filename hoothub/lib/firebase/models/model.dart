abstract class Model {
  /// Validates this model for Firebase.
  /// PLEASE CALL BEFORE UPLOADING THE MODEL TO FIREBASE.
  bool isValid();
  Map<String, dynamic> toJson();
  // Model copy();
}
