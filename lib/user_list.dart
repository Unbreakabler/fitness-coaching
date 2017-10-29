import 'package:flutter/material.dart';

import 'user_data.dart';
import 'user_row.dart';

class UserList extends StatelessWidget {
  const UserList({ Key key, this.users, this.onOpen, this.onShow, this.onAction }) : super(key: key);

  final List<User> users;
  final UserRowActionCallback onOpen;
  final UserRowActionCallback onShow;
  final UserRowActionCallback onAction;

  @override
  Widget build(BuildContext context) {
    return new ListView.builder(
      key: const ValueKey<String>('user-list'),
      itemExtent: UserRow.kHeight,
      itemCount: users.length,
      itemBuilder: (BuildContext context, int index) {
        return new UserRow(
          user: users[index],
          onPressed: onOpen,
          onDoubleTap: onShow,
          onLongPressed: onAction
        );
      },
    );
  }
}
