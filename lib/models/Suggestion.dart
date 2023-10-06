import 'Comment.dart';

class Suggestion{
  late String title;
  late String description;
  late int isAccepted = 0;
  late int up = 0;
  late int down = 0;
  late List<Comment> comments = [];
  late String sid;
  late int choice = 0;
  late DateTime creationDate;

  Suggestion({
    required this.up,
    required this.down,
    required this.title,
    required this.description,
    required this.sid,
    required this.isAccepted,
    required this.creationDate
});

}