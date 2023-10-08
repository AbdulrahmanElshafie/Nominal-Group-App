import 'package:flutter/material.dart';
import 'package:nominal_group/models/Suggestion.dart';
import '../../models/Comment.dart';
import '../../shared/components/Components.dart';

class ViewSuggestion extends StatefulWidget {
  const ViewSuggestion({super.key, required this.suggestion});
  final Suggestion suggestion;

  @override
  State<ViewSuggestion> createState() => _SuggestionState();
}

class _SuggestionState extends State<ViewSuggestion> {
  int up = 0;
  int down = 0;
  late TextEditingController commentController = TextEditingController(),
  editingController = TextEditingController();
  Color upIconColor = Colors.grey;
  Color downIconColor = Colors.grey;

  upColor(){
    if(widget.suggestion.choice == 1) {
      return Colors.greenAccent;
    } else {
      return upIconColor;
    }
  }

  downColor(){
    if(widget.suggestion.choice == 2) {
      return Colors.redAccent;
    } else {
      return downIconColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.suggestion.title
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
                  child: Column(
                    children: [
                      Text(
                          '${widget.suggestion.creationDate.year} - '
                          '${widget.suggestion.creationDate.month} - '
                          '${widget.suggestion.creationDate.day}'
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width*0.9,
                            child: Text(
                              widget.suggestion.description,
                              style: const TextStyle(
                                fontSize: 16
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                alignment: AlignmentDirectional.centerStart,
                child: Column(
                  children: [
                    const Text(
                        'Comments',
                      style: TextStyle(
                        fontSize: 20
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),

                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.3,
                      child: ListView.separated(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          separatorBuilder: (BuildContext context, int index) => const Divider(),
                          itemCount: widget.suggestion.comments.length,
                          itemBuilder: (BuildContext context, int index){
                            if(widget.suggestion.comments[index].uid == user.uid){
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Remaining Edits ${3 - widget.suggestion.comments[index].edits}'
                                      ),
                                      IconButton(
                                        onPressed: (){
                                          editingController.text = widget.suggestion.comments[index].comment;
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context){
                                                if(widget.suggestion.comments[index].edits == 3){
                                                  return const AlertDialog(
                                                    title: Text(
                                                        'Your Available Edits is Finished'
                                                    ),
                                                    content: Text(
                                                      "You've finished all you available edits! You can't edit your comment anymore"
                                                    ),
                                                  );
                                                } else {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        'Edit Your Comment'
                                                    ),
                                                    content: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        SizedBox(
                                                          width: 300,
                                                          child: TextField(
                                                            decoration: const InputDecoration(
                                                              border: OutlineInputBorder(),
                                                              labelText: 'Comment',
                                                            ),
                                                            controller: editingController,
                                                            maxLines: 5,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 20,
                                                        ),
                                                        TextButton(
                                                            onPressed: (){
                                                              // Comment comment = Comment(comment: editingController.text, uid: user.uid);
                                                              widget.suggestion.comments[index].comment = editingController.text;
                                                              db.collection('Teams').doc(user.teams[0].username).collection('Suggestions')
                                                                  .doc(widget.suggestion.sid).collection('Comments').doc(widget.suggestion.comments[index].uid).update(
                                                                  {
                                                                    'edits': ++widget.suggestion.comments[index].edits
                                                                  }
                                                              );
                                                              Navigator.pop(context);
                                                              setState(() {

                                                              });

                                                            },
                                                            child: const Text(
                                                                'Add Comment'
                                                            )
                                                        )
                                                      ],
                                                    ),
                                                  );
                                                }
                                              }
                                          );
                                        },
                                        icon: const Icon(
                                            Icons.edit
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                      widget.suggestion.comments[index].comment
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  )
                                ],
                              );
                            } else {
                              return Column(
                                children: [
                                  Text(
                                      widget.suggestion.comments[index].comment
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  )
                                ],
                              );
                            }
                          },

                      ),
                    )
                  ],
                ),
              ),
            ),
            Column(
              // mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        IconButton(
                            onPressed: (){
                              setState(() {
                                if(up == 1){
                                  up = 0;
                                  upIconColor = Colors.grey;
                                  widget.suggestion.choice = 0;
                                } else {
                                  up = 1;
                                  upIconColor = Colors.greenAccent;
                                  widget.suggestion.choice = 1;
                                }
                                if(down == 1){
                                  down = 0;
                                  downIconColor = Colors.grey;
                                }
                                db.collection('Teams').doc(user.teams[0].username).collection('Suggestions').doc(widget.suggestion.sid).update(
                                    {
                                      'up': widget.suggestion.up + up,
                                      'down': widget.suggestion.down + down,
                                    }
                                );
                                db.collection('Users').doc(user.uid).collection('Teams').doc(user.teams[0].username)
                                    .collection('Suggestions').doc(widget.suggestion.sid).set(
                                    {
                                      'choice': widget.suggestion.choice
                                    }
                                );
                              });
                            },
                            icon: Icon(
                              Icons.thumb_up,
                              color: upColor(),
                            )
                        ),
                      ],
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Column(
                      children: [
                        IconButton(
                            onPressed: (){
                              setState(() {
                                if(down == 1){
                                  down = 0;
                                  downIconColor = Colors.grey;
                                  widget.suggestion.choice = 0;
                                } else {
                                  down = 1;
                                  downIconColor = Colors.redAccent;
                                  widget.suggestion.choice = 2;
                                }
                                if(up == 1){
                                  up = 0;
                                  upIconColor = Colors.grey;
                                }
                                db.collection('Teams').doc(user.teams[0].username).collection('Suggestions').doc(widget.suggestion.sid).update(
                                    {
                                      'up': widget.suggestion.up + up,
                                      'down': widget.suggestion.down + down,
                                    }
                                );
                                db.collection('Users').doc(user.uid).collection('Teams').doc(user.teams[0].username)
                                .collection('Suggestions').doc(widget.suggestion.sid).set(
                                  {
                                    'choice': widget.suggestion.choice
                                  }
                                );
                              });
                            },
                            icon: Icon(
                              Icons.thumb_down,
                              color: downColor(),
                            )
                        ),
                      ],
                    ),
                  ],
                ),
                TextButton(
                    onPressed: ()
                    {
                      showDialog(
                          context: context,
                          builder: (BuildContext context){
                            for(Comment comment in widget.suggestion.comments){
                              if(comment.uid == user.uid){
                                return const AlertDialog(
                                  title: Text(
                                      "You've commented before"
                                  ),
                                  content: Text(
                                    'You can add only one comment for any suggestion! You can edit your previous comment if wanted'
                                  ),
                                );
                              }
                            }
                            return AlertDialog(
                              title: const Text(
                                  'Add a Comment'
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 300,
                                    child: TextField(
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: 'Comment',
                                      ),
                                      controller: commentController,
                                      maxLines: 5,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  TextButton(
                                      onPressed: () async {
                                        Comment comment = Comment(comment: commentController.text, uid: user.uid);
                                        widget.suggestion.comments.add(comment);
                                       await db.collection('Teams').doc(user.teams[0].username).collection('Suggestions')
                                            .doc(widget.suggestion.sid).collection('Comments').doc(comment.uid).set(
                                            {
                                              'comment': commentController.text,
                                              'uid': comment.uid,
                                              'edits': 0
                                            }
                                        );
                                        Navigator.pop(context);
                                        commentController.text = '';
                                        setState(() {

                                        });

                                      },
                                      child: const Text(
                                          'Add Comment'
                                      )
                                  )
                                ],
                              ),
                            );
                          }
                      );
                    },
                    child:
                    const Text(
                        'Add a Comment'
                    )
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
