import 'Team.dart';
import 'Update.dart';

class Account{
  late String name;
  late String email;
  late List<Team> teams = [];
  late Team crntTeam;
  late String uid;
  late List<Update> notifications = [];

  Account({
    required this.uid,
    this.name = '',
    this.email = ''
      });
}