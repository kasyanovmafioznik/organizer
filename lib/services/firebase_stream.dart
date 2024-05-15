import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:to_do_list/screens/to_do.dart';
import 'package:to_do_list/screens/verify_email_address.dart';

class FirebaseStream extends StatelessWidget {
  const FirebaseStream({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if(snapshot.hasError){
            return const Scaffold(
              body: Center(child: Text('Что то пошло не так'),),
            );
          } else if(snapshot.hasData){
            if(!snapshot.data!.emailVerified){
              return const VerifyEmailScreen();
            }
            return const ToDoScreen();
          }else{
            return const ToDoScreen();
          }
        });
  }
}
