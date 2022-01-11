import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../data/fusion/fusion_socket.dart';
import '../../data/models/shuttle_eta.dart';
import '../../data/models/shuttle_update.dart';

part 'fusion_event.dart';
part 'fusion_state.dart';

class FusionBloc extends Bloc<FusionEvent, FusionState> {
  final FusionSocket fusionSocket;
  Map<ShuttleUpdate, Marker> fusionMap = {};
  Map<int, Color> shuttleColors = {};
  List<Marker> currentShuttles = [];
  dynamic currentVehicleMessage;
  dynamic currentETAMessage;

  FusionBloc({@required this.fusionSocket}) : super(FusionInitial()) {
    connect(fusionSocket: fusionSocket);
    on<FusionEvent>((event, emit) async {
      var state = await mapEventToState(event);
      emit(state);
    });
  }

  void connect({@required FusionSocket fusionSocket}) {
    print('WS is connected');
    fusionSocket.openWS();
    fusionSocket.subscribe('eta');
    fusionSocket.subscribe('vehicle_location');

    fusionSocket.channel.stream.listen((message) {
      fusionSocket.streamController.add(message);

      var response = jsonDecode(message);
      if (response['type'] == 'server_id') {
        fusionSocket.serverID = response['message'];
        print(fusionSocket.serverID);
      } else if (response['type'] == 'vehicle_location') {
        add(GetFusionVehicleData(
            shuttleUpdate: fusionSocket.handleVehicleLocations(message)));
      } else if (response['type'] == 'eta') {
        List<dynamic> body = response['message']['stop_etas'];
        if (body.isNotEmpty) {
          currentETAMessage = message;
          add(GetFusionETAData(shuttleETAs: fusionSocket.handleEtas(message)));
        }
      }
    }, onError: (error) {
      print(error);
      fusionSocket.closeWS();
    }, onDone: () async {
      print('WS is done');
      await Future.delayed(Duration(
          seconds: 3)); // Check every 3 seconds to reestablish the connection
      connect(fusionSocket: fusionSocket);
    });
  }

  Future<FusionState> mapEventToState(
    FusionEvent event,
  ) async {
    if (event is GetFusionVehicleData) {
      var data = await event.shuttleUpdate;
      if (shuttleColors[data.routeId] != null) {
        data.setColor = shuttleColors[data.routeId];
      } else {
        data.setColor = Colors.white;
      }

      addShuttle(shuttle: data);
      removeOldShuttles();

      var list = <Marker>[];
      fusionMap.forEach((k, v) => list.add(v));

      currentShuttles = list;

      return FusionVehicleLoaded(updates: currentShuttles);
    } else if (event is GetFusionETAData) {
      var data = event.shuttleETAs;
      return FusionETALoaded(etas: data, updates: currentShuttles);
    }
  }

  set setShuttleColors(Map<int, Color> colors) => shuttleColors = colors;

  void addShuttle({ShuttleUpdate shuttle}) {
    // Only include shuttles that are within 5 minutes of the current time
    var currentTime = DateTime.now().toUtc();
    if (currentTime.difference(shuttle.time).inMinutes < 7) {
      fusionMap[shuttle] = shuttle.getMarker();
    }
  }

  void removeOldShuttles() {
    // - Loop through fusionMap
    // - Check if any shuttle in fusionMap is too old and remove it
    var currentTime = DateTime.now().toUtc();
    fusionMap.removeWhere((key, value) {
      bool isRemoved;
      isRemoved = currentTime.difference(key.time).inMinutes >= 7 ?? false;
      if (isRemoved) {
        print('Removed $key');
      }
      return isRemoved;
    });
  }

  @override
  Future<void> close() {
    fusionSocket.closeWS();
    return super.close();
  }
}
