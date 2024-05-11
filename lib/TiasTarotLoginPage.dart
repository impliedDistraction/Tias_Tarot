import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tias_tarot/FullScreenModal.dart';
import 'package:tias_tarot/TiasTarotSignUpPage.dart';
import 'package:tias_tarot/TiasTarotHomepage.dart';
import 'package:tias_tarot/main.dart';

import 'FullScreenModalTextRequest.dart';

class TiasTarotLoginPage extends StatefulWidget {
  TiasTarotLoginPage({super.key, required this.title});

  final String title;

  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  @override
  State<TiasTarotLoginPage> createState() => _LoginPage();
}

class _LoginPage extends State<TiasTarotLoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child:
        Padding(
          padding: const EdgeInsets.all(32),
          child:
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextField(
                controller: widget.email,
                enableSuggestions: false,
                autocorrect: false,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
              ),
              TextField(
                controller: widget.password,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
              ),
              Padding(
                  padding: const EdgeInsets.only(top: 32),
                  child:
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: tryUserLogin,
                        child: const Text('Log In'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => TiasTarotSignUpPage(title: "Sign Up")),
                          );
                        },
                        child: const Text('Sign Up'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          sendPasswordResetRequest();
                        },
                        child: const Text('Lost Password'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel'),
                      ),
                    ],
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> tryUserLogin() async {
    FullScreenModal modal = FullScreenModal(
        title: "Logging in User",
        description: "This shouldn't take long.",
        showButton: false
    );

    try {
      Navigator.of(context).push(modal);

      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: widget.email.value.text,
          password: widget.password.value.text
      );

      if(FirebaseAuth.instance.currentUser?.emailVerified == false) {
        try {
          await FirebaseAuth.instance.currentUser?.sendEmailVerification();
        } catch (e) {
          print("An error occured while trying to send email verification");
          print(e);
        }
      }

      modal.setPressedAction((BuildContext bc) {
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
        TiasTarotHomepage(title: "Tia's Tarot",)), (Route<dynamic> route) => false);
      });

      modal.update("User Logged In", "You are now logged in!", true);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        modal.update('User Error', 'No user found for that email.', true);
      } else if (e.code == 'wrong-password') {
        modal.update('Password Error', 'Wrong password provided for that user.', true);
      } else {
        modal.update('Error', "Username or password invalid", true);
      }
    } catch (e) {
      modal.update('Error', "Username or password invalid", true);
    }
  }

  sendPasswordResetRequest() {
    FullScreenModalTextRequest modal = FullScreenModalTextRequest(
      title: "Request Password",
      description: "Enter the email for your account",
      showButton: true,
      validate: (String text)
      {
        if(text.length < 3) return false;
        return true;
      },
      errorMessage: "That doesn't look like an email.",
      onFinished: (String email) {
        FirebaseAuth.instance
            .sendPasswordResetEmail(email: email)
            .then((value) => (status) {
              print(status);
            })
            .catchError((e) => (status) {
              print(status);
            });


        FullScreenModal modal = FullScreenModal(
            title: "Email Sent",
            description: "Instructions sent to $email on how to change your password",
            showButton: true
        );

        // ignore: use_build_context_synchronously
        Navigator.of(context).push(modal);
      },
    );

    Navigator.of(context).push(modal);
  }
}