import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hoothub/firebase/models/model.dart';

class UserScores extends Model {
  UserScores({
    this.id,
    this.userId,
    required this.isPublic,
    required this.questionsAnswered,
    required this.questionsAnsweredCorrect,
  });

  String? id;
  String? userId;
  bool isPublic;
  int questionsAnswered;
  int questionsAnsweredCorrect;

  @override
  bool isValid() => questionsAnsweredCorrect >= questionsAnswered;

  static UserScores? fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    Map<String, dynamic>? data = snapshot.data();

    if (data == null) return null;

    return UserScores(
      id: data['id'],
      userId: data['userId'],
      isPublic: data['isPublic'],
      questionsAnswered: data['questionsAnswered'],
      questionsAnsweredCorrect: data['questionsAnsweredCorrect'],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'isPublic': isPublic,
    'questionsAnswered': questionsAnswered,
    'questionsAnsweredCorrect': questionsAnsweredCorrect,
  };
}
