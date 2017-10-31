import 'package:flutter/material.dart';
import '../user/user_data.dart';

class FitnessUserPage extends StatelessWidget {
  FitnessUserPage({this.symbol, this.users});

  final UserData users;
  final String symbol;

  @override
  Widget build(BuildContext build) {
    return new AnimatedBuilder(
      animation: users,
      builder: (BuildContext context, Widget child) {
        final User user = users[symbol];
        return new Scaffold(
          appBar: new AppBar(
            title: new Text(user?.name ?? symbol),
          ),
          body: new SingleChildScrollView(
            child: new Container(
              margin: const EdgeInsets.all(20.0),
              child: new Card(
                child: new AnimatedCrossFade(
                  duration: const Duration(milliseconds: 300),
                  firstChild: const Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: const Center(
                      child: const CircularProgressIndicator()
                    )
                  ),
                  secondChild: user != null
                    ? new _UserSymbolView(
                      user: user,
                      arrow: new Hero(
                        tag: user,
                        child: const Text('JB'),
                      ),
                    ) : new Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: new Center(
                        child: new Text('$symbol not found'),
                      )
                    ),
                  crossFadeState: user == null && users.loading ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                )
              ),
            )
          )
        );
      },
    );
  }
}

class _UserSymbolView extends StatelessWidget {
  const _UserSymbolView({ this.user, this.arrow });

  final User user;
  final Widget arrow;

  @override
  Widget build(BuildContext context) {
    assert(user != null);
    // final String lastSale = "\$${user.lastSale.toStringAsFixed(2)}";
    // String changeInPrice = "${user.percentChange.toStringAsFixed(2)}%";
    // if (user.percentChange > 0)
    //   changeInPrice = "+" + changeInPrice;

    final currentWeight = user.weight[user.weight.length - 1];
    final previousWeight = user.weight[user.weight.length - 2];

    String weightChange = "${(currentWeight - previousWeight).toStringAsFixed(1)}";
    MaterialColor weightChangeColor = Colors.green;
    if (currentWeight > 0) {
      weightChange = "+" + weightChange;
      weightChangeColor = Colors.red;
    }

    final TextStyle headings = Theme.of(context).textTheme.body2;
    return new Container(
      padding: const EdgeInsets.all(20.0),
      child: new Column(
        children: <Widget>[
          new Row(
            children: <Widget>[
              new Text(
                '${user.name}',
                style: Theme.of(context).textTheme.display1
              ),
              arrow,
            ],
            mainAxisAlignment: MainAxisAlignment.spaceBetween
          ),
          new Container(
            height: 8.0
          ),
          new Divider(),
          new Row(
            children: <Widget>[
              new Text('Current Weight:', style: headings),
              new Container(
                width: 8.0
              ),
              new Text('$currentWeight'),
              new Container(
                width: 4.0
              ),
              new Text(
                '$weightChange',
                style: new TextStyle(
                  color: weightChangeColor,
                )
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
          new Container(
            height: 8.0
          ),
          new Container(
            decoration: const BoxDecoration(
              border: const Border(top: const BorderSide(color: Colors.black26))
            ),
            child: new Column(
              children: <Widget>[
                // new Expanded(
                  new ListView.builder(
                    shrinkWrap: true,
                    key: const ValueKey<String>('user-list'),
                    itemExtent: 70.0,
                    itemCount: user.lifts.length,
                    itemBuilder: (BuildContext context, int index) {
                      String liftName = user.lifts.keys.toList()[index];
                      var currentLift = user.lifts[liftName][user.lifts[liftName].length-1];
                      var previousLift = user.lifts[liftName][user.lifts[liftName].length-2];

                      var diff = currentLift - previousLift;

                      String liftChange = "${diff.toStringAsFixed(1)}";

                      if (diff > 0) {
                        liftChange = "+" + liftChange;
                      }

                      return new Container(
                        height: 7.0,
                        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 20.0),
                        decoration: new BoxDecoration(
                          border: new Border(
                            bottom: new BorderSide(color: Theme.of(context).dividerColor)
                          )
                        ),
                        child: new Row(
                          children: <Widget>[
                            new Text(liftName, style: headings),
                            new Column(
                              children: <Widget>[
                                new Text(currentLift.toString(), style: headings),
                                // new Container(width: 2.0),
                                new Row(
                                  children: <Widget>[
                                    new Text('('),
                                    new Text(liftChange, style: new TextStyle(color: Colors.green)),
                                    new Text(' over previous)'),
                                    new Container(width: 2.0),
                                    new Text(user.liftUnit),  
                                  ],
                                )
                              ],
                            )
                          ],
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        )
                      );
                    },
                  )
                // )
              ],
            )
          )
        ],
        mainAxisSize: MainAxisSize.min
      )
    );
  }
}