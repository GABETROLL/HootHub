import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final auth = FirebaseAuth.instance;
final usersCollection = FirebaseFirestore.instance.collection('users');
final usersScoresCollection = FirebaseFirestore.instance.collection('usersScores');
final testsCollection = FirebaseFirestore.instance.collection('tests');
final commentsCollection = FirebaseFirestore.instance.collection('comments');
