class Update{
  late String nid;
  late String sid;
  bool seen = false;
  late String teamName;
  late String teamUserName;
  late String suggestionTitle;
  late int type;

  Update({
    required this.nid,
    required this.sid,
    required this.teamName,
    required this.teamUserName,
    required this.suggestionTitle,
    required this.type,
  });
}