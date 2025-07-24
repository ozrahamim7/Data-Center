import 'package:uuid/uuid.dart';

class EquipmentModel {
  late final String uuid;
  final String type;
  final String description;
  final String vendor;
  final int count;

  EquipmentModel({
    String? uuid,
    required this.type,
    required this.description,
    required this.vendor,
    this.count = 1,
  }) : uuid = uuid ?? const Uuid().v4();

  factory EquipmentModel.fromMap(Map<String, dynamic> data, String documentId) {
    return EquipmentModel(
      uuid: documentId,
      type: data['type'] ?? '',
      description: data['description'] ?? '',
      vendor: data['vendor'] ?? '',
      count: data['count'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'description': description,
      'vendor': vendor,
      'count': count,
    };
  }

  EquipmentModel copyWith({
    String? type,
    String? description,
    String? vendor,
    int? count,
  }) {
    return EquipmentModel(
      uuid: this.uuid,
      type: type ?? this.type,
      description: description ?? this.description,
      vendor: vendor ?? this.vendor,
      count: count ?? this.count,
    );
  }
}
