import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final auth = FirebaseAuth.instance;
final privateUsersCollection = FirebaseFirestore.instance.collection('privateUsers');
final publicUsersCollection = FirebaseFirestore.instance.collection('publicUsers');
final privateUserScoresCollection = FirebaseFirestore.instance.collection('privateUserScores');
final publicUsersScoresCollection = FirebaseFirestore.instance.collection('publicUsersScores');
final privateTestsCollection = FirebaseFirestore.instance.collection('privateTests');
final publicTestsCollection = FirebaseFirestore.instance.collection('publicTests');
final commentsCollection = FirebaseFirestore.instance.collection('comments');
