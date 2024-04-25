import 'package:hoothub/firebase/models/question.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Test {
  Test({required this.id, required this.name, required this.questions}) {
    if (id == '') {
      throw "`id` argument of `Test` contructor is empty!";
    }
    if (name == '') {
      throw "`id` argument of `Test` contructor is empty!";
    }
    if (questions.isEmpty) {
      throw "`questions` argument of `Test` constructor must have at least one `Question`!";
    }
  }

  final String id;
  final String name;
  final List<Question> questions;

  /// Returns the `Test` representation of `snapshot.data()`.
  /// If the data is null, this method returns null.
  /// If any of the fields are wrong, the constructor call inside this method
  /// takes care of those errors, and throws them up the stack.
  static Test? fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    Map<String, dynamic>? data = snapshot.data();

    if (data == null) return null;

    if (data['questions'] is! List<Map<String, dynamic>>) {
      throw "`questions` field of snapshot data is not the correct type!";
    }

    List<Question> questions = List.from(
      data['questions'].map(
        (Map<String, dynamic> question) => Question.fromJson(question),
      ),
    );

    return Test(
      id: data['id'],
      name: data['name'],
      questions: questions,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'questions': questions,
  };
}
