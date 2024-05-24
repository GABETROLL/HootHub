// back-end
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hoothub/firebase/models/user.dart';
import 'package:hoothub/firebase/api/auth.dart';
// front-end
import 'package:flutter/material.dart';
import 'styles.dart';
import 'signup.dart';

/// This Widget, INTENDED TO BE USED AS A ROUTE,
/// attempts to login the user to FirebaseAuth,
/// then POPS with the (now logged in)
/// user's `UserModel?` as this Widget's ROUTE's result.
///
/// The user's model may be null, because something may have gone wrong.
class Login extends StatefulWidget {
  Login({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _passwordHidden = true;

  /// (Asynchronously) logs in the user using `logInUser`,
  /// and the text from the email and password `TextField`s.
  ///
  /// If the `context` is still mounted after called `logInUser`,
  /// this function displays a `SnackBar` with either
  /// the error logging in, or a welcome back message to the user.
  ///
  /// Then, this function attempts to get the user's current `UserModel?`,
  /// and POPS this widget's route, using the model as its RESULT.
  ///
  /// TODO: It may not be anymore:
  /// `context`'s SCAFFOLD MUST BE THE `Scaffold` RETURNED BY THIS WIDGET'S `build`.
  /// You can use `Builder` inside `build` to wrap the widget that triggers this event handler.
  Future<void> _onLogIn(BuildContext context) async {
    String logInResult = await logInUser(
      email: widget.emailController.text,
      password: widget.passwordController.text,
    );

    if (logInResult != 'Ok') {
      if (!(context.mounted)) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging in: $logInResult')),
      );
    } else {
      UserModel? userModel;
      String loggedInMessage;

      try {
        userModel = await loggedInUser();

        if (userModel != null) {
          loggedInMessage = 'Welcome back to HootHub, ${userModel.username}';
        } else {
          loggedInMessage = 'Unable to retrieve credentials!';
        }
      } on FirebaseException catch (error) {
        loggedInMessage = error.message ?? error.code;
      } catch (error) {
        loggedInMessage = error.toString();
      }

      if (!(context.mounted)) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loggedInMessage)),
      );

      Navigator.pop<UserModel?>(context, userModel);
    }
  }

  /// (Asynchronously) PUSHES a `MaterialPageRoute<SignUp>` to the `Navigator`,
  /// awaits for that route's `UserModel?` result,
  /// then POPS THIS ROUTE WITH THAT RESULT.
  ///
  /// That way, the user may choose the other auth method screen,
  /// and their credentials will pop back down to `Home`!
  Future<void> _onSignUpInstead(BuildContext context) async {
    UserModel? signUpScreenResult = await Navigator.push<UserModel?>(
      context,
      MaterialPageRoute<UserModel?>(builder: (BuildContext context) => SignUp()),
    );

    if (!(context.mounted)) return;

    Navigator.pop<UserModel?>(context, signUpScreenResult);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Align(
        alignment: Alignment.center,
        child: Container(
          constraints: const BoxConstraints(maxWidth: mediumScreenWidth),
          child: Column(
            children: <Widget>[
              TextField(
                controller: widget.emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
              ),
              TextField(
                controller: widget.passwordController,
                obscureText: _passwordHidden,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    onPressed: () => setState(() { _passwordHidden = !_passwordHidden; }),
                    icon: Icon(_passwordHidden ? Icons.visibility_off : Icons.visibility),
                  ),
                ),
              ),
              Builder(
                builder: (BuildContext context) => ElevatedButton(
                  onPressed: () => _onLogIn(context),
                  child: const Text('Log in'),
                ),
              ),
              const Divider(),
              Row(
                children: <Widget>[
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () => _onSignUpInstead(context),
                    child: const Text('Sign up'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ); 
  }
}
