import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nominal_group/moduls/home/Home.dart';
import 'package:nominal_group/moduls/login/Login.dart';
import 'package:nominal_group/moduls/register/Register.dart';
import 'models/Account.dart';
import 'models/Team.dart';
import 'moduls/teams/Teams.dart';
import 'shared/components/Components.dart';
import 'shared/network/remote/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
  );
  if(FirebaseAuth.instance.currentUser != null) {
    user = Account(uid: FirebaseAuth.instance.currentUser!.uid);

   await db.collection('Users').doc(user.uid).collection('Teams').get().then(
            (querySnapshot) {
          for (var docSnapshot in querySnapshot.docs) {
            user.teams.add(Team(name: docSnapshot.data()['Team Name'],
                username: docSnapshot.id));
          }
        }
    );

   await db.collection('User').doc(user.uid).get().then(
            (docSnapshot) {
          user.email = docSnapshot.data()!['email'];
          user.name = docSnapshot.data()!['name'];
        }
    );
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Widget start(){
    if(FirebaseAuth.instance.currentUser != null){
      updateSuggestions(user.teams[0].username);

      return const Home();
    } else {
      return Register();
    }

  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: start(),
      routes: {
        '/login': (context) =>  Login(),
        'register': (context) => Register(),
        '/teams': (context) => Teams(),
        '/home': (context) => const Home()
      },
    );
  }
}
