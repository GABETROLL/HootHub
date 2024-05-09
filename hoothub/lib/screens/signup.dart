// back-end
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hoothub/firebase/models/user.dart';
import 'package:hoothub/firebase/api/auth.dart';
// front-end
import 'package:flutter/material.dart';
import 'login.dart';

/// This Widget, INTENDED TO BE USED AS A ROUTE,
/// attempts to signup AND login the user to FirebaseAuth,
/// then POPS with the (now signed up AND logged in)
/// user's `UserModel?` as this Widget's ROUTE's result.
///
/// The user's model may be null, because something may have gone wrong.
class SignUp extends StatefulWidget {
  SignUp({super.key});

  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmationController = TextEditingController();

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool _passwordHidden = true;

  /// (Asynchronously) signs up AND logs in the user using `signUpUser`,
  /// and the text from the email, password and username `TextField`s.
  ///
  /// If the `context` is still mounted after called `logInUser`,
  /// this function displays a `SnackBar` with either
  /// the error signing up AND loggin in, or a welcome message to the user.
  ///
  /// Then, this function attempts to get the user's current `UserModel?`,
  /// and POPS this widget's route, using the model as its RESULT.
  ///
  /// TODO: It may not be anymore:
  /// `context`'s SCAFFOLD MUST BE THE `Scaffold` RETURNED BY THIS WIDGET'S `build`.
  /// You can use `Builder` inside `build` to wrap the widget that triggers this event handler.
  Future<void> _onSignUp(BuildContext context) async {
    String signupResult = await signUpUser(
      email: widget.emailController.text,
      password: widget.passwordController.text,
      username: widget.usernameController.text,
    );

    if (signupResult != 'Ok') {
      if (!(context.mounted)) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing up: $signupResult')),
      );
    } else {
      UserModel? userModel;
      String signedUpMessage;

      try {
        userModel = await loggedInUser();

        if (userModel != null) {
          signedUpMessage = 'Welcome back to HootHub, ${userModel.username}';
        } else {
          signedUpMessage = 'Unable to retrieve credentials!';
        }
      } on FirebaseException catch (error) {
        signedUpMessage = error.message ?? error.code;
      } catch (error) {
        signedUpMessage = error.toString();
      }

      if (!(context.mounted)) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(signedUpMessage)),
      );

      Navigator.pop<UserModel?>(context, userModel);
    }
  }

  /// (Asynchronously) PUSHES a `MaterialPageRoute<LogIn>` to the `Navigator`,
  /// awaits for that route's `UserModel?` result,
  /// then POPS THIS ROUTE WITH THAT RESULT.
  ///
  /// That way, the user may choose the other auth method screen,
  /// and their credentials will pop back down to `Home`!
  Future<void> _onLoginInstead(BuildContext context) async {
    UserModel? loginInScreenResult = await Navigator.push<UserModel?>(
      context,
      MaterialPageRoute<UserModel?>(builder: (BuildContext context) => Login()),
    );

    if (!(context.mounted)) return;

    Navigator.pop<UserModel?>(context, loginInScreenResult);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Align(
        alignment: Alignment.center,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            children: <Widget>[
              TextField(
                controller: widget.emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
              ),
              TextField(
                controller: widget.usernameController,
                keyboardType: TextInputType.name,
                decoration: const InputDecoration(
                  labelText: 'Username',
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
              TextField(
                controller: widget.passwordConfirmationController,
                obscureText: _passwordHidden,
                decoration: InputDecoration(
                  labelText: 'Confirm you password',
                  suffixIcon: IconButton(
                    onPressed: () => setState(() { _passwordHidden = !_passwordHidden; }),
                    icon: Icon(_passwordHidden ? Icons.visibility_off : Icons.visibility),
                  ),
                ),
              ),
              Builder(
                builder: (BuildContext context) => ElevatedButton(
                  onPressed: () => _onSignUp(context),
                  child: const Text('Sign up'),
                ),
              ),
              const Divider(),
              Row(
                children: <Widget>[
                  const Text("Already have an account?"),
                  TextButton(
                    onPressed: () =>_onLoginInstead(context),
                    child: const Text('Log in'),
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
