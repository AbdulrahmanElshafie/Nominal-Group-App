import 'package:flutter/material.dart';
import 'package:nominal_group/models/Account.dart';
import 'package:nominal_group/shared/components/Components.dart';

class AdminScreen extends StatefulWidget{
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  TextEditingController newTeamNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            'Team Dashboard'
        ),
        centerTitle: true,
        leading: const Icon(
            Icons.people
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                Text(
                  'Team Name: ${user.crntTeam.name}',
                  style: const TextStyle(
                      fontSize: 25
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                const Text(
                  "Suggestions",
                  style: TextStyle(
                      fontSize: 20
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'Accepted Suggestions: ${user.crntTeam.acceptedSuggestions.length}',
                  style: const TextStyle(
                      fontSize: 18
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'Declined Suggestions: ${user.crntTeam.declinedSuggestions.length}',
                  style: const TextStyle(
                      fontSize: 18
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'Pending Suggestions: ${user.crntTeam.pendingSuggestions.length}',
                  style: const TextStyle(
                      fontSize: 18
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                SizedBox(
                  height: 300,
                  child: ListView.separated(
                    itemBuilder: (BuildContext context, int index){
                      return Container(
                        height: 80,
                        width: double.infinity,
                        color: Colors.lightBlue,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                user.crntTeam.members.elementAt(index).name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                user.crntTeam.members.elementAt(index).email,
                                style: const TextStyle(
                                    fontSize: 13
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) => const Divider(
                      thickness: 1,
                      color: Colors.black,
                      height: 0,
                    ),
                    itemCount: user.crntTeam.members.length,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Btn(
                    onTap: (){
                      showDialog(
                          context: context,
                          builder: (BuildContext context){
                            return AlertDialog(
                              title: const Text('Delete the Team, Sure? '),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Btn(
                                      onTap: (){
                                        db.collection('Teams').doc(user.crntTeam.username).delete();

                                        for(Account member in user.crntTeam.members){
                                          db.collection('Users').doc(member.uid).collection('Teams').doc(user.crntTeam.username).delete();
                                        }

                                        user.teams.remove(user.crntTeam);
                                        setState(() {

                                        });
                                        Navigator.pop(context);
                                        user.crntTeam = user.teams.last;
                                        Navigator.pushNamed(context, '/home');
                                      },
                                      name: 'Delete Team'
                                  )
                                ],
                              ),
                            );
                          }
                      );
                    },
                    name: 'Delete Team'
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
                              title: const Text('Change Team Name'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextInput(
                                    controller: newTeamNameController,
                                    label: 'New Team Name',
                                    isObscure: false,
                                  ),
                                  Btn(
                                      onTap: (){
                                        db.collection('Teams').doc(user.crntTeam.username).update(
                                            {
                                              'Team Name': newTeamNameController.text.trim()
                                            }
                                        );
                                        user.crntTeam.name = newTeamNameController.text.trim();
                                        setState(() {

                                        });
                                        Navigator.pop(context);
                                      },
                                      name: 'Confirm'
                                  )
                                ],
                              ),
                            );
                          }
                      );
                    },
                    name: 'Change Team Name'
                ),

              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavBar(currentPageIndex: 2,),

    );
  }
}