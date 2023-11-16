import 'Team.dart';

class Account{
  late String name;
  late String email;
  late List<Team> teams = [];
  late Team crntTeam;
  late String uid;

  Account({
    required this.uid,
    this.name = '',
    this.email = ''
      });
}