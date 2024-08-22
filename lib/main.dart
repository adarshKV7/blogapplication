// ignore_for_file: prefer_const_constructors

import 'package:blogapplication/controller/firebase_controller.dart';
import 'package:blogapplication/controller/login_screen_controller.dart';
import 'package:blogapplication/controller/regisration_screen_controller.dart';
import 'package:blogapplication/firebase_options.dart';
import 'package:blogapplication/view/admin_panel/admin_panel.dart';
import 'package:blogapplication/view/blog_screation/blog_creation_screen.dart';
import 'package:blogapplication/view/home_screen/home_screen.dart';
import 'package:blogapplication/view/login_screen/login_screen.dart';
import 'package:blogapplication/view/profile_screen/profile_screen.dart';
import 'package:blogapplication/view/search_screen/search_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => RegistrationScreenController(),
        ),
        ChangeNotifierProvider(
          create: (context) => LoginScreenController(),
        ),
        ChangeNotifierProvider(
          create: (context) => FirebaseController(),
        ),
      ],
      child: Consumer<FirebaseController>(
        builder: (context, firebaseController, child) {
          return MaterialApp(
            title: 'Blog Application',
            theme: ThemeData(primarySwatch: Colors.blue),
            darkTheme: ThemeData.dark(),
            themeMode: firebaseController.themeMode,
            home: StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return HomeScreen();
                } else {
                  return LoginScreen();
                }
              },
            ),
            routes: {
              '/create': (context) => BlogCreationScreen(),
              '/admin': (context) => AdminPanelScreen(),
              '/search': (context) => SearchScreen(),
              '/home': (context) => HomeScreen(),
              '/login': (context) => LoginScreen(),
              '/profile': (context) => ProfileScreen(),
            },
          );
        },
      ),
    );
  }
}
