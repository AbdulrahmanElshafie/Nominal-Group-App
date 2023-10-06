import 'package:flutter/material.dart';
import 'package:nominal_group/models/Suggestion.dart';
class DecidedSuggestion extends StatefulWidget {
  const DecidedSuggestion({super.key, required this.suggestion});

  final Suggestion suggestion;



  @override
  State<DecidedSuggestion> createState() => _SuggestionState();
}

class _SuggestionState extends State<DecidedSuggestion> {
  int up = 0;
  int down = 0;
  late TextEditingController commentController = TextEditingController(),
      editingController = TextEditingController();
  Color upIconColor = Colors.grey;
  Color downIconColor = Colors.grey;

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
                      Row(
                        children: [
                          Text(
                              'UpVotes ${widget.suggestion.up}',
                            style: TextStyle(
                              color: Colors.greenAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 20

                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                              'DownVotes: ${widget.suggestion.down}',
                            style: TextStyle(
                              color: Colors.redAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 20
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width*0.9,
                            child: Text(
                              widget.suggestion.description,
                              style: TextStyle(
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
                    Text(
                      'Comments',
                      style: TextStyle(
                          fontSize: 20
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: 350,
                      child: ListView.separated(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        separatorBuilder: (BuildContext context, int index) => const Divider(),
                        itemCount: widget.suggestion.comments.length,
                        itemBuilder: (BuildContext context, int index){
                         return Column(
                            children: [
                              Text(
                                  '${widget.suggestion.creationDate.year} - '
                                      '${widget.suggestion.creationDate.month} - '
                                      '${widget.suggestion.creationDate.day}'
                              ),
                              Text(
                                  widget.suggestion.comments[index].comment
                              ),
                              SizedBox(
                                height: 10,
                              )
                            ],
                          );
                        },

                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
