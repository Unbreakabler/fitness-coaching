// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

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
