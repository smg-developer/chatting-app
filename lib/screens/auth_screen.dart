import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;

  var _enteredEmail = '';
  var _enteredPassword = '';
  var _enteredUserName = '';
  final _form = GlobalKey<FormState>();

  void _submit() async {
    final isValid = _form.currentState!.validate();

    if (!isValid) {
      return;
    }

    _form.currentState!.save();

    if (_isLogin) {
      try {
        UserCredential creds = await _firebase.signInWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );
        print(creds);

        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Login successful")));
        setState(() {
          _form.currentState!.reset();
          //_isLogin = true;
        });
      } on FirebaseAuthException catch (error) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message ?? 'Login failed')),
        );
      }
    } else {
      try {
        UserCredential creds = await _firebase.createUserWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );

        print(creds);

        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Successfully signed up!")));

        setState(() {
          _form.currentState!.reset();
          _isLogin = true;
        });

        await FirebaseFirestore.instance
            .collection('users')
            .doc(creds.user!.uid)
            .set({'username': _enteredUserName, 'email': _enteredEmail});
      } on FirebaseAuthException catch (error) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message ?? 'Authentication failed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,

      appBar: AppBar(title: Text('Chat app')),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(
                  top: 30,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                width: 200,
                child: Image.asset("assets/images/chat.png", fit: BoxFit.cover),
              ),
              Card(
                margin: EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Form(
                      key: _form,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            decoration: InputDecoration(
                              label: Text('Email Address'),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (val) {
                              if (val == null ||
                                  val.trim().isEmpty ||
                                  !val.contains('@')) {
                                return 'Please enter valid email ID';
                              }
                            },
                            onSaved: (newValue) {
                              _enteredEmail = newValue!;
                            },
                            // style: TextStyle(
                            //   color: Theme.of(
                            //     context,
                            //   ).colorScheme.primaryContainer,
                            // ),
                          ),

                          if (!_isLogin)
                            TextFormField(
                              decoration: InputDecoration(
                                label: Text('User Name'),
                              ),
                              autocorrect: false,
                              textCapitalization: TextCapitalization.none,
                              validator: (val) {
                                if (val == null ||
                                    val.trim().isEmpty ||
                                    val.trim().length < 4) {
                                  return 'User name must be minimum 4 characters long';
                                }
                              },
                              enableSuggestions: false,
                              onSaved: (newValue) {
                                _enteredUserName = newValue!;
                              },
                              // style: TextStyle(
                              //   color: Theme.of(
                              //     context,
                              //   ).colorScheme.primaryContainer,
                              // ),
                            ),

                          TextFormField(
                            decoration: InputDecoration(
                              label: Text('Password'),
                            ),
                            obscureText: true,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            // style: TextStyle(
                            //   color: Theme.of(
                            //     context,
                            //   ).colorScheme.primaryContainer,
                            // ),
                            validator: (val) {
                              if (val == null || val.trim().length < 6) {
                                return 'Password must be at least 6 characters long';
                              }
                            },
                            onSaved: (newValue) {
                              _enteredPassword = newValue!;
                            },
                          ),

                          SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                            ),
                            child: Text(_isLogin ? 'Log In' : 'Sign Up'),
                          ),
                          //SizedBox(height: 12),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isLogin = !_isLogin;
                              });
                            },
                            child: Text(
                              _isLogin ? 'Create an account' : 'Login instead',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
