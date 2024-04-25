import 'package:hoothub/firebase/models/question.dart';

class Test {
  const Test({required this.id, required this.name, required this.questions});

  final String id;
  final String name;
  final List<Question> questions;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'questions': questions,
  };
}
