import 'package:evolution_cam/configs/app_controller.dart';
import 'package:evolution_cam/auth/register_screen.dart';
import 'package:evolution_cam/configs/theme.dart';
import 'package:evolution_cam/pages/innerReg_screen.dart';
import 'package:evolution_cam/pages/profile_screen.dart';
import 'package:evolution_cam/pages/upload_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'auth/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pages/home_screen.dart';
import 'pages/set_colection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MainApp createState() => _MainApp();
}

class _MainApp extends State<MyApp> {
  final _auth = FirebaseAuth.instance;

  Widget _choosePage() {
    if (_auth.currentUser != null) {
      return HomeScreen();
    }
    return LoginScreen();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: AppController.instance,
        builder: (context, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppController.instance.isDarkTheme ? darkTheme : lightTheme,
            initialRoute: '/',
            routes: {
              '/login': (context) => LoginScreen(),
              '/register': (context) => RegisterScreen(),
              '/': (context) => _choosePage(),
              '/create': (context) => SetColectionScreen(),
              '/inner': (context) => InnerCollestionScreen(),
              '/profile': (context) => ProfileScreen(),
              '/upload': (context) => UploadScreen(
                    collectionId: '',
                  ),
            },
          );
        });
  }
}
