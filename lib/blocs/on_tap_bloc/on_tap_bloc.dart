import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'on_tap_event.dart';
part 'on_tap_state.dart';

class OnTapBloc extends Bloc<OnTapEvent, OnTapState> {
  OnTapBloc() : super(InitialState()) {
    on<OnTapEvent>((event, emit) async {
      var state = await mapEventToState(event);
      emit(state);
    });
  }

  Future<OnTapState> mapEventToState(
    OnTapEvent event,
  ) async {
    if (event is MapStopTapped) {
      return TappedState(stopName: event.stopName, index: event.index);
    } else if (event is TileStopTapped) {
      return TappedState(stopName: event.stopName);
    }
  }
}
