import 'package:flutter/material.dart';
import 'package:serverapp/pages/HomePage.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login(BuildContext context) {
    // TODO: validate input with login server
    if (_usernameController.text == 'admin' && _passwordController.text == 'admin') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const Homepage(title: 'Homepage Title'))
      );
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid username or password'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                hintText: 'Username',
                hintStyle: TextStyle(
                  color: Colors.grey,
                )
              ),
              textAlignVertical: TextAlignVertical.bottom,
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Password',
                hintStyle: TextStyle(
                  color: Colors.grey,
                ),
              ),
              textAlignVertical: TextAlignVertical.bottom,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
                onPressed: () => _login(context),
                child: const Text('Login')
            ),
          ],
        ),
      ),
    );
  }
}