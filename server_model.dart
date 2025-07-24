import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

enum ServerState {
  active,
  maintenance,
  offline,
}

class ServerModel {
  late final String uuid;
  final String name;
  final String location;
  final String ipAddress;
  final int port;
  final String description;
  final ServerState state;
  final String cabinet;
  final String cabinetLocation;
  final String vendor;
  final String switchName;
  final String panel;

  ServerModel({
    String? uuid,
    required this.name,
    required this.location,
    required this.ipAddress,
    required this.port,
    required this.description,
    required this.state,
    required this.cabinet,
    required this.cabinetLocation,
    required this.vendor,
    required this.switchName,
    required this.panel,
  }) : uuid = uuid ?? const Uuid().v4();

  factory ServerModel.fromMap(Map<String, dynamic> data, String documentId) {
    return ServerModel(
      uuid: documentId,
      name: data['name'] ?? '',
      location: data['location'] ?? '',
      ipAddress: data['ipAddress'] ?? '',
      port: data['port'] ?? 0,
      description: data['description'] ?? '',
      state: _getStateFromString(data['state'] ?? 'offline'),
      cabinet: data['cabinet'] ?? '',
      cabinetLocation: data['cabinetLocation'] ?? '',
      vendor: data['vendor'] ?? '',
      switchName: data['switchName'] ?? '',
      panel: data['panel'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'location': location,
      'ipAddress': ipAddress,
      'port': port,
      'description': description,
      'state': state.toString().split('.').last,
      'cabinet': cabinet,
      'cabinetLocation': cabinetLocation,
      'vendor': vendor,
      'switchName': switchName,
      'panel': panel,
    };
  }

  static ServerState _getStateFromString(String stateStr) {
    switch (stateStr) {
      case 'active':
        return ServerState.active;
      case 'maintenance':
        return ServerState.maintenance;
      default:
        return ServerState.offline;
    }
  }

  static Color getStateColor(ServerState state) {
    switch (state) {
      case ServerState.active:
        return const Color(0xFF4CAF50);
      case ServerState.maintenance:
        return const Color(0xFFFFC107);
      case ServerState.offline:
        return const Color(0xFFF44336);
    }
  }

  static String getStateString(ServerState state) {
    switch (state) {
      case ServerState.active:
        return 'Active';
      case ServerState.maintenance:
        return 'Maintenance';
      case ServerState.offline:
        return 'Offline';
    }
  }

  ServerModel copyWith({
    String? name,
    String? location,
    String? ipAddress,
    int? port,
    String? description,
    ServerState? state,
    String? cabinet,
    String? cabinetLocation,
    String? vendor,
    String? switchName,
    String? panel,
  }) {
    return ServerModel(
      uuid: this.uuid,
      name: name ?? this.name,
      location: location ?? this.location,
      ipAddress: ipAddress ?? this.ipAddress,
      port: port ?? this.port,
      description: description ?? this.description,
      state: state ?? this.state,
      cabinet: cabinet ?? this.cabinet,
      cabinetLocation: cabinetLocation ?? this.cabinetLocation,
      vendor: vendor ?? this.vendor,
      switchName: switchName ?? this.switchName,
      panel: panel ?? this.panel,
    );
  }
}
