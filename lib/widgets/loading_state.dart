import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Theme.of(context).appBarTheme.color,
        child: Center(child: CircularProgressIndicator()));
  }
}
