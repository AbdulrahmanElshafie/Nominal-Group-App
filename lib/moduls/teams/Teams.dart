import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nominal_group/shared/components/Components.dart';
import '../../models/Team.dart';

class Teams extends StatelessWidget{
  Teams({super.key});
  TextEditingController teamNameController = TextEditingController(),
      teamUserNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Teams'
        ),
        centerTitle: true,
        leading: const Icon(
          Icons.people
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Btn(
                onTap: (){
                  showDialog(
                      context: context,
                      builder: (BuildContext context){
                        return AlertDialog(
                          title: const Text(
                            'Create a Team'
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextInput(controller: teamNameController, label: 'Team Name'),
                              TextInput(controller: teamUserNameController, label: 'Team Username'),
                              Btn(onTap:
                                  (){
                                    db.collection('Users').doc(user.uid).collection('Teams').
                                    doc(teamUserNameController.text.trim()).set(
                                        {
                                          'Team Name': teamNameController.text.trim()
                                        }
                                    );
                                    db.collection('Teams').doc(teamUserNameController.text.trim()).set(
                                        {
                                          'Team Name': teamNameController.text.trim()
                                        }
                                    );
                                    user.teams.add(Team(name: teamNameController.text.trim(), username: teamUserNameController.text.trim()));
                                    teamUserNameController.clear();
                                    teamNameController.clear();
                                    Navigator.pushNamed(context, '/home');
                                  },
                                  name: 'Create Team'
                              )
                            ],
                          ),
                        );
                      }
                  );
                },
                name: 'Create a Team'
            ),
            const SizedBox(
              height: 20,
            ),
            Btn(
                onTap: (){
                  showDialog(
                      context: context,
                      builder: (BuildContext context){
                        return AlertDialog(
                          title: const Text(
                              'Create a Team'
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextInput(controller: teamUserNameController, label: 'Team Username'),
                              Btn(onTap:
                                  (){
                                    db.collection('Teams').doc(teamUserNameController.text.trim()).get().then(
                                          (DocumentSnapshot doc) {
                                        final data = doc.data() as Map<String, dynamic>;
                                        user.teams.add(Team(name: data['Team Name'], username: doc.id));
                                      },
                                      onError: (e) => print("Error getting document: $e"),
                                    );

                                    db.collection('Users').doc(user.uid).collection('Teams').
                                    doc(teamUserNameController.text.trim()).set(
                                        {
                                          'Team Name': user.teams[0].name
                                        }
                                    );

                                    teamUserNameController.clear();
                                    sleep(const Duration(seconds: 1));
                                    Navigator.pushNamed(context, '/home');
                              },
                                  name: 'Join Team'
                              )
                            ],
                          ),
                        );
                      }
                  );
                },
                name: 'Join a Team'
            )
          ],
        ),
      ),
    );
  }

}