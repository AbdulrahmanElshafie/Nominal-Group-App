import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nominal_group/models/Account.dart';
import 'package:translator/translator.dart';
import '../../models/Comment.dart';
import '../../models/Suggestion.dart';

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
    this.isObscure = false
  });

  @override
  State<TextInput> createState() => _TextInputState();
}

class _TextInputState extends State<TextInput> {
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
          icon: const Icon(
            Icons.remove_red_eye
          ),
          onPressed: (){
            setState(() {
              widget.isObscure = !widget.isObscure;
            });
          },
        )
      );
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
              final translator = GoogleTranslator();
              Translation translation = await translator.translate(txt);
              if(translation.sourceLanguage.code == 'ar'){
                widget.direction = TextDirection.rtl;
              } else {
                widget.direction = TextDirection.ltr;
              }
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

    judgeSuggestion(suggestion);

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
  user.teams[0].allSuggestions = crntSuggestions;
}



getAcceptedSuggestions(){
  List<Suggestion> accepted = [];
  for(Suggestion suggestion in user.teams[0].allSuggestions){
    if(suggestion.isAccepted == 1){
      accepted.add(suggestion);
    }
  }
  user.teams[0].acceptedSuggestions = accepted;
}

getDeclinedSuggestions(){
  List<Suggestion> declined = [];
  for(Suggestion suggestion in user.teams[0].allSuggestions){
    if(suggestion.isAccepted == 2){
      declined.add(suggestion);
    }
  }
  user.teams[0].declinedSuggestions = declined;
}

getPendingSuggestions(){
  List<Suggestion> pending = [];
  for(Suggestion suggestion in user.teams[0].allSuggestions){
    if(suggestion.isAccepted == 0){
      pending.add(suggestion);
    }
  }
  user.teams[0].pendingSuggestions = pending;
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
      db.collection('Teams').doc('seeforme ').collection('Suggestions').doc(suggestion.sid).update(
          {
            'isAccepted': 1
          }
      );
    } else if (suggestion.down > suggestion.up) {
      suggestion.isAccepted = 2;
      db.collection('Teams').doc('seeforme ').collection('Suggestions').doc(suggestion.sid).update(
          {
            'isAccepted': 2
          }
      );
    }
  }
}
