import 'package:evolution_cam/components/add_image_inner.dart';
import 'package:evolution_cam/configs/app_controller.dart';
import 'package:evolution_cam/auth/register_screen.dart';
import 'package:evolution_cam/configs/theme.dart';
import 'package:evolution_cam/pages/inner_reg_screen.dart';
import 'package:evolution_cam/pages/profile_screen.dart';
import 'package:evolution_cam/pages/show_image_screen.dart';
import 'package:evolution_cam/configs/supabase_config.dart';
import 'package:evolution_cam/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'auth/login_screen.dart';
import 'pages/home_screen.dart';
import 'pages/set_collection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.publishableKey,
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MainApp createState() => _MainApp();
}

class _MainApp extends State<MyApp> {
  Widget _choosePage() {
    if (AuthService.instance.isLoggedIn) {
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
              '/addimage': (context) => Addimageinner(),
              '/showimage': (context) => ShowImageScreen(),
              '/profile': (context) => ProfileScreen(),
            },
          );
        });
  }
}
