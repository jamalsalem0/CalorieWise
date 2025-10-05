import 'package:calorie_wise/features/splash/splash_screen.dart';
import 'package:calorie_wise/theme/app_theme.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  print(
    'CLARIFAI_API_KEY is: ${dotenv.env['354f91aa1575486cab1c2ed6de948da6']}',
  );

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  List<CameraDescription> cameras = [];
  try {
    cameras = await availableCameras();
  } catch (e) {
    print('Error initializing cameras: $e');
  }

  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  const MyApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CalorieWise',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
