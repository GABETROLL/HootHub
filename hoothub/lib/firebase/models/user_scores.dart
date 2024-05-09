import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hoothub/firebase/models/model.dart';

/// Independent document `Model` that represents a corresponding `UserModel`'s test score statistics.
class UserScores extends Model {
  UserScores({
    this.userId,
    required this.isPublic,
    required this.questionsAnswered,
    required this.questionsAnsweredCorrect,
  });

  String? userId;
  bool isPublic;
  int questionsAnswered;
  int questionsAnsweredCorrect;

  @override
  bool isValid() => questionsAnsweredCorrect >= 0
    && questionsAnswered >= 0
    && questionsAnsweredCorrect <= questionsAnswered
  ;

  static UserScores? fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    Map<String, dynamic>? data = snapshot.data();

    if (data == null) return null;

    return UserScores(
      userId: data['userId'],
      isPublic: data['isPublic'],
      questionsAnswered: data['questionsAnswered'],
      questionsAnsweredCorrect: data['questionsAnsweredCorrect'],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'userId': userId,
    'isPublic': isPublic,
    'questionsAnswered': questionsAnswered,
    'questionsAnsweredCorrect': questionsAnsweredCorrect,
  };
}
