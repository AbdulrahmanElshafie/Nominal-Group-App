import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nominal_group/models/Suggestion.dart';
import 'package:nominal_group/shared/components/Components.dart';
import '../viewsuggestion/ViewSuggestion.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications'
        ),
        leading: const Icon(
          Icons.notification_add
        ),
      ),
      body: ListView.separated(
          itemBuilder: (BuildContext context, int index){
            return GestureDetector(
              child: Container(
                height: 120,
                color: user.notifications[index].seen == false? Colors.lightBlue: Colors.grey[300],
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.notifications[index].teamName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: user.notifications[index].seen == false? Colors.white: Colors.black
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        user.notifications[index].type == 0? 'A New Suggestion Has Been Added: ${user.notifications[index].suggestionTitle}'
                            : 'A New Comment Has Been Added on Suggestion: ${user.notifications[index].suggestionTitle}',
                        style: TextStyle(
                          fontSize: 16,
                          color: user.notifications[index].seen == false? Colors.white: Colors.black
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),
              onTap: () async{
                user.notifications[index].seen = true;

                for(var team in user.teams){
                  if(team.username == user.notifications[index].teamUserName){
                    user.crntTeam = team;
                    break;
                  }
                }

                await db.collection('Teams').doc(user.crntTeam.username).collection('Suggestions').doc(user.notifications[index].sid).get().then(
                        (docSnapShot){
                          final data = docSnapShot.data() as Map<String, dynamic>;
                          Suggestion suggestion = Suggestion(up: data['up'], down:data['down'],
                              title: data['title'], description: data['description'], sid: docSnapShot.id,
                              isAccepted: data['isAccepted'], creationDate: (data['creationDate'] as Timestamp).toDate());

                          Navigator.push(context, MaterialPageRoute(builder: (context) => ViewSuggestion(suggestion: suggestion)));                        }
                );

                await db.collection('Users').doc(user.uid).collection('Notifications').doc(user.notifications[index].nid).update(
                  {
                    'seen': true
                  }
                );

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
          itemCount: user.notifications.length
      ),
      bottomNavigationBar: NavBar(currentPageIndex: 1,),
    );
  }
}
