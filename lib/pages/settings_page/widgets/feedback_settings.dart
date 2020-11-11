import 'package:flutter/material.dart';

import '../../../blocs/theme_bloc/theme_bloc.dart';

class FeedbackSettings extends StatelessWidget {
  final ThemeState theme;
  FeedbackSettings({this.theme});

  Widget build(BuildContext context) {
    var feedbackSettingsList = <Widget>[
      ListTile(
        leading: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Send Feedback',
              style: TextStyle(color: theme.getTheme.hoverColor, fontSize: 16),
            ),
            Text(
              'Any comments? Send them here!',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
      ListTile(
        dense: true,
        leading: Text(
          'Rate this app',
          style: TextStyle(color: theme.getTheme.hoverColor, fontSize: 16),
        ),
      ),
    ];
    return Column(
      children: <Widget>[
        ListTile(
          dense: true,
          leading: Text(
            'Feedback',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
          ),
        ),
        NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowGlow();
            return null;
          },
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: feedbackSettingsList.length,
            itemBuilder: (context, index) => feedbackSettingsList[index],
            separatorBuilder: (context, index) {
              return Divider(
                color: Colors.grey[600],
                height: 4,
                indent: 15.0,
              );
            },
          ),
        )
      ],
    );
  }
}
