import 'package:evolution_cam/auth/login_screen.dart';
import 'package:evolution_cam/auth/register_screen.dart';
import 'package:evolution_cam/configs/app_controller.dart';
import 'package:evolution_cam/configs/supabase_config.dart';
import 'package:evolution_cam/configs/theme.dart';
import 'package:evolution_cam/pages/add_image_screen.dart';
import 'package:evolution_cam/pages/home_screen.dart';
import 'package:evolution_cam/pages/inner_reg_screen.dart';
import 'package:evolution_cam/pages/profile_screen.dart';
import 'package:evolution_cam/pages/show_image_screen.dart';
import 'package:evolution_cam/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.publishableKey,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppController.instance,
      builder: (context, child) {
        return MaterialApp(
          title: 'EvolutionCam',
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: AppController.instance.isDarkTheme
              ? ThemeMode.dark
              : ThemeMode.light,
          initialRoute: AuthService.instance.isLoggedIn ? '/' : '/login',
          routes: {
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/': (context) => const HomeScreen(),
            '/inner': (context) => const InnerCollectionScreen(),
            '/addimage': (context) => const AddImageScreen(),
            '/showimage': (context) => const ShowImageScreen(),
            '/profile': (context) => const ProfileScreen(),
          },
        );
      },
    );
  }
}
