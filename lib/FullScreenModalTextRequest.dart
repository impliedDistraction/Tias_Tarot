// this class defines the full-screen semi-transparent modal dialog
// by extending the ModalRoute class
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tias_tarot/FullScreenModal.dart';

class FullScreenModalTextRequest extends ModalRoute {
  // variables passed from the parent widget
  String title;
  String description;
  bool _showButton;

  Function validate;

  String errorMessage;

  TextEditingController request = TextEditingController();

  Function? _pressedAction = null;

  Function onFinished;

  // constructor
  FullScreenModalTextRequest({
    required this.title,
    required this.description,
    required bool showButton,
    required this.validate,
    required this.errorMessage,
    required this.onFinished,
  }) : _showButton = showButton;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 500);

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => false;

  @override
  Color get barrierColor => Colors.black.withOpacity(0.85);

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      ) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 40.0),
            ),
            const SizedBox(
              height: 15,
            ),
            Text(description,
                style: const TextStyle(color: Colors.white, fontSize: 18)),
            const SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.all(32),
              child:
                TextField(
                  controller: request,
                  obscureText: false,
                  enableSuggestions: true,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    labelText: 'Input',
                  ),
                ),
            ),
            if(_showButton)
              ElevatedButton.icon(
                onPressed: usePressedAction(context),
                icon: const Icon(Icons.check),
                label: const Text('Submit'),
              )
          ],
        ),
      ),
    );
  }

  void update(String newTitle, String newDescription, bool showButton) {
    title = newTitle;
    description = newDescription;
    _showButton = showButton;

    setState(() { });
    changedExternalState();
    changedInternalState();
    setState(() { });
  }

  void setDescription(String desc) {
    description = desc;

    setState(() { });
    changedExternalState();
  }

  void showButton() {
    _showButton = true;
    setState(() { });
  }

  void goBack(BuildContext context) {
    Navigator.pop(context, []);
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    // add fade animation
    return FadeTransition(
      opacity: animation,
      // add slide animation
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -1),
          end: Offset.zero,
        ).animate(animation),
        // add scale animation
        child: ScaleTransition(
          scale: animation,
          child: child,
        ),
      ),
    );
  }

  setPressedAction(Function fun) {
    _pressedAction = fun;
  }

  usePressedAction(BuildContext context) {
    return () {
      if(validate(request.value.text) == false) {
        FullScreenModal modal = FullScreenModal(
          title: "Invalid Entry",
          description: errorMessage,
          showButton: true,
        );

        Navigator.of(context).push(modal);
        return;
      }

      if (_pressedAction != null) {
        _pressedAction!(context);
      } else {
        Navigator.pop(context, []);

        onFinished(request.value.text);
      }
    };
  }
}