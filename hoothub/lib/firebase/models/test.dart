import 'question.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Test {
  /// Only use this constructor for representing a document already created, and stored in Firebase!
  /// If you need to create and upload a new `Test` model to Firebase,
  /// use the API.
  Test({required this.id, required this.name, this.questions = const <Question>[]}) {
    if (id == '') {
      throw "`id` argument of `Test` contructor is empty!";
    }
    if (name == '') {
      throw "`name` argument of `Test` contructor is empty!";
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

    // TODO: Will this work?
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
    'questions': List.from(
      questions.map<Map<String, dynamic>>((Question question) => question.toJson())
    ) ,
  };
}
