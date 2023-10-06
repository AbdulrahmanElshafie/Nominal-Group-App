import 'Suggestion.dart';

class Team{
  late String name;
  late String username;
  List<Suggestion> allSuggestions = [];
  List<Suggestion> acceptedSuggestions = [];
  List<Suggestion> declinedSuggestions = [];
  List<Suggestion> pendingSuggestions = [];

  Team({
    required this.name,
    required this.username,
    });
}