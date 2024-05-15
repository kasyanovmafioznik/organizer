import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:to_do_list/firebase_options.dart';
import 'package:to_do_list/screens/autorization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:to_do_list/screens/sing_up.dart';
import 'package:to_do_list/screens/to_do.dart';
import 'package:to_do_list/screens/verify_email_address.dart';
import 'package:to_do_list/services/firebase_stream.dart';
import 'package:timezone/data/latest.dart' as tz;

var kColorScheme = ColorScheme.fromSeed(
  seedColor: const Color.fromARGB(255, 96, 59, 255),
  brightness: Brightness.light,
);
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  tz.initializeTimeZones();
  await FirebaseMessaging.instance.setAutoInitEnabled(true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To-do List',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          textTheme: GoogleFonts.latoTextTheme(),
          ),
      routes: {
        '/': (context) => const AutorizationScreen(),
        '/home': (context) => const ToDoScreen(),
        '/login': (context) => const AutorizationScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/verify_email': (context) => const VerifyEmailScreen(),
        '/firestream': (context) => const FirebaseStream(),
      },
    );
  }
}
