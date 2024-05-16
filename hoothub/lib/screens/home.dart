// back-end
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hoothub/firebase/api/auth.dart';
import 'package:hoothub/firebase/api/images.dart';
import 'package:hoothub/firebase/models/test.dart';
import 'package:hoothub/firebase/models/user.dart';
// front-end
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hoothub/screens/make_test/make_test.dart';
import 'login.dart';
import 'view_tests/view_tests.dart';

/// For now, this widget only shows the user a test test.
///
/// If the user is not logged in, this widget should re-direct the user to the Login screen.
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  UserModel? _userModel;
  bool _userChecked = false;
  Uint8List? _userProfileImage;
  bool _userProfileImageFetched = false;

  /// Tries to get the user's `UserModel` from `loggedInUser`,
  /// then sets `_userModel` to its result, if it was eventually recieved,
  /// and `_userChecked` to true.
  ///
  /// If `context` is unmounted by the time the user info has arrived,
  /// this method DOESN'T change this widget's state.
  ///
  /// If anything goes wrong, and `context` is still mounted,
  /// this method spawns a `SnackBar` that shows the error.
  Future<void> _checkLogin(BuildContext context) async {
    UserModel? userModel;

    try {
      userModel = await loggedInUser();
    } on FirebaseException catch (error) {
      if (!(context.mounted)) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting current user info: ${error.message ?? error.code}')),
      );
    } catch (error) {
      if (!(context.mounted)) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting current user info: $error')),
      );
    }

    if (!(context.mounted)) return;

    return setState(() {
      _userModel = userModel;
      _userChecked = true;
    });
  }

  /// Tries to fetch the `_userModel`'s profile image from the `images`
  /// `Reference`, and assign it to `_userProfileImage`,
  /// then sets `_userProfileImageFetched: true`.
  Future<void> _fetchUserProfileImage(BuildContext context) async {
    if (_userModel == null) return;

    Uint8List? userProfileImage;

    try {
      userProfileImage = await downloadUserImage(_userModel!.id);
    } on FirebaseException catch (error) {
      if (!(context.mounted)) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error getting current user's profile image: ${error.message ?? error.code}")),
      );
    } catch (error) {
      if (!(context.mounted)) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error getting current user's profile image: $error")),
      );
    }

    if (!(context.mounted)) return;

    setState(() {
      _userProfileImage = userProfileImage;
      _userProfileImageFetched = true;
    });
  }

  /// Tries to push `Login` screen, then set `_userModel` to its result,
  /// then sets `_userChecked` to true.
  ///
  /// If by the time the `Login` route pops, `context` has already unmounted,
  /// this method DOESN'T change this widget's state.
  ///
  /// If anything goes wrong, and `context` is still mounted,
  /// this method spawns a SnackBar` that shows the error.
  Future<void> _onLogin(BuildContext context) async {
    try {
      UserModel? userModel = await Navigator.push<UserModel?>(
        context,
        MaterialPageRoute<UserModel?>(
          builder: (BuildContext context) => Login(),
        ),
      );

      if (!(context.mounted)) return;

      return setState(() {
        _userModel = userModel;
        _userChecked = true;
      });
    } catch (error) {
      if (!(context.mounted)) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error receiving login screen information: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_userChecked) {
      _checkLogin(context);
    } else if (!_userProfileImageFetched) {
      _fetchUserProfileImage(context);
    }

    List<Widget> actions;

    if (_userModel != null) {
      Image profileImage;

      if (_userProfileImage != null) {
        try {
          profileImage = Image.memory(_userProfileImage!);
        } catch (error) {
          profileImage = Image.asset('default_user_image.png');
        }
      } else {
        profileImage = Image.asset('default_user_image.png');
      }

      actions = <Widget>[
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => MakeTest(
                  testModel: Test(),
                ),
              ),
            );
          },
          icon: const Icon(Icons.add),
        ),
        InkWell(
          onTap: () {
            // TODO: GO TO USER'S PROFILE HERE
          },
          child: Row(
            children: [
              profileImage,
              Text(_userModel!.username),
            ],
          ),
        ),
      ];
    } else {
      actions = <Widget>[
        ElevatedButton(
          onPressed: () => _onLogin(context),
          child: const Text('Login'),
        ),
      ];
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('HootHub'),
        actions: actions,
      ),
      body: const ViewTests(),
    );
  }
}
