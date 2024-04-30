// back-end
import 'package:hoothub/firebase/api/auth.dart';
// front-end
import 'package:flutter/material.dart';
import 'home.dart';
import 'login.dart';

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

  /// Signs up the user using `signUpUser`,
  /// and the text from the email, password and username `TextField`s.
  ///
  /// `context`'s SCAFFOLD MUST BE THE `Scaffold` RETURNED BY THIS WIDGET'S `build`.
  /// You can use `Builder` inside `build` to wrap the widget that triggers this event handler.
  Future<void> _onSignUp(BuildContext context) async {
    String signupResult = await signUpUser(
      email: widget.emailController.text,
      password: widget.passwordController.text,
      username: widget.usernameController.text,
    );

    if (!(context.mounted)) return;

    if (signupResult != 'Ok') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing up: $signupResult')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Welcome to HootHub, ${widget.usernameController.text}!')),
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (BuildContext context) => Login()),
                      );
                    },
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
