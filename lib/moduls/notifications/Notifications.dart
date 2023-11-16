import 'package:flutter/material.dart';
import 'package:nominal_group/shared/components/Components.dart';

class Notifications extends StatelessWidget {
  const Notifications({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications'
        ),
        leading: Icon(
          Icons.notification_add
        ),
      ),
      bottomNavigationBar: NavBar(currentPageIndex: 1,),
    );
  }
}
