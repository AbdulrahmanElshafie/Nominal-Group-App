import 'package:flutter/material.dart';
import '../../shared/components/Components.dart';

class MemberScreen extends StatelessWidget {
  const MemberScreen({super.key});

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
                              title: const Text('Leave the Team, Sure? '),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Btn(
                                      onTap: (){
                                        db.collection('Users').doc(user.uid).collection('Teams').doc(user.crntTeam.username).delete();
                                        db.collection('Teams').doc(user.crntTeam.username).collection('Members').doc(user.uid).delete();
                                        user.teams.remove(user.crntTeam);
                                        // setState(() {
                                        //
                                        // });
                                        Navigator.pop(context);
                                        user.crntTeam = user.teams.last;
                                        Navigator.pushNamed(context, '/home');
                                      },
                                      name: 'Leave Team'
                                  )
                                ],
                              ),
                            );
                          }
                      );
                    },
                    name: 'Leave Team'
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
