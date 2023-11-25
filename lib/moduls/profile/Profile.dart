import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/Team.dart';
import '../../shared/components/Components.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  TextEditingController teamNameController = TextEditingController(),
      teamUserNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            'Profile'
        ),
        leading: const Icon(
          Icons.person
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Text(
                'Name: ${user.name}',
                style: const TextStyle(
                  fontSize: 18
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                height: 400,
                child: ListView.separated(
                  itemBuilder: (BuildContext context, int index){
                    return GestureDetector(
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        color: user.crntTeam.username == user.teams.elementAt(index).username? Colors.greenAccent: Colors.lightBlue,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                user.teams.elementAt(index).name,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: user.crntTeam.username == user.teams.elementAt(index).username? Colors.black: Colors.white
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Accepted Suggestions: ${user.teams.elementAt(index).acceptedSuggestions.length}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: user.crntTeam.username == user.teams.elementAt(index).username? Colors.black: Colors.white
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                'Declined Suggestions: ${user.teams.elementAt(index).declinedSuggestions.length}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: user.crntTeam.username == user.teams.elementAt(index).username? Colors.black: Colors.white
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                'Pending Suggestions: ${user.teams.elementAt(index).pendingSuggestions.length}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: user.crntTeam.username == user.teams.elementAt(index).username? Colors.black: Colors.white
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      onTap: () async {
                        user.crntTeam = user.teams.elementAt(index);
                        await updateTeamData(user.crntTeam.username);
                        await Navigator.pushNamed(context, '/home');
                        setState(() {

                        });
                      },
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) => const Divider(
                    thickness: 1,
                    color: Colors.black,
                    height: 0,
                  ),
                  itemCount: user.teams.length,
                ),
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
                                TextInput(controller: teamNameController, label: 'Team Name', isObscure: false,),
                                TextInput(controller: teamUserNameController, label: 'Team Username', isObscure: false,),
                                Btn(
                                    onTap: (){
                                  db.collection('Users').doc(user.uid).collection('Teams').
                                  doc(teamUserNameController.text.trim()).set(
                                      {
                                        'Team Name': teamNameController.text.trim()
                                      }
                                  );
                                  db.collection('Teams').doc(teamUserNameController.text.trim()).set(
                                      {
                                        'Team Name': teamNameController.text.trim(),
                                        'ownerID': user.uid
                                      }
                                  );

                                  db.collection('Teams').doc(teamUserNameController.text.trim()).collection('Members').doc(user.uid).set({});

                                  Team team = Team(name: teamNameController.text.trim(), username: teamUserNameController.text.trim());
                                  team.ownerID = user.uid;
                                  user.teams.add(team);

                                  user.crntTeam = user.teams.last;
                                  user.crntTeam.members.add(user);

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
                                'Join a Team'
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextInput(controller: teamUserNameController, label: 'Team Username', isObscure: false,),
                                Btn(
                                    onTap: () async {

                                      Team team0;
                                      bool isJoined = false;
                                      for(team0 in user.teams){
                                        if(team0.username == teamUserNameController.text.trim()){
                                          isJoined = true;
                                        }
                                      }

                                      if(isJoined == false){
                                        await db.collection('Teams').doc(teamUserNameController.text.trim()).get().then(
                                              (DocumentSnapshot doc) {

                                            final data = doc.data() as Map<String, dynamic>;

                                            Team team = Team(name: data['Team Name'], username: doc.id);
                                            team.ownerID = data['ownerID'];
                                            user.teams.add(team);

                                            user.crntTeam = user.teams.last;
                                          },
                                          onError: (e) => print("Error getting document: $e"),
                                        );

                                        await db.collection('Users').doc(user.uid).collection('Teams').
                                        doc(teamUserNameController.text.trim()).set(
                                            {
                                              'Team Name': user.crntTeam.name
                                            }
                                        );

                                        db.collection('Teams').doc(teamUserNameController.text.trim()).collection('Members').doc(user.uid).set(
                                          {

                                          });

                                        await updateTeamData(teamUserNameController.text.trim());

                                        teamUserNameController.clear();
                                        Navigator.pushNamed(context, '/home');
                                      } else {
                                        Navigator.pop(context);
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return const AlertDialog(
                                                title: Text('Team Already Joined!!'),
                                              );
                                            }
                                        );
                                      }
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
      ),
      bottomNavigationBar: NavBar(currentPageIndex: 3,),

    );
  }
}
