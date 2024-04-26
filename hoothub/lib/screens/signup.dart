import 'package:flutter/material.dart';
import 'package:hoothub/firebase/api/auth.dart';

class Login extends StatefulWidget {
  Login({super.key});

  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmationController = TextEditingController();

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _passwordHidden = true;

  @override
  Widget build(BuildContext context) {
    return Align(
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
            ElevatedButton(
              onPressed: () {
                signUpUser(
                  email: widget.emailController.text,
                  password: widget.passwordController.text,
                  username: widget.usernameController.text,
                );
                /* TODO: NAVIGATE TO MAIN SCREEN HERE */
              },
              child: const Text('Sign up'),
            ),
          ],
        ),
      ),
    );
  }
}
