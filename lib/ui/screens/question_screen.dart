import 'package:flutter/cupertino.dart';

import 'tree_home_screen.dart';

/// Legacy entry point kept for compatibility.
/// The app now uses TreeHomeScreen as the primary experience.
class QuestionScreen extends StatelessWidget {
  const QuestionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TreeHomeScreen();
  }
}
