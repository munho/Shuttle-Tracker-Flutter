import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../theme/theme.dart' as theme;

enum ThemeEvent { toggle }

class ThemeBloc extends HydratedBloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(ThemeState(isDarkMode: false)) {
    on<ThemeEvent>((event, emit) async {
      var state = await mapEventToState(event);
      emit(state);
    });
  }

  @override
  ThemeState fromJson(Map<String, dynamic> source) {
    try {
      return ThemeState(isDarkMode: source['isDarkMode'] as bool);
    } catch (_) {
      return null;
    }
  }

  @override
  Map<String, bool> toJson(ThemeState state) {
    try {
      return {'isDarkMode': state.isDarkMode};
    } catch (_) {
      return null;
    }
  }

  Future<ThemeState> mapEventToState(ThemeEvent event) async {
    switch (event) {
      case ThemeEvent.toggle:
        return state.isDarkMode == true
            ? ThemeState(isDarkMode: false)
            : ThemeState(isDarkMode: true);
        break;
    }
    return ThemeState(isDarkMode: false);
  }
}

class ThemeState {
  bool isDarkMode;

  ThemeState({this.isDarkMode});

  ThemeData get getTheme => isDarkMode ? theme.darkMode : theme.lightMode;
  bool get getThemeState => isDarkMode;
}
