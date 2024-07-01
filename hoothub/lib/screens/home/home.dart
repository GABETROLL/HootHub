// back-end
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hoothub/firebase/api/auth.dart';
import 'package:hoothub/firebase/models/test.dart';
import 'package:hoothub/firebase/models/user.dart';
// front-end
import 'package:flutter/material.dart';
import 'package:hoothub/screens/home/view_home_tests.dart';
import 'package:hoothub/screens/make_test/make_test.dart';
import 'package:hoothub/screens/widgets/user_author_button.dart';
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

  /// Ticks from false to true and back forever,
  /// whenever this widget needs to refresh.
  bool _refresher = false;

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

    final UserModel? userModelPromoted = _userModel;

    final List<Widget> actions;

    if (userModelPromoted != null) {
      actions = <Widget>[
        IconButton(
          onPressed: () async {
            Test? testWithChanges = await Navigator.push<Test>(
              context,
              MaterialPageRoute<Test>(
                builder: (BuildContext context) => MakeTest(
                  testModel: Test(),
                ),
              ),
            );

            if (!mounted) return;

            if (testWithChanges != null) {
              // TODO: SOMEHOW ONLY REFRESH THE CHANGED TEST,
              //  TO SHOW THE USER THE CHANGES
              setState(() {
                _refresher = !_refresher;
              });
            }
          },
          icon: const Icon(Icons.add),
        ),
        UserAuthorButton(
          userId: userModelPromoted.id,
        ),
        ElevatedButton(
          onPressed: () async {
            final String logOutResult = await logOut();

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(logOutResult)),
              );
            }

            if (mounted) {
              setState(() {
                _refresher = !_refresher;
              });
            }
          },
          child: const Text('Logout'),
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
