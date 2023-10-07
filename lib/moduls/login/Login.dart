import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nominal_group/models/Account.dart';
import 'package:nominal_group/models/Team.dart';
import 'package:nominal_group/shared/components/Components.dart';

class Login extends StatelessWidget{
  Login({super.key});
  TextEditingController emailController = TextEditingController(),
  passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Login'
        ),
        leading: const Icon(
          Icons.login
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.88,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextInput(
                    controller: emailController,
                    label: 'Email'
                ),
                TextInput(
                    controller: passwordController,
                    label: 'Password',
                    hideTxt: true,
                ),
                Btn(
                    onTap: () async {
                      if(emailController.text == '' || passwordController.text == ''){
                        showDialog(
                            context: context,
                            builder: (BuildContext context){
                              return const AlertDialog(
                                title: Text(
                                  'NOTE!'
                                ),
                                content: Text(
                                  'Please enter the email & password'
                                ),
                              );
                            }
                        );
                      } else {
                        try {
                          await FirebaseAuth.instance.signInWithEmailAndPassword(
                              email: emailController.text,
                              password: passwordController.text
                          );
                          if(FirebaseAuth.instance.currentUser != null){
                            user = Account(email: emailController.text, uid: FirebaseAuth.instance.currentUser!.uid);
                           await db.collection('Users').doc(user.uid).collection('Teams').get().then(
                                (querySnapshot){
                                  for(var docSnapshot in querySnapshot.docs){
                                    user.teams.add(Team(name: docSnapshot.data()['Team Name'], username: docSnapshot.id));
                                  }
                                }
                            );
                            Navigator.pushNamed(context, '/teams');
                          }
                        } on FirebaseAuthException catch (e) {
                           if (e.code == 'INVALID_LOGIN_CREDENTIALS') {
                            showDialog(
                                context: context,
                                builder: (BuildContext context){
                                  return const AlertDialog(
                                    title: Text(
                                        'INVALID LOGIN CREDENTIALS!'
                                    ),
                                    content: Text(
                                        'Check your password and email please.'
                                    ),
                                  );
                                }
                            );
                          }
                        }
                      }
                    },
                    name: 'Login'),
                const SizedBox(
                  height: 20,
                ),
                Column(
                  children: [
                    const Text(
                        "Don't have an account?"
                    ),
                    TextButton(
                        onPressed: ()
                        {
                          Navigator.pop(context);
                        },
                        child: const Text(
                            'Create an Account Now'
                        )
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}