// back-end
import 'package:hoothub/firebase/api/auth.dart';
// front-end
import 'package:flutter/material.dart';
import 'package:hoothub/screens/home.dart';
import 'signup.dart';

class Login extends StatefulWidget {
  Login({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _passwordHidden = true;

  /// Logs in the user using `logInUser`,
  /// and the text from the email and password `TextField`s.
  ///
  /// `context`'s SCAFFOLD MUST BE THE `Scaffold` RETURNED BY THIS WIDGET'S `build`.
  /// You can use `Builder` inside `build` to wrap the widget that triggers this event handler.
  Future<void> _onLogIn(BuildContext context) async {
    String logInResult = await logInUser(
      email: widget.emailController.text,
      password: widget.passwordController.text
    );

    if (!(context.mounted)) return;

    if (logInResult != 'Ok') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging in: $logInResult')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Welcome back to HootHub, ${widget.emailController.text}')),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const Home(),
        ),
      );
    }
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (BuildContext context) => SignUp()),
                      );
                    },
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
