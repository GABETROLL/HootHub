// back-end
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hoothub/firebase/api/auth.dart';
import 'package:hoothub/firebase/api/images.dart';
import 'package:hoothub/firebase/models/test.dart';
import 'package:hoothub/firebase/models/user.dart';
// front-end
import 'package:flutter/material.dart';
import 'package:hoothub/screens/home/view_home_tests.dart';
import 'package:hoothub/screens/make_test/make_test.dart';
import 'package:hoothub/screens/widgets/info_downloader.dart';
import 'login.dart';

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

      return Scaffold(
        appBar: AppBar(
          title: const Text('HootHub'),
        ),
        body: const Center(child: Text('Loading credentials...')),
      );
    }

    final List<Widget> actions;

    if (_userModel != null) {
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
              InfoDownloader<Uint8List>(
                downloadInfo: () => downloadUserImage(_userModel!.id),
                builder: (BuildContext context, Uint8List? userImageData, bool downloaded) {
                  if (userImageData != null) {
                    return Image.memory(userImageData);
                  }
                  return Image.asset('default_user_image.png');
                },
                buildError: (BuildContext context, Object error) {
                  return Text("Error loading current user's profile image: $error");
                },
              ),
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
      body: ViewHomeTests(key: UniqueKey()),
    );
  }
}
