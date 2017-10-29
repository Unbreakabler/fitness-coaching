// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

// import 'stock_arrow.dart';
import 'user_data.dart';

typedef void UserRowActionCallback(User user);

class UserRow extends StatelessWidget {
  UserRow({
    this.user,
    this.onPressed,
    this.onDoubleTap,
    this.onLongPressed
  }) : super(key: new ObjectKey(user));

  final User user;
  final UserRowActionCallback onPressed;
  final UserRowActionCallback onDoubleTap;
  final UserRowActionCallback onLongPressed;

  static const double kHeight = 69.0;

  GestureTapCallback _getHandler(UserRowActionCallback callback) {
    return callback == null ? null : () => callback(user);
  }

  @override
  Widget build(BuildContext context) {
    // final String lastSale = "\$${stock.lastSale.toStringAsFixed(2)}";
    // String changeInPrice = "${stock.percentChange.toStringAsFixed(2)}%";
    // if (stock.percentChange > 0)
    //   changeInPrice = "+" + changeInPrice;
    return new InkWell(
      onTap: _getHandler(onPressed),
      onDoubleTap: _getHandler(onDoubleTap),
      onLongPress: _getHandler(onLongPressed),
      child: new Container(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 20.0),
        decoration: new BoxDecoration(
          border: new Border(
            bottom: new BorderSide(color: Theme.of(context).dividerColor)
          )
        ),
        child: new Row(
          children: <Widget>[
            // new Container(
            //   margin: const EdgeInsets.only(right: 5.0),
            //   child: new Hero(
            //     tag: stock,
            //     child: new StockArrow(percentChange: stock.percentChange)
            //   )
            // ),
            new Expanded(
              child: new Row(
                children: <Widget>[
                  new Expanded(
                    flex: 2,
                    child: new Text(
                      user.symbol
                    )
                  ),
                  new Expanded(
                    child: new Text(
                      user.weight[0].toString(),
                      textAlign: TextAlign.right
                    )
                  ),
                  new Expanded(
                    child: new Text(
                      user.trainingType,
                      textAlign: TextAlign.right
                    )
                  ),
                ],
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: DefaultTextStyle.of(context).style.textBaseline
              )
            ),
          ]
        )
      )
    );
  }
}
