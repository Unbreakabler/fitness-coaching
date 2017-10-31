import 'package:flutter/material.dart';

import 'client_create.dart';

// TODO(jon): implement administration capabilities for the coach
// - resend email, remove client
class PendingClientList extends StatelessWidget {
  const PendingClientList({ Key key, this.clients }) : super(key: key);

  final List<Client> clients;

  @override
  Widget build(BuildContext context) {
    return new ListView.builder(
      key: const ValueKey<String>('user-list'),
      itemExtent: 65.0,
      itemCount: clients.length,
      itemBuilder: (BuildContext context, int index) {
        Client client = clients[index];
        String active = (client.activated != null && client.activated) ? 'yes' : 'no';
        return new InkWell(
          child: new Container(
            padding: const EdgeInsets.all(16.0),
            decoration: new BoxDecoration(
              border: new Border(
                bottom: new BorderSide(color: Theme.of(context).dividerColor)
              )
            ),
            child: new Row(
              children: <Widget>[
                new Expanded(
                  child: new Row(
                    children: <Widget>[
                      new Expanded(
                        flex: 2,
                        child: new Text(
                          client.name
                        ),
                      ),
                      new Expanded(
                        flex: 2,
                        child: new Text(
                          client.email
                        ),
                      ),
                      new Expanded(
                        flex: 2,
                        // child: new Text(
                        //   client.activated.toString()
                        // ),
                        child: new Column(
                          children: <Widget>[
                            new Text('Active:'),
                            new Text(active)
                          ],
                        )
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        );
        // return new UserRow(
        //   user: users[index],
        //   onPressed: onOpen,
        //   onDoubleTap: onShow,
        //   onLongPressed: onAction
        // );
      },
    );
  }
}
