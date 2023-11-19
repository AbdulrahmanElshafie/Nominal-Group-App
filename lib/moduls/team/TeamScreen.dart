import 'package:flutter/material.dart';
import 'package:nominal_group/moduls/team/Admin.dart';
import 'package:nominal_group/moduls/team/Member.dart';
import 'package:nominal_group/shared/components/Components.dart';

class TeamScreen extends StatelessWidget {
  const TeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return user.crntTeam.ownerID == user.uid? AdminScreen(): MemberScreen();
  }
}
