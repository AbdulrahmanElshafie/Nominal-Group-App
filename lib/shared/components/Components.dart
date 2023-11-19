import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nominal_group/models/Account.dart';
import 'package:translator/translator.dart';
import '../../models/Comment.dart';
import '../../models/Suggestion.dart';

// Text Input
class TextInput extends StatefulWidget{
  late final TextEditingController controller;
  int lines;
  late final String label;
  bool hideTxt, isObscure;
  TextDirection direction = TextDirection.ltr;

  TextInput({
    super.key,
    required this.controller,
    required this.label,
    this.lines = 1,
    this.hideTxt = false,
    this.isObscure = true
  });

  @override
  State<TextInput> createState() => _TextInputState();
}

class _TextInputState extends State<TextInput> {
  Icon _icon = const Icon(Icons.lock);
  
  InputDecoration txtFieldDecoration(){
    if(widget.hideTxt == false){
      return InputDecoration(
        border: const OutlineInputBorder(),
        labelText: widget.label,
      );
    } else {
      return InputDecoration(
        border: const OutlineInputBorder(),
        labelText: widget.label,
        suffixIcon: IconButton(
          icon: _icon,
          onPressed: (){
            setState(() {
              widget.isObscure = !widget.isObscure;
              if(widget.isObscure == true){
                _icon = const Icon(Icons.lock);
              } else {
                _icon = const Icon(Icons.lock_open);
              }
            });
          },
        )
      );
    }
  }

  checkLang(txt) async {
    final translator = GoogleTranslator();
    Translation translation = await translator.translate(txt);
    if(translation.sourceLanguage.code == 'ar'){
      widget.direction = TextDirection.rtl;
    } else {
      widget.direction = TextDirection.ltr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 300,
          child: TextFormField(
            controller: widget.controller,
            maxLines: widget.lines,
            decoration: txtFieldDecoration(),
            obscureText: widget.isObscure,
            onChanged: (txt) async {
              checkLang(txt);
              setState(() {
              });
            },
            textDirection: widget.direction,
          ),
        ),
        const SizedBox(
          height: 20,
        )
      ],
    );
  }
}

// Btns
class Btn extends StatelessWidget{
  final Function()? onTap;
  final String name;

  const Btn({super.key, required this.onTap, required this.name});


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
          height: 40,
          width: 320,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(20)
          ),
          child: Text(
            name,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20
            ),
          ),
      ),
    );
  }
}

late Account user;
FirebaseFirestore db = FirebaseFirestore.instance;

// Suggestions
getSuggestions(teamId) async {
  await db.collection("Teams").doc(teamId).collection('Suggestions').get().then(
        (querySnapshot) {
      saveSuggestions(querySnapshot, teamId);
    },
    onError: (e) => print("Error completing: $e"),
  );
}

saveSuggestions(querySnapshot, teamId) async {
  List<Suggestion> crntSuggestions = [];
  for (var docSnapshot in querySnapshot.docs) {

    Suggestion suggestion = Suggestion(title: docSnapshot.data()['title'].toString().trim(),
        description: docSnapshot.data()['description'].toString().trim(), sid: docSnapshot.id,
        up: docSnapshot.data()['up'], down: docSnapshot.data()['down'], isAccepted: docSnapshot.data()['isAccepted'],
        creationDate:  (docSnapshot.data()['creationDate'] as Timestamp).toDate());

    await db.collection('Teams').doc(teamId).collection('Suggestions').doc(docSnapshot.id).collection('Comments').get().then(
            (querySnapshot) {
          for(var docSnapshot in querySnapshot.docs) {
            Comment comment = Comment(comment: docSnapshot.data()['comment'], uid: docSnapshot.id, edits: docSnapshot.data()['edits']);
            suggestion.comments.add(comment);
          }
        }
    );

    await db.collection('Users').doc(user.uid).collection('Teams').doc(teamId)
        .collection('Suggestions').get().then(
            (querySnapshot) {
          for(var docSnapshot in querySnapshot.docs){
            if(docSnapshot.id == suggestion.sid){
              suggestion.choice = docSnapshot.data()['choice'];
            }
          }
        }

    );

    crntSuggestions.add(suggestion);
  }
  user.crntTeam.allSuggestions = crntSuggestions;
}

getAcceptedSuggestions(){
  List<Suggestion> accepted = [];
  for(Suggestion suggestion in user.crntTeam.allSuggestions){
    if(suggestion.isAccepted == 1){
      accepted.add(suggestion);
    }
  }
  user.crntTeam.acceptedSuggestions = accepted;
}

getDeclinedSuggestions(){
  List<Suggestion> declined = [];
  for(Suggestion suggestion in user.crntTeam.allSuggestions){
    if(suggestion.isAccepted == 2){
      declined.add(suggestion);
    }
  }
  user.crntTeam.declinedSuggestions = declined;
}

getPendingSuggestions(){
  List<Suggestion> pending = [];
  for(Suggestion suggestion in user.crntTeam.allSuggestions){
    if(suggestion.isAccepted == 0){
      pending.add(suggestion);
    }
  }
  user.crntTeam.pendingSuggestions = pending;
}

updateSuggestions(teamId){
  getSuggestions(teamId);
  getAcceptedSuggestions();
  getDeclinedSuggestions();
  getPendingSuggestions();
}

judgeSuggestion(Suggestion suggestion) {
  if(DateTime.now().isAfter(suggestion.creationDate.add(const Duration(days: 3)))){
    if(suggestion.up > suggestion.down){
      suggestion.isAccepted = 1;
      db.collection('Teams').doc(user.crntTeam.username).collection('Suggestions').doc(suggestion.sid).update(
          {
            'isAccepted': 1
          }
      );
    } else if (suggestion.down > suggestion.up) {
      suggestion.isAccepted = 2;
      db.collection('Teams').doc(user.crntTeam.username).collection('Suggestions').doc(suggestion.sid).update(
          {
            'isAccepted': 2
          }
      );
    }
  }
}

// Navigation Bar
class NavBar extends StatefulWidget{
  int currentPageIndex;
  NavBar({super.key, this.currentPageIndex = 0});


  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      height: 90,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home),
          selectedIcon: Icon(Icons.home_outlined),
          label: 'Home',
          tooltip: 'Home Page For The Team',
        ),
        NavigationDestination(
          icon: Icon(Icons.notification_add),
          selectedIcon: Icon(Icons.notification_add_outlined),
          label: 'Notifications',
          tooltip: 'Your Notifications',
        ),
        NavigationDestination(
          icon: Icon(Icons.people),
          selectedIcon: Icon(Icons.people_outline),
          label: 'Team',
          tooltip: 'Insights & Info About The Team',
        ),
        NavigationDestination(
          icon: Icon(Icons.person),
          selectedIcon: Icon(Icons.person_outline),
          label: 'Profile',
          tooltip: 'Your Profile',

        ),
      ],
      selectedIndex: widget.currentPageIndex,
      onDestinationSelected: (int index){
        setState(() {
          widget.currentPageIndex = index;
          if(widget.currentPageIndex == 0){
            Navigator.of(context).pushNamed('/home');
          } else if (widget.currentPageIndex == 1){
            Navigator.of(context).pushNamed('/notifications');
          } else if (widget.currentPageIndex == 2){
            Navigator.of(context).pushNamed('/teams');
          } else if (widget.currentPageIndex == 3){
            Navigator.of(context).pushNamed('/profile');
          }

        });
      },
      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      // animationDuration: const Duration(microseconds: 1000),
    );
  }
}