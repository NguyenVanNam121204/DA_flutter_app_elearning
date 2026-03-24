import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (const String.fromEnvironment('APP_ENV', defaultValue: 'dev') == 'dev') {
    await dotenv.load(fileName: '.env');
  }

  runApp(const ProviderScope(child: EnglishLearningApp()));
}
