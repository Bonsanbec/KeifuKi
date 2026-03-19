import 'package:flutter/cupertino.dart';

import 'app.dart';
import 'services/app_data_runtime.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppDataRuntime.switchToLive();
  runApp(const KeifuKiApp());
}
