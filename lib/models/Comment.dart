class Comment{
  late String comment;
  late String uid;
  int edits = 0;

  Comment({
    required this.comment,
    required this.uid,
    this.edits = 0
});

}