import 'package:flutter/cupertino.dart';

import 'ui/screens/question_screen.dart';

class KeifuKiApp extends StatelessWidget {
  const KeifuKiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      debugShowCheckedModeBanner: false,
      title: 'KeifuKi',
      home: QuestionScreen(),
    );
  }
}