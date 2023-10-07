import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nominal_group/models/Account.dart';

import '../../shared/components/Components.dart';

class Register extends StatelessWidget{
  Register({super.key});
  TextEditingController nameController = TextEditingController(),
      emailController = TextEditingController(),
      passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Register'
        ),
        leading: const Icon(
          Icons.app_registration
        ),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.9,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextInput(
                    controller: nameController,
                    label: 'Name'
                ),
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
                      if(emailController.text == '' || passwordController.text == '' || nameController.text == ''){
                        showDialog(
                            context: context,
                            builder: (BuildContext context){
                              return const AlertDialog(
                                title: Text(
                                    'NOTE!'
                                ),
                                content: Text(
                                    'Please enter the name, email, & password'
                                ),
                              );
                            }
                        );
                      } else {
                        try {
                          await FirebaseAuth.instance.createUserWithEmailAndPassword(
                              email: emailController.text,
                              password: passwordController.text
                          );
                          if(FirebaseAuth.instance.currentUser != null){
                            user = Account(email: emailController.text, uid: FirebaseAuth.instance.currentUser!.uid, name: nameController.text);

                            db.collection('Users').doc(user.uid).set({
                                  "email": emailController.text.trim(),
                                  "password": passwordController.text,
                                  "name": nameController.text.trim()
                                });

                            Navigator.pushNamed(context, '/teams');

                          }
                        } on FirebaseAuthException catch (e) {
                          if (e.code == 'weak-password') {
                            showDialog(
                                context: context,
                                builder: (BuildContext context){
                                  return const AlertDialog(
                                    title: Text(
                                        'NOTE!'
                                    ),
                                    content: Text(
                                        'The password provided is too weak.'
                                    ),
                                  );
                                }
                            );

                          } else if (e.code == 'email-already-in-use') {
                            showDialog(
                                context: context,
                                builder: (BuildContext context){
                                  return const AlertDialog(
                                    title: Text(
                                        'NOTE!'
                                    ),
                                    content: Text(
                                        'The account already exists for that email.'
                                    ),
                                  );
                                }
                            );

                          }
                        } catch (e) {
                          print(e);
                        }
                      }
                    },
                    name: 'Register'),
                const SizedBox(
                  height: 20,
                ),
                Column(
                  children: [
                    const Text(
                        "Have an account?"
                    ),
                    TextButton(
                        onPressed: ()
                        {
                          Navigator.pushNamed(context, '/login');
                        },
                        child: const Text(
                            'Login Now'
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