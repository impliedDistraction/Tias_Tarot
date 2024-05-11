// this class defines the full-screen semi-transparent modal dialog
// by extending the ModalRoute class
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FullScreenModalWidget extends ModalRoute {
  // variables passed from the parent widget
  String title;
  Widget toDisplay;

  Function? _pressedAction = null;

  // constructor
  FullScreenModalWidget({
    required this.title,
    required this.toDisplay,
  });

  @override
  Duration get transitionDuration => const Duration(milliseconds: 500);

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => false;

  @override
  Color get barrierColor => Colors.black.withOpacity(0.86);

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
      child: SingleChildScrollView(
        child: SafeArea(
          child: Flexible(
            child:
                Column(
                  children: [
                    toDisplay,
                    ElevatedButton.icon(
                      onPressed: usePressedAction(context),
                      icon: const Icon(Icons.close),
                      label: const Text('Close'),
                    )
                  ]
                )
          ),
        ),
      ),
    );
  }

  void update(String newTitle, String newDescription, bool showButton) {
    title = newTitle;

    setState(() {});
    changedExternalState();
    changedInternalState();
    setState(() {});
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
        _pressedAction!();
      } else {
        // close the modal dialog and return some data if needed
        Navigator.pop(context, []);
      }
    };
  }
}
