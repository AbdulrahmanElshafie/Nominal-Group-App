import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nominal_group/models/Suggestion.dart';
import 'package:nominal_group/moduls/decidedsuggestions/DecidedSuggestion.dart';
import '../../shared/components/Components.dart';
import '../viewsuggestion/ViewSuggestion.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController titleController = TextEditingController(),
  descriptionController = TextEditingController();

  int currentPageIndex = 0;

  Color? setSuggestionColor(isAccepted){
    if(isAccepted == 0){
      return Colors.grey[300];
    } else if (isAccepted == 1){
      return Colors.greenAccent;
    } else {
      return Colors.redAccent;
    }
  }

  Color a = Colors.blue, b = Colors.black, c = Colors.black, d = Colors.black;

  List<Suggestion> suggestions = user.crntTeam.allSuggestions;
  bool visible = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          user.crntTeam.name
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.refresh
          ),
          onPressed: () async {
              await updateAll(user.crntTeam.username);
              suggestions = user.crntTeam.allSuggestions;
              a = Colors.blue;
              b = Colors.black;
              c = Colors.black;
              d = Colors.black;
              visible = !visible;
              setState(() {

              });
          },
        ),
      ),
      body: Stack(
        children: [
          ListView.separated(
          itemBuilder: (BuildContext context, int index){
            return GestureDetector(
              child: Container(
                height: 150,
                width: double.infinity,
                color: setSuggestionColor(suggestions[index].isAccepted),
                // color: Colors.amber[colorCodes[index]],
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        suggestions.elementAt(index).title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        suggestions.elementAt(index).description,
                        maxLines: 2,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              onTap: (){
                if(suggestions[index].isAccepted == 0){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ViewSuggestion(suggestion: suggestions[index])));
                } else {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => DecidedSuggestion(suggestion: suggestions[index])));
                }
              },
            );
          },
          separatorBuilder: (BuildContext context, int index) => const Divider(
            thickness: 1,
            color: Colors.black,
            height: 0,
          ),
          itemCount: suggestions.length,
        ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: IconButton(
                          onPressed: (){
                            showDialog(
                                context: context,
                                builder: (BuildContext context){
                                  return AlertDialog(
                                    title: const Text(
                                        'Add a Suggestion'
                                    ),
                                    content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextInput(
                                              controller: titleController,
                                              label: 'Suggestion Title',
                                              isObscure: false,
                                          ),
                                          TextInput(
                                            controller: descriptionController,
                                            label: 'Description',
                                            isObscure: false,
                                            lines: 3,
                                          ),
                                          Btn(
                                              onTap: () async {
                                                var sid = await db.collection('Teams').doc(user.crntTeam.username).collection('Suggestions').add(
                                                    {
                                                      'title': titleController.text.trim(),
                                                      'description': descriptionController.text.trim(),
                                                      'up': 0,
                                                      'down': 0,
                                                      'isAccepted': 0,
                                                      'creationDate': Timestamp.now()
                                                    }
                                                );

                                                for(var member in user.crntTeam.members){
                                                  if(member.uid != user.uid){
                                                    await db.collection('Users').doc(member.uid).collection('Notifications').add(
                                                      {
                                                      'seen': false,
                                                      'type': 0,
                                                      'Team Name': user.crntTeam.name,
                                                      'Team Username': user.crntTeam.username,
                                                      'Suggestion Title': titleController.text.trim(),
                                                      'sid': sid.id
                                                      }
                                                    );
                                                  }
                                                }

                                                titleController.clear();
                                                descriptionController.clear();
                                                updateSuggestions(user.crntTeam.username);
                                                Navigator.pop(context);
                                                setState(() {

                                                });
                                              },
                                              name: 'Add Suggestion'
                                          )
                                        ]
                                    ),
                                  );
                                }
                            );
                          },
                          icon: const Icon(
                              Icons.add,
                              color: Colors.white,
                          )
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: PopupMenuButton(
                          itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 1,
                                  onTap: (){
                                      suggestions = user.crntTeam.allSuggestions;
                                  },
                                    child: Text(
                                      'All Suggestions',
                                      style: TextStyle(
                                        color: a,
                                      ),
                                    ),
                                ),
                                PopupMenuItem(
                                  value: 2,
                                  onTap: (){
                                    suggestions = user.crntTeam.pendingSuggestions;
                                  },
                                  child: Text(
                                    'Pending Suggestions',
                                    style: TextStyle(
                                        color: b,
                                    ),
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 3,
                                  onTap: (){
                                    suggestions = user.crntTeam.acceptedSuggestions;
                                  },
                                  child: Text(
                                    'Accepted Suggestions',
                                    style: TextStyle(
                                      color: c
                                    ),
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 4,
                                  onTap: (){
                                    suggestions = user.crntTeam.declinedSuggestions;
                                  },
                                  child: Text(
                                    'Declined Suggestions',
                                    style: TextStyle(
                                      color: d
                                    ),
                                  ),
                                ),
                            ],
                        icon: const Icon(
                          Icons.filter_list,
                          color: Colors.white,
                        ),
                        onSelected: (value){
                            if(value == 1){
                              a = Colors.blue;
                              b = Colors.black;
                              c = Colors.black;
                              d = Colors.black;
                            } else if (value == 2) {
                              a = Colors.black;
                              b = Colors.blue;
                              c = Colors.black;
                              d = Colors.black;
                            } else if(value == 3){
                              a = Colors.black;
                              b = Colors.black;
                              c = Colors.blue;
                              d = Colors.black;
                            } else if(value == 4){
                              a = Colors.black;
                              b = Colors.black;
                              c = Colors.black;
                              d = Colors.blue;
                            }
                            setState(() {
                            });
                        },
                      ),
                    )
                  ],
                ),
              )
            ],
          )
        ],
      ),
      bottomNavigationBar: NavBar(currentPageIndex: 0,),
    );
  }
}
