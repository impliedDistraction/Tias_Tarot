import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pw_validator/flutter_pw_validator.dart';
import 'package:tias_tarot/FullScreenModal.dart';
import 'package:tias_tarot/TiasTarotHomepage.dart';

import 'main.dart';

class TiasTarotSignUpPage extends StatefulWidget {
  TiasTarotSignUpPage({super.key, required this.title});

  final String title;

  bool good = false;
  bool emailGood = false;
  bool passwordOneGood = false;
  bool passwordTwoGood = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordSignupController1 = TextEditingController();
  final TextEditingController passwordSignupController2 = TextEditingController();

  @override
  State<TiasTarotSignUpPage> createState() => _SignUpPage();
}

class _SignUpPage extends State<TiasTarotSignUpPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: SingleChildScrollView(
        child:
        Padding(
          padding: const EdgeInsets.all(32),
          child:
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Focus(
                onFocusChange: (value) => (value ? (){} : onEmailLostFocus()),
                child:
                TextField(
                  controller: widget.emailController,
                  enableSuggestions: false,
                  autocorrect: false,
                  onChanged: onEmailChange,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                ),
              ),
              TextField(
                controller: widget.passwordSignupController1,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                onChanged: onPasswordOneChanged,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
              ),
              FlutterPwValidator(
                  controller: widget.passwordSignupController1,
                  minLength: 6,
                  uppercaseCharCount: 1,
                  numericCharCount: 1,
                  specialCharCount: 1,
                  width: 400,
                  height: 150,

                  onSuccess: onSignupPasswordOneGood,
                  onFail: onSignupPasswordOneBad
              ),
              TextField(
                controller: widget.passwordSignupController2,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                onChanged: onPasswordTwoChanged,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                ),
              ),
              FlutterPwValidator(
                  controller: widget.passwordSignupController2,
                  minLength: 6,
                  uppercaseCharCount: 1,
                  numericCharCount: 1,
                  specialCharCount: 1,
                  width: 400,
                  height: 150,

                  onSuccess: onSignupPasswordTwoGood,
                  onFail: onSignupPasswordTwoBad
              ),
              Padding(
                  padding: const EdgeInsets.only(top: 32),
                  child:
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: widget.good ? onSignUpButtonPressedAllGood : null,
                        child: const Text('Sign Up'),
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

  onSignUpButtonPressedAllGood() async {
    FullScreenModal dialog = FullScreenModal(
        title: "Creating User",
        description: "This should only take a moment!",
        showButton: false
    );

    try {
      String email = widget.emailController.value.text;
      String password = widget.passwordSignupController1.value.text;

      print("creating new user $email, $password");

      Navigator.of(context).push(dialog);

      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      try {
        await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      } catch (e) {
        print("An error occured while trying to send email verification");
        print(e);
      }

      dialog.setPressedAction((BuildContext bc) {
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
        TiasTarotHomepage(title: "Tia's Tarot",)), (Route<dynamic> route) => false);
      });

      dialog.update("User Created", "You are now logged in!", true);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        dialog.update("Password Error", "That password is too weak!", true);
      } else if (e.code == 'email-already-in-use') {
        dialog.update("Email in User", "That email is already in use!", true);
      }
    } catch (e) {
      print(e);
    }
  }

  onSignupPasswordOneGood() {
    widget.passwordOneGood = true;
  }

  onSignupPasswordTwoGood() {
    widget.passwordTwoGood = true;
  }

  onSignupPasswordOneBad() {
    widget.passwordOneGood = false;
  }

  onSignupPasswordTwoBad() {
    widget.passwordTwoGood = false;
  }

  checkAllGoodAndResetState() {
    setAllGoodIfAllFieldsAreValid();

    setState(() {

    });
  }

  onEmailChange(value) {
    widget.emailGood = EmailValidator.validate(value);
    checkAllGoodAndResetState();
  }

  onEmailLostFocus() {
    String emailEntered = widget.emailController.value.text;
    onEmailChange(emailEntered);

    if(!widget.emailGood) {
      final SnackBar badEmail = SnackBar(
          content: const Text("That email does not appear to be valid!"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.deepPurple,
          margin: const EdgeInsets.all(30.0),
          action: SnackBarAction(
            textColor: Colors.white,
            disabledTextColor: Colors.white,
            label: "close",
            onPressed: () {

            },
          )
      );

      ScaffoldMessenger.of(context).showSnackBar(badEmail);
    }
  }

  bool isEmailValid() {
    return widget.emailGood;
  }

  void setAllGoodIfAllFieldsAreValid() {
    widget.good = isEmailValid() && areBothPasswordsGood() && doPasswordsMatch();
  }

  bool areBothPasswordsGood() => widget.passwordOneGood && widget.passwordTwoGood;

  bool doPasswordsMatch() => widget.passwordSignupController1.value.text == widget.passwordSignupController2.value.text;

  void onPasswordOneChanged(String value) {
    checkAllGoodAndResetState();
  }

  void onPasswordTwoChanged(String value) {
    checkAllGoodAndResetState();
  }
}