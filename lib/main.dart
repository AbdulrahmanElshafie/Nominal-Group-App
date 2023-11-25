import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nominal_group/moduls/home/Home.dart';
import 'package:nominal_group/moduls/login/Login.dart';
import 'package:nominal_group/moduls/notifications/Notifications.dart';
import 'package:nominal_group/moduls/profile/Profile.dart';
import 'package:nominal_group/moduls/register/Register.dart';
import 'models/Account.dart';
import 'models/Team.dart';
import 'moduls/team/TeamScreen.dart';
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
            (querySnapshot) async {
          for (var docSnapshot in querySnapshot.docs) {

            Team team = Team(name: docSnapshot.data()['Team Name'], username: docSnapshot.id);

            await db.collection('Teams').doc(docSnapshot.id).get().then(
                (DocumentSnapshot doc) async {
                  final data = doc.data() as Map<String, dynamic>;
                  team.ownerID = data['ownerID'];
                }
            );

            user.teams.add(team);
          }
        }
    );

   await db.collection('Users').doc(user.uid).get().then(
            (docSnapshot) {
          user.email = docSnapshot.data()!['email'];
          user.name = docSnapshot.data()!['name'];
        }
    );

   user.crntTeam = user.teams.first;

   await updateNotifications();
   await updateTeamData(user.crntTeam.username);
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Widget start(){
    if(FirebaseAuth.instance.currentUser != null){
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
        '/teams': (context) => const TeamScreen(),
        '/home': (context) => const Home(),
        '/profile': (context) => const Profile(),
        '/notifications': (context) => const Notifications(),
      },
    );
  }
}
