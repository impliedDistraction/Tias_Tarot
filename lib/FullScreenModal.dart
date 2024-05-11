// this class defines the full-screen semi-transparent modal dialog
// by extending the ModalRoute class
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FullScreenModal extends ModalRoute {
  // variables passed from the parent widget
  String title;
  String description;
  bool _showButton;

  Function? _pressedAction = null;

  // constructor
  FullScreenModal({
    required this.title,
    required this.description,
    required bool showButton,
  }) : _showButton = showButton;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 500);

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => false;

  @override
  Color get barrierColor => Colors.black.withOpacity(0.6);

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
            Padding(
              padding: const EdgeInsets.all(12),
              child:
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 40.0),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.all(32),
              child:
              Text(description,
                  style: const TextStyle(color: Colors.white, fontSize: 18)),
            ),
            const SizedBox(
              height: 30,
            ),
            if(_showButton)
              ElevatedButton.icon(
                onPressed: usePressedAction(context),
                icon: const Icon(Icons.close),
                label: const Text('Close'),
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
      if (_pressedAction != null) {
        _pressedAction!(context);
      } else {
        // close the modal dialog and return some data if needed
        Navigator.pop(context, []);
      }
    };
  }
}